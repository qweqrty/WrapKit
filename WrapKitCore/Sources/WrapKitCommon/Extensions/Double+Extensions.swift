//
//  Double+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Double {
    func toAmountString(
        minimumFractionDigits: Int = 0,
        maximumFractionDigits: Int = 2
    ) -> String? {
        asString(
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits,
            decimalSeparator: ",",
            groupingSeparator: " "
        )
    }

    /*
     Decimal.asString(withDecimalPlaces:decimalSeparator:groupingSeparator:locale:)",
         message: "Double gives inaccurate floating point for large numbers or large fraction parts. Use Decimal instead."
    )
    */
    func asString(
        withDecimalPlaces count: Int,
        decimalSeparator: String? = nil,
        groupingSeparator: String? = nil,
        locale: Locale = .current
    ) -> String? {
        return asString(
            minimumFractionDigits: 0,
            maximumFractionDigits: count,
            decimalSeparator: decimalSeparator,
            groupingSeparator: groupingSeparator,
            locale: locale
        )
    }
    
    func asString(
        minimumFractionDigits: Int = 0,
        maximumFractionDigits count: Int = 2,
        decimalSeparator: String? = nil,
        groupingSeparator: String? = nil,
        locale: Locale = .current
    ) -> String? {
        // special non-finite values
        if self.isNaN { return String(Double.nan) }
        if self.isInfinite { return String(self) } // "inf" or "-inf"
        
        // Format integer part with grouping according to locale
        let formatterDouble = NumberFormatter()
        formatterDouble.locale = locale
        formatterDouble.numberStyle = .decimal
        formatterDouble.minimumFractionDigits = minimumFractionDigits
        formatterDouble.maximumFractionDigits = count
        formatterDouble.roundingMode = .down // truncate
        formatterDouble.usesGroupingSeparator = true
        if let groupingSeparator {
            formatterDouble.groupingSeparator = groupingSeparator
        }
        if let decimalSeparator {
            formatterDouble.decimalSeparator = decimalSeparator
        }
        formatterDouble.groupingSize = 3
        
        return formatterDouble.string(for: self)
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
