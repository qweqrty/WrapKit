import WrapKit
import WrapKitTestUtils
import UIKit
import XCTest

@available(iOS 17.0, *)
final class SUISwitchControlSnapshotTests: XCTestCase {

    func test_switchControl_default_state() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"

        sut.display(isOn: true)
        sut.display(isEnabled: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_default_state() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"

        sut.display(isOn: false)
        sut.display(isEnabled: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_isOn_false() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(tintColor: .red, thumbTintColor: .black, backgroundColor: .cyan, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_switchControl_with_tintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_with_tintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"

        sut.display(style: .init(tintColor: .systemRed, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_switchControl_with_thumbTintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_with_thumbTintColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .green, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .systemBlue

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_switchControl_with_backgroundColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_with_backgroundColor() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .blue, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .systemBlue

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_switchControl_with_cornerRadius() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 10, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_with_cornerRadius() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 20, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    // UIKit-only until both implementations expose a deterministic shimmer phase for snapshots.
}

@available(iOS 17.0, *)
extension SUISwitchControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUISwitchControlSnapshotSUT {
        let container = makeContainer()
        let sut = SwiftUISwitchControlSnapshotSUT(uiKitContainer: container)

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
