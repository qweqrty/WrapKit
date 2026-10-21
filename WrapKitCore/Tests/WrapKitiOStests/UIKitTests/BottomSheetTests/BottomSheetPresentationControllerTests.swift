import UIKit
@testable import WrapKit
import XCTest

final class BottomSheetPresentationControllerTests: XCTestCase {
    func test_completedTapDismissal_notifiesOnlyTapCallback() {
        let sut = makeSUT()
        var tapCount = 0
        var panCount = 0
        sut.onTapOutside = { tapCount += 1 }
        sut.onPanToDismiss = { panCount += 1 }

        sut.beginDismissal(reason: .tapOutside)
        sut.dismissalTransitionDidEnd(true)

        XCTAssertEqual(tapCount, 1)
        XCTAssertEqual(panCount, 0)
    }

    func test_completedPanDismissal_notifiesOnlyPanCallback() {
        let sut = makeSUT()
        var tapCount = 0
        var panCount = 0
        sut.onTapOutside = { tapCount += 1 }
        sut.onPanToDismiss = { panCount += 1 }

        sut.beginDismissal(reason: .panToDismiss)
        sut.dismissalTransitionDidEnd(true)

        XCTAssertEqual(tapCount, 0)
        XCTAssertEqual(panCount, 1)
    }

    func test_cancelledDismissal_clearsPendingReasonWithoutCallback() {
        let sut = makeSUT()
        var callbackCount = 0
        sut.onTapOutside = { callbackCount += 1 }

        sut.beginDismissal(reason: .tapOutside)
        sut.dismissalTransitionDidEnd(false)
        sut.dismissalTransitionDidEnd(true)

        XCTAssertEqual(callbackCount, 0)
    }

    func test_programmaticDismissal_doesNotNotifyInteractionCallbacks() {
        let sut = makeSUT()
        var callbackCount = 0
        sut.onTapOutside = { callbackCount += 1 }
        sut.onPanToDismiss = { callbackCount += 1 }

        sut.dismissalTransitionDidEnd(true)

        XCTAssertEqual(callbackCount, 0)
    }

    func test_secondDismissTrigger_doesNotReplaceFirstInteractionReason() {
        let sut = makeSUT()
        var tapCount = 0
        var panCount = 0
        sut.onTapOutside = { tapCount += 1 }
        sut.onPanToDismiss = { panCount += 1 }

        XCTAssertTrue(sut.beginDismissal(reason: .panToDismiss))
        XCTAssertFalse(sut.beginDismissal(reason: .tapOutside))
        sut.dismissalTransitionDidEnd(true)

        XCTAssertEqual(tapCount, 0)
        XCTAssertEqual(panCount, 1)
    }

    func test_updateBackdropMask_cutsOutHighlightedSourceContainer() throws {
        let presentingViewController = UIViewController()
        presentingViewController.loadViewIfNeeded()
        presentingViewController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        let sourceContainer = UIView(frame: CGRect(x: 24, y: 80, width: 64, height: 48))
        sourceContainer.layer.cornerRadius = 12
        let sourceView = UIView(frame: CGRect(x: 20, y: 12, width: 24, height: 24))
        sourceView.accessibilityIdentifier = "source"
        sourceContainer.addSubview(sourceView)
        presentingViewController.view.addSubview(sourceContainer)

        let sut = makeSUT(presentingViewController: presentingViewController)
        sut.highlightedSourceViewIdentifier = "source"
        sut.backdropView.frame = presentingViewController.view.bounds
        presentingViewController.view.addSubview(sut.backdropView)

        sut.updateBackdropMask()

        let mask = try XCTUnwrap(sut.backdropView.layer.mask as? CAShapeLayer)
        let path = try XCTUnwrap(mask.path)
        XCTAssertEqual(mask.fillRule, .evenOdd)
        XCTAssertTrue(path.contains(CGPoint(x: 10, y: 10), using: .evenOdd))
        XCTAssertFalse(path.contains(CGPoint(x: 56, y: 104), using: .evenOdd))
    }

    func test_updateBackdropMask_withoutMatchingSource_removesPreviousMask() {
        let sut = makeSUT()
        sut.backdropView.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        sut.backdropView.layer.mask = CALayer()
        sut.highlightedSourceViewIdentifier = "missing"

        sut.updateBackdropMask()

        XCTAssertNil(sut.backdropView.layer.mask)
    }

    func test_transitioningDelegate_propagatesDismissalAndHighlightConfiguration() throws {
        let delegate = BottomSheetTransitioningDelegate(
            preferredSheetTopInset: 24,
            preferredSheetLeftInset: 0,
            preferredSheetRightInset: 0,
            preferredSheetBottomInset: 0,
            preferredSheetCornerRadius: 12,
            preferredSheetSizingFactor: 0.5,
            preferredSheetBackdropColor: .black
        )
        var tapCount = 0
        delegate.tapToDismissEnabled = false
        delegate.panToDismissEnabled = false
        delegate.highlightedSourceViewIdentifier = "source"
        delegate.onTapOutside = { tapCount += 1 }

        let presentingViewController = UIViewController()
        let presentationController = try XCTUnwrap(delegate.presentationController(
            forPresented: UIViewController(),
            presenting: presentingViewController,
            source: presentingViewController
        ) as? BottomSheetPresentationController)

        XCTAssertFalse(presentationController.tapGestureRecognizer.isEnabled)
        XCTAssertFalse(presentationController.panToDismissEnabled)
        XCTAssertEqual(presentationController.highlightedSourceViewIdentifier, "source")
        presentationController.beginDismissal(reason: .tapOutside)
        presentationController.dismissalTransitionDidEnd(true)
        XCTAssertEqual(tapCount, 1)
    }

    private func makeSUT(
        presentingViewController: UIViewController = UIViewController()
    ) -> BottomSheetPresentationController {
        BottomSheetPresentationController(
            presentedViewController: UIViewController(),
            presenting: presentingViewController,
            containerMargins: .zero,
            sheetCornerRadius: 12,
            sheetSizingFactor: 0.5,
            sheetBackdropColor: .black
        )
    }
}
