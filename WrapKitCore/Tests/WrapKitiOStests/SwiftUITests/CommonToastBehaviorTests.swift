import XCTest
@testable import WrapKit

#if canImport(UIKit)
import UIKit

final class CommonToastBehaviorTests: XCTestCase {
    func test_regularToast_usesSemanticSymbolInBothImplementations() {
        let uiKitSUT = ToastView(duration: nil, position: .top)
        let swiftUIAdapter = CommonToastOutputSwiftUIAdapter()
        let swiftUISUT = SUIToastViewStateModel(adapter: swiftUIAdapter)
        let toast = CommonToast.success(.init(
            keyTitle: "Saved",
            position: .top,
            duration: nil
        ))

        uiKitSUT.display(toast)
        swiftUIAdapter.display(toast)

        XCTAssertEqual(
            uiKitSUT.cardView.leadingImageView.currentImageEnum,
            .symbolName("checkmark.circle.fill")
        )
        XCTAssertEqual(
            swiftUISUT.currentCardModel?.leadingImage?.image,
            .symbolName("checkmark.circle.fill")
        )
    }

    func test_uikitToast_forwardsToastOnPressToRenderedCard() {
        var pressCount = 0
        let sut = ToastView(duration: nil, position: .top)

        sut.display(.success(.init(
            cardViewModel: .init(title: .text("Saved")),
            position: .top,
            onPress: { pressCount += 1 }
        )))
        sut.cardView.onPress?()

        XCTAssertEqual(pressCount, 1)
        XCTAssertTrue(sut.cardView.isUserInteractionEnabled)
    }

    func test_swiftUIToast_forwardsToastOnPressToRenderedCardAdapter() {
        var pressCount = 0
        let adapter = CommonToastOutputSwiftUIAdapter()
        let sut = SUIToastViewStateModel(adapter: adapter)

        adapter.display(.warning(.init(
            cardViewModel: .init(title: .text("Review required")),
            position: .top,
            onPress: { pressCount += 1 }
        )))
        sut.cardAdapter.displayOnPressState?.onPress?()

        XCTAssertEqual(pressCount, 1)
        XCTAssertEqual(
            sut.cardAdapter.displayIsUserInteractionEnabledState?.isUserInteractionEnabled,
            true
        )
    }

    func test_customButtons_renderAndForwardActionsInBothImplementations() {
        var uiKitPressCount = 0
        var swiftUIPressCount = 0
        let uiKitSUT = ToastView(duration: nil, position: .top)
        let swiftUIAdapter = CommonToastOutputSwiftUIAdapter()
        let swiftUISUT = SUIToastViewStateModel(adapter: swiftUIAdapter)

        uiKitSUT.display(.custom(.init(
            common: .init(cardViewModel: .init(title: .text("Update ready")), position: .top),
            buttons: [.init(title: "Install", onPress: { uiKitPressCount += 1 })]
        )))
        swiftUIAdapter.display(.custom(.init(
            common: .init(cardViewModel: .init(title: .text("Update ready")), position: .top),
            buttons: [.init(title: "Install", onPress: { swiftUIPressCount += 1 })]
        )))

        uiKitSUT.customActionButtons.first?.onPress?()
        swiftUISUT.actionButtonModel(at: 0)?.onPress?()

        XCTAssertEqual(uiKitSUT.customActionButtons.count, 1)
        XCTAssertEqual(swiftUISUT.currentButtons.count, 1)
        XCTAssertEqual(uiKitPressCount, 1)
        XCTAssertEqual(swiftUIPressCount, 1)
    }

    func test_swiftUIToast_queuesModelsAndAdvancesAfterHide() {
        let adapter = CommonToastOutputSwiftUIAdapter()
        let sut = SUIToastViewStateModel(adapter: adapter)

        adapter.display(.success(.init(
            keyTitle: "First",
            position: .top,
            duration: nil
        )))
        adapter.display(.warning(.init(
            keyTitle: "Second",
            position: .bottom(additionalBottomPadding: 24),
            duration: nil
        )))

        XCTAssertEqual(sut.currentCardModel?.title?.plainText, "First")
        XCTAssertEqual(sut.currentItem?.position, .top)

        adapter.hide()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))

        XCTAssertEqual(sut.currentCardModel?.title?.plainText, "Second")
        XCTAssertEqual(sut.currentItem?.position, .bottom(additionalBottomPadding: 24))
    }

    func test_swiftUIToast_replaysPremountCommandsInFIFOOrder() {
        let adapter = CommonToastOutputSwiftUIAdapter()

        adapter.display(.success(.init(
            keyTitle: "First",
            position: .top,
            duration: nil
        )))
        adapter.display(.warning(.init(
            keyTitle: "Second",
            position: .bottom(),
            duration: nil
        )))

        let sut = SUIToastViewStateModel(adapter: adapter)

        XCTAssertEqual(sut.currentCardModel?.title?.plainText, "First")
        adapter.hide()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        XCTAssertEqual(sut.currentCardModel?.title?.plainText, "Second")
    }

    func test_swiftUIToast_regularModelClearsCustomOnlyConfiguration() {
        let adapter = CommonToastOutputSwiftUIAdapter()
        let sut = SUIToastViewStateModel(adapter: adapter)

        adapter.display(.custom(.init(
            common: .init(
                keyTitle: "Custom",
                position: .top,
                duration: nil
            ),
            backgroundColor: .systemPurple,
            buttons: [.init(title: "Details")]
        )))
        XCTAssertEqual(sut.currentButtons.count, 1)

        adapter.hide()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        adapter.display(.error(.init(
            keyTitle: "Regular",
            position: .top,
            duration: nil
        )))

        XCTAssertTrue(sut.currentButtons.isEmpty)
        XCTAssertTrue(sut.actionBackgroundColor.isEqual(UIColor.clear))
        XCTAssertEqual(sut.currentCardModel?.title?.plainText, "Regular")
    }
}

private extension TextOutputPresentableModel {
    var plainText: String? {
        guard case let .text(value) = model else { return nil }
        return value
    }
}
#endif
