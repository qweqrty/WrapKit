#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SUIKeyValueFieldViewStateModelTests: XCTestCase {
    func test_bottomImage_revealsAndHidesOtherwiseEmptyVerticalField() {
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        let sut = SUIKeyValueFieldViewStateModel(
            adapter: adapter,
            displaysBottomImage: true,
            isHidden: false
        )

        adapter.display(model: nil)
        XCTAssertTrue(sut.isHidden)

        adapter.display(bottomImage: imageModel)
        XCTAssertFalse(sut.isHidden)

        adapter.display(bottomImage: nil)
        XCTAssertTrue(sut.isHidden)
    }

    func test_uiKitBottomImage_revealsAndHidesOtherwiseEmptyVerticalField() {
        let sut = VKeyValueFieldView()

        sut.display(model: nil)
        XCTAssertTrue(sut.isHidden)

        sut.display(bottomImage: imageModel)
        XCTAssertFalse(sut.isHidden)

        sut.display(bottomImage: nil)
        XCTAssertTrue(sut.isHidden)
    }

    func test_uiKitBottomImage_revealsAndHidesOtherwiseEmptyHorizontalField() {
        let sut = HKeyValueFieldView()

        sut.display(model: nil)
        XCTAssertTrue(sut.isHidden)

        sut.display(bottomImage: imageModel)
        XCTAssertFalse(sut.isHidden)
        XCTAssertFalse(sut.bottomImageWrapperView.isHidden)
        XCTAssertTrue(sut.bottomImageView.superview === sut.bottomImageWrapperView)

        sut.display(bottomImage: nil)
        XCTAssertTrue(sut.isHidden)
        XCTAssertTrue(sut.bottomImageWrapperView.isHidden)
    }

    func test_uiKitHorizontalField_bottomImageAddsOnlyItsContentHeight() {
        let sut = HKeyValueFieldView(spacing: 6)
        sut.display(model: .init(.text("Key"), .text("Value")))
        let textOnlyHeight = fittingHeight(of: sut)

        sut.display(bottomImage: imageModel)
        let heightWithImage = fittingHeight(of: sut)

        XCTAssertEqual(heightWithImage - textOnlyHeight, 28, accuracy: 0.5)
    }

    func test_swiftUIHorizontalField_bottomImageDefinesIntrinsicHeightWithoutText() {
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        adapter.display(model: nil)
        adapter.display(bottomImage: imageModel)
        let host = UIHostingController(
            rootView: SUIHKeyValueFieldView(adapter: adapter)
                .fixedSize(horizontal: false, vertical: true)
        )
        host.loadViewIfNeeded()

        let size = host.sizeThatFits(in: CGSize(width: 200, height: 1_000))

        XCTAssertEqual(size.height, 22, accuracy: 0.5)
    }

    private func fittingHeight(of view: UIView) -> CGFloat {
        view.systemLayoutSizeFitting(
            CGSize(width: 200, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    private var imageModel: ImageViewPresentableModel {
        .systemSymbol(
            "checkmark.seal.fill",
            size: .init(width: 22, height: 22),
            contentModeIsFit: true
        )
    }
}
#endif
