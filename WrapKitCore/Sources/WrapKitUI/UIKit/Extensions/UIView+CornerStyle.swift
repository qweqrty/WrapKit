//
//  UIView+CornerStyle.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/22/26.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UIView {
    func applyCornerStyle(_ cornerStyle: CornerStyle) {
        if #available(iOS 26, tvOS 26, visionOS 26, *) {
            let previousConfiguration = cornerConfiguration
            let previousCornerRadius = layer.cornerRadius
            let previousMaskedCorners = layer.maskedCorners
            let previousMasksToBounds = layer.masksToBounds
            applyiOS26CornerStyle(cornerStyle)
            if previousConfiguration != cornerConfiguration
                || previousCornerRadius != layer.cornerRadius
                || previousMaskedCorners != layer.maskedCorners
                || previousMasksToBounds != layer.masksToBounds {
                setNeedsLayout()
            }
        } else {
            let previousCornerRadius = layer.cornerRadius
            let previousMaskedCorners = layer.maskedCorners
            let previousMasksToBounds = layer.masksToBounds
            applyOldCornerStyle(cornerStyle)
            if previousCornerRadius != layer.cornerRadius
                || previousMaskedCorners != layer.maskedCorners
                || previousMasksToBounds != layer.masksToBounds {
                setNeedsLayout()
            }
        }
    }
    
    @available(iOS 26, tvOS 26, visionOS 26, *)
    func applyiOS26CornerStyle(_ cornerStyle: CornerStyle) {
        if layer.cornerRadius != .zero || layer.maskedCorners != .allCorners {
            layer.cornerRadius = .zero
            layer.maskedCorners = .allCorners
        }
        let configuration = cornerStyle.cornerConfiguation
        if cornerConfiguration != configuration {
            cornerConfiguration = configuration
        }
        let shouldClipToBounds = cornerStyle.value != .zero
        if clipsToBounds != shouldClipToBounds {
            clipsToBounds = shouldClipToBounds
        }
    }
    
    func applyOldCornerStyleOnlyiOS18(_ cornerStyle: CornerStyle) {
        guard #unavailable(iOS 26, tvOS 26, visionOS 26) else { return }
        applyOldCornerStyle(cornerStyle)
    }
    
    func applyOldCornerStyle(_ cornerStyle: CornerStyle) {
        let maskedCorners: CACornerMask
        let cornerRadius: CGFloat
        switch cornerStyle {
        case .automatic:
            maskedCorners = .allCorners
            cornerRadius = min(bounds.height, bounds.width) / 2
        case .fixed(let radius):
            maskedCorners = .allCorners
            cornerRadius = radius
        case .none:
            maskedCorners = []
            cornerRadius = .zero
        case .corners(let corners):
            maskedCorners = corners.maskedCorners
            cornerRadius = corners.maximum
        }
        if layer.maskedCorners != maskedCorners {
            layer.maskedCorners = maskedCorners
        }
        if layer.cornerRadius != cornerRadius {
            layer.cornerRadius = cornerRadius
        }
        let shouldMaskToBounds = cornerRadius > .zero
        if layer.masksToBounds != shouldMaskToBounds {
            layer.masksToBounds = shouldMaskToBounds
        }
    }
}

extension UIView {
    public func maskedCornersValue() -> CACornerMask {
        cornerRadiiValue().maskedCorners
    }

    public func cornerRadiusValue() -> CGFloat {
        cornerRadiiValue().maximum
    }

    @available(iOS 26, tvOS 26, visionOS 26, *)
    public func cornerConfigurationMaskedCorners() -> CACornerMask {
        cornerRadiiValue().maskedCorners
    }

    @available(iOS 26, tvOS 26, visionOS 26, *)
    public func cornerConfigurationMaxRadius() -> CGFloat {
        cornerRadiiValue().maximum
    }

    func cornerRadiiValue() -> CornerStyle.Corners {
        if #available(iOS 26, tvOS 26, visionOS 26, *) {
            let resolvedRadii = CornerStyle.Corners(
                topLeft: effectiveRadius(corner: .topLeft),
                topRight: effectiveRadius(corner: .topRight),
                bottomLeft: effectiveRadius(corner: .bottomLeft),
                bottomRight: effectiveRadius(corner: .bottomRight)
            )
            if resolvedRadii.maximum > .zero || layer.cornerRadius == .zero {
                return resolvedRadii
            }
        }

        let radius = layer.cornerRadius
        return CornerStyle.Corners(
            topLeft: layer.maskedCorners.contains(.layerMinXMinYCorner) ? radius : .zero,
            topRight: layer.maskedCorners.contains(.layerMaxXMinYCorner) ? radius : .zero,
            bottomLeft: layer.maskedCorners.contains(.layerMinXMaxYCorner) ? radius : .zero,
            bottomRight: layer.maskedCorners.contains(.layerMaxXMaxYCorner) ? radius : .zero
        )
    }
}

public extension CornerStyle {
    @available(iOS 26, tvOS 26, visionOS 26, *)
    var cornerConfiguation: UICornerConfiguration {
        switch self {
        case .automatic: .capsule()
        case .fixed(let value): .corners(radius: .fixed(value))
        case .corners(let corners): .corners(
            topLeftRadius: .fixed(corners.topLeft),
            topRightRadius: .fixed(corners.topRight),
            bottomLeftRadius: .fixed(corners.bottomLeft),
            bottomRightRadius: .fixed(corners.bottomRight)
        )
        case .none: .corners(radius: .fixed(.zero))
        }
    }
    
    var value: CGFloat? {
        switch self {
        case .automatic: .none
        case .fixed(let value): value
        case .corners(let corners): corners.maximum
        case .none: .zero
        }
    }
}

#endif

public var isAvailableOS26: Bool {
    if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *) {
        return true
    }
    return false
}

public var isLiquidGlassEnabled = true
