#if canImport(SwiftUI) && canImport(UIKit)
import Darwin
import SwiftUI
import UIKit

@available(iOS 17.0, *)
final class SwiftUIAccessibilityTestHost {
    private let accessibilitySession: SwiftUIAccessibilityAutomationSession
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow
    private weak var previousKeyWindow: UIWindow?

    init(
        rootView: some View,
        size: CGSize = CGSize(width: 390, height: 300)
    ) {
        precondition(Thread.isMainThread, "SwiftUI accessibility tests must run on the main thread.")
        accessibilitySession = SwiftUIAccessibilityAutomationSession()
        hostingController = UIHostingController(rootView: AnyView(rootView))
        let foregroundScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        if let foregroundScene {
            previousKeyWindow = foregroundScene.windows.first(where: \.isKeyWindow)
            window = UIWindow(windowScene: foregroundScene)
            window.frame = CGRect(origin: .zero, size: size)
        } else {
            window = UIWindow(frame: CGRect(origin: .zero, size: size))
        }
        window.rootViewController = hostingController
        hostingController.view.frame = window.bounds
        window.makeKeyAndVisible()
        settle()
    }

    deinit {
        window.isHidden = true
        previousKeyWindow?.makeKeyAndVisible()
    }

    func settle() {
        window.setNeedsLayout()
        window.layoutIfNeeded()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        window.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
    }

    func element(withLabel label: String) -> NSObject? {
        firstElement { $0.accessibilityLabel == label }
    }

    func element(withIdentifier identifier: String) -> NSObject? {
        let getter = #selector(getter: UIAccessibilityIdentification.accessibilityIdentifier)
        return firstElement { object in
            // SwiftUI accessibility nodes implement the public getter without declaring the UIKit protocol.
            guard object.responds(to: getter) else { return false }
            return object.perform(getter)?.takeUnretainedValue() as? String == identifier
        }
    }

    static var isAccessibilityAutomationEnabled: Bool {
        SwiftUIAccessibilityAutomationSession.isEnabled
    }

    var frame: CGRect {
        hostingController.view.convert(hostingController.view.bounds, to: nil)
    }

    var diagnosticDescription: String {
        let scenes = UIApplication.shared.connectedScenes.map { String(describing: $0.activationState) }
        return "mainThread=\(Thread.isMainThread), applicationState=\(UIApplication.shared.applicationState), "
            + "scenes=\(scenes), windowScene=\(String(describing: window.windowScene?.activationState)), "
            + "keyWindow=\(window.isKeyWindow), hidden=\(window.isHidden), frame=\(window.frame), "
            + "voiceOver=\(UIAccessibility.isVoiceOverRunning), "
            + "accessibilityChildren=\(hostingController.view.accessibilityElementCount()), "
            + "automationChildren=\(hostingController.view.automationElements?.count ?? 0)"
    }

    func frame<T: UIView>(ofFirstSubviewType type: T.Type) -> CGRect? {
        guard let view = firstSubview(of: type) else { return nil }
        return view.convert(view.bounds, to: nil)
    }

    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        firstSubview(of: type, in: hostingController.view)
    }

    func firstAccessibilityElement() -> NSObject? {
        firstElement { $0.isAccessibilityElement }
    }

    private func firstElement(where predicate: (NSObject) -> Bool) -> NSObject? {
        var visited = Set<ObjectIdentifier>()
        return findElement(
            matching: predicate,
            in: hostingController.view,
            visited: &visited
        )
    }

    func perform(_ action: UIAccessibilityCustomAction) -> Bool {
        if let actionHandler = action.actionHandler {
            return actionHandler(action)
        }
        guard let target = action.target else { return false }
        return UIApplication.shared.sendAction(
            action.selector,
            to: target,
            from: action,
            for: nil
        )
    }

    private func findElement(
        matching predicate: (NSObject) -> Bool,
        in object: NSObject,
        visited: inout Set<ObjectIdentifier>
    ) -> NSObject? {
        guard visited.insert(ObjectIdentifier(object)).inserted else { return nil }

        if predicate(object) {
            return object
        }

        let explicitChildren = (object.accessibilityElements ?? []) + (object.automationElements ?? [])
        for case let child as NSObject in explicitChildren {
            if let match = findElement(
                matching: predicate,
                in: child,
                visited: &visited
            ) {
                return match
            }
        }

        let childCount = object.accessibilityElementCount()
        if childCount > 0, childCount < 10_000 {
            for index in 0..<childCount {
                guard let child = object.accessibilityElement(at: index) as? NSObject else { continue }
                if let match = findElement(
                    matching: predicate,
                    in: child,
                    visited: &visited
                ) {
                    return match
                }
            }
        }

        if let view = object as? UIView {
            for child in view.subviews {
                if let match = findElement(
                    matching: predicate,
                    in: child,
                    visited: &visited
                ) {
                    return match
                }
            }
        }

        return nil
    }

    private func firstSubview<T: UIView>(of type: T.Type, in view: UIView) -> T? {
        if let match = view as? T {
            return match
        }
        return view.subviews.lazy.compactMap { self.firstSubview(of: type, in: $0) }.first
    }
}

// Hosted unit tests do not start the accessibility automation service that XCUITest starts.
// On a clean simulator SwiftUI therefore exposes no accessibility children, even in a visible,
// foreground window. Keep this private API confined to the test target, as AccessibilitySnapshot
// does in ASAccessibilityEnabler.m. It enables automation, not VoiceOver or synthetic callbacks.
// https://github.com/cashapp/AccessibilitySnapshot/blob/main/Sources/AccessibilitySnapshot/Parser/ObjC/ASAccessibilityEnabler.m
// The original setting is restored when the last host is released, with an exit-time fallback.
private final class SwiftUIAccessibilityAutomationSession {
    private static let runtime = Runtime()

    static var isEnabled: Bool { runtime.isEnabled }

    init() {
        Self.runtime.acquire()
    }

    deinit {
        Self.runtime.release()
    }

    private final class Runtime {
        private typealias GetEnabled = @convention(c) () -> Int32
        private typealias SetEnabled = @convention(c) (Int32) -> Void

        private let getEnabled: GetEnabled
        private let setEnabled: SetEnabled
        private var activeHosts = 0
        private var originalState: Int32?

        var isEnabled: Bool { getEnabled() != 0 }

        init() {
            let simulatorRoot = ProcessInfo.processInfo.environment["IPHONE_SIMULATOR_ROOT"] ?? ""
            let libraryPath = simulatorRoot + "/usr/lib/libAccessibility.dylib"
            guard let library = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL),
                  let getter = dlsym(library, "_AXSAutomationEnabled"),
                  let setter = dlsym(library, "_AXSSetAutomationEnabled") else {
                preconditionFailure("Cannot initialize accessibility automation for hosted SwiftUI tests: \(libraryPath)")
            }
            getEnabled = unsafeBitCast(getter, to: GetEnabled.self)
            setEnabled = unsafeBitCast(setter, to: SetEnabled.self)
            atexit {
                SwiftUIAccessibilityAutomationSession.runtime.restore()
            }
        }

        func acquire() {
            if activeHosts == 0 {
                originalState = getEnabled()
                setEnabled(1)
                precondition(getEnabled() != 0, "Accessibility automation could not be enabled for SwiftUI tests.")
            }
            activeHosts += 1
        }

        func release() {
            activeHosts -= 1
            if activeHosts == 0 {
                restore()
            }
        }

        func restore() {
            guard let originalState else { return }
            setEnabled(originalState)
            self.originalState = nil
        }
    }
}
#endif
