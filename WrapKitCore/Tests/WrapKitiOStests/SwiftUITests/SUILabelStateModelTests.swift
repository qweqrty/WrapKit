#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUILabelStateModelTests: XCTestCase {
    func test_fullModelWithoutText_keepsExistingContentVisibleLikeUIKit() {
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)

        adapter.display(text: "Existing")
        adapter.display(model: .init(
            accessibilityIdentifier: "updated-label",
            accessibility: .init(label: "Updated accessibility"),
            model: nil
        ))

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
        XCTAssertEqual(sut.presentable.accessibilityIdentifier, "updated-label")
        XCTAssertEqual(sut.presentable.accessibility?.label, "Updated accessibility")
    }

    func test_nilFullModel_hidesWithoutDiscardingExistingContent() {
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)

        adapter.display(text: "Existing")
        adapter.display(model: nil)

        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
    }
}
#endif
