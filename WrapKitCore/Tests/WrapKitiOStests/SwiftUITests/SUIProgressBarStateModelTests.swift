#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import UIKit
import XCTest

final class SUIProgressBarStateModelTests: XCTestCase {
    func test_premountFullModelAndGranularOutputsHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = ProgressBarOutputSwiftUIAdapter()
        modelLastAdapter.display(progress: 80)
        modelLastAdapter.display(style: .init(height: 28))
        modelLastAdapter.display(isHidden: true)
        modelLastAdapter.display(model: .init(
            progress: 42,
            style: .init(height: 12)
        ))

        let granularLastAdapter = ProgressBarOutputSwiftUIAdapter()
        granularLastAdapter.display(model: .init(
            progress: 42,
            style: .init(height: 12)
        ))
        granularLastAdapter.display(progress: 80)
        granularLastAdapter.display(style: .init(height: 28))
        granularLastAdapter.display(isHidden: true)

        let modelLast = SUIProgressBarStateModel(adapter: modelLastAdapter)
        let granularLast = SUIProgressBarStateModel(adapter: granularLastAdapter)

        XCTAssertEqual(modelLast.progress, 42)
        XCTAssertEqual(modelLast.layoutHeight, 12)
        XCTAssertFalse(modelLast.isHidden)
        XCTAssertFalse(modelLast.animatesProgressChanges)
        XCTAssertEqual(granularLast.progress, 80)
        XCTAssertEqual(granularLast.layoutHeight, 28)
        XCTAssertTrue(granularLast.isHidden)
        XCTAssertTrue(granularLast.animatesProgressChanges)
    }

    func test_premountNilModelHidesAndPreservesGranularProgressAndStyle() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        adapter.display(progress: 35)
        adapter.display(style: .init(height: 28))
        adapter.display(model: nil)

        let sut = SUIProgressBarStateModel(adapter: adapter)

        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.progress, 35)
        XCTAssertEqual(sut.layoutHeight, 28)
        XCTAssertNotNil(sut.style)
        XCTAssertTrue(sut.animatesProgressChanges)
    }

    func test_premountGranularNilStyleClearsStyleAndPreservesEstablishedLayoutHeight() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        adapter.display(model: .init(
            progress: 35,
            style: .init(height: 28)
        ))
        adapter.display(style: nil)

        let sut = SUIProgressBarStateModel(adapter: adapter)

        XCTAssertNil(sut.style)
        XCTAssertEqual(sut.layoutHeight, 28)
    }

    func test_premountFullModelWithoutStylePreservesGranularStyle() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        adapter.display(style: .init(height: 28))
        adapter.display(model: .init(progress: 35, style: nil))

        let sut = SUIProgressBarStateModel(adapter: adapter)

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.progress, 35)
        XCTAssertNotNil(sut.style)
        XCTAssertEqual(sut.layoutHeight, 28)
        XCTAssertFalse(sut.animatesProgressChanges)
    }

    func test_fullModelMatchesUIKitVisibilityStyleAndNonanimatedProgress() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        let sut = SUIProgressBarStateModel(adapter: adapter)

        adapter.display(model: .init(
            progress: 42,
            style: .init(
                backgroundColor: .systemGray4,
                progressBarColor: .systemGreen,
                height: 12,
                trackHeight: 8,
                cornerStyle: .fixed(6)
            )
        ))

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.progress, 42)
        XCTAssertEqual(sut.layoutHeight, 12)
        XCTAssertFalse(sut.animatesProgressChanges)
        XCTAssertTrue(sut.style?.progressBarColor?.isEqual(UIColor.systemGreen) == true)
    }

    func test_incrementalProgressAnimatesWhileFullModelDoesNot() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        let sut = SUIProgressBarStateModel(adapter: adapter)
        adapter.display(model: .init(progress: 10, style: nil))

        adapter.display(progress: 80)

        XCTAssertEqual(sut.progress, 80)
        XCTAssertTrue(sut.animatesProgressChanges)
    }

    func test_nilModelPreservesProgressAndLayoutAfterGranularNilStyle() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        let sut = SUIProgressBarStateModel(adapter: adapter)
        adapter.display(model: .init(
            progress: 35,
            style: .init(height: 28, trackHeight: 10)
        ))

        adapter.display(style: nil)
        XCTAssertNil(sut.style)
        XCTAssertEqual(sut.layoutHeight, 28)

        adapter.display(model: nil)
        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.progress, 35)
        XCTAssertEqual(sut.layoutHeight, 28)
    }

    func test_incrementalStyleWithoutHeight_preservesEstablishedLayoutHeight() {
        let adapter = ProgressBarOutputSwiftUIAdapter()
        let sut = SUIProgressBarStateModel(adapter: adapter)

        adapter.display(style: .init(
            backgroundColor: .systemRed,
            height: 50,
            cornerStyle: CornerStyle.none
        ))
        adapter.display(style: .init(
            backgroundColor: .systemRed,
            trackHeight: 33,
            cornerStyle: CornerStyle.none
        ))

        XCTAssertEqual(sut.layoutHeight, 50)
        XCTAssertEqual(sut.style?.trackHeight, 33)
    }
}
#endif
