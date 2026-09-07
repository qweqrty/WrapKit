//
//  SUIShimmerView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/4/26.
//

import SwiftUI

public struct SUIShimmerView: View {
    @Environment(\.self) private var environment
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    let style: ShimmerStyle?

    @State private var horizontalProgress: CGFloat = -1

    public init(style: ShimmerStyle? = nil) {
        self.style = style
    }
    
    public var body: some View {
        let colorOne = style.map { SwiftUIColor($0.gradientColorOne) } ?? SwiftUIColor(.clear)
        let colorTwo = style.map { SwiftUIColor($0.gradientColorTwo) }
            ?? SwiftUIColor(.sRGB, white: 0.95, opacity: 0.6)
        let cornerRadius = style?.cornerRadius ?? 0
        let backgroundColor = style.map { SwiftUIColor($0.backgroundColor) } ?? SwiftUIColor(.clear)
        
        GeometryReader { geometry in
            ZStack {
                backgroundColor

                gradient(colors: [colorOne, colorTwo, colorOne])
                    .offset(
                        x: accessibilityReduceMotion
                            ? 0
                            : horizontalProgress * geometry.size.width
                    )
            }
        }
        .cornerRadius(cornerRadius)
        .task(id: accessibilityReduceMotion) {
            await animateShimmer()
        }
    }

    @MainActor
    private func animateShimmer() async {
        guard !accessibilityReduceMotion else {
            setHorizontalProgress(0)
            return
        }

        while !Task.isCancelled {
            setHorizontalProgress(-1)
            await Task.yield()

            guard !Task.isCancelled else { return }
            withAnimation(.linear(duration: ShimmerAnimationTiming.sweepDuration)) {
                horizontalProgress = 1
            }

            do {
                try await Task.sleep(
                    nanoseconds: ShimmerAnimationTiming.cycleDurationNanoseconds
                )
            } catch {
                return
            }
        }
    }

    private func setHorizontalProgress(_ progress: CGFloat) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            horizontalProgress = progress
        }
    }

    @ViewBuilder
    private func gradient(colors: [SwiftUIColor]) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            if colors.contains(where: { $0.resolve(in: environment).opacity < 1 }) {
                LinearGradient(
                    stops: unpremultipliedStops(colors: colors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        } else {
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private func unpremultipliedStops(colors: [SwiftUIColor]) -> [Gradient.Stop] {
        guard colors.count > 1 else {
            return colors.map { .init(color: $0, location: 0) }
        }

        // SwiftUI interpolates translucent gradient colors after premultiplying alpha,
        // while CAGradientLayer interpolates the color and alpha components independently.
        // Sample that curve explicitly so `.clear` edge colors keep UIKit's visible sweep.
        let resolvedColors = colors.map { $0.resolve(in: environment) }
        let samplesPerSegment = 16
        let segmentCount = resolvedColors.count - 1
        var stops: [Gradient.Stop] = []

        for segment in 0..<segmentCount {
            let firstStep = segment == 0 ? 0 : 1
            for step in firstStep...samplesPerSegment {
                let progress = Float(step) / Float(samplesPerSegment)
                let location = (
                    CGFloat(segment) + CGFloat(progress)
                ) / CGFloat(segmentCount)
                stops.append(.init(
                    color: interpolatedColor(
                        from: resolvedColors[segment],
                        to: resolvedColors[segment + 1],
                        progress: progress
                    ),
                    location: location
                ))
            }
        }
        return stops
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private func interpolatedColor(
        from start: SwiftUIColor.Resolved,
        to end: SwiftUIColor.Resolved,
        progress: Float
    ) -> SwiftUIColor {
        func interpolate(_ start: Float, _ end: Float) -> Float {
            start + (end - start) * progress
        }

        return SwiftUIColor(.init(
            colorSpace: .sRGB,
            red: interpolate(start.red, end.red),
            green: interpolate(start.green, end.green),
            blue: interpolate(start.blue, end.blue),
            opacity: interpolate(start.opacity, end.opacity)
        ))
    }
}

private enum ShimmerAnimationTiming {
    static let sweepDuration: TimeInterval = 1.4
    static let holdDuration: TimeInterval = 2.8
    static let cycleDurationNanoseconds = UInt64(
        (sweepDuration + holdDuration) * 1_000_000_000
    )
}
