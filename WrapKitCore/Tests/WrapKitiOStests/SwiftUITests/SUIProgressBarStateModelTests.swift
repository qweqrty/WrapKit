#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import UIKit
import XCTest

final class SUIProgressBarStateModelTests: XCTestCase {
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

    func test_nilModelAndNilStylePreserveUIKitRetainedLayoutState() {
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
}
#endif
