//
//  TextViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by sunflow on 7/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

final class TextViewSnapshotTests: XCTestCase {
    func test_Textview_default_state() {
        let snapshotName = "TEXTVIEW_DEFAULT_STATE"
        
        // GIVEn
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_Textview_default_state() {
        let snapshotName = "TEXTVIEW_DEFAULT_STATE"
        
        // GIVEn
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE.")
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - display(mask:) tests
    func test_Textview_mask_as_placeholder() {
        let snapshotName = "TEXTVIEW_MASK_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("H"),
            .literal("E"),
            .literal("L"),
            .literal("L"),
            .literal("O")
        ])
        
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_Textview_mask_as_placeholder() {
        let snapshotName = "TEXTVIEW_MASK_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("H"),
            .literal("E"),
            .literal("L"),
            .literal("L"),
            .literal("O"),
            .literal("!")
        ])
        
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_Textview_with_masked_text() {
        let snapshotName = "TEXTVIEW_MASKED_INPUT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("+"),
            .literal("7"),
            .literal(" "),
            .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let inputText = "1234567"
        let maskedResult = mask.applied(to: inputText)
        
        sut.display(text: maskedResult.input)
        
        if !maskedResult.maskToInput.isEmpty {
            sut.placeholderLabel.text = maskedResult.maskToInput
            sut.placeholderLabel.isHidden = false
        }
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_Textview_with_masked_text() {
        let snapshotName = "TEXTVIEW_MASKED_INPUT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("+"),
            .literal("7"),
            .literal(" "),
            .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let inputText = "2234567"
        let maskedResult = mask.applied(to: inputText)
        
        sut.display(text: maskedResult.input)
        
        if !maskedResult.maskToInput.isEmpty {
            sut.placeholderLabel.text = maskedResult.maskToInput
            sut.placeholderLabel.isHidden = false
        }
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_Textview_mask_pattern() {
        let snapshotName = "TEXTVIEW_MASK_PATTERN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("+"),
            .literal("7"),
            .literal(" "),
            .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal("-"),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal("-"),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_Textview_mask_pattern() {
        let snapshotName = "TEXTVIEW_MASK_PATTERN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("+"),
            .literal("8"),
            .literal(" "),
            .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal("-"),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal("-"),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_Textview_mask_with_color() {
        let snapshotName = "TEXTVIEW_MASK_COLOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("C"),
            .literal("O"),
            .literal("L"),
            .literal("O"),
            .literal("O"),
            .literal("R")
        ])
        
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        sut.placeholderLabel.textColor = .systemRed
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_Textview_mask_with_color() {
        let snapshotName = "TEXTVIEW_MASK_COLOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("C"),
            .literal("O"),
            .literal("L"),
            .literal("O"),
            .literal("O"),
            .literal("R")
        ])
        
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        sut.placeholderLabel.textColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - display(isValid:) tests
    func test_TextView_invalid_state() {
        let snapshotName = "TEXTVIEW_INVALID_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Invalid text")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_invalid_state() {
        let snapshotName = "TEXTVIEW_INVALID_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Invalid text")
        sut.display(isValid: true)
        sut.updateAppearance(isValid: true)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_TextView_valid_state() {
        let snapshotName = "TEXTVIEW_VALID_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Valid text")
        sut.display(isValid: true)
        sut.updateAppearance(isValid: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_valid_state() {
        let snapshotName = "TEXTVIEW_VALID_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Valid text")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_TextView_valid_to_invalid_transition() {
        let snapshotName = "TEXTVIEW_VALIDATION_TRANSITION"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.updateAppearance(isValid: true)
        
        // WHEN - пользователь удалил часть текста, email стал невалидным
        sut.display(text: "test@")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_valid_to_invalid_transition() {
        let snapshotName = "TEXTVIEW_VALIDATION_TRANSITION"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.updateAppearance(isValid: true)
        
        // WHEN - пользователь удалил часть текста, email стал невалидным
        sut.display(text: "test@e")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_TextView_invalid_with_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_invalid_with_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Enter valid email.")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_TextView_invalid_with_text_and_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_WITH_TEXT_AND_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_invalid_with_text_and_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_WITH_TEXT_AND_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!.")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - display(placeholder:) tests
    func test_TextView_with_placeholder() {
        let snapshotName = "TEXTVIEW_WITH_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Placeholder")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_with_placeholder() {
        let snapshotName = "TEXTVIEW_WITH_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Placeholder.")
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - its better make unit test for this case
    func test_TextView_with_securityTextEntry() {
        let snapshotName = "TEXTVIEW_WITH_SECURITY_TEXT_ENTRY"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "password123")
        sut.display(isSecureTextEntry: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_with_securityTextEntry() {
        let snapshotName = "TEXTVIEW_WITH_SECURITY_TEXT_ENTRY"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "password1234")
        sut.display(isSecureTextEntry: true)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_TextView_onPress() {
        let snapshotName = "TEXTVIEW_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        sut.display(text: "ON PRESS")
        sut.display(onPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
            exp.fulfill()
        })
        
        sut.onPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_onPress() {
        let snapshotName = "TEXTVIEW_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        sut.display(text: "ON PRESS")
        sut.display(onPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .systemRed
            exp.fulfill()
        })
        
        sut.onPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_TextView_onPaste() {
        let snapshotName = "TEXTVIEW_ONPASTE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let text: String? = "Text to paste"
        
        sut.display(onPaste: { [weak sut]  text in
            sut?.display(text: text)
            exp.fulfill()
        })
        
        sut.onPaste?(text)
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_onPaste() {
        let snapshotName = "TEXTVIEW_ONPASTE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let text: String? = "Text to paste."
        
        sut.display(onPaste: { [weak sut]  text in
            sut?.display(text: text)
            exp.fulfill()
        })
        
        sut.onPaste?(text)
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - No realization for textView
    func test_TextView_onTapBackspace() {
        let snapshotName = "TEXTVIEW_ONTAPBACKSPACE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        sut.display(text: "Text to delete")
        sut.display(onTapBackspace: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
            exp.fulfill()
        })
        
        sut.deleteBackward()
        sut.onTapBackspace?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_onTapBackspace() {
        let snapshotName = "TEXTVIEW_ONTAPBACKSPACE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        sut.display(text: "Text to delete.")
        sut.display(onTapBackspace: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
            exp.fulfill()
        })
        
        sut.deleteBackward()
        sut.onTapBackspace?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - There are no realization for textView
    func test_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEARBUTTONACTIVE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEARBUTTONACTIVE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Clear button.")
        sut.display(isClearButtonActive: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - There are no realization for textView
    func test_TextView_trailingSymbol() {
        let snapshotName = "TEXTVIEW_TRAILINGSYMBOL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Clear button")
        sut.display(trailingSymbol: "X")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_TextView_trailingSymbol() {
        let snapshotName = "TEXTVIEW_TRAILINGSYMBOL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Clear button.")
        sut.display(trailingSymbol: "X")
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension TextViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: Textview, container: UIView) {
        let sut = Textview(appearance: .init(
            colors: .init(
                textColor: .blue,
                selectedBorderColor: .yellow,
                selectedBackgroundColor: .cyan,
                selectedErrorBorderColor: .red,
                errorBorderColor: .systemRed,
                errorBackgroundColor: .brown,
                deselectedBorderColor: .green,
                deselectedBackgroundColor: .orange,
                disabledTextColor: .purple,
                disabledBackgroundColor: .systemPurple),
            font: .systemFont(ofSize: 24),
            border: .init(
                idleBorderWidth: 2,
                selectedBorderWidth: 3)
        ))
        
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(300, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
