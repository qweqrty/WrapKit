//
//  Double+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Double {
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Double) -> Double {
        let intDiv = Double(Int(self / nearest))
        return intDiv * nearest
    }
    
    func asString(withDecimalPlaces count: Int) -> String {
        return String(format: "%.\(count)f", self)
    }
}

public extension Float {
    func round(nearest: Float) -> Float {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Float) -> Float {
        let intDiv = Float(Int(self / nearest))
        return intDiv * nearest
    }
    
    func asString(withDecimalPlaces count: Int, separator: Character = ".") -> String {
        return String(format: "%.\(count)f", self)
    }
}
