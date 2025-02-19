//
//  File.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/1/25.
//

import Foundation

public struct EdgeInsets: Equatable {
    public let top: CGFloat
    public let leading: CGFloat
    public let bottom: CGFloat
    public let trailing: CGFloat
    
    public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    // Convenience initializer for uniform insets
    public init(all: CGFloat) {
        self.top = all
        self.leading = all
        self.bottom = all
        self.trailing = all
    }

    // Convenience initializer for horizontal and vertical insets
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.top = vertical
        self.leading = horizontal
        self.bottom = vertical
        self.trailing = horizontal
    }

    // Static properties for common cases
    public static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

#if canImport(UIKit)
import UIKit

extension EdgeInsets {
    var asUIEdgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }
}
#endif
