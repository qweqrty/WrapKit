#if canImport(SwiftUI)
@testable import WrapKit
import SwiftUI
import WrapKitTestUtils
import XCTest

final class SUILabelStateModelTests: XCTestCase {
    @available(iOS 17.0, *)
    @MainActor
    func test_htmlOverflow_fillsContainerAndKeepsFullAttributedContent() throws {
        let size = CGSize(width: 390, height: 150)
        let config = HTMLAttributedStringConfig(lineSpacing: 8)
        let expectedText = try XCTUnwrap(
            HtmlTestCases.lists.asHtmlAttributedString(config: config)
        ).string
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUILabelView(
                model: .attributedString(HtmlTestCases.lists, config: config)
            )
            .frame(width: size.width, height: size.height),
            size: size
        )

        let label = try XCTUnwrap(host.firstSubview(of: WrapKit.Label.self))
        XCTAssertEqual(label.bounds.width, size.width, accuracy: 0.001)
        XCTAssertEqual(label.bounds.height, size.height, accuracy: 0.001)
        XCTAssertEqual(label.numberOfLines, 0)
        XCTAssertEqual(label.attributedText?.string, expectedText)
        XCTAssertGreaterThan(
            label.sizeThatFits(
                CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
            ).height,
            size.height
        )
    }

    @available(iOS 17.0, *)
    @MainActor
    func test_nonHTMLAttributes_keepNativeSwiftUIRenderer() {
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUILabelView(
                model: .attributes([TextAttributes(text: "Native attributed text")])
            )
            .frame(width: 390, height: 150),
            size: CGSize(width: 390, height: 150)
        )

        XCTAssertNil(host.firstSubview(of: WrapKit.Label.self))
    }

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
