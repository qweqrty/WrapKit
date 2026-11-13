#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
@testable import WrapKit
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SUIHostingControllerTests: XCTestCase {
    #if os(iOS) && !targetEnvironment(macCatalyst)
    func test_navigationOrientationPolicyMatchesPlainHostingController() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKeyAndVisible()
        }
        let plain = UIHostingController(rootView: Text("Orientation"))
        let wrapped = SUIHostingController(rootView: Text("Orientation"))
        for (name, controller) in [("plain", plain as UIViewController), ("wrapped", wrapped)] {
            let navigation = UINavigationController(rootViewController: controller)
            window.rootViewController = navigation
            window.makeKeyAndVisible()
            settle(window)
            XCTAssertTrue(controller.supportedInterfaceOrientations.contains(.landscapeLeft), name)
            XCTAssertTrue(navigation.supportedInterfaceOrientations.contains(.landscapeLeft), name)
            if #available(iOS 26.0, *) {
                XCTAssertFalse(controller.prefersInterfaceOrientationLocked, name)
                XCTAssertFalse(navigation.prefersInterfaceOrientationLocked, name)
                XCTAssertTrue(navigation.childForInterfaceOrientationLock === controller, name)
            }
        }
        XCTAssertEqual(wrapped.supportedInterfaceOrientations, plain.supportedInterfaceOrientations)
        XCTAssertEqual(wrapped.shouldAutorotate, plain.shouldAutorotate)
        XCTAssertEqual(wrapped.preferredInterfaceOrientationForPresentation, plain.preferredInterfaceOrientationForPresentation)
        if #available(iOS 26.0, *) {
            XCTAssertEqual(wrapped.children.first?.prefersInterfaceOrientationLocked, plain.prefersInterfaceOrientationLocked)
        }
    }

    @available(iOS 16.0, *)
    func test_sceneGeometryRotatesPlainAndWrappedHostingControllers() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        defer {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKeyAndVisible()
        }
        let plain = UIHostingController(rootView: Text("Orientation"))
        let wrapped = SUIHostingController(rootView: Text("Orientation"))
        for (name, controller) in [("plain", plain as UIViewController), ("wrapped", wrapped)] {
            let navigation = UINavigationController(rootViewController: controller)
            window.rootViewController = navigation
            window.makeKeyAndVisible()
            settle(window)
            var requestError: Error?
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft)) { requestError = $0 }
            let landscapeDeadline = Date().addingTimeInterval(3)
            while window.bounds.width < window.bounds.height && requestError == nil && Date() < landscapeDeadline {
                settle(window)
            }
            XCTAssertNil(requestError)
            XCTAssertGreaterThan(window.bounds.width, window.bounds.height, "\(name) must rotate its real window")
            XCTAssertGreaterThan(controller.view.bounds.width, controller.view.bounds.height, "\(name) must rotate its actual content")
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            let portraitDeadline = Date().addingTimeInterval(3)
            while window.bounds.width > window.bounds.height && Date() < portraitDeadline { settle(window) }
        }
    }

    @available(iOS 16.0, *)
    func test_nativeHeaderRelayoutsAcrossBoundsChangesAndTrailingUpdates() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 900, height: 700)
        window.overrideUserInterfaceStyle = .light
        let container = UIViewController()
        container.view.backgroundColor = .white
        let navigation = UINavigationController(rootViewController: UIViewController())
        container.addChild(navigation)
        container.view.addSubview(navigation.view)
        navigation.view.autoresizingMask = []
        navigation.view.frame = CGRect(x: 0, y: 0, width: 390, height: 700)
        navigation.didMove(toParent: container)
        window.rootViewController = container
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKeyAndVisible()
        }
        settle(window)
        settle(window)
        let sut = SUIHostingController(rootView: Text("Bounds resize"))
        var backPresses = 0
        let trailing = ButtonPresentableModel(image: UIImage(systemName: "xmark"), onPress: {})
        sut.headerOutput.display(model: .init(
            style: .init(backgroundColor: .systemGroupedBackground, horizontalSpacing: 8,
                primeFont: .systemFont(ofSize: 18), primeColor: .label,
                secondaryFont: .systemFont(ofSize: 14), secondaryColor: .secondaryLabel),
            centerView: .keyValue(.init(.text("Navigation"), nil)),
            leadingCard: .init(title: .text("Back to list"),
                leadingImage: .init(image: .asset(UIImage(systemName: "chevron.left"))),
                onPress: { backPresses += 1 }),
            primeTrailingImage: trailing, secondaryTrailingImage: trailing, tertiaryTrailingImage: trailing
        ))
        navigation.pushViewController(sut, animated: false)

        func capture(width: CGFloat, trailingCount: Int, name: String) throws -> CGRect? {
            navigation.view.frame = CGRect(x: 0, y: 0, width: width, height: window.bounds.height)
            settle(window)
            navigation.view.layoutIfNeeded()
            let bar = navigation.navigationBar
            let title = try XCTUnwrap(sut.navigationItem.titleView)
            let leading = try XCTUnwrap(sut.navigationItem.leftBarButtonItem?.customView as? UIControl)
            let actions = actionControls(in: bar)
            XCTAssertEqual(bar.bounds.width, width, accuracy: 0.5)
            XCTAssertEqual(actions.count, trailingCount)
            XCTAssertEqual(sut.navigationItem.rightBarButtonItems?.count, trailingCount)
            XCTAssertEqual(sut.headerOutput.headerTitleLabel.text, "Navigation")
            XCTAssertTrue(sut.navigationItem.hidesBackButton)
            XCTAssertFalse(sut.navigationItem.leftItemsSupplementBackButton)
            XCTAssertFalse(navigation.isNavigationBarHidden)
            XCTAssertEqual(sut.navigationItem.standardAppearance?.backgroundColor, .systemGroupedBackground)
            let titleVisible = title.isDescendant(of: bar) && !title.isHidden && title.bounds.width > 0
            if width >= 844 { XCTAssertTrue(titleVisible) }
            let titleFrame = titleVisible ? title.convert(title.bounds, to: bar) : nil
            let frames = (titleFrame.map { [$0] } ?? []) + [leading.convert(leading.bounds, to: bar)]
                + actions.map { $0.convert($0.bounds, to: bar) }
            for (index, frame) in frames.enumerated() {
                XCTAssertGreaterThan(frame.width, 0)
                XCTAssertGreaterThanOrEqual(frame.minX, -0.5)
                XCTAssertLessThanOrEqual(frame.maxX, width + 0.5)
                for other in frames.dropFirst(index + 1) {
                    XCTAssertFalse(frame.insetBy(dx: 0.5, dy: 0.5).intersects(other.insetBy(dx: 0.5, dy: 0.5)))
                }
            }
            let image = UIGraphicsImageRenderer(bounds: bar.bounds).image { context in
                UIColor.white.setFill()
                context.fill(bar.bounds)
                bar.drawHierarchy(in: bar.bounds, afterScreenUpdates: true)
            }
            let attachment = XCTAttachment(image: image)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
            return titleFrame
        }

        let initial = try capture(width: 390, trailingCount: 3, name: "01_narrow_three_buttons")
        sut.headerOutput.display(primeTrailingImage: nil)
        _ = try capture(width: 390, trailingCount: 2, name: "02_narrow_two_buttons")
        _ = try capture(width: 844, trailingCount: 2, name: "03_wide_two_buttons")
        sut.headerOutput.display(primeTrailingImage: trailing)
        _ = try capture(width: 844, trailingCount: 3, name: "04_wide_three_buttons")
        let restored = try capture(width: 390, trailingCount: 3, name: "05_narrow_restored")
        XCTAssertEqual(restored == nil, initial == nil)
        if let restored, let initial {
            XCTAssertEqual(restored.minX, initial.minX, accuracy: 0.5)
            XCTAssertEqual(restored.width, initial.width, accuracy: 0.5)
        }
        let leading = try XCTUnwrap(sut.navigationItem.leftBarButtonItem?.customView as? UIControl)
        leading.sendActions(for: .touchUpInside)
        XCTAssertEqual(backPresses, 1)
        XCTAssertTrue(navigation.topViewController === sut)
    }
    #endif

    func test_loadingViewUsesClearBackgroundAndInstallsKeyboardDismissalOnce() {
        let sut = SUIHostingController(rootView: Text("Scene"))

        sut.loadViewIfNeeded()
        let gestureCount = sut.view.gestureRecognizers?.count
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.view.backgroundColor, .clear)
        XCTAssertEqual(sut.view.gestureRecognizers?.count, gestureCount)
        XCTAssertTrue(sut.view.gestureRecognizers?.contains { $0 is UITapGestureRecognizer && !$0.cancelsTouchesInView } == true)
    }

    func test_containerRetainsOneChildAndForwardsContentSizing() throws {
        let sut = SUIHostingController(rootView: Text("Scene").frame(width: 120, height: 36))
        sut.loadViewIfNeeded()
        let host = try XCTUnwrap(sut.children.first)

        XCTAssertEqual(sut.children.count, 1)
        XCTAssertTrue(host.parent === sut)
        XCTAssertTrue(host.view.superview === sut.view)
        XCTAssertEqual(sut.sizeThatFits(in: CGSize(width: 320, height: 640)), CGSize(width: 120, height: 36))

        host.preferredContentSize = CGSize(width: 120, height: 36)
        XCTAssertEqual(sut.preferredContentSize, host.preferredContentSize)

        sut.rootView = Text("Updated").frame(width: 160, height: 50)
        XCTAssertEqual(sut.sizeThatFits(in: CGSize(width: 320, height: 640)), CGSize(width: 160, height: 50))
        XCTAssertTrue(sut.children.first === host)
    }

    func test_appearanceShowsConfiguredNativeHeader() {
        let sut = SUIHostingController(rootView: Text("Scene"))
        sut.headerOutput.display(centerView: .keyValue(.init(.text("Title"), nil)))
        let navigation = UINavigationController(rootViewController: sut)
        navigation.setNavigationBarHidden(true, animated: false)

        sut.viewWillAppear(false)

        XCTAssertFalse(navigation.isNavigationBarHidden)
        XCTAssertEqual(sut.headerOutput.headerTitleLabel.text, "Title")
    }

    func test_appearanceRestoresHeaderVisibilityAfterReturningFromHeaderlessScene() {
        let sut = SUIHostingController(rootView: Text("Native header"))
        sut.headerOutput.display(centerView: .keyValue(.init(.text("Title"), nil)))
        let navigation = UINavigationController(rootViewController: sut)
        sut.viewWillAppear(false)

        sut.viewWillDisappear(false)
        XCTAssertFalse(navigation.isNavigationBarHidden)

        let next = SUIHostingController(rootView: Text("Custom header"))
        navigation.pushViewController(next, animated: false)
        next.viewWillAppear(false)
        XCTAssertTrue(navigation.isNavigationBarHidden)

        navigation.popViewController(animated: false)
        sut.viewWillAppear(false)

        XCTAssertFalse(navigation.isNavigationBarHidden)
        XCTAssertEqual(sut.headerOutput.headerTitleLabel.text, "Title")
    }

    func test_livePushKeepsOnlyPresenterBackButtonAfterSwiftUILifecycleUpdates() throws {
        try assertLivePushKeepsPresenterHeader(displayDelay: 0.05)
    }

    func test_livePushKeepsSynchronousPresenterHeaderAfterSwiftUILifecycleUpdates() throws {
        try assertLivePushKeepsPresenterHeader(displayDelay: nil)
    }

    func test_livePushKeepsPartialPresenterHeaderAfterSwiftUILifecycleUpdates() throws {
        try assertLivePushKeepsPresenterHeader(displayDelay: 0.05, usesFullModel: false)
    }

    func test_livePushKeepsSynchronousPartialPresenterHeaderAfterSwiftUILifecycleUpdates() throws {
        try assertLivePushKeepsPresenterHeader(displayDelay: nil, usesFullModel: false)
    }

    func test_livePushKeepsHeaderConfiguredBeforePushAfterSwiftUILifecycleUpdates() throws {
        try assertLivePushKeepsPresenterHeader(displayDelay: nil, displaysBeforePush: true)
    }

    private func assertLivePushKeepsPresenterHeader(
        displayDelay: TimeInterval?, usesFullModel: Bool = true, displaysBeforePush: Bool = false
    ) throws {
        let root = UIViewController()
        root.title = "Root"
        let navigation = UINavigationController(rootViewController: root)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = .light
        window.backgroundColor = .systemBackground
        root.view.backgroundColor = .systemBackground
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKeyAndVisible()
        }
        navigation.view.frame = window.bounds
        settle(window)
        #if !os(tvOS)
        let gestureDelegate = GestureDelegate()
        navigation.interactivePopGestureRecognizer?.delegate = gestureDelegate
        #endif

        let presenter = HeaderPresenter(displayDelay: displayDelay, usesFullModel: usesFullModel)
        let analytics = AnalyticsRecorder()
        let lifecycle = presenter.withAnalytics(eventName: "scene", parameters: [:], analytics: analytics)
        let sut = SUIHostingController(rootView: LifeCycleView(lifeCycleOutput: lifecycle) {
            RedrawingContent(presenter: presenter)
        })
        presenter.header = sut.headerOutput.weakReferenced.mainQueueDispatched
        if displaysBeforePush { presenter.displayHeader() }
        let originalItem = sut.navigationItem
        let originalHeader = sut.headerOutput
        navigation.pushViewController(sut, animated: false)
        settle(window)
        settle(window)

        XCTAssertTrue(window.isKeyWindow)
        XCTAssertTrue(sut.view.window === window)
        XCTAssertTrue(presenter.didDisplay)
        XCTAssertEqual(presenter.events, ["load", "willAppear", "didAppear"])
        XCTAssertEqual(analytics.events, ["scene"])
        #if !os(tvOS)
        XCTAssertNil(navigation.interactivePopGestureRecognizer?.delegate)
        #endif
        XCTAssertTrue(originalItem === sut.navigationItem)
        XCTAssertTrue(originalHeader === sut.headerOutput)
        let screenshot = UIGraphicsImageRenderer(bounds: navigation.navigationBar.bounds).image { context in
            UIColor.systemBackground.setFill()
            context.fill(navigation.navigationBar.bounds)
            navigation.navigationBar.drawHierarchy(in: navigation.navigationBar.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: screenshot)
        attachment.name = "live-hosting-native-header"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertFalse(navigation.isNavigationBarHidden)
        XCTAssertEqual(sut.headerOutput.headerTitleLabel.text, "Title")
        XCTAssertTrue(sut.headerOutput.headerTitleLabel.isDescendant(of: navigation.navigationBar))
        XCTAssertTrue(sut.navigationItem.hidesBackButton)
        XCTAssertFalse(sut.navigationItem.leftItemsSupplementBackButton)
        XCTAssertEqual(sut.navigationItem.leftBarButtonItems?.count, 1)
        let leadingControls = actionControls(in: navigation.navigationBar)
        XCTAssertEqual(leadingControls.count, 1)
        try XCTUnwrap(leadingControls.first).sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(presenter.backPresses, 1)
        XCTAssertTrue(navigation.topViewController === sut, "The presenter callback must run, not an automatic UIKit pop")

        let next = SUIHostingController(rootView: Text("Headerless scene"))
        navigation.pushViewController(next, animated: false)
        settle(window)
        XCTAssertTrue(navigation.isNavigationBarHidden)
        navigation.popViewController(animated: false)
        settle(window)

        XCTAssertFalse(navigation.isNavigationBarHidden)
        XCTAssertTrue(sut.navigationItem.hidesBackButton)
        XCTAssertFalse(sut.navigationItem.leftItemsSupplementBackButton)
        XCTAssertEqual(sut.navigationItem.leftBarButtonItems?.count, 1)
        XCTAssertEqual(actionControls(in: navigation.navigationBar).count, 1)
        XCTAssertEqual(presenter.events, [
            "load", "willAppear", "didAppear", "willDisappear", "didDisappear", "willAppear", "didAppear"
        ])
        XCTAssertEqual(analytics.events, ["scene"])

        presenter.text = "Updated scene"
        settle(window)

        XCTAssertEqual(sut.headerOutput.headerTitleLabel.text, "Title")
        XCTAssertTrue(sut.headerOutput.headerTitleLabel.isDescendant(of: navigation.navigationBar))
        XCTAssertTrue(sut.navigationItem.hidesBackButton)
        XCTAssertFalse(sut.navigationItem.leftItemsSupplementBackButton)
        XCTAssertEqual(sut.navigationItem.leftBarButtonItems?.count, 1)

        sut.rootView = LifeCycleView(lifeCycleOutput: lifecycle) { RedrawingContent(presenter: presenter) }
        settle(window)

        XCTAssertEqual(analytics.events, ["scene"])
        XCTAssertEqual(presenter.events.filter { $0 == "load" }.count, 1)
        XCTAssertTrue(sut.navigationItem.hidesBackButton)
        XCTAssertFalse(sut.navigationItem.leftItemsSupplementBackButton)
        XCTAssertEqual(actionControls(in: navigation.navigationBar).count, 1)

        navigation.popViewController(animated: false)
        settle(window)

        XCTAssertTrue(navigation.topViewController === root)
        XCTAssertFalse(root.navigationItem.hidesBackButton)
        XCTAssertNil(root.navigationItem.leftBarButtonItem)
        #if !os(tvOS)
        XCTAssertTrue(navigation.interactivePopGestureRecognizer?.delegate === gestureDelegate)
        #endif
    }

    private func settle(_ window: UIWindow) {
        window.layoutIfNeeded()
        window.rootViewController?.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        window.layoutIfNeeded()
        window.rootViewController?.view.layoutIfNeeded()
    }

    private func actionControls(in view: UIView) -> [UIControl] {
        let current = (view as? UIControl).flatMap { $0.allControlEvents.contains(.primaryActionTriggered) ? $0 : nil }
        return (current.map { [$0] } ?? []) + view.subviews.flatMap(actionControls)
    }

    private struct RedrawingContent: View {
        @ObservedObject var presenter: HeaderPresenter

        var body: some View {
            VStack {
                TextField("Phone", text: $presenter.text)
                Text(presenter.text)
            }
        }
    }

    private final class HeaderPresenter: ObservableObject, LifeCycleViewOutput {
        var header: HeaderOutput?
        @Published var text = "Scene"
        var didDisplay = false
        var backPresses = 0
        var events: [String] = []
        private let displayDelay: TimeInterval?
        private let usesFullModel: Bool

        init(displayDelay: TimeInterval?, usesFullModel: Bool) {
            self.displayDelay = displayDelay
            self.usesFullModel = usesFullModel
        }

        func viewDidLoad() {
            events.append("load")
            guard !didDisplay else { return }
            if let displayDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + displayDelay) { [weak self] in
                    self?.displayHeader()
                }
            } else {
                displayHeader()
            }
        }

        func viewWillAppear() { events.append("willAppear") }
        func viewDidAppear() { events.append("didAppear") }
        func viewWillDisappear() { events.append("willDisappear") }
        func viewDidDisappear() { events.append("didDisappear") }

        func displayHeader() {
            didDisplay = true
            let title = HeaderPresentableModel.CenterView.keyValue(.init(.text("Title"), nil))
            let leading = CardViewPresentableModel(
                leadingImage: .init(image: .asset(UIImage(systemName: "chevron.left"))),
                onPress: { [weak self] in self?.backPresses += 1 }
            )
            if usesFullModel {
                header?.display(model: .init(centerView: title, leadingCard: leading))
            } else {
                header?.display(centerView: title)
                header?.display(leadingCard: leading)
            }
        }
    }

    private final class AnalyticsRecorder: AnalyticsTracker {
        var events: [String] = []

        func log(eventName: String, parameters: [String: Any]) {
            events.append(eventName)
        }
    }

    #if !os(tvOS)
    func test_appearanceHidesNativeBarAndRestoresInteractivePopDelegateOnExit() {
        let sut = SUIHostingController(rootView: Text("Scene"))
        let navigation = UINavigationController(rootViewController: sut)
        let delegate = GestureDelegate()
        navigation.loadViewIfNeeded()
        navigation.interactivePopGestureRecognizer?.delegate = delegate

        sut.viewWillAppear(false)

        XCTAssertTrue(navigation.isNavigationBarHidden)
        XCTAssertNil(navigation.interactivePopGestureRecognizer?.delegate)

        sut.viewWillDisappear(false)

        XCTAssertTrue(navigation.isNavigationBarHidden)
        XCTAssertTrue(navigation.interactivePopGestureRecognizer?.delegate === delegate)
    }

    private final class GestureDelegate: NSObject, UIGestureRecognizerDelegate {}
    #endif
}
#endif
