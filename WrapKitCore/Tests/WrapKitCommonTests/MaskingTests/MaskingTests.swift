#if canImport(UIKit)
import XCTest
import UIKit
@testable import WrapKit

class MaskingKeyboardTypeTests: XCTestCase {

    // Mock Masking type for testing
    struct MockMasking: Masking {
        var format: [MaskedCharacter]

        init(format: [MaskedCharacter]) {
            self.format = format
        }

        func applied(to text: String) -> (input: String, maskToInput: String) {
            return (text, "") // Mock implementation
        }

        func removeCharacters(from text: String, in range: NSRange) -> (input: String, maskToInput: String) {
            return (text, "") // Mock implementation
        }

        func extractUserInput(from text: String) -> String {
            return text // Mock implementation
        }

        func isLiteralCharacter(at index: Int) -> Bool {
            return false // Mock implementation
        }

        func maxSpecifiersLength() -> Int {
            return format.filter {
                if case .specifier = $0 {
                    return true
                }
                return false
            }.count
        }

        func removeLiterals(from text: String) -> String {
            return text.filter { char in
                !format.contains(where: {
                    if case .literal(let literalChar) = $0 {
                        return literalChar == char
                    }
                    return false
                })
            }
        }
    }

    func testKeyboardType_withNumbersOnly() {
        // Given: Format allows only numbers
        let masking = MockMasking(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])

        // When
        let keyboardType = masking.keyboardType()

        // Then
        XCTAssertEqual(keyboardType, .numberPad)
    }

    func testKeyboardType_withDecimalNumbers() {
        // Given: Format allows decimal numbers
        let masking = MockMasking(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits.union(CharacterSet(charactersIn: ".,")))
        ])

        // When
        let keyboardType = masking.keyboardType()

        // Then
        XCTAssertEqual(keyboardType, .decimalPad)
    }

    func testKeyboardType_withLettersOnly() {
        // Given: Format allows only letters
        let masking = MockMasking(format: [
            .specifier(placeholder: "A", allowedCharacters: .letters)
        ])

        // When
        let keyboardType = masking.keyboardType()

        // Then
        XCTAssertEqual(keyboardType, .alphabet)
    }

    func testKeyboardType_withSymbols() {
        // Given: Format allows symbols
        let masking = MockMasking(format: [
            .specifier(placeholder: "*", allowedCharacters: .symbols)
        ])

        // When
        let keyboardType = masking.keyboardType()

        // Then
        XCTAssertEqual(keyboardType, .asciiCapable)
    }

    func testKeyboardType_withMixedLettersAndNumbers() {
        // Given: Format allows letters and numbers
        let masking = MockMasking(format: [
            .specifier(placeholder: "A", allowedCharacters: .letters.union(.decimalDigits))
        ])

        // When
        let keyboardType = masking.keyboardType()

        // Then
        XCTAssertEqual(keyboardType, .default)
    }

    func testKeyboardType_withDefaultFallback() {
        // Given: Format with no special characters
        let masking = MockMasking(format: [
            .literal("-")
        ])

        // When
        let keyboardType = masking.keyboardType()

        // Then
        XCTAssertEqual(keyboardType, .default)
    }
}
#endif
