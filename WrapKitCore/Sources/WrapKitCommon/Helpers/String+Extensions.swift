//
//  String+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/12/23.
//

import Foundation

public extension String {
    static let post = "POST"
    static let patch = "PATCH"
    static let put = "PUT"
    static let get = "GET"
    static let delete = "DELETE"
}

public extension Optional where Wrapped == String {
    var isEmpty: Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}

public extension Date {
    /// Converts a Date to a String with the given format
    func toString(format: String, locale: Locale = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        return dateFormatter.string(from: self)
    }
}

public extension String {
    var asHtmlAttributedString: NSAttributedString? {
        return asHtmlAttributedString()
    }

    func asHtmlAttributedString(config: HTMLAttributedStringConfig? = .default) -> NSAttributedString? {

        guard let data = data(using: .utf8) else { return nil }

        var options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if #available(iOS 18.0, macOS 15.0, *) {
            options[.textKit1ListMarkerFormatDocumentOption] = true
        }

        guard let attributed = try? NSMutableAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ) else { return nil }

        let whole = NSRange(location: 0, length: attributed.length)

        /// COLOR: если передали — ставим на весь текст
        if let color = config?.color {
            attributed.addAttribute(.foregroundColor, value: color, range: whole)
        }

        /// FONT: если size/weight передали — обновляем только их, сохраняя traits (italic и т.п.) из HTML
        if config?.size != nil || config?.weight != nil {
            attributed.enumerateAttribute(.font, in: whole, options: []) { value, range, _ in
                let oldFont = (value as? Font) ?? Font.systemFont(ofSize: Font.systemFontSize)
                let oldDescriptor = oldFont.fontDescriptor

                let traits = oldDescriptor.symbolicTraits
                let finalSize = config?.size ?? oldFont.pointSize
                let finalWeight = config?.weight ?? extractWeight(from: oldDescriptor) ?? Font.Weight.regular

                var newDescriptor = Font.systemFont(ofSize: finalSize, weight: finalWeight).fontDescriptor
#if canImport(UIKit)
if let d = newDescriptor.withSymbolicTraits(traits) {
    newDescriptor = d
}
#else
newDescriptor = newDescriptor.withSymbolicTraits(traits)
#endif

                if let newFont = makeFont(from: newDescriptor, size: finalSize) {
                    attributed.addAttribute(.font, value: newFont, range: range)
                }
            }
        }

        /// PARAGRAPH STYLE
        if config?.lineSpacing != nil
            || config?.paragraphSpacing != nil
            || config?.paragraphSpacingBefore != nil
            || config?.lineHeightMultiple != nil
            || config?.textAlignment != nil
            || config?.lineBreakMode != nil
            || config?.firstLineHeadIndent != nil
            || config?.headIndent != nil
            || config?.tailIndent != nil {

            attributed.enumerateAttribute(.paragraphStyle, in: whole, options: []) { value, range, _ in
                let style = MutableParagraphStyle()

                if let existing = value as? ParagraphStyle {
                    style.setParagraphStyle(existing)
                }

                if let paragraphSpacing = config?.paragraphSpacing { style.paragraphSpacing = paragraphSpacing }
                if let paragraphSpacingBefore = config?.paragraphSpacingBefore { style.paragraphSpacingBefore = paragraphSpacingBefore }

                if let textAlignment = config?.textAlignment { style.alignment = textAlignment }
                if let lineBreakMode = config?.lineBreakMode { style.lineBreakMode = lineBreakMode }

                if let firstLineHeadIndent = config?.firstLineHeadIndent { style.firstLineHeadIndent = firstLineHeadIndent }
                if let headIndent = config?.headIndent { style.headIndent = headIndent }
                if let tailIndent = config?.tailIndent { style.tailIndent = tailIndent }

                // приоритет: lineHeightMultiple, иначе lineSpacing
                if let lineHeightMultiple = config?.lineHeightMultiple {
                    style.lineHeightMultiple = lineHeightMultiple
                } else if let lineSpacing = config?.lineSpacing {
                    style.lineSpacing = lineSpacing
                }

                attributed.addAttribute(.paragraphStyle, value: style, range: range)
            }
        }

        return attributed
    }
}

public extension String {
    func asDate(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

public extension String {
    func numberFormatted(numberStyle: NumberFormatter.Style, groupingSeparator: String?, maxDigits: Int = 12) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = numberStyle
        formatter.groupingSeparator = groupingSeparator ?? Locale.current.groupingSeparator
        formatter.locale = Locale.current
        
        guard let digits = Double(self.replacingOccurrences(of: formatter.groupingSeparator, with: "").prefix(maxDigits)) else { return "" }
        let number = NSNumber(value: digits)
        return formatter.string(from: number) ?? ""
    }
    
    func toIntFromFormatted(groupingSeparator: String? = nil) -> Int? {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = groupingSeparator ?? Locale.current.groupingSeparator
        
        let cleanString = self.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        return Int(cleanString)
    }
}

public extension Int {
    /// Converts milliseconds to Date
    var toDateFromMilliseconds: Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }

    /// Converts milliseconds to formatted String date
    func millisecondsToDateString(format: String, locale: Locale = .current) -> String {
        let date = self.toDateFromMilliseconds
        return date.toString(format: format, locale: locale)
    }
}

public extension Double {
    /// Converts milliseconds to Date
    var toDateFromMilliseconds: Date {
        return Date(timeIntervalSince1970: self / 1000)
    }

    /// Converts milliseconds to formatted String date
    func millisecondsToDateString(format: String, locale: Locale = .current) -> String {
        let date = self.toDateFromMilliseconds
        return date.toString(format: format, locale: locale)
    }
}

public extension Float {
    /// Converts milliseconds to Date
    var toDateFromMilliseconds: Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }

    /// Converts milliseconds to formatted String date
    func millisecondsToDateString(format: String, locale: Locale = .current) -> String {
        let date = self.toDateFromMilliseconds
        return date.toString(format: format, locale: locale)
    }
}


/// UIKit/AppKit differences)
private func extractWeight(from descriptor: FontDescriptor) -> Font.Weight? {
    #if canImport(UIKit)
    let traitsDict = descriptor.object(forKey: .traits) as? [FontDescriptor.TraitKey: Any]
    if let raw = traitsDict?[.weight] as? CGFloat {
        return Font.Weight(rawValue: raw)
    }
    return nil
    #else
    let traitsDict = descriptor.object(forKey: .traits) as? [FontDescriptor.TraitKey: Any]
    if let raw = traitsDict?[.weight] as? CGFloat {
        return Font.Weight(raw)
    }
    return nil
    #endif
}

private func makeFont(from descriptor: FontDescriptor, size: CGFloat) -> Font? {
    #if canImport(UIKit)
    return Font(descriptor: descriptor, size: size) /// non-optional
    #else
    return Font(descriptor: descriptor, size: size) /// optional
    #endif
}
