//
//  NSMutableParagraphStyle+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension NSMutableParagraphStyle {
    convenience init(lineSpacing: CGFloat, textAlignment: NSTextAlignment) {
        self.init()
        self.lineSpacing = lineSpacing
        self.alignment = textAlignment
    }
}

#endif
