#if canImport(SwiftUI) && canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit
import XCTest
import WrapKit

@MainActor
final class LifeCycleViewTests: XCTestCase {
    private weak var previousKeyWindow: UIWindow?

    override func tearDown() {
        previousKeyWindow?.makeKeyAndVisible()
        previousKeyWindow = nil
        super.tearDown()
    }

    func test_firstAppearance_loadsBeforeAppearing() {
        let output = LifecycleRecorder()
        let host = UIHostingController(rootView: LifeCycleView(lifeCycleOutput: output) {
            Text("Screen")
        })
        let window = show(host)
        defer { window.isHidden = true }

        XCTAssertEqual(output.events, ["load", "willAppear", "didAppear"])
    }

    func test_returnAndRedraw_doNotReloadTheScreen() {
        let output = LifecycleRecorder()
        let host = UIHostingController(rootView: LifeCycleView(lifeCycleOutput: output) {
            Text("Screen")
        })
        let navigation = UINavigationController(rootViewController: host)
        let window = show(navigation)
        defer { window.isHidden = true }

        host.rootView = LifeCycleView(lifeCycleOutput: output) { Text("Updated screen") }
        settle()
        XCTAssertEqual(output.events, ["load", "willAppear", "didAppear"])

        navigation.pushViewController(UIViewController(), animated: false)
        settle()
        navigation.popViewController(animated: false)
        settle()

        XCTAssertEqual(output.events, [
            "load", "willAppear", "didAppear",
            "willDisappear", "didDisappear", "willAppear", "didAppear"
        ])
    }

    private func show(_ controller: UIViewController) -> UIWindow {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        previousKeyWindow = scene?.windows.first(where: \.isKeyWindow)
        let window = scene.map(UIWindow.init(windowScene:))
            ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.frame = window.bounds
        controller.view.layoutIfNeeded()
        settle()
        return window
    }

    private func settle() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }
}

private final class LifecycleRecorder: LifeCycleViewOutput {
    var events: [String] = []
    func viewDidLoad() { events.append("load") }
    func viewWillAppear() { events.append("willAppear") }
    func viewDidAppear() { events.append("didAppear") }
    func viewWillDisappear() { events.append("willDisappear") }
    func viewDidDisappear() { events.append("didDisappear") }
}
#endif
