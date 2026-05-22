//
//  UIView+CornerStyle.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/22/26.
//

#if canImport(UIKit)
import UIKit

extension UIView {
    func applyCornerStyle(_ cornerStyle: CornerStyle) {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, *) {
            applyiOS26CornerStyle(cornerStyle)
        } else {
            applyOldCornerStyle(cornerStyle)
        }
    }
    
    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, *)
    func applyiOS26CornerStyle(_ cornerStyle: CornerStyle) {
        cornerConfiguration = switch cornerStyle {
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
    
    func applyOldCornerStyleOnlyiOS18(_ cornerStyle: CornerStyle) {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, *) {} else {
            applyOldCornerStyle(cornerStyle)
        }
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
}

#endif
