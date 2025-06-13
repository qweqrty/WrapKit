//
//  AmountMask.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 13/6/25.
//

import Foundation

/// A `Masking` implementation for monetary amounts, either integer-only or fixed-precision decimals.
public struct AmountMask: Masking {
    public let format: [MaskedCharacter] = []
    private let mode: Mode

    /// Defines whether this mask is integer-only or decimal with precision.
    public enum Mode {
        /// Only whole numbers, up to `maxDigits`.
        case integer(maxDigits: Int)
        /// Decimal numbers: up to `maxIntegerDigits` before the separator and up to `maxFractionDigits` after.
        case decimal(maxIntegerDigits: Int, maxFractionDigits: Int, separator: Character)
    }

    /// - Parameter integerMaxDigits: max count of digits for an integer mask.
    public init(integerMaxDigits: Int) {
        self.mode = .integer(maxDigits: integerMaxDigits)
    }

    /// - Parameters:
    ///   - maxIntegerDigits: max digits before the separator.
    ///   - maxFractionDigits: max digits after the separator.
    ///   - decimalSeparator: character to use as decimal point (default is `"."`).
    public init(maxIntegerDigits: Int, maxFractionDigits: Int, decimalSeparator: Character = ".") {
        self.mode = .decimal(
            maxIntegerDigits: maxIntegerDigits,
            maxFractionDigits: maxFractionDigits,
            separator: decimalSeparator
        )
    }
    
    public init(format: [MaskedCharacter]) {
        let specifierCount = format.reduce(into: 0) { count, masked in
            if case .specifier = masked { count += 1 }
        }
        self.mode = .integer(maxDigits: specifierCount)
    }

    public func applied(to text: String) -> (input: String, maskToInput: String) {
        // Filter only digits and (if decimal) separator
        let raw = text.filter { char in
            if char.isWholeNumber { return true }
            if case .decimal(_, _, let sep) = mode, char == sep { return true }
            return false
        }

        switch mode {
        case .integer(let maxDigits):
            // Only digits, limit count
            let digits = raw.filter { $0.isWholeNumber }
            let truncated = String(digits.prefix(maxDigits))
            return (truncated, "")

        case .decimal(let maxInt, let maxFrac, let sep):
            // Split at first separator
            var intPart = ""
            var fracPart = ""
            var seenSep = false

            for ch in raw {
                if ch == sep {
                    if !seenSep {
                        seenSep = true
                    }
                    continue
                }
                if !seenSep {
                    intPart.append(ch)
                } else {
                    fracPart.append(ch)
                }
            }

            // Truncate parts
            if intPart.count > maxInt {
                intPart = String(intPart.prefix(maxInt))
            }
            if fracPart.count > maxFrac {
                fracPart = String(fracPart.prefix(maxFrac))
            }

            // Reassemble
            let result: String
            if !fractionEmpty(fracPart) {
                result = intPart + String(sep) + fracPart
            } else if seenSep {
                // allow trailing separator if user typed it
                result = intPart + String(sep)
            } else {
                result = intPart
            }
            return (result, "")
        }
    }

    public func removeCharacters(from text: String, in range: NSRange) -> (input: String, maskToInput: String) {
        guard let start = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex),
              let end = text.index(start, offsetBy: range.length, limitedBy: text.endIndex) else {
            return (text, "")
        }
        var modified = text
        modified.removeSubrange(start..<end)
        let (input, _) = applied(to: modified)
        return (input, "")
    }

    public func extractUserInput(from text: String) -> String {
        return applied(to: text).input
    }

    public func isLiteralCharacter(at index: Int) -> Bool {
        return false
    }

    public func maxSpecifiersLength() -> Int {
        switch mode {
        case .integer(let maxDigits):
            return maxDigits
        case .decimal(let maxInt, let maxFrac, _):
            // +1 for separator
            return maxInt + (maxFrac > 0 ? 1 + maxFrac : 0)
        }
    }

    public func removeLiterals(from text: String) -> String {
        return applied(to: text).input
    }

    private func fractionEmpty(_ frac: String) -> Bool {
        return frac.isEmpty
    }
}
