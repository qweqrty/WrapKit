//
//  KeyboardType+Mask.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/5/24.
//

#if canImport(UIKit)
import UIKit

public extension Masking {
    func keyboardType() -> UIKeyboardType {
        var allowsDecimalNumbers = false
        var allowsLetters = false
        var allowsNumbers = false
        var allowsSymbols = false

        for maskedCharacter in format {
            switch maskedCharacter {
            case .literal:
                continue
            case .specifier(_, let allowedCharacters):
                if allowedCharacters.isSuperset(of: .decimalDigits) {
                    allowsNumbers = true
                    if ".".rangeOfCharacter(from: allowedCharacters) != nil || ",".rangeOfCharacter(from: allowedCharacters) != nil {
                        allowsDecimalNumbers = true
                    }
                }
                if allowedCharacters.isSuperset(of: .letters) {
                    allowsLetters = true
                }
                // Check for symbols
                if allowedCharacters.isSuperset(of: .symbols) ||
                   allowedCharacters.subtracting(.letters).subtracting(.decimalDigits).isEmpty == false {
                    allowsSymbols = true
                }
            }
        }

        if allowsSymbols {
            return .asciiCapable
        } else if allowsDecimalNumbers && !allowsLetters {
            return .decimalPad
        } else if allowsNumbers && !allowsLetters {
            return .numberPad
        } else if allowsLetters && !allowsNumbers {
            return .alphabet
        } else {
            return .default
        }
    }
}

#endif
