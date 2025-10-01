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

        // Truncate to the specified number of decimal places
        let divisor = pow(10.0, Double(count))
        let truncatedValue = (self * divisor).rounded(.towardZero) / divisor

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = count
        formatter.maximumFractionDigits = count
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = locale.groupingSeparator
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.roundingMode = .floor // Ensure no additional rounding

        return formatter.string(from: NSNumber(value: truncatedValue)) ?? String(format: "%.\(count)f", truncatedValue)
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
