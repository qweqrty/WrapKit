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

        // Use Decimal for exactness
        var decimal = Decimal(self)
        let roundingMode: NSDecimalNumber.RoundingMode = self >= 0 ? .plain : .up
        var truncated = Decimal()
        NSDecimalRound(&truncated, &decimal, count, roundingMode)

        // Format using locale
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = count
        formatter.maximumFractionDigits = count
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = locale.groupingSeparator // Explicitly set for consistency
        formatter.decimalSeparator = locale.decimalSeparator // Explicitly set for consistency

        // Convert Decimal to NSDecimalNumber for precise formatting
        let number = NSDecimalNumber(decimal: truncated)
        return formatter.string(from: number) ?? String(format: "%.\(count)f", number.doubleValue)
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
