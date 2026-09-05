//
//  SUIShimmerView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/4/26.
//

import SwiftUI

enum SUIShimmerPhase {
    case animated
    case fixed(horizontalOffset: CGFloat)
}

public struct SUIShimmerView: View {
    @Environment(\.self) private var environment

    let style: ShimmerStyle?
    let phase: SUIShimmerPhase

    @State private var isAnimating = false

    public init(style: ShimmerStyle? = nil) {
        self.style = style
        self.phase = .animated
    }

    init(
        style: ShimmerStyle? = nil,
        phase: SUIShimmerPhase
    ) {
        self.style = style
        self.phase = phase
    }
    
    public var body: some View {
        let colorOne = style.map { SwiftUIColor($0.gradientColorOne) } ?? SwiftUIColor(.clear)
        let colorTwo = style.map { SwiftUIColor($0.gradientColorTwo) }
            ?? SwiftUIColor(.sRGB, white: 0.95, opacity: 0.6)
        let cornerRadius = style?.cornerRadius ?? 0
        let backgroundColor = style.map { SwiftUIColor($0.backgroundColor) } ?? SwiftUIColor(.clear)
        
        ZStack {
            backgroundColor

            shimmerGradient(colors: [colorOne, colorTwo, colorOne])
        }
        .cornerRadius(cornerRadius)
        .onAppear {
            guard case .animated = phase else { return }
            isAnimating = true
        }
        .onDisappear { isAnimating = false }
    }

    @ViewBuilder
    private func shimmerGradient(colors: [SwiftUIColor]) -> some View {
        switch phase {
        case .animated:
            gradient(colors: colors)
                .offset(x: isAnimating ? 400 : -400)
                .animation(
                    SwiftUI.Animation.linear(duration: 1.4)
                        .delay(0)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        case .fixed(let horizontalOffset):
            gradient(colors: colors)
                .offset(x: horizontalOffset)
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
