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

#endif

public struct TextAttributes {
    public init(
        text: String,
        color: Color? = nil,
        font: Font? = nil,
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

    public var text: String
    public let color: Color?
    public let underlineStyle: UnderlineStyle?
    public let font: Font?
    public let textAlignment: TextAlignment?
    public let leadingImage: Image?
    public let leadingImageBounds: CGRect
    public let trailingImage: Image?
    public let trailingImageBounds: CGRect
    public let onTap: (() -> Void)?
    var range: NSRange?
}
