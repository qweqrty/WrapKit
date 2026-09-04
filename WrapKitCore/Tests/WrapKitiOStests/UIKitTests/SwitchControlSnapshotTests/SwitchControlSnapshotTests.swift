//
//  SwitchControlSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class SwitchControlSnapshotTests: XCTestCase {
    func test_switchControl_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"
        // WHEN
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"
        // WHEN
        sut.display(isOn: false)
        sut.display(isEnabled: true)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_isOn_false() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"

        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .black,
            backgroundColor: .cyan,
            cornerRadius: 0,
            shimmerStyle: nil))
        // WHEN

        sut.display(isOn: false)

        container.setNeedsLayout()
        container.layoutIfNeeded()

        sut.setNeedsLayout()
        sut.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_isOn_false() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"

        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .black,
            backgroundColor: .cyan,
            cornerRadius: 0,
            shimmerStyle: nil))
        // WHEN

        sut.display(isOn: true)

        container.setNeedsLayout()
        container.layoutIfNeeded()

        sut.setNeedsLayout()
        sut.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // MARK: - Style tests
    func test_switchControl_with_tintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_tintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .systemRed,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_thumbTintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        sut.backgroundColor = .blue

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_thumbTintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .green,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        sut.backgroundColor = .systemBlue

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_backgroundColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .systemBlue,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        sut.backgroundColor = .blue

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_backgroundColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .blue,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        sut.backgroundColor = .systemBlue

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .systemBlue,
            cornerRadius: 10,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        sut.backgroundColor = .blue

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .systemBlue,
            cornerRadius: 11,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        sut.backgroundColor = .blue

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_shimmerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"

        // WHEN
        let style = ShimmerStyle(
            backgroundColor: .systemYellow,
            gradientColorOne: .systemPurple,
            gradientColorTwo: .red,
            cornerRadius: 10)

        sut.display(style: .init(
            tintColor: .systemGreen,
            thumbTintColor: .cyan,
            backgroundColor: .clear,
            cornerRadius: 10,
            shimmerStyle: style))

        sut.display(isLoading: true)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_shimmerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"

        // WHEN
        let style = ShimmerStyle(
            backgroundColor: .red,
            gradientColorOne: .yellow,
            gradientColorTwo: .black,
            cornerRadius: 11)

        sut.display(style: .init(
            tintColor: .clear,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 11,
            shimmerStyle: style))

        sut.display(isLoading: true)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
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
        XCTAssertFalse(sut.clipsToBounds)
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
        XCTAssertFalse(sut.switchControl.clipsToBounds)
    }
}

extension SwitchControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SwitchControl, container: UIView) {

        let sut = SwitchControl()
        let container = makeContainer()

        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .width(200, priority: .required),
            .height(50, priority: .required)
        )

        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
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
