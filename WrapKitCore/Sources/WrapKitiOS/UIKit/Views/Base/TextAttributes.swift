//
//  File.swift
//  
//
//  Created by Gulzat Zheenbek kyzy on 22/10/24.
//

#if canImport(UIKit)
import UIKit
public typealias UnderlineStyle = NSUnderlineStyle
public typealias TextAlignment = NSTextAlignment

#elseif canImport(AppKit)
import AppKit
public typealias UnderlineStyle = NSUnderlineStyle
public typealias TextAlignment = NSTextAlignment

#elseif canImport(WatchKit)
import WatchKit
public typealias UnderlineStyle = NSUnderlineStyle
public typealias TextAlignment = NSTextAlignment

#elseif canImport(SwiftUI)
import SwiftUI
public typealias UnderlineStyle = UnderlineStyleWrapper // Custom type for SwiftUI
public typealias TextAlignment = TextAlignmentWrapper // Custom type for SwiftUI

public struct UnderlineStyleWrapper {
    public var style: NSUnderlineStyle?

    public init(style: NSUnderlineStyle? = nil) {
        self.style = style
    }
    
    // Apply underline in SwiftUI
    public func apply(to text: Text) -> Text {
        if let style = style, style.contains(.single) {
            return text.underline(true)
        }
        return text
    }
}

public struct TextAlignmentWrapper {
    public var alignment: TextAlignment?

    public init(alignment: TextAlignment? = nil) {
        self.alignment = alignment
    }
    
    // Convert TextAlignment to SwiftUI equivalent
    public func alignmentForSwiftUI() -> Alignment {
        switch alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }
}
#endif

public struct TextAttributes {
    public init(
        text: String,
        color: Color,
        font: Font,
        underlineStyle: UnderlineStyle? = nil,
        textAlignment: TextAlignment? = nil,
        leadingImage: Image? = nil,
        leadingImageBounds: CGRect = .zero,
        trailingImage: Image? = nil,
        trailingImageBounds: CGRect = .zero,
        onTap: (() -> Void)? = nil
    ) {
        self.text = text
        self.color = color
        self.font = font
        self.onTap = onTap
        self.range = nil
        self.underlineStyle = underlineStyle
        self.textAlignment = textAlignment
        self.leadingImage = leadingImage
        self.leadingImageBounds = leadingImageBounds
        self.trailingImage = trailingImage
        self.trailingImageBounds = trailingImageBounds
    }

    public let text: String
    public let color: Color
    public let underlineStyle: UnderlineStyle?
    public let font: Font
    public let textAlignment: TextAlignment?
    public let leadingImage: Image?
    public let leadingImageBounds: CGRect
    public let trailingImage: Image?
    public let trailingImageBounds: CGRect
    public let onTap: (() -> Void)?
    var range: NSRange?
}
