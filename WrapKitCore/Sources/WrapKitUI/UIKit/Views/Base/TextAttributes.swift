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
        id: String = UUID().uuidString,
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
        self.id = id
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

    public var id: String
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

public extension TextAttributes {
    func makeNSAttributedString(
        unsupportedUnderlines: [NSUnderlineStyle] = [],
        font: Font? = nil,
        textColor: Color? = nil,
        textAlignment: TextAlignment? = nil,
        lineSpacing: CGFloat = 4
    ) -> NSAttributedString {
        var underlineStyle = self.underlineStyle
        if let style = underlineStyle, unsupportedUnderlines.contains(style) { underlineStyle = .single } // others not working without, only with OR
        return NSAttributedString(
            self.text,
            font: self.font ?? font,
            color: self.color ?? textColor,
            lineSpacing: lineSpacing,
            underlineStyle: underlineStyle,
            textAlignment: self.textAlignment ?? textAlignment,
            leadingImage: self.leadingImage,
            leadingImageBounds: self.leadingImageBounds,
            trailingImage: self.trailingImage,
            trailingImageBounds: self.trailingImageBounds
        )
    }
}

public extension [TextAttributes] {
    mutating func makeNSAttributedString(
        unsupportedUnderlines: [NSUnderlineStyle] = [],
        font: Font? = nil,
        textColor: Color? = nil,
        textAlignment: TextAlignment? = nil
    ) -> NSAttributedString {
        let combinedAttributedString = NSMutableAttributedString()
        for (index, current) in self.enumerated() {
            let attrString = current.makeNSAttributedString(unsupportedUnderlines: unsupportedUnderlines, font: font, textColor: textColor, textAlignment: textAlignment)
            combinedAttributedString.append(attrString)
            
            let currentLocation = combinedAttributedString.length - attrString.length
            self[index].range = NSRange(location: currentLocation, length: attrString.length)
        }
        return combinedAttributedString
    }
}
