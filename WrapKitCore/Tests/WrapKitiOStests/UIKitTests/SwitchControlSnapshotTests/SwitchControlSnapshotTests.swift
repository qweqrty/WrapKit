import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import enum SwiftUI.ColorScheme
#endif

final class SwitchControlSnapshotTests: XCTestCase {

    private weak var currentPairedSUT: PairedSwitchControlSnapshotSUT?

    private var swiftUISnapshotPrecision: Float { 0.98 }
    private var swiftUIFailSnapshotPrecision: Float { 1 }

    func test_switchControl_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"

        sut.display(isOn: true)
        sut.display(isEnabled: true)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"

        sut.display(isOn: false)
        sut.display(isEnabled: true)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // TODO: - wrong appearance on ios26
    func test_switchControl_isOn_false() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(tintColor: .red, thumbTintColor: .black, backgroundColor: .cyan, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: false)

        container.setNeedsLayout()
        container.layoutIfNeeded()
        sut.uiKitView.setNeedsLayout()
        sut.uiKitView.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        // UIKit-only — backgroundColor контейнера не синхронизируется со SwiftUI
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_isOn_false() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        let exp = expectation(description: "Wait for expectation")

        sut.display(style: .init(tintColor: .red, thumbTintColor: .black, backgroundColor: .cyan, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        container.setNeedsLayout()
        container.layoutIfNeeded()
        sut.uiKitView.setNeedsLayout()
        sut.uiKitView.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_tintColor() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_tintColor() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"

        sut.display(style: .init(tintColor: .systemRed, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_thumbTintColor() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_thumbTintColor() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .green, backgroundColor: .clear, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .systemBlue

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_backgroundColor() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_backgroundColor() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .blue, cornerRadius: 0, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .systemBlue

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_switchControl_with_cornerRadius() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 10, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_cornerRadius() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 11, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        sut.backgroundColor = .blue

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // shimmerStyle — UIKit-only, ShimmerView анимируется и не совпадёт со SwiftUI
    func test_switchControl_with_shimmerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"

        let style = ShimmerStyle(backgroundColor: .systemYellow, gradientColorOne: .systemPurple, gradientColorTwo: .red, cornerRadius: 10)
        sut.display(style: .init(tintColor: .systemGreen, thumbTintColor: .cyan, backgroundColor: .clear, cornerRadius: 10, shimmerStyle: style))
        sut.display(isLoading: true)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_switchControl_with_shimmerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"

        let style = ShimmerStyle(backgroundColor: .red, gradientColorOne: .yellow, gradientColorTwo: .black, cornerRadius: 11)
        sut.display(style: .init(tintColor: .clear, thumbTintColor: .clear, backgroundColor: .clear, cornerRadius: 11, shimmerStyle: style))
        sut.display(isLoading: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension SwitchControlSnapshotTests {

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(snapshot: snapshot, named: name, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assert(
                snapshot: swiftUISnapshot,
                named: name,
                precision: swiftUISnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func assertPairedSnapshotFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertFail(snapshot: snapshot, named: name, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertFail(
                snapshot: swiftUISnapshot,
                named: name,
                precision: swiftUIFailSnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func colorScheme(from snapshotName: String) -> ColorScheme {
        snapshotName.hasSuffix("_DARK") ? .dark : .light
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedSwitchControlSnapshotSUT, container: UIView) {
        let sut = PairedSwitchControlSnapshotSUT()
        let container = makeContainer()

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .width(200, priority: .required),
            .height(50, priority: .required)
        )
        container.layoutIfNeeded()

        currentPairedSUT = sut
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
