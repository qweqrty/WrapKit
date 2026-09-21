//
//  SegmentedControlSnapshotTests.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class SegmentedControlSnapshotTests: XCTestCase {

    func test_SegmentedControl_default_state() {
        let snapshotName = "SEGMENTEDCONTROL_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(segments: makeSegments())

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_SegmentedControl_default_state() {
        let snapshotName = "SEGMENTEDCONTROL_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(segments: [
            .init(title: "First.", index: 0),
            .init(title: "Second", index: 1),
            .init(title: "Third", index: 2)
        ])

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_SegmentedControl_with_appearance() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_APPEARANCE"
        let sut = makeSUT()

        sut.display(appearence: makeAccentAppearance())
        sut.display(segments: makeSegments())

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_SegmentedControl_with_appearance() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_APPEARANCE"
        let sut = makeSUT()

        sut.display(appearence: makeFailAccentAppearance())
        sut.display(segments: makeSegments())

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_SegmentedControl_with_long_titles() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_LONG_TITLES"
        let sut = makeSUT()

        sut.display(segments: [
            .init(title: "Very long first", index: 0),
            .init(title: "Very long second", index: 1),
            .init(title: "Very long third", index: 2)
        ])

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_SegmentedControl_with_long_titles() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_LONG_TITLES"
        let sut = makeSUT()

        sut.display(segments: [
            .init(title: "Different first", index: 0),
            .init(title: "Very long second", index: 1),
            .init(title: "Very long third", index: 2)
        ])

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }
}
private extension SegmentedControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SegmentedControlSnapshotSUT {
        let appearance = makeDefaultAppearance()
        let snapshotHeight: CGFloat = 32
        let container = makeContainer()
        let view = SegmentedControl(appearance: appearance)
        let sut = SegmentedControlSnapshotSUT(view: view, container: container)

        container.addSubview(view)
        view.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(snapshotHeight)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(view, file: file, line: line)
        return sut
    }

    func assertSnapshots(
        of view: UIView,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(
            snapshot: view.snapshot(for: .iPhone(style: .light)),
            named: "\(snapshotOSPrefix)_\(name)_LIGHT",
            file: file,
            line: line
        )
        assert(
            snapshot: view.snapshot(for: .iPhone(style: .dark)),
            named: "\(snapshotOSPrefix)_\(name)_DARK",
            file: file,
            line: line
        )
    }

    func assertFailSnapshots(
        of view: UIView,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertFail(
            snapshot: view.snapshot(for: .iPhone(style: .light)),
            named: "\(snapshotOSPrefix)_\(name)_LIGHT",
            file: file,
            line: line
        )
        assertFail(
            snapshot: view.snapshot(for: .iPhone(style: .dark)),
            named: "\(snapshotOSPrefix)_\(name)_DARK",
            file: file,
            line: line
        )
    }

    var snapshotOSPrefix: String {
        if #available(iOS 26.0, *) {
            return "iOS26"
        }
        return "iOS18.5"
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

private final class SegmentedControlSnapshotSUT {
    let view: SegmentedControl
    let container: UIView

    init(view: SegmentedControl, container: UIView) {
        self.view = view
        self.container = container
    }

    func display(appearence: SegmentedControlAppearance) {
        view.display(appearence: appearence)
    }

    func display(segments: [SegmentControlModel]) {
        view.display(segments: segments)
    }
}
