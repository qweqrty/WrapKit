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
    
    func asHtmlAttributedString(font: Font? = nil, color: Color? = nil) -> NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        var options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if #available(macOS 15.0, iOS 18.0, *) {
            options[.textKit1ListMarkerFormatDocumentOption] = true
        }
        let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
        guard var attributedString else { return nil }
        let wholeRange = NSRange(location: 0, length: attributedString.length)
        if let font {
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: wholeRange)
        }
        if let color = color {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: wholeRange)
        }
        // Parse the original HTML to extract inline styles
        let styleRanges = extractInlineStyles(from: self)
        // Apply the styles to the attributed string
        for styleRange in styleRanges {
            applyStyle(styleRange, to: &attributedString)
        }
        
        return attributedString
    }
    
    private func extractInlineStyles(from html: String) -> [(text: String, fontSize: CGFloat?, fontWeight: Font.Weight?)] {
        var results: [(String, CGFloat?, Font.Weight?)] = []
        
        // Regex to find tags with style attributes
        let pattern = "<(\\w+)\\s+style=\"([^\"]+)\"[^>]*>([^<]+)<\\/\\1>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            if match.numberOfRanges >= 4 {
                let styleString = nsString.substring(with: match.range(at: 2))
                let textContent = nsString.substring(with: match.range(at: 3))
                
                let fontSize = extractFontSize(from: styleString)
                let fontWeight = extractFontWeight(from: styleString)
                
                results.append((textContent, fontSize, fontWeight))
            }
        }
        
        return results
    }
    
    private func extractFontSize(from style: String) -> CGFloat? {
        let pattern = "font-size:\\s*(\\d+)px"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: style, range: NSRange(style.startIndex..., in: style)),
              let range = Range(match.range(at: 1), in: style) else {
            return nil
        }
        return CGFloat(Int(style[range]) ?? 0)
    }
    
    private func extractFontWeight(from style: String) -> Font.Weight? {
        let pattern = "font-weight:\\s*(\\d+|bold|normal)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: style, range: NSRange(style.startIndex..., in: style)),
              let range = Range(match.range(at: 1), in: style) else {
            return nil
        }
        
        let weight = String(style[range])
        switch weight {
        case "bold", "700": return .bold
        case "600": return .semibold
        case "500": return .medium
        case "normal", "400": return .regular
        case "300": return .light
        default: return nil
        }
    }
    
    private func applyStyle(
        _ styleRange: (text: String, fontSize: CGFloat?, fontWeight: Font.Weight?),
        to attributedString: inout NSMutableAttributedString
    ) {
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let searchText = styleRange.text
        
        if let range = attributedString.string.range(of: searchText) {
            let nsRange = NSRange(range, in: attributedString.string)
            
            var font = Font.systemFont(ofSize: 15) // default
            
            if let existingFont = attributedString.attribute(.font, at: nsRange.location, effectiveRange: nil) as? Font {
                font = existingFont
            }
            
            let fontSize = styleRange.fontSize ?? font.pointSize
            let fontWeight = styleRange.fontWeight ?? .regular
            
            let newFont = Font.systemFont(ofSize: fontSize, weight: fontWeight)
            attributedString.addAttribute(.font, value: newFont, range: nsRange)
        }
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
