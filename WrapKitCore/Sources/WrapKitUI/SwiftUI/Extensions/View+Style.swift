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

struct SUICornerShape: InsettableShape {
    let style: CornerStyle
    private var insetAmount: CGFloat = 0

    init(style: CornerStyle) {
        self.style = style
    }

    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radii = cornerRadii(in: insetRect)

        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *) {
            if case .automatic = style {
                return Capsule(style: .continuous).path(in: insetRect)
            }
            return Path(
                roundedRect: insetRect,
                cornerRadii: .init(
                    topLeading: radii.topLeft,
                    bottomLeading: radii.bottomLeft,
                    bottomTrailing: radii.bottomRight,
                    topTrailing: radii.topRight
                ),
                style: .continuous
            )
        }

        var path = Path()

        path.move(to: CGPoint(x: insetRect.minX + radii.topLeft, y: insetRect.minY))
        path.addLine(to: CGPoint(x: insetRect.maxX - radii.topRight, y: insetRect.minY))
        addArc(
            to: &path,
            center: CGPoint(x: insetRect.maxX - radii.topRight, y: insetRect.minY + radii.topRight),
            radius: radii.topRight,
            startAngle: -90,
            endAngle: 0
        )
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY - radii.bottomRight))
        addArc(
            to: &path,
            center: CGPoint(
                x: insetRect.maxX - radii.bottomRight,
                y: insetRect.maxY - radii.bottomRight
            ),
            radius: radii.bottomRight,
            startAngle: 0,
            endAngle: 90
        )
        path.addLine(to: CGPoint(x: insetRect.minX + radii.bottomLeft, y: insetRect.maxY))
        addArc(
            to: &path,
            center: CGPoint(
                x: insetRect.minX + radii.bottomLeft,
                y: insetRect.maxY - radii.bottomLeft
            ),
            radius: radii.bottomLeft,
            startAngle: 90,
            endAngle: 180
        )
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.minY + radii.topLeft))
        addArc(
            to: &path,
            center: CGPoint(x: insetRect.minX + radii.topLeft, y: insetRect.minY + radii.topLeft),
            radius: radii.topLeft,
            startAngle: 180,
            endAngle: 270
        )
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> SUICornerShape {
        var copy = self
        copy.insetAmount += amount
        return copy
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
            let insetRadius = max(radius - insetAmount, 0)
            source = .init(
                topLeft: insetRadius,
                topRight: insetRadius,
                bottomLeft: insetRadius,
                bottomRight: insetRadius
            )
        case .corners(let corners):
            source = .init(
                topLeft: max(corners.topLeft - insetAmount, 0),
                topRight: max(corners.topRight - insetAmount, 0),
                bottomLeft: max(corners.bottomLeft - insetAmount, 0),
                bottomRight: max(corners.bottomRight - insetAmount, 0)
            )
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
