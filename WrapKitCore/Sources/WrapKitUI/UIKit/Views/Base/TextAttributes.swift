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

public struct TextAttributes: HashableWithReflection, Equatable {
    public init(
        id: String = UUID().uuidString,
        text: String,
        color: Color? = nil,
        font: Font? = nil,
        lineSpacing: CGFloat = 4,
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
        self.lineSpacing = lineSpacing
        self.onTap = onTap
        self.range = nil
        self.underlineStyle = underlineStyle
        self.textAlignment = textAlignment
        self.leadingImage = leadingImage
        self.leadingImageBounds = leadingImageBounds
        self.trailingImage = trailingImage
        self.trailingImageBounds = trailingImageBounds
    }

    public var id: String // used for SUILabel.TappableID, do not check in Equatable
    public var text: String
    public let color: Color?
    public let font: Font?
    public let lineSpacing: CGFloat
    public let underlineStyle: UnderlineStyle?
    public let textAlignment: TextAlignment?
    public let leadingImage: Image?
    public let leadingImageBounds: CGRect
    public let trailingImage: Image?
    public let trailingImageBounds: CGRect
    public let onTap: (() -> Void)?
    var range: NSRange?
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.text == rhs.text
        && lhs.color == rhs.color
        && lhs.font == rhs.font
        && lhs.lineSpacing == rhs.lineSpacing
        && lhs.underlineStyle == rhs.underlineStyle
        && lhs.textAlignment == rhs.textAlignment
        && lhs.leadingImage == rhs.leadingImage
        && lhs.leadingImageBounds == rhs.leadingImageBounds
        && lhs.trailingImage == rhs.trailingImage
        && lhs.trailingImageBounds == rhs.trailingImageBounds
        && String(describing: lhs.onTap) == String(describing: rhs.onTap)
    }
}

public extension TextAttributes {
    func makeNSAttributedString(
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .label,
        textAlignment: TextAlignment? = nil,
        link: URL? = nil // needed for onTap in SwiftUI
    ) -> NSAttributedString {
        return NSAttributedString(
            self.text,
            font: self.font ?? font,
            color: self.color ?? textColor,
            lineSpacing: self.lineSpacing,
            underlineStyle: underlineStyle,
            textAlignment: self.textAlignment ?? textAlignment,
            leadingImage: self.leadingImage,
            leadingImageBounds: self.leadingImageBounds,
            trailingImage: self.trailingImage,
            trailingImageBounds: self.trailingImageBounds,
            link: link
        )
    }
}

public extension [TextAttributes] {
    mutating func makeNSAttributedString(
        font: Font,
        textColor: Color = .label,
        textAlignment: TextAlignment? = nil
    ) -> NSAttributedString {
        let combinedAttributedString = NSMutableAttributedString()
        for (index, current) in self.enumerated() {
            let attrString = current.makeNSAttributedString(
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
            combinedAttributedString.append(attrString)
            
            let currentLocation = combinedAttributedString.length - attrString.length
            self[index].range = NSRange(location: currentLocation, length: attrString.length)
        }
        return combinedAttributedString
    }
}
