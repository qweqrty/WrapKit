//
//  Decimal+Extension.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 9/12/25.
//

import Foundation

public extension String {
    func asDecimal() -> Decimal? {
        Decimal(string: self)
    }
}

public extension Double {
    func asDecimal() -> Decimal {
        Decimal(self)
    }
}

public extension Decimal {
    var nsDecimal: NSDecimalNumber {
        self as NSDecimalNumber
    }
    
    var doubleValue: Double {
        nsDecimal.doubleValue
    }
    
    var intValue: Int {
        nsDecimal.intValue
    }
    
    var roundedDouble: Double {
        let string = nsDecimal.stringValue
        return Double(string) ?? doubleValue
    }
    
    func rounded(withDecimalPlaces count: Int = 2) -> Decimal {
        var rounded = self
        var original = self
        NSDecimalRound(&rounded, &original, count, .down)
        return rounded
    }
    
    func asString(
        withDecimalPlaces count: Int = 0,
        decimalSeparator: String? = nil,
        groupingSeparator: String? = nil,
        locale: Locale = .current
    ) -> String {
        return self.asString(minimumFractionDigits: count, maximumFractionDigits: count, decimalSeparator: decimalSeparator, groupingSeparator: groupingSeparator, locale: locale)
    }
    
    func asString(
        minimumFractionDigits: Int = 0,
        maximumFractionDigits: Int = 0,
        decimalSeparator: String? = nil,
        groupingSeparator: String? = nil,
        locale: Locale = .current
    ) -> String {
        if self.isNaN { return String(Double.nan) }
        // Format integer part with grouping according to locale
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.roundingMode = .down // truncate
        formatter.usesGroupingSeparator = true
        if let groupingSeparator {
            formatter.groupingSeparator = groupingSeparator
        }
        if let decimalSeparator {
            formatter.decimalSeparator = decimalSeparator
        }
        formatter.groupingSize = 3
        
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? String(format: "%.\(minimumFractionDigits)f", NSDecimalNumber(decimal: self))
    }
}
