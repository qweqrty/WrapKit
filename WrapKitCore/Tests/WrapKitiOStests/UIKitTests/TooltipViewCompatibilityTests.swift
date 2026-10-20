#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
import WrapKit
import XCTest

@MainActor
final class TooltipViewCompatibilityTests: XCTestCase {
    func test_tapTooltip_enablesLabelInteractionWithoutReplacingExistingGestures() {
        let label = Label()
        let existingGesture = UIPanGestureRecognizer()
        label.addGestureRecognizer(existingGesture)
        let originalTapCount = label.gestureRecognizers?.filter { $0 is UITapGestureRecognizer }.count ?? 0

        label.display(tooltipModel: .init(items: [.init(title: "Copy", onTap: {})], trigger: .tap))

        XCTAssertTrue(label.isUserInteractionEnabled)
        XCTAssertTrue(label.gestureRecognizers?.contains(existingGesture) == true)
        XCTAssertEqual(label.gestureRecognizers?.filter { $0 is UITapGestureRecognizer }.count, originalTapCount + 1)
    }

    func test_replacingTrigger_removesOnlyPreviousTooltipGesture() {
        let view = UIView()
        let existingGesture = UIPanGestureRecognizer()
        view.addGestureRecognizer(existingGesture)
        view.display(tooltipModel: .init(items: [.init(title: "Copy", onTap: {})], trigger: .tap))

        view.display(tooltipModel: .init(
            items: [.init(title: "Copy", onTap: {})], trigger: .longPress(minimumPressDuration: 0.8)
        ))

        XCTAssertTrue(view.gestureRecognizers?.contains(existingGesture) == true)
        XCTAssertFalse(view.gestureRecognizers?.contains { $0 is UITapGestureRecognizer } == true)
        let longPress = view.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }
        XCTAssertEqual(longPress?.count, 1)
        XCTAssertEqual(longPress?.first?.minimumPressDuration, 0.8)
    }

    func test_nilModel_removesTooltipGestureAndReleasesCallbacksWithoutDismissCallback() {
        let view = UIView()
        let existingGesture = UIPanGestureRecognizer()
        view.addGestureRecognizer(existingGesture)
        var dismissCount = 0
        var capture: CallbackCapture? = CallbackCapture()
        weak var weakCapture = capture
        view.display(tooltipModel: .init(
            items: [.init(title: "Copy", onTap: { [capture] in _ = capture })],
            onDismiss: { dismissCount += 1 }
        ))
        capture = nil
        XCTAssertNotNil(weakCapture)

        view.display(tooltipModel: nil)

        XCTAssertEqual(view.gestureRecognizers?.count, 1)
        XCTAssertTrue(view.gestureRecognizers?.contains(existingGesture) == true)
        XCTAssertNil(weakCapture)
        XCTAssertEqual(dismissCount, 0)
    }

    func test_removingAnchor_releasesTooltipCallbacks() {
        var view: UIView? = UIView()
        var capture: CallbackCapture? = CallbackCapture()
        weak var weakCapture = capture
        view?.display(tooltipModel: .init(items: [.init(title: "Copy", onTap: { [capture] in _ = capture })]))
        capture = nil
        XCTAssertNotNil(weakCapture)

        view = nil

        XCTAssertNil(weakCapture)
    }

    private final class CallbackCapture {}
}
#endif
