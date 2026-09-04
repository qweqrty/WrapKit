#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUICircleStrokeSpinTests: XCTestCase {
    func test_animationTimeline_matchesCircleStrokeSpinMilestones() {
        let cycleDuration = CGFloat(SUICircleStrokeSpinAnimation.cycleDuration)

        let initial = SUICircleStrokeSpinAnimation.values(atCycleProgress: 0)
        XCTAssertEqual(initial.strokeStart, 0)
        XCTAssertEqual(initial.strokeEnd, 0)

        let whenStrokeStartBegins = SUICircleStrokeSpinAnimation.values(
            atCycleProgress: CGFloat(SUICircleStrokeSpinAnimation.strokeStartDelay) / cycleDuration
        )
        XCTAssertEqual(whenStrokeStartBegins.strokeStart, 0)
        XCTAssertGreaterThan(whenStrokeStartBegins.strokeEnd, 0)
        XCTAssertLessThan(whenStrokeStartBegins.strokeEnd, 1)

        let whenStrokeEndCompletes = SUICircleStrokeSpinAnimation.values(
            atCycleProgress: CGFloat(SUICircleStrokeSpinAnimation.strokeEndDuration) / cycleDuration
        )
        XCTAssertGreaterThan(whenStrokeEndCompletes.strokeStart, 0)
        XCTAssertEqual(whenStrokeEndCompletes.strokeEnd, 1)

        let completed = SUICircleStrokeSpinAnimation.values(atCycleProgress: 1)
        XCTAssertEqual(completed.strokeStart, 1)
        XCTAssertEqual(completed.strokeEnd, 1)
    }

    func test_animationTimeline_usesUIKitDurationsAndLineWidth() {
        XCTAssertEqual(SUICircleStrokeSpinAnimation.strokeEndDuration, 0.7)
        XCTAssertEqual(SUICircleStrokeSpinAnimation.strokeStartDelay, 0.5)
        XCTAssertEqual(SUICircleStrokeSpinAnimation.strokeStartDuration, 1.2)
        XCTAssertEqual(SUICircleStrokeSpinAnimation.cycleDuration, 1.7)
        XCTAssertEqual(SUICircleStrokeSpin.lineWidth, 2)
    }
}
#endif
