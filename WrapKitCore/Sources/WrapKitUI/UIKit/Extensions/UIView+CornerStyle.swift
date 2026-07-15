//
//  UIView+CornerStyle.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/22/26.
//

#if canImport(UIKit)
import UIKit

public extension UIView {
    func applyCornerStyle(_ cornerStyle: CornerStyle) {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, *) {
            applyiOS26CornerStyle(cornerStyle)
        } else {
            applyOldCornerStyle(cornerStyle)
        }
    }
    
    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, *)
    func applyiOS26CornerStyle(_ cornerStyle: CornerStyle) {
        cornerConfiguration = cornerStyle.cornerConfiguation
        clipsToBounds = cornerStyle.value != .zero
    }
    
    func applyOldCornerStyleOnlyiOS18(_ cornerStyle: CornerStyle) {
        guard #unavailable(iOS 26, macOS 26, watchOS 26, tvOS 26) else { return }
        applyOldCornerStyle(cornerStyle)
    }
    
    func applyOldCornerStyle(_ cornerStyle: CornerStyle) {
        switch cornerStyle {
        case .automatic:
            layer.maskedCorners = .allCorners
            layer.cornerRadius = min(bounds.height, bounds.width) / 2
        case .fixed(let radius):
            layer.maskedCorners = .allCorners
            layer.cornerRadius = radius
        case .none:
            layer.maskedCorners = []
            layer.cornerRadius = .zero
        case .corners(let corners):
            layer.maskedCorners = corners.maskedCorners
            layer.cornerRadius = corners.maximum
        }
        layer.masksToBounds = layer.cornerRadius > 0
    }
    
    @available(iOS 26.0, *)
    func cornerConfigurationMaskedCorners() -> CACornerMask {
        let topLeftRadius = effectiveRadius(corner: .topLeft)
        let topRightRadius = effectiveRadius(corner: .topRight)
        let bottomLeftRadius = effectiveRadius(corner: .bottomLeft)
        let bottomRightRadius = effectiveRadius(corner: .bottomRight)
        
        var reconstructedMask: CACornerMask = []
        
        if topLeftRadius > 0 { reconstructedMask.insert(.layerMinXMinYCorner) }
        if topRightRadius > 0 { reconstructedMask.insert(.layerMaxXMinYCorner) }
        if bottomLeftRadius > 0 { reconstructedMask.insert(.layerMinXMaxYCorner) }
        if bottomRightRadius > 0 { reconstructedMask.insert(.layerMaxXMaxYCorner) }
        
        return reconstructedMask
    }
    
    func maskedCornersValue() -> CACornerMask {
        guard #available(iOS 26.0, *) else { return layer.maskedCorners }
        let corners = cornerConfigurationMaskedCorners()
        return !corners.isEmpty ? layer.maskedCorners : corners
    }
    
    func cornerRadiusValue() -> CGFloat {
        guard #available(iOS 26.0, *) else { return layer.cornerRadius }
        let radius = cornerConfigurationMaxRadius()
        return radius > .zero ? radius : layer.cornerRadius
    }
    
    @available(iOS 26.0, *)
    func cornerConfigurationMaxRadius() -> CGFloat {
        let topLeftRadius = effectiveRadius(corner: .topLeft)
        let topRightRadius = effectiveRadius(corner: .topRight)
        let bottomLeftRadius = effectiveRadius(corner: .bottomLeft)
        let bottomRightRadius = effectiveRadius(corner: .bottomRight)
        return max(topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius)
    }
}

public extension CornerStyle {
    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, *)
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
    if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
        return true
    }
    return false
}

public var isLiquidGlassEnabled = true
