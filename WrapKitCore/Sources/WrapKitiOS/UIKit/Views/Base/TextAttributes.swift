//
//  File.swift
//  
//
//  Created by Gulzat Zheenbek kyzy on 22/10/24.
//
#if canImport(UIKit)

public struct TextAttributes {
    public init(
        text: String,
        color: UIColor,
        font: UIFont,
        underlineStyle: NSUnderlineStyle? = nil,
        textAlignment: NSTextAlignment? = nil,
        leadingImage: UIImage? = nil,
        leadingImageBounds: CGRect = .zero,
        trailingImage: UIImage? = nil,
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
    public let color: UIColor
    public let underlineStyle: NSUnderlineStyle?
    public let font: UIFont
    public let textAlignment: NSTextAlignment?
    public let leadingImage: UIImage?
    public let leadingImageBounds: CGRect
    public let trailingImage: UIImage?
    public let trailingImageBounds: CGRect
    public let onTap: (() -> Void)?
    var range: NSRange?
}
#endif
