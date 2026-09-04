#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

@available(iOS 17.0, *)
final class SwiftUIAccessibilityTestHost {
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow
    private weak var previousKeyWindow: UIWindow?

    init(
        rootView: some View,
        size: CGSize = CGSize(width: 390, height: 300)
    ) {
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
        firstElement {
            ($0 as? UIAccessibilityIdentification)?.accessibilityIdentifier == identifier
        }
    }

    var frame: CGRect {
        hostingController.view.convert(hostingController.view.bounds, to: nil)
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
#endif
