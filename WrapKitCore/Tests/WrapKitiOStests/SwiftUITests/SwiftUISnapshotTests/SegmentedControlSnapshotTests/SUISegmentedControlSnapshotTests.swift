//
//  SUISegmentedControlSnapshotTests.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUISegmentedControlSnapshotTests: XCTestCase {

    func test_SegmentedControl_default_state() {
        let snapshotName = "SEGMENTEDCONTROL_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(segments: makeSegments())

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_SegmentedControl_default_state() {
        let snapshotName = "SEGMENTEDCONTROL_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(segments: [
            .init(title: "First.", index: 0),
            .init(title: "Second", index: 1),
            .init(title: "Third", index: 2)
        ])

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_SegmentedControl_with_appearance() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_APPEARANCE"
        let sut = makeSUT()

        sut.display(appearence: makeAccentAppearance())
        sut.display(segments: makeSegments())

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_SegmentedControl_with_appearance() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_APPEARANCE"
        let sut = makeSUT()

        sut.display(appearence: makeFailAccentAppearance())
        sut.display(segments: makeSegments())

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_SegmentedControl_with_long_titles() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_LONG_TITLES"
        let sut = makeSUT()

        sut.display(segments: [
            .init(title: "Very long first", index: 0),
            .init(title: "Very long second", index: 1),
            .init(title: "Very long third", index: 2)
        ])

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_SegmentedControl_with_long_titles() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_LONG_TITLES"
        let sut = makeSUT()

        sut.display(segments: [
            .init(title: "Different first", index: 0),
            .init(title: "Very long second", index: 1),
            .init(title: "Very long third", index: 2)
        ])

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }
}
@available(iOS 17.0, *)
private extension SUISegmentedControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUISegmentedControlSnapshotSUT {
        let appearance = makeDefaultAppearance()
        let snapshotHeight: CGFloat = 32
        let container = makeContainer()
        let sut = SwiftUISegmentedControlSnapshotSUT(
            uiKitContainer: container,
            appearance: appearance,
            snapshotHeight: snapshotHeight
        )

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(snapshotHeight)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 140)
        container.backgroundColor = .clear
        return container
    }

    func makeSegments() -> [SegmentControlModel] {
        [
            .init(title: "First", index: 0),
            .init(title: "Second", index: 1),
            .init(title: "Third", index: 2)
        ]
    }

    func makeDefaultAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .black,
                backgroundColor: .systemGray5,
                selectedBackgroundColor: .white
            ),
            font: .systemFont(ofSize: 18, weight: .semibold),
            cornerRadius: 10
        )
    }

    func makeAccentAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .white,
                backgroundColor: .systemBlue,
                selectedBackgroundColor: .systemRed
            ),
            font: .systemFont(ofSize: 20, weight: .bold),
            cornerRadius: 14
        )
    }

    func makeFailAccentAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .white,
                backgroundColor: .systemPurple,
                selectedBackgroundColor: .systemRed
            ),
            font: .systemFont(ofSize: 20, weight: .bold),
            cornerRadius: 14
        )
    }
}
