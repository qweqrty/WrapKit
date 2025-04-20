//
//  Double+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Double {
    func round(nearest: Double) -> Double {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Double) -> Double {
        let intDiv = Double(Int(self / nearest))
        return intDiv * nearest
    }

    func asString(withDecimalPlaces count: Int = 0, locale: Locale = .current) -> String {
        // Use String(format:) to control decimal places directly
        let format = "%.\(count)f"
        // Split the number into integer and fractional parts
        let multiplier = pow(10.0, Double(count))
        let intPart = Int(self)
        let fracPart = Int((self - Double(intPart)) * multiplier)
        return String(format: format, Double(intPart) + Double(fracPart) / multiplier)
    }
}

public extension Float {
    func round(nearest: Float) -> Float {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Float) -> Float {
        let intDiv = Float(Int(self / nearest))
        return intDiv * nearest
    }

    func asString(withDecimalPlaces count: Int = 0, locale: Locale = .current) -> String {
            // Use String(format:) to control decimal places directly
            let format = "%.\(count)f"
            // Split the number into integer and fractional parts
            let multiplier = pow(10.0, Float(count))
            let intPart = Int(self)
            let fracPart = Int((self - Float(intPart)) * multiplier)
            return String(format: format, Float(intPart) + Float(fracPart) / multiplier)
        }
}

public extension Int {
    func asString(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
