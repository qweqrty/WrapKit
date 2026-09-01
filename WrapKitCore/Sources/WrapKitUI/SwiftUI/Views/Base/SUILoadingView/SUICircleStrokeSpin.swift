//
//  SUICircleStrokeSpin.swift
//  WrapKit
//

import SwiftUI

enum SUICircleStrokeSpinPhase {
    case animated
    case fixed(strokeStart: CGFloat, strokeEnd: CGFloat, rotation: Angle)
}

struct SUICircleStrokeSpin: View {
    static let lineWidth: CGFloat = 2

    @State private var isAnimating = false

    let color: SwiftUIColor
    let size: CGSize
    let phase: SUICircleStrokeSpinPhase

    init(
        color: SwiftUIColor,
        size: CGSize,
        phase: SUICircleStrokeSpinPhase = .animated
    ) {
        self.color = color
        self.size = size
        self.phase = phase
    }

    var body: some View {
        indicator
            .frame(width: size.width, height: size.height)
            .onAppear {
                guard case .animated = phase else { return }
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
    }

    @ViewBuilder
    private var indicator: some View {
        switch phase {
        case .animated:
            SUICircleStrokeSpinShape(cycleProgress: isAnimating ? 1 : 0)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: SUICircleStrokeSpinAnimation.cycleDuration)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        case .fixed(let strokeStart, let strokeEnd, let rotation):
            Circle()
                .trim(from: strokeStart, to: strokeEnd)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .butt)
                )
                .rotationEffect(rotation)
        }
    }
}

struct SUICircleStrokeSpinAnimation {
    static let cycleDuration: TimeInterval = 1.7
    static let strokeEndDuration: TimeInterval = 0.7
    static let strokeStartDelay: TimeInterval = 0.5
    static let strokeStartDuration: TimeInterval = 1.2

    struct Values: Equatable {
        let strokeStart: CGFloat
        let strokeEnd: CGFloat
    }

    static func values(atCycleProgress cycleProgress: CGFloat) -> Values {
        let elapsedTime = clamped(cycleProgress) * CGFloat(cycleDuration)
        let strokeEndProgress = clamped(elapsedTime / CGFloat(strokeEndDuration))
        let strokeStartProgress = clamped(
            (elapsedTime - CGFloat(strokeStartDelay)) / CGFloat(strokeStartDuration)
        )

        return Values(
            strokeStart: mediaTimingCurveValue(at: strokeStartProgress),
            strokeEnd: mediaTimingCurveValue(at: strokeEndProgress)
        )
    }

    private static func mediaTimingCurveValue(at progress: CGFloat) -> CGFloat {
        let progress = clamped(progress)
        guard progress > 0, progress < 1 else { return progress }

        var lowerBound: CGFloat = 0
        var upperBound: CGFloat = 1

        for _ in 0..<16 {
            let parameter = (lowerBound + upperBound) / 2
            let curveProgress = cubicBezierValue(
                at: parameter,
                firstControlPoint: 0.4,
                secondControlPoint: 0.2
            )

            if curveProgress < progress {
                lowerBound = parameter
            } else {
                upperBound = parameter
            }
        }

        return cubicBezierValue(
            at: (lowerBound + upperBound) / 2,
            firstControlPoint: 0,
            secondControlPoint: 1
        )
    }

    private static func cubicBezierValue(
        at parameter: CGFloat,
        firstControlPoint: CGFloat,
        secondControlPoint: CGFloat
    ) -> CGFloat {
        let inverse = 1 - parameter
        return 3 * inverse * inverse * parameter * firstControlPoint
            + 3 * inverse * parameter * parameter * secondControlPoint
            + parameter * parameter * parameter
    }

    private static func clamped(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }
}

private struct SUICircleStrokeSpinShape: Shape {
    var cycleProgress: CGFloat

    var animatableData: CGFloat {
        get { cycleProgress }
        set { cycleProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let values = SUICircleStrokeSpinAnimation.values(atCycleProgress: cycleProgress)
        return Circle()
            .path(in: rect)
            .trimmedPath(from: values.strokeStart, to: values.strokeEnd)
    }
}
