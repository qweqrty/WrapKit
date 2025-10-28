//
//  NSAttrubitedString+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension NSAttributedString {
    convenience init(
        _ text: String,
        font: UIFont?,
        color: UIColor?,
        lineSpacing: CGFloat = 0,
        underlineStyle: NSUnderlineStyle? = nil,
        textAlignment: NSTextAlignment?,
        leadingImage: UIImage? = nil,
        leadingImageBounds: CGRect = .zero,
        trailingImage: UIImage? = nil,
        trailingImageBounds: CGRect = .zero
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        if let textAlignment {
            paragraphStyle.alignment = textAlignment
        }
        var attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]
        if let font {
            attributes[.font] = font
        }
        if let color {
            attributes[.foregroundColor] = color
        }

        if let underlineStyle {
            attributes[.underlineStyle] = underlineStyle.rawValue
        }
        
        let attributedString = NSMutableAttributedString(string: "", attributes: attributes)
        
        if let image = leadingImage {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = leadingImageBounds == .zero ? CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height) : leadingImageBounds

            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(attachmentString)
            attributedString.append(NSAttributedString(string: " "))
        }

        let mainString = NSMutableAttributedString(string: text, attributes: attributes)
        attributedString.append(mainString)
        
        if let image = trailingImage {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = trailingImageBounds == .zero ? CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height) : trailingImageBounds

            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(NSAttributedString(string: " "))
            attributedString.append(attachmentString)
        }

        self.init(attributedString: attributedString)
    }
    
    static func combined(_ attributedStrings: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString()
        attributedStrings.forEach { result.append($0) }
        return result
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSAttributedString {
    convenience init(
        _ text: String,
        font: NSFont?,
        color: NSColor?,
        lineSpacing: CGFloat = 0,
        underlineStyle: NSUnderlineStyle? = nil,
        textAlignment: NSTextAlignment?,
        leadingImage: NSImage? = nil,
        leadingImageBounds: CGRect = .zero,
        trailingImage: NSImage? = nil,
        trailingImageBounds: CGRect = .zero
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        if let textAlignment {
            paragraphStyle.alignment = textAlignment
        }
        var attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]
        if let font {
            attributes[.font] = font
        }
        if let color {
            attributes[.foregroundColor] = color
        }

        if let underlineStyle {
            attributes[.underlineStyle] = underlineStyle.rawValue
        }
        
        let attributedString = NSMutableAttributedString(string: "", attributes: attributes)
        
        if let image = leadingImage {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = leadingImageBounds == .zero ? CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height) : leadingImageBounds

            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(attachmentString)
            attributedString.append(NSAttributedString(string: " "))
        }

        let mainString = NSMutableAttributedString(string: text, attributes: attributes)
        attributedString.append(mainString)
        
        if let image = trailingImage {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = trailingImageBounds == .zero ? CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height) : trailingImageBounds

            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(NSAttributedString(string: " "))
            attributedString.append(attachmentString)
        }

        self.init(attributedString: attributedString)
    }
}
#endif
