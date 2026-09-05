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

        sut.display(style: .init(tintColor: .red, thumbTintColor: .systemGreen, backgroundColor: .systemBlue, cornerRadius: 11, shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_switchControl_with_shimmerStyle() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"
        let style = ShimmerStyle(
            backgroundColor: .systemYellow,
            gradientColorOne: .systemPurple,
            gradientColorTwo: .red,
            cornerRadius: 10
        )

        sut.display(style: .init(
            tintColor: .systemGreen,
            thumbTintColor: .cyan,
            backgroundColor: .clear,
            cornerRadius: 10,
            shimmerStyle: style
        ))
        sut.display(isLoading: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_switchControl_with_shimmerStyle() {
        let sut = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"
        let style = ShimmerStyle(
            backgroundColor: .red,
            gradientColorOne: .yellow,
            gradientColorTwo: .black,
            cornerRadius: 11
        )

        sut.display(style: .init(
            tintColor: .clear,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 11,
            shimmerStyle: style
        ))
        sut.display(isLoading: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_switchControl_fixedShimmerPhase_isDeterministic() throws {
        let sut = makeSUT()
        let style = ShimmerStyle(
            backgroundColor: .systemYellow,
            gradientColorOne: .systemPurple,
            gradientColorTwo: .red,
            cornerRadius: 10
        )
        sut.display(style: .init(
            tintColor: .systemGreen,
            thumbTintColor: .cyan,
            backgroundColor: .clear,
            cornerRadius: 10,
            shimmerStyle: style
        ))
        sut.display(isLoading: true)

        let first = try XCTUnwrap(sut.swiftUISnapshot(for: .light).pngData())
        let second = try XCTUnwrap(sut.swiftUISnapshot(for: .light).pngData())

        XCTAssertEqual(first, second)
    }
}

@available(iOS 17.0, *)
extension SUISwitchControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUISwitchControlSnapshotSUT {
        let sut = SwiftUISwitchControlSnapshotSUT()

        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
