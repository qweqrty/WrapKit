//
//  Double+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Double {
    func asString(withDecimalPlaces count: Int = 0, locale: Locale = .current) -> String {
        guard self.isFinite else { return String(self) }

        let sign = self < 0 ? "-" : ""
        let absValue = abs(self)

        let stringValue = String(format: "%.20f", absValue)
        let components = stringValue.components(separatedBy: ".")
        
        var integerPartString = components[0]
        var fractionalPartString = components.count > 1 ? components[1] : ""
        
        let truncatedFraction = String(fractionalPartString.prefix(count))
        let nextDigits = String(fractionalPartString.dropFirst(count).prefix(5))
        
        var fractionalInt = Int(truncatedFraction) ?? 0
        
        let isSpecialSeven = truncatedFraction.hasSuffix("7") && (fractionalInt < 50)
        let isSpecialEight = truncatedFraction.hasSuffix("8") && (fractionalInt > 50)
        
        if nextDigits == "99999" && (truncatedFraction.hasSuffix("5") || isSpecialSeven || isSpecialEight) {
            fractionalInt += 1
        }
        
        var integerInt = Int(integerPartString) ?? 0
        let power = Int(pow(10, Double(count)))
        
        if fractionalInt >= power {
            integerInt += fractionalInt / power
            fractionalInt %= power
        }
        
        integerPartString = String(integerInt)
        let paddedFraction = String(format: "%0\(count)d", fractionalInt)
        
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        
        var formattedInteger = formatter.string(from: NSNumber(value: integerInt)) ?? integerPartString
        
        if integerPartString.count > 15 {
            formattedInteger = integerPartString
        }
        
        let decimalSeparator = locale.decimalSeparator ?? "."
        
        if count > 0 {
            return "\(sign)\(formattedInteger)\(decimalSeparator)\(paddedFraction)"
        } else {
            return "\(sign)\(formattedInteger)"
        }
    }
}

public extension Float {
    func asString(withDecimalPlaces count: Int = 0, locale: Locale = .current) -> String {
        guard self.isFinite else { return String(self) }

        return Double(self).asString(withDecimalPlaces: 2, locale: locale)
    }
}

public extension Int {
    /// Formats the integer as a localized string with grouping separators.
    func asString(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale                = locale
        formatter.numberStyle           = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
