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
        
        for maskedCharacter in format {
            switch maskedCharacter {
            case .literal:
                continue
            case .specifier(_, let allowedCharacters):
                if allowedCharacters.isSuperset(of: .decimalDigits) {
                    allowsNumbers = true
                    if allowedCharacters.contains(Character(".")) || allowedCharacters.contains(Character(",")) {
                        allowsDecimalNumbers = true
                    }
                }
                if allowedCharacters.isSuperset(of: .letters) {
                    allowsLetters = true
                }
            }
        }
        
        if allowsDecimalNumbers && !allowsLetters {
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
