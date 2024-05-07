//
//  NSAttrubitedString+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension NSAttributedString {
    convenience init(_ text: String,
                     font: UIFont,
                     color: UIColor,
                     lineSpacing: CGFloat = 0,
                     underlineStyle: NSUnderlineStyle? = nil,
                     textAlignment: NSTextAlignment,
                     trailingImage: UIImage? = nil,
                     trailingImageBounds: CGRect = .zero) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = textAlignment

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]

        if let underline = underlineStyle {
            attributes[.underlineStyle] = underline.rawValue
        }

        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
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
