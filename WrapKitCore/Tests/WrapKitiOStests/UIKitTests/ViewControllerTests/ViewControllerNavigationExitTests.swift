import UIKit
import WrapKit
import XCTest

final class ViewControllerNavigationExitTests: XCTestCase {
    private var window: UIWindow?

    override func tearDown() {
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
        super.tearDown()
    }

    func test_pushingChild_doesNotReportNavigationExit() throws {
        let sut = makeSUT()
        let navigation = try makeNavigationController(root: sut)
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        let child = makeSUT()
        navigation.pushViewController(child, animated: false)
        waitForParent(of: child, toBe: navigation)
        sut.viewWillDisappear(false)
        sut.viewDidDisappear(false)

        XCTAssertEqual(exitCount, 0)
    }

    func test_completedPop_reportsNavigationExitOnce() throws {
        let sut = makeSUT()
        let navigation = try makeNavigationController(root: UIViewController())
        navigation.pushViewController(sut, animated: false)
        waitForParent(of: sut, toBe: navigation)
        XCTAssertTrue(sut.parent === navigation)
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        navigation.popViewController(animated: false)
        waitForParent(of: sut, toBe: nil)
        XCTAssertNil(sut.parent)
        sut.viewDidDisappear(false)
        sut.didMove(toParent: nil)

        XCTAssertEqual(exitCount, 1)
    }

    func test_removingHiddenControllerFromStack_reportsNavigationExit() throws {
        let root = UIViewController()
        let sut = makeSUT()
        let child = makeSUT()
        let navigation = try makeNavigationController(root: root)
        navigation.pushViewController(sut, animated: false)
        waitForParent(of: sut, toBe: navigation)
        XCTAssertTrue(sut.parent === navigation)
        navigation.pushViewController(child, animated: false)
        waitForParent(of: child, toBe: navigation)
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        navigation.setViewControllers([root, child], animated: false)
        waitForParent(of: sut, toBe: nil)
        XCTAssertNil(sut.parent)

        XCTAssertEqual(exitCount, 1)
    }

    func test_cancelledPop_doesNotReportNavigationExit() throws {
        let sut = makeSUT()
        let navigation = try makeNavigationController(root: UIViewController())
        navigation.pushViewController(sut, animated: false)
        waitForParent(of: sut, toBe: navigation)
        XCTAssertTrue(sut.parent === navigation)
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        sut.simulatedMovingFromParent = true
        sut.viewWillDisappear(true)
        XCTAssertEqual(exitCount, 0)
        sut.simulatedMovingFromParent = false
        sut.viewWillAppear(true)
        sut.viewDidAppear(true)

        XCTAssertEqual(exitCount, 0)
        XCTAssertTrue(navigation.viewControllers.last === sut)

        navigation.popViewController(animated: false)
        waitForParent(of: sut, toBe: nil)
        XCTAssertNil(sut.parent)
        XCTAssertEqual(exitCount, 1)
    }

    func test_completedDismissal_reportsNavigationExitOnce() {
        let sut = makeSUT()
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        sut.simulatedBeingDismissed = true
        sut.viewWillDisappear(true)
        XCTAssertEqual(exitCount, 0)
        sut.viewDidDisappear(true)
        sut.viewDidDisappear(true)

        XCTAssertEqual(exitCount, 1)
    }

    func test_navigationControllerDismissal_reportsNavigationExit() {
        let sut = makeSUT()
        let navigation = DismissingNavigationController(rootViewController: sut)
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        navigation.simulatedBeingDismissed = true
        sut.viewWillDisappear(true)
        sut.viewDidDisappear(true)

        XCTAssertEqual(exitCount, 1)
    }

    func test_cancelledDismissal_doesNotReportExitOnNextOrdinaryDisappearance() {
        let sut = makeSUT()
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        sut.simulatedBeingDismissed = true
        sut.viewWillDisappear(true)
        sut.simulatedBeingDismissed = false
        sut.viewWillAppear(true)
        sut.viewDidAppear(true)
        sut.viewWillDisappear(false)
        sut.viewDidDisappear(false)

        XCTAssertEqual(exitCount, 0)
    }

    func test_controllerWithoutParent_doesNotReportExit() {
        let sut = makeSUT()
        var exitCount = 0
        sut.onNavigationExit = { exitCount += 1 }

        sut.didMove(toParent: nil)
        sut.viewWillDisappear(false)
        sut.viewDidDisappear(false)

        XCTAssertEqual(exitCount, 0)
    }

    func test_navigationExit_preservesLifecycleDeliveryBeforeCallback() {
        let output = LifeCycleViewOutputSpy()
        let sut = NavigationStateViewController(contentView: UIView(), lifeCycleViewOutput: output)
        var disappearCountAtExit: Int?
        sut.onNavigationExit = { disappearCountAtExit = output.capturedViewDidDisappearCallCount }

        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)
        sut.viewDidAppear(false)
        sut.simulatedBeingDismissed = true
        sut.viewWillDisappear(false)
        sut.viewDidDisappear(false)

        XCTAssertEqual(output.capturedViewDidLoadCallCount, 1)
        XCTAssertEqual(output.capturedViewWillAppearCallCount, 1)
        XCTAssertEqual(output.capturedViewDidAppearCallCount, 1)
        XCTAssertEqual(output.capturedViewWillDisappearCallCount, 1)
        XCTAssertEqual(output.capturedViewDidDisappearCallCount, 1)
        XCTAssertEqual(disappearCountAtExit, 1)
    }

    private func waitForParent(of controller: NavigationStateViewController, toBe parent: UIViewController?) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in controller.completedParent === parent },
            object: nil
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 2), .completed)
    }

    private func makeSUT() -> NavigationStateViewController {
        NavigationStateViewController(contentView: UIView())
    }

    private func makeNavigationController(root: UIViewController) throws -> UINavigationController {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        let navigation = UINavigationController(rootViewController: root)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        navigation.view.layoutIfNeeded()
        self.window = window
        if let controller = root as? NavigationStateViewController {
            waitForParent(of: controller, toBe: navigation)
        }
        return navigation
    }
}

private final class NavigationStateViewController: ViewController<UIView> {
    var simulatedMovingFromParent = false
    var simulatedBeingDismissed = false
    private(set) weak var completedParent: UIViewController?

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        completedParent = parent
    }

    override var isMovingFromParent: Bool { simulatedMovingFromParent || super.isMovingFromParent }
    override var isBeingDismissed: Bool { simulatedBeingDismissed || super.isBeingDismissed }
}

private final class DismissingNavigationController: UINavigationController {
    var simulatedBeingDismissed = false

    override var isBeingDismissed: Bool { simulatedBeingDismissed || super.isBeingDismissed }
}
