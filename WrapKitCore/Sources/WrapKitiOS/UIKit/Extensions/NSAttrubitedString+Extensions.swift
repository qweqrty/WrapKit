//
//  NSAttrubitedString+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension NSAttributedString {
    convenience init(_ text: String, font: UIFont, color: UIColor, lineSpacing: CGFloat = 0, underlineStyle: NSUnderlineStyle? = nil, textAlignment: NSTextAlignment) {
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineSpacing: lineSpacing, textAlignment: textAlignment)
        ]
        if let underlineStyle = underlineStyle {
            attributes[NSAttributedString.Key.underlineStyle] = underlineStyle.rawValue
        }
        self.init(string: text, attributes: attributes)
    }
    
    static func combined(_ attributedStrings: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString()
        attributedStrings.forEach { result.append($0) }
        return result
    }
}
#endif
