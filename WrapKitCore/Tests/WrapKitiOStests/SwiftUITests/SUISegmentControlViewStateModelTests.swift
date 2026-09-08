#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import UIKit
import XCTest

final class SUISegmentControlViewStateModelTests: XCTestCase {
    func test_outputUpdatesAppearanceAndSegments() {
        let adapter = SegmentedControlOutputSwiftUIAdapter()
        let initialAppearance = makeAppearance(backgroundColor: .systemGray5)
        let updatedAppearance = makeAppearance(backgroundColor: .systemPurple)
        let sut = SUISegmentControlViewStateModel(
            adapter: adapter,
            appearance: initialAppearance
        )

        adapter.display(appearence: updatedAppearance)
        adapter.display(segments: [
            .init(title: "First", index: 10),
            .init(title: "Second", index: 20)
        ])

        XCTAssertTrue(sut.appearance.colors.backgroundColor.isEqual(UIColor.systemPurple))
        XCTAssertEqual(sut.segments.map(\.title), ["First", "Second"])
        XCTAssertEqual(sut.selectedIndex, 0)
    }

    func test_selectionUsesDisplayedPositionLikeUIKitAndInvokesCallback() {
        let adapter = SegmentedControlOutputSwiftUIAdapter()
        let sut = SUISegmentControlViewStateModel(
            adapter: adapter,
            appearance: makeAppearance(backgroundColor: .systemGray5)
        )
        var selectedIndexes: [Int] = []
        adapter.display(segments: [
            .init(title: "First", index: 10),
            .init(title: "Second", index: 20, onTap: { selectedIndexes.append($0) })
        ])

        sut.selectSegment(at: 1)

        XCTAssertEqual(sut.selectedIndex, 1)
        XCTAssertEqual(selectedIndexes, [1])
    }

    func test_replacingAndClearingSegmentsResetsSelectionLikeUIKit() {
        let adapter = SegmentedControlOutputSwiftUIAdapter()
        let sut = SUISegmentControlViewStateModel(
            adapter: adapter,
            appearance: makeAppearance(backgroundColor: .systemGray5)
        )
        adapter.display(segments: [
            .init(title: "First", index: 0),
            .init(title: "Second", index: 1)
        ])
        sut.selectSegment(at: 1)

        adapter.display(segments: [.init(title: "Replacement", index: 7)])
        XCTAssertEqual(sut.selectedIndex, 0)

        adapter.display(segments: [])
        XCTAssertEqual(sut.selectedIndex, UISegmentedControl.noSegment)
    }

    private func makeAppearance(backgroundColor: UIColor) -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .label,
                backgroundColor: backgroundColor,
                selectedBackgroundColor: .systemBackground
            ),
            font: .systemFont(ofSize: 15),
            cornerRadius: 10
        )
    }
}
#endif
