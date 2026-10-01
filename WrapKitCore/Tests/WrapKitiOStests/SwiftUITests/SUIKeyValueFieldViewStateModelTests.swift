#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SUIKeyValueFieldViewStateModelTests: XCTestCase {
    func test_nilThenContentlessModelPreservesKeyActionAcrossRemountLikeUIKit() throws {
        final class ActionOwner {}

        let uiKitView = HKeyValueFieldView()
        weak var uiKitOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            uiKitOwner = owner
            uiKitView.display(model: .init(
                .attributes([.init(text: "Retained key", onTap: { _ = owner })]),
                nil
            ))
        }
        uiKitView.display(model: nil)
        XCTAssertNotNil(uiKitOwner)
        uiKitView.display(model: .init(.init(model: nil), nil))
        XCTAssertFalse(uiKitView.isHidden)
        XCTAssertNotNil(uiKitOwner)
        uiKitView.display(keyTitle: .attributes([.init(text: "Replacement")]))
        XCTAssertNil(uiKitOwner)

        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        var calls = 0
        weak var weakOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            adapter.display(model: .init(
                .attributes([
                    .init(text: "Retained key", onTap: {
                        _ = owner
                        calls += 1
                    })
                ]),
                nil
            ))
        }

        adapter.display(model: nil)
        XCTAssertNotNil(weakOwner)
        adapter.display(model: .init(.init(model: nil), nil))

        var sut: SUIKeyValueFieldViewStateModel? = makeSUT(adapter: adapter)
        sut = nil
        let remountedSUT = makeSUT(adapter: adapter)

        let action = try XCTUnwrap(firstTapAction(
            in: remountedSUT.keyTitleStateModel.presentable.model
        ))
        action()
        XCTAssertEqual(calls, 1)

        adapter.display(keyTitle: .attributes([.init(text: "Replacement")]))
        XCTAssertNil(weakOwner)
    }

    func test_keyAnimationCompletionSurvivesPlainReplacementAndStateModelRemount() {
        let completion = expectation(description: "Key animation completes")
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        var sut: SUIKeyValueFieldViewStateModel? = makeSUT(adapter: adapter)

        adapter.display(keyTitle: .init(model: .animatedDecimal(
            from: 0,
            to: 1,
            mapToString: { .text($0.asString()) },
            animationStyle: .none,
            duration: 0.05,
            completion: { completion.fulfill() }
        )))
        adapter.display(keyTitle: .text("Replacement"))

        sut = nil
        let remountedSUT = makeSUT(adapter: adapter)

        wait(for: [completion], timeout: 0.5)
        XCTAssertEqual(remountedSUT.keyTitle?.model?.text, "Replacement")
        XCTAssertEqual(remountedSUT.keyTitleStateModel.presentable.model?.text, "1")
    }

    func test_freshStateWithGranularTitle_preservesUntouchedSlotLikeUIKit() {
        let keyAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
        let keySUT = makeSUT(adapter: keyAdapter)
        let valueAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
        let valueSUT = makeSUT(adapter: valueAdapter)

        keyAdapter.display(keyTitle: .text("Key"))
        valueAdapter.display(valueTitle: .text("Value"))

        XCTAssertFalse(keySUT.isKeySlotHidden)
        XCTAssertFalse(keySUT.isValueSlotHidden)
        XCTAssertTrue(keySUT.isBottomImageSlotHidden)
        XCTAssertFalse(keySUT.isHidden)
        XCTAssertFalse(valueSUT.isKeySlotHidden)
        XCTAssertFalse(valueSUT.isValueSlotHidden)
        XCTAssertTrue(valueSUT.isBottomImageSlotHidden)
        XCTAssertFalse(valueSUT.isHidden)
    }

    func test_premountFullModelAndGranularTitlesHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
        modelLastAdapter.display(keyTitle: .text("Old granular key"))
        modelLastAdapter.display(valueTitle: .text("Old granular value"))
        modelLastAdapter.display(model: .init(
            .text("Latest model key"),
            .text("Latest model value")
        ))

        let granularLastAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
        granularLastAdapter.display(model: .init(
            .text("Old model key"),
            .text("Old model value")
        ))
        granularLastAdapter.display(keyTitle: .text("Latest granular key"))
        granularLastAdapter.display(valueTitle: .text("Latest granular value"))

        let modelLast = makeSUT(adapter: modelLastAdapter)
        let granularLast = makeSUT(adapter: granularLastAdapter)

        XCTAssertEqual(modelLast.keyTitle?.model?.text, "Latest model key")
        XCTAssertEqual(modelLast.valueTitle?.model?.text, "Latest model value")
        XCTAssertEqual(granularLast.keyTitle?.model?.text, "Latest granular key")
        XCTAssertEqual(granularLast.valueTitle?.model?.text, "Latest granular value")
    }

    func test_premountNilModelClearsTitlesAndPreservesBottomImage() {
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        adapter.display(keyTitle: .text("Key"))
        adapter.display(valueTitle: .text("Value"))
        adapter.display(bottomImage: imageModel)
        adapter.display(model: nil)

        let sut = makeSUT(adapter: adapter)

        XCTAssertNil(sut.keyTitle)
        XCTAssertNil(sut.valueTitle)
        XCTAssertNotNil(sut.bottomImage)
        XCTAssertTrue(sut.isKeySlotHidden)
        XCTAssertTrue(sut.isValueSlotHidden)
        XCTAssertFalse(sut.isBottomImageSlotHidden)
        XCTAssertFalse(sut.isHidden)
    }

    func test_bottomImage_revealsAndHidesOtherwiseEmptyVerticalField() {
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        let sut = makeSUT(adapter: adapter)

        adapter.display(model: nil)
        XCTAssertTrue(sut.isHidden)

        adapter.display(bottomImage: imageModel)
        XCTAssertFalse(sut.isHidden)

        adapter.display(bottomImage: nil)
        XCTAssertTrue(sut.isHidden)
    }

    func test_eachContentSlotIndependentlyControlsVisibility() {
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        let sut = makeSUT(adapter: adapter)
        adapter.display(model: nil)
        XCTAssertTrue(sut.isHidden)

        adapter.display(keyTitle: .text("Key"))
        XCTAssertFalse(sut.isHidden)
        adapter.display(keyTitle: nil)
        XCTAssertTrue(sut.isHidden)

        adapter.display(valueTitle: .text("Value"))
        XCTAssertFalse(sut.isHidden)
        adapter.display(valueTitle: nil)
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

    func test_swiftUIHorizontalField_emptyTextAndAttributesMatchUIKitAcrossRemount() {
        let model = Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>(
            .text(""),
            .attributes([])
        )
        let uiKitSUT = HKeyValueFieldView(
            contentInsets: .init(top: 8, left: 8, bottom: 8, right: 8)
        )
        uiKitSUT.display(model: model)

        XCTAssertTrue(uiKitSUT.isHidden)

        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        adapter.display(model: model)

        XCTAssertEqual(swiftUIHorizontalFieldSize(adapter: adapter), .zero)
        XCTAssertEqual(swiftUIHorizontalFieldSize(adapter: adapter), .zero)
    }

    private func fittingHeight(of view: UIView) -> CGFloat {
        view.systemLayoutSizeFitting(
            CGSize(width: 200, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    private func swiftUIHorizontalFieldSize(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter
    ) -> CGSize {
        let host = UIHostingController(
            rootView: SUIHKeyValueFieldView(
                adapter: adapter,
                contentInsets: .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            )
            .fixedSize(horizontal: false, vertical: true)
        )
        host.loadViewIfNeeded()
        return host.sizeThatFits(in: CGSize(width: 200, height: 1_000))
    }

    private var imageModel: ImageViewPresentableModel {
        .systemSymbol(
            "checkmark.seal.fill",
            size: .init(width: 22, height: 22),
            contentModeIsFit: true
        )
    }

    private func makeSUT(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter
    ) -> SUIKeyValueFieldViewStateModel {
        SUIKeyValueFieldViewStateModel(
            adapter: adapter,
            displaysBottomImage: true,
            isHidden: false
        )
    }
}

private func firstTapAction(
    in model: TextOutputPresentableModel.TextModel?,
    file: StaticString = #filePath,
    line: UInt = #line
) -> (() -> Void)? {
    guard case let .attributes(attributes)? = model else {
        XCTFail("Expected text attributes", file: file, line: line)
        return nil
    }
    return attributes.first?.onTap
}
#endif
