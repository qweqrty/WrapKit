//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/1/25.
//

import Foundation

public struct EdgeInsets {
    public let top: CGFloat
    public let left: CGFloat
    public let bottom: CGFloat
    public let right: CGFloat

    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    // Convenience initializer for uniform insets
    public init(all: CGFloat) {
        self.top = all
        self.left = all
        self.bottom = all
        self.right = all
    }

    // Convenience initializer for horizontal and vertical insets
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.top = vertical
        self.left = horizontal
        self.bottom = vertical
        self.right = horizontal
    }

    // Static properties for common cases
    public static let zero = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

#if canImport(UIKit)
import UIKit

extension EdgeInsets {
    var asUIEdgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}
#endif
