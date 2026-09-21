#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import UIKit
import XCTest

final class SUITitledViewStateModelTests: XCTestCase {
    func test_nilThenContentlessBottomTitlePreservesActionAcrossRemountLikeUIKit() throws {
        final class ActionOwner {}

        let uiKitView = TitledView<UIView>()
        weak var uiKitOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            uiKitOwner = owner
            uiKitView.display(model: .init(bottomTitles: .init(
                .attributes([.init(text: "Retained helper", onTap: { _ = owner })]),
                nil
            )))
        }
        uiKitView.display(model: nil)
        XCTAssertNotNil(uiKitOwner)
        uiKitView.display(model: .init(bottomTitles: .init(.init(model: nil), nil)))
        XCTAssertFalse(uiKitView.closingTitleVFieldView.keyLabel.isHidden)
        XCTAssertNotNil(uiKitOwner)
        uiKitView.display(leadingBottomTitle: .attributes([.init(text: "Replacement")]))
        XCTAssertNil(uiKitOwner)

        let adapter = TitledOutputSwiftUIAdapter()
        var calls = 0
        weak var weakOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            adapter.display(model: .init(bottomTitles: .init(
                .attributes([
                    .init(text: "Retained helper", onTap: {
                        _ = owner
                        calls += 1
                    })
                ]),
                nil
            )))
        }

        adapter.display(model: nil)
        XCTAssertNotNil(weakOwner)
        adapter.display(model: .init(bottomTitles: .init(.init(model: nil), nil)))

        var stateModel: SUITitledViewStateModel? = .init(adapter: adapter)
        var bottomTitlesStateModel: SUIKeyValueFieldViewStateModel? = .init(
            adapter: stateModel!.bottomTitlesAdapter,
            displaysBottomImage: true,
            isHidden: false
        )
        bottomTitlesStateModel = nil
        stateModel = nil

        let remountedStateModel = SUITitledViewStateModel(adapter: adapter)
        let remountedBottomTitlesStateModel = SUIKeyValueFieldViewStateModel(
            adapter: remountedStateModel.bottomTitlesAdapter,
            displaysBottomImage: true,
            isHidden: false
        )
        let action = try XCTUnwrap(firstTapAction(
            in: remountedBottomTitlesStateModel.keyTitleStateModel.presentable.model
        ))
        action()
        XCTAssertEqual(calls, 1)

        adapter.display(leadingBottomTitle: .attributes([.init(text: "Replacement")]))
        XCTAssertNil(weakOwner)
    }

    func test_premountModelAndIncrementalOutputsHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = TitledOutputSwiftUIAdapter()
        modelLastAdapter.display(leadingBottomTitle: .text("Old incremental helper"))
        modelLastAdapter.display(isUserInteractionEnabled: false)
        modelLastAdapter.display(isHidden: true)
        modelLastAdapter.display(model: .init(
            bottomTitles: .init(.text("Latest model helper"), nil),
            isUserInteractionEnabled: true
        ))

        let incrementalLastAdapter = TitledOutputSwiftUIAdapter()
        incrementalLastAdapter.display(model: .init(
            bottomTitles: .init(.text("Old model helper"), nil),
            isUserInteractionEnabled: true
        ))
        incrementalLastAdapter.display(leadingBottomTitle: .text("Latest incremental helper"))
        incrementalLastAdapter.display(isUserInteractionEnabled: false)
        incrementalLastAdapter.display(isHidden: true)

        let modelLast = SUITitledViewStateModel(adapter: modelLastAdapter)
        let incrementalLast = SUITitledViewStateModel(adapter: incrementalLastAdapter)

        assertTitles(
            in: modelLast.bottomTitlesAdapter,
            key: "Latest model helper",
            value: nil
        )
        XCTAssertTrue(modelLast.isUserInteractionEnabled)
        XCTAssertFalse(modelLast.isHidden)
        assertTitles(
            in: incrementalLast.bottomTitlesAdapter,
            key: "Latest incremental helper",
            value: nil
        )
        XCTAssertFalse(incrementalLast.isUserInteractionEnabled)
        XCTAssertTrue(incrementalLast.isHidden)
    }

    func test_modelMatchesUIKitVisibilityAndInteractionSemantics() {
        let adapter = TitledOutputSwiftUIAdapter()
        let sut = SUITitledViewStateModel(adapter: adapter)

        adapter.display(model: .init(
            titles: .init(.text("Title"), .text("Value")),
            bottomTitles: .init(.text("Helper"), .text("12/40")),
            isUserInteractionEnabled: false
        ))

        XCTAssertFalse(sut.isHidden)
        XCTAssertFalse(sut.isUserInteractionEnabled)
        assertTitles(
            in: sut.titlesAdapter,
            key: "Title",
            value: "Value"
        )
        assertTitles(
            in: sut.bottomTitlesAdapter,
            key: "Helper",
            value: "12/40"
        )

        adapter.display(model: nil)

        XCTAssertTrue(sut.isHidden)
        assertTitles(in: sut.titlesAdapter, key: nil, value: nil)
        assertTitles(in: sut.bottomTitlesAdapter, key: nil, value: nil)
    }

    func test_incrementalBottomTitleUpdatesPreserveTheOtherSlot() {
        let adapter = TitledOutputSwiftUIAdapter()
        let sut = SUITitledViewStateModel(adapter: adapter)

        adapter.display(bottomTitles: .init(.text("Helper"), .text("12/40")))
        adapter.display(leadingBottomTitle: .text("Validation error"))

        assertTitles(
            in: sut.bottomTitlesAdapter,
            key: "Validation error",
            value: "12/40"
        )

        adapter.display(trailingBottomTitle: nil)

        assertTitles(
            in: sut.bottomTitlesAdapter,
            key: "Validation error",
            value: nil
        )
    }

    func test_explicitVisibilityAndInteractionOutputsOverrideCurrentModel() {
        let adapter = TitledOutputSwiftUIAdapter()
        let sut = SUITitledViewStateModel(adapter: adapter)
        adapter.display(model: .init(isUserInteractionEnabled: true))

        adapter.display(isHidden: true)
        adapter.display(isUserInteractionEnabled: false)

        XCTAssertTrue(sut.isHidden)
        XCTAssertFalse(sut.isUserInteractionEnabled)
    }

    private func assertTitles(
        in adapter: KeyValueFieldViewOutputSwiftUIAdapter,
        key: String?,
        value: String?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let stateModel = SUIKeyValueFieldViewStateModel(
            adapter: adapter,
            displaysBottomImage: true,
            isHidden: false
        )

        XCTAssertEqual(stateModel.keyTitle?.plainText, key, file: file, line: line)
        XCTAssertEqual(stateModel.valueTitle?.plainText, value, file: file, line: line)
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

private extension TextOutputPresentableModel {
    var plainText: String? {
        guard case let .text(value) = model else { return nil }
        return value
    }
}
#endif
