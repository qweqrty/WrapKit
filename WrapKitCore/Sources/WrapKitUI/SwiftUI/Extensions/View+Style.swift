//
//  View+CornerStyle.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func cornerStyle(_ style: CornerStyle) -> some View {
        switch style {
        case .none:
            self
        default:
            self.clipShape(SUICornerShape(style: style))
        }
    }

    @ViewBuilder
    func wrapKitGlassButtonStyle(
        _ configuration: ButtonStyle.GlassConfiguration,
        tint: SwiftUIColor? = nil,
        cornerStyle: CornerStyle = .automatic
    ) -> some View {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *), isLiquidGlassEnabled {
            switch configuration {
            case .glass:
                self
                    .buttonBorderShape(cornerStyle.buttonBorderShape)
                    .buttonStyle(.glass)
                    .tint(tint)
            case .prominentGlass:
                self
                    .buttonBorderShape(cornerStyle.buttonBorderShape)
                    .buttonStyle(.glassProminent)
                    .tint(tint)
            case .clearGlass:
                if #available(iOS 26.1, macOS 26.1, tvOS 26.1, watchOS 26.1, *) {
                    self
                        .buttonBorderShape(cornerStyle.buttonBorderShape)
                        .buttonStyle(.glass(.clear))
                        .tint(tint)
                } else {
                    self
                        .buttonBorderShape(cornerStyle.buttonBorderShape)
                        .buttonStyle(.glass)
                        .tint(tint)
                }
            case .prominentClearGlass:
                if #available(iOS 26.1, macOS 26.1, tvOS 26.1, watchOS 26.1, *) {
                    self
                        .buttonBorderShape(cornerStyle.buttonBorderShape)
                        .buttonStyle(.glass(.clear))
                        .tint(tint ?? .accentColor)
                } else {
                    self
                        .buttonBorderShape(cornerStyle.buttonBorderShape)
                        .buttonStyle(.glassProminent)
                        .tint(tint)
                }
            }
        } else {
            self
        }
    }
}

private extension CornerStyle {
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, *)
    var buttonBorderShape: SwiftUI.ButtonBorderShape {
        switch self {
        case .automatic:
            return .capsule
        case .fixed(let radius):
            return .roundedRectangle(radius: radius)
        case .corners(let corners):
            return .roundedRectangle(radius: corners.maximum)
        case .none:
            return .roundedRectangle(radius: 0)
        }
    }
}

struct SUICornerShape: Shape {
    let style: CornerStyle

    func path(in rect: CGRect) -> Path {
        let radii = cornerRadii(in: rect)
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + radii.topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radii.topRight, y: rect.minY))
        addArc(
            to: &path,
            center: CGPoint(x: rect.maxX - radii.topRight, y: rect.minY + radii.topRight),
            radius: radii.topRight,
            startAngle: -90,
            endAngle: 0
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radii.bottomRight))
        addArc(
            to: &path,
            center: CGPoint(x: rect.maxX - radii.bottomRight, y: rect.maxY - radii.bottomRight),
            radius: radii.bottomRight,
            startAngle: 0,
            endAngle: 90
        )
        path.addLine(to: CGPoint(x: rect.minX + radii.bottomLeft, y: rect.maxY))
        addArc(
            to: &path,
            center: CGPoint(x: rect.minX + radii.bottomLeft, y: rect.maxY - radii.bottomLeft),
            radius: radii.bottomLeft,
            startAngle: 90,
            endAngle: 180
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radii.topLeft))
        addArc(
            to: &path,
            center: CGPoint(x: rect.minX + radii.topLeft, y: rect.minY + radii.topLeft),
            radius: radii.topLeft,
            startAngle: 180,
            endAngle: 270
        )
        path.closeSubpath()
        return path
    }

    private func addArc(
        to path: inout Path,
        center: CGPoint,
        radius: CGFloat,
        startAngle: Double,
        endAngle: Double
    ) {
        guard radius > 0 else {
            path.addLine(to: center)
            return
        }
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
    }

    private func cornerRadii(in rect: CGRect) -> CornerStyle.Corners {
        let maximumRadius = min(rect.width, rect.height) / 2
        let source: CornerStyle.Corners
        switch style {
        case .automatic:
            source = .init(
                topLeft: maximumRadius,
                topRight: maximumRadius,
                bottomLeft: maximumRadius,
                bottomRight: maximumRadius
            )
        case .fixed(let radius):
            source = .init(
                topLeft: radius,
                topRight: radius,
                bottomLeft: radius,
                bottomRight: radius
            )
        case .corners(let corners):
            source = corners
        case .none:
            source = .init(topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0)
        }
        return .init(
            topLeft: min(max(source.topLeft, 0), maximumRadius),
            topRight: min(max(source.topRight, 0), maximumRadius),
            bottomLeft: min(max(source.bottomLeft, 0), maximumRadius),
            bottomRight: min(max(source.bottomRight, 0), maximumRadius)
        )
    }
}
