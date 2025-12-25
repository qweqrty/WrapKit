//
//  Double+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Double {
    @available(
        *,
         deprecated,
         renamed: "Decimal.asString(withDecimalPlaces:decimalSeparator:groupingSeparator:locale:)",
         message: "Double gives inaccurate floating point for large numbers or large fraction parts. Use Decimal instead."
    )
    func asString(
        withDecimalPlaces count: Int = 0,
        decimalSeparator: String? = nil,
        groupingSeparator: String? = nil,
        locale: Locale = .current
    ) -> String {
        // special non-finite values
        if self.isNaN { return String(Double.nan) }
        if self.isInfinite { return String(self) } // "inf" or "-inf"

        // Detect overall sign (keep negative for non-zero values)
        let isNegative = self < 0

        // Work with absolute value
        let absValue = Swift.abs(self)

        // Use en_US_POSIX to get stable '.' decimal separator and full/fixed fractional output
        let raw = String(format: "%.20f", locale: Locale(identifier: "en_US_POSIX"), absValue)

        let parts = raw.split(separator: ".", omittingEmptySubsequences: false)
        let intPartRaw = parts.first.map(String.init) ?? "0"
        let fracPartRaw = parts.count > 1 ? String(parts[1]) : ""

        // Truncate fractional part (strict truncate, no rounding)
        let truncatedFracPrefix = count > 0 ? String(fracPartRaw.prefix(count)) : ""
        let paddedFraction: String
        if count > 0 {
            if truncatedFracPrefix.count < count {
                paddedFraction = truncatedFracPrefix + String(repeating: "0", count: count - truncatedFracPrefix.count)
            } else {
                paddedFraction = truncatedFracPrefix
            }
        } else {
            paddedFraction = ""
        }

        // Format integer part with grouping according to locale
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = count
        formatter.roundingMode = .down // truncate
        formatter.usesGroupingSeparator = true
        if let groupingSeparator {
            formatter.groupingSeparator = groupingSeparator
        }
        if let decimalSeparator {
            formatter.decimalSeparator = decimalSeparator
        }
        formatter.groupingSize = 3
        
        // Use NSDecimalNumber(string:) so very large integers are handled reliably
        let intNumber = NSDecimalNumber(string: intPartRaw)
        var formattedInteger = formatter.string(from: intNumber) ?? intPartRaw

        // If integer string is extremely long and NumberFormatter did something unexpected,
        // fallback to raw integer string (keeps behavior close to original code).
        if intPartRaw.count > 18 { // choose threshold defensively
            formattedInteger = intPartRaw
        }

        let decimalSeparator = locale.decimalSeparator ?? "."

        var result: String
        if count > 0 {
            result = "\(isNegative ? "-" : "")\(formattedInteger)\(decimalSeparator)\(paddedFraction)"
        } else {
            result = "\(isNegative ? "-" : "")\(formattedInteger)"
        }

        // Convert "-0.00", "-0", "-0.000" -> "0.00"/"0" etc.
        // Check if numeric value after truncation equals zero
        let intAllZero = intPartRaw.trimmingCharacters(in: CharacterSet(charactersIn: "0")) == ""
        let fracAllZero = paddedFraction.trimmingCharacters(in: CharacterSet(charactersIn: "0")) == ""
        if intAllZero && (count == 0 || fracAllZero) {
            // ensure positive zero
            if result.hasPrefix("-") {
                result.removeFirst()
            }
        }

        return result
    }
}


public extension Float {
    func asString(withDecimalPlaces count: Int = 0, locale: Locale = .current) -> String {
        guard self.isFinite else { return String(self) }
        return Double(self).asString(withDecimalPlaces: count, locale: locale)
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
