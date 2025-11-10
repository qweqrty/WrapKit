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
        // GIVEn
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_DEFAULT_STATE_DARK")
    }
    
    // MARK: - display(mask:) tests
    func test_Textview_mask_as_placeholder() {
        // GIVEN
        let sut = makeSUT()
        
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_MASK_PLACEHOLDER_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_MASK_PLACEHOLDER_DARK")
    }
    
    func test_Textview_with_masked_text() {
        // GIVEN
        let sut = makeSUT()
        
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_MASKED_INPUT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_MASKED_INPUT_DARK")
    }
    
    func test_Textview_mask_pattern() {
        // GIVEN
        let sut = makeSUT()
        
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_MASK_PATTERN_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_MASK_PATTERN_DARK")
    }
    
    func test_Textview_mask_with_color() {
        // GIVEN
        let sut = makeSUT()
        
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_MASK_COLOR_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_MASK_COLOR_DARK")
    }
    
    // MARK: - display(isValid:) tests
    func test_TextView_invalid_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "Invalid text")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_INVALID_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_INVALID_STATE_DARK")
    }
    
    func test_TextView_valid_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "Valid text")
        sut.display(isValid: true)
        sut.updateAppearance(isValid: true)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_VALID_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_VALID_STATE_DARK")
    }
    
    func test_TextView_valid_to_invalid_transition() {
        // GIVEN
        let sut = makeSUT()
        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.updateAppearance(isValid: true)
        
        // WHEN - пользователь удалил часть текста, email стал невалидным
        sut.display(text: "test@")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_VALIDATION_TRANSITION_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_VALIDATION_TRANSITION_DARK")
    }
    
    func test_TextView_invalid_with_placeholder() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_INVALID_PLACEHOLDER_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_INVALID_PLACEHOLDER_DARK")
    }
    
    func test_TextView_invalid_with_text_and_placeholder() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!")
        sut.display(isValid: false)
        sut.updateAppearance(isValid: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_INVALID_WITH_TEXT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_INVALID_WITH_TEXT_DARK")
    }
    
    // MARK: - display(placeholder:) tests
    func test_TextView_with_placeholder() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Placeholder")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_WITH_PLACEHOLDER_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_WITH_PLACEHOLDER_DARK")
    }
    
    // TODO: - its better make unit test for this case
    func test_TextView_with_securityTextEntry() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "password123")
        sut.display(isSecureTextEntry: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_WITH_SECURITY_TEXT_ENTRY_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_WITH_SECURITY_TEXT_ENTRY_DARK")
    }
    
    func test_TextView_onPress() {
        // GIVEN
        let sut = makeSUT()
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_ONPRESS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_ONPRESS_DARK")
    }
    
    func test_TextView_onPaste() {
        // GIVEN
        let sut = makeSUT()
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_ONPASTE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_ONPASTE_DARK")
    }
    
    // TODO: - No realization for textView
    func test_TextView_onTapBackspace() {
        // GIVEN
        let sut = makeSUT()
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_ONTAPBACKSPACE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_ONTAPBACKSPACE_DARK")
    }
    
    // TODO: - There are no realization for textView
    func test_TextView_clearButtonActive() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_CLEABUTTONACTIVE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_CLEABUTTONACTIVE_DARK")
    }
    
    // TODO: - There are no realization for textView
    func test_TextView_trailingSymbol() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "Clear button")
        sut.display(trailingSymbol: "X")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_TRAILINGSYMBOL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_TRAILINGSYMBOL_DARK")
    }
}

extension TextViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Textview {
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
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        return sut
    }
}
