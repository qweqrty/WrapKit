//
//  TextViewSnapshotTests.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class TextViewSnapshotTests: XCTestCase {

    func test_Textview_default_state() {
        let snapshotName = "TEXTVIEW_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textview_default_state() {
        let snapshotName = "TEXTVIEW_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE.")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textview_mask_as_placeholder() {
        let snapshotName = "TEXTVIEW_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("O")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textview_mask_as_placeholder() {
        let snapshotName = "TEXTVIEW_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("O"), .literal("!")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textview_with_masked_text() {
        // UIKit implementation detail: this scenario mutates placeholderLabel directly and has no
        // TextInputOutput state that can be mirrored by the SwiftUI adapter.
        let snapshotName = "TEXTVIEW_MASKED_INPUT"
        let exclusionReason = "The scenario mutates UIKit placeholderLabel directly; no equivalent TextInputOutput state exists."
        let sut = makeSUT()

        let mask = makePhoneMask()
        let maskedResult = mask.applied(to: "1234567")
        sut.display(text: maskedResult.input)
        if !maskedResult.maskToInput.isEmpty {
            sut.placeholderLabel.text = maskedResult.maskToInput
            sut.placeholderLabel.isHidden = false
        }

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textview_with_masked_text() {
        let snapshotName = "TEXTVIEW_MASKED_INPUT"
        let exclusionReason = "The scenario mutates UIKit placeholderLabel directly; no equivalent TextInputOutput state exists."
        let sut = makeSUT()

        let mask = makePhoneMask()
        let maskedResult = mask.applied(to: "2234567")
        sut.display(text: maskedResult.input)
        if !maskedResult.maskToInput.isEmpty {
            sut.placeholderLabel.text = maskedResult.maskToInput
            sut.placeholderLabel.isHidden = false
        }

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textview_mask_pattern() {
        let snapshotName = "TEXTVIEW_MASK_PATTERN"
        let sut = makeSUT()

        let mask = makeFullPhoneMask(countryCode: "7")
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textview_mask_pattern() {
        let snapshotName = "TEXTVIEW_MASK_PATTERN"
        let sut = makeSUT()

        let mask = makeFullPhoneMask(countryCode: "8")
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textview_mask_with_color() {
        // UIKit implementation detail: this scenario mutates placeholderLabel directly and has no
        // TextInputOutput state that can be mirrored by the SwiftUI adapter.
        let snapshotName = "TEXTVIEW_MASK_COLOR"
        let exclusionReason = "The scenario mutates UIKit placeholderLabel color directly; no equivalent TextInputOutput state exists."
        let sut = makeSUT()

        let mask = Mask(format: [.literal("C"), .literal("O"), .literal("L"), .literal("O"), .literal("O"), .literal("R")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        sut.placeholderLabel.textColor = .systemRed

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textview_mask_with_color() {
        let snapshotName = "TEXTVIEW_MASK_COLOR"
        let exclusionReason = "The scenario mutates UIKit placeholderLabel color directly; no equivalent TextInputOutput state exists."
        let sut = makeSUT()

        let mask = Mask(format: [.literal("C"), .literal("O"), .literal("L"), .literal("O"), .literal("O"), .literal("R")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)
        sut.placeholderLabel.textColor = .red

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_TextView_invalid_state() {
        let snapshotName = "TEXTVIEW_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid text")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_invalid_state() {
        let snapshotName = "TEXTVIEW_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid text")
        sut.display(isValid: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_valid_state() {
        let snapshotName = "TEXTVIEW_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid text")
        sut.display(isValid: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_valid_state() {
        let snapshotName = "TEXTVIEW_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid text")
        sut.display(isValid: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_valid_to_invalid_transition() {
        let snapshotName = "TEXTVIEW_VALIDATION_TRANSITION"
        let sut = makeSUT()

        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.display(text: "test@")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_valid_to_invalid_transition() {
        let snapshotName = "TEXTVIEW_VALIDATION_TRANSITION"
        let sut = makeSUT()

        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.display(text: "test@e")
        sut.display(isValid: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_invalid_with_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_invalid_with_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Enter valid email.")
        sut.display(isValid: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_invalid_with_text_and_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_WITH_TEXT_AND_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_invalid_with_text_and_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_WITH_TEXT_AND_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!.")
        sut.display(isValid: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_with_placeholder() {
        let snapshotName = "TEXTVIEW_WITH_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Placeholder")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_with_placeholder() {
        let snapshotName = "TEXTVIEW_WITH_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Placeholder.")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_with_securityTextEntry() {
        let snapshotName = "TEXTVIEW_WITH_SECURITY_TEXT_ENTRY"
        let sut = makeSUT()

        sut.display(text: "password123")
        sut.display(isSecureTextEntry: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_TextView_onPress() {
        let snapshotName = "TEXTVIEW_ONPRESS"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(text: "ON PRESS")
        sut.display(onPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
            exp.fulfill()
        })
        sut.onPress?()
        wait(for: [exp], timeout: 1.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_onPress() {
        let snapshotName = "TEXTVIEW_ONPRESS"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(text: "ON PRESS")
        sut.display(onPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.systemRed)
            exp.fulfill()
        })
        sut.onPress?()
        wait(for: [exp], timeout: 1.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_onPaste() {
        let snapshotName = "TEXTVIEW_ONPASTE"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(onPaste: { [weak sut] text in
            sut?.display(text: text)
            exp.fulfill()
        })
        sut.onPaste?("Text to paste")
        wait(for: [exp], timeout: 1.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_onPaste() {
        let snapshotName = "TEXTVIEW_ONPASTE"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(onPaste: { [weak sut] text in
            sut?.display(text: text)
            exp.fulfill()
        })
        sut.onPaste?("Text to paste.")
        wait(for: [exp], timeout: 1.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_onTapBackspace() {
        let snapshotName = "TEXTVIEW_ONTAPBACKSPACE"
        let exclusionReason = "Native SwiftUI TextEditor on iOS 15 does not expose deleteBackward; this test invokes the stored UIKit callback manually."
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(text: "Text to delete")
        sut.display(onTapBackspace: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
            exp.fulfill()
        })
        sut.deleteBackward()
        sut.onTapBackspace?()
        wait(for: [exp], timeout: 1.0)

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_TextView_onTapBackspace() {
        let snapshotName = "TEXTVIEW_ONTAPBACKSPACE"
        let exclusionReason = "Native SwiftUI TextEditor on iOS 15 does not expose deleteBackward; this test invokes the stored UIKit callback manually."
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(text: "Text to delete.")
        sut.display(onTapBackspace: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
            exp.fulfill()
        })
        sut.deleteBackward()
        sut.onTapBackspace?()
        wait(for: [exp], timeout: 1.0)

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEARBUTTONACTIVE"
        let sut = makeSUT()

        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEARBUTTONACTIVE"
        let sut = makeSUT()

        sut.display(text: "Clear button.")
        sut.display(isClearButtonActive: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_trailingSymbol() {
        let snapshotName = "TEXTVIEW_TRAILINGSYMBOL"
        let sut = makeSUT()

        sut.display(text: "Clear button")
        sut.display(trailingSymbol: "X")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_trailingSymbol() {
        let snapshotName = "TEXTVIEW_TRAILINGSYMBOL"
        let sut = makeSUT()

        sut.display(text: "Clear button.")
        sut.display(trailingSymbol: "X")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_textview_emoji() {
        let snapshotName = "TEXTVIEW_EMOJI_STATE"
        let sut = makeSUT()

        sut.display(model: .init(text: "it's fine 🙂"))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_textview_utfLikeText() {
        let snapshotName = "TEXTVIEW_FAKE_EMOJI_STATE"
        let sut = makeSUT()

        sut.display(model: .init(text: "Saima 500+O!TV- SALE 30%_850"))

        assert(snapshot: sut, named: snapshotName)
    }
}

extension TextViewSnapshotTests {
    func makePhoneMask() -> Mask {
        Mask(format: [
            .literal("+"), .literal("7"), .literal(" "), .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"), .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
    }

    func makeFullPhoneMask(countryCode: String) -> Mask {
        let countryCodeChar: Character = countryCode.first ?? "7"
        return Mask(format: [
            .literal("+"), .literal(countryCodeChar), .literal(" "), .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"), .literal(" "),
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
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PairedTextViewSnapshotSUT {
        let appearance = TextfieldAppearance(
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
            border: .init(idleBorderWidth: 2, selectedBorderWidth: 3)
        )
        let container = makeContainer()
        let sut = PairedTextViewSnapshotSUT(
            appearance: appearance,
            uiKitContainer: container
        )

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(300, priority: .required)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
