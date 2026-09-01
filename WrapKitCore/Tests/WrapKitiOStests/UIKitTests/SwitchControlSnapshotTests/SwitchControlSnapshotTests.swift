import WrapKit
import WrapKitTestUtils
import UIKit
import XCTest

final class SwitchControlSnapshotTests: XCTestCase {

    func test_switchControl_default_state() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"

        sut.display(isOn: true)
        sut.display(isEnabled: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_switchControl_default_state() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"

        sut.display(isOn: false)
        sut.display(isEnabled: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    // TODO: - wrong appearance on ios26
    func test_switchControl_isOn_false() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(tintColor: .red, thumbTintColor: .black, backgroundColor: .cyan, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_switchControl_isOn_false() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(tintColor: .red, thumbTintColor: .black, backgroundColor: .cyan, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_switchControl_with_tintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_switchControl_with_tintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"

        sut.display(style: .init(tintColor: .systemRed, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_switchControl_with_thumbTintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_switchControl_with_thumbTintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .green, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .systemBlue

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_switchControl_with_backgroundColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_switchControl_with_backgroundColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .blue, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .systemBlue

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_switchControl_with_cornerRadius() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 10, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_switchControl_with_cornerRadius() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 20, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        assertFail(snapshot: sut, named: snapshotName)
    }

    // UIKit-only until both implementations expose a deterministic shimmer phase for snapshots.
    func test_switchControl_with_shimmerStyle() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"

        let style = ShimmerStyle(backgroundColor: .systemYellow, gradientColorOne: .systemPurple, gradientColorTwo: .red, cornerRadius: 10)
        sut.display(style: .init(tintColor: .systemGreen, thumbTintColor: .cyan, backgroundColor: .clear, cornerRadius: 10, shimmerStyle: style))
        sut.display(isLoading: true)

        assertUIKitOnlySnapshot(
            snapshot: sut,
            named: snapshotName,
            reason: "Animated shimmer has no deterministic shared snapshot phase."
        )
    }

    func test_fail_switchControl_with_shimmerStyle() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"

        let style = ShimmerStyle(backgroundColor: .red, gradientColorOne: .yellow, gradientColorTwo: .black, cornerRadius: 11)
        sut.display(style: .init(tintColor: .clear, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 11, shimmerStyle: style))
        sut.display(isLoading: true)

        assertUIKitOnlySnapshotFail(
            snapshot: sut,
            named: snapshotName,
            reason: "Animated shimmer has no deterministic shared snapshot phase."
        )
    }

    @available(iOS 17.0, *)
    func test_swiftUISwitch_loadingDisablesNativeControlThenValueChangeCallbackResumes() throws {
        let adapter = SwitchCotrolOutputSwiftUIAdapter()
        var pressCount = 0
        adapter.display(model: .init(
            accessibilityIdentifier: "switch",
            onPress: { _ in pressCount += 1 },
            isOn: false,
            isEnabled: true
        ))
        adapter.display(isLoading: true)
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUISwitchControl(adapter: adapter),
            size: CGSize(width: 100, height: 60)
        )

        let loadingSwitch = try XCTUnwrap(host.firstSubview(of: UISwitch.self))
        XCTAssertFalse(loadingSwitch.isEnabled)
        XCTAssertEqual(pressCount, 0)

        adapter.display(isLoading: false)
        host.settle()
        let enabledSwitch = try XCTUnwrap(host.firstSubview(of: UISwitch.self))
        XCTAssertTrue(enabledSwitch.isEnabled)
        enabledSwitch.setOn(true, animated: false)
        enabledSwitch.sendActions(for: .valueChanged)
        XCTAssertEqual(pressCount, 1)
    }

    func test_uikitSwitch_mountReappliesStoredOutputStyle() {
        guard #available(iOS 26.0, *) else { return }

        let style = SwitchControlPresentableModel.Style(
            tintColor: .systemPurple,
            thumbTintColor: .systemYellow,
            backgroundColor: .systemGreen,
            cornerRadius: 9
        )
        let sut = SwitchControl()
        sut.display(style: style)
        sut.display(isOn: true)

        let host = UIKitMountTestHost(rootView: sut, size: CGSize(width: 100, height: 60))
        host.settle()

        XCTAssertEqual(sut.onTintColor, style.tintColor)
        XCTAssertEqual(sut.thumbTintColor, style.thumbTintColor)
        XCTAssertEqual(sut.backgroundColor, style.backgroundColor)
        XCTAssertEqual(sut.cornerRadiusValue(), style.cornerRadius, accuracy: 0.001)
    }

    func test_uikitCardSwitch_mountReappliesStoredOutputStyle() {
        guard #available(iOS 26.0, *) else { return }

        let style = SwitchControlPresentableModel.Style(
            tintColor: .systemBlue,
            thumbTintColor: .systemGreen,
            backgroundColor: .white,
            cornerRadius: 10
        )
        let sut = CardView()
        sut.display(switchControl: .init(
            isOn: true,
            isEnabled: true,
            style: style
        ))

        let host = UIKitMountTestHost(rootView: sut, size: CGSize(width: 390, height: 100))
        host.settle()

        XCTAssertEqual(sut.switchControl.onTintColor, style.tintColor)
        XCTAssertEqual(sut.switchControl.thumbTintColor, style.thumbTintColor)
        XCTAssertEqual(sut.switchControl.backgroundColor, style.backgroundColor)
        XCTAssertEqual(sut.switchControl.cornerRadiusValue(), style.cornerRadius, accuracy: 0.001)
    }
}

extension SwitchControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PairedSwitchControlSnapshotSUT {
        let container = makeContainer()
        let sut = PairedSwitchControlSnapshotSUT(uiKitContainer: container)

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .width(200, priority: .required),
            .height(50, priority: .required)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}

private final class UIKitMountTestHost {
    private let viewController = UIViewController()
    private let window: UIWindow
    private weak var previousKeyWindow: UIWindow?

    init(rootView: UIView, size: CGSize) {
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

        window.rootViewController = viewController
        viewController.view.frame = window.bounds
        rootView.frame = viewController.view.bounds
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(rootView)
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
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }
}
