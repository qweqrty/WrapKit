#if canImport(SwiftUI)
@testable import WrapKit
import UIKit
import XCTest

final class SUITextInputEventBridgeTests: XCTestCase {
    func test_textFieldForwardsBackspaceAndPreservesOriginalDecision() {
        let originalDelegate = TextFieldDelegateStub(shouldChange: false)
        let textField = UITextField()
        textField.delegate = originalDelegate
        var backspaceCount = 0
        let callback = expectation(description: "Backspace callback")
        let sut = SUITextInputEventCoordinator(
            onTapBackspace: {
                backspaceCount += 1
                callback.fulfill()
            },
            onPaste: nil
        )

        sut.attach(to: textField)
        let shouldChange = sut.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: ""
        )

        XCTAssertEqual(backspaceCount, 0)
        XCTAssertFalse(shouldChange)
        XCTAssertTrue(textField.delegate === sut)
        wait(for: [callback], timeout: 1)
        XCTAssertEqual(backspaceCount, 1)
    }

    func test_textViewForwardsBackspaceAndPreservesOriginalDecision() {
        let originalDelegate = TextViewDelegateStub(shouldChange: false)
        let textView = UITextView()
        textView.delegate = originalDelegate
        var backspaceCount = 0
        let callback = expectation(description: "Backspace callback")
        let sut = SUITextInputEventCoordinator(
            onTapBackspace: {
                backspaceCount += 1
                callback.fulfill()
            },
            onPaste: nil
        )

        sut.attach(to: textView)
        let shouldChange = sut.textView(
            textView,
            shouldChangeTextIn: NSRange(location: 0, length: 0),
            replacementText: ""
        )

        XCTAssertEqual(backspaceCount, 0)
        XCTAssertFalse(shouldChange)
        XCTAssertTrue(textView.delegate === sut)
        wait(for: [callback], timeout: 1)
        XCTAssertEqual(backspaceCount, 1)
    }

    func test_textFieldBackspaceCallbackRunsAfterNativeTextMutation() {
        let textField = UITextField()
        textField.text = "AB"
        var textObservedByCallback: String?
        let callback = expectation(description: "Backspace callback")
        let sut = SUITextInputEventCoordinator(
            onTapBackspace: {
                textObservedByCallback = textField.text
                callback.fulfill()
            },
            onPaste: nil
        )

        sut.attach(to: textField)
        let shouldChange = sut.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 1, length: 1),
            replacementString: ""
        )
        XCTAssertTrue(shouldChange)
        XCTAssertNil(textObservedByCallback)

        // UIKit mutates the native control after the delegate returns.
        textField.text = "A"
        wait(for: [callback], timeout: 1)

        XCTAssertEqual(textObservedByCallback, "A")
    }

    func test_pasteCallbackInterceptsTextLikeUIKitOutput() {
        let textField = UITextField()
        var pastedText: String?
        let sut = SUITextInputEventCoordinator(
            onTapBackspace: nil,
            onPaste: { pastedText = $0 }
        )
        sut.attach(to: textField)
        guard let range = textField.textRange(
            from: textField.beginningOfDocument,
            to: textField.beginningOfDocument
        ) else { return XCTFail("Expected an empty text range") }

        let resultingRange = sut.textPasteConfigurationSupporting(
            textField,
            performPasteOf: NSAttributedString(string: "Pasted value"),
            to: range
        )

        XCTAssertEqual(pastedText, "Pasted value")
        XCTAssertTrue(resultingRange === range)
        XCTAssertTrue(textField.pasteDelegate === sut)
    }

    func test_removingPasteCallbackRestoresOriginalPasteDelegate() {
        let originalDelegate = TextPasteDelegateStub()
        let textField = UITextField()
        textField.pasteDelegate = originalDelegate
        let sut = SUITextInputEventCoordinator(
            onTapBackspace: nil,
            onPaste: { _ in }
        )
        sut.attach(to: textField)

        sut.update(onTapBackspace: nil, onPaste: nil)

        XCTAssertTrue(textField.pasteDelegate === originalDelegate)
    }

    func test_trailingSymbolWithoutMask_doesNotAlterUserTextLikeUIKit() {
        let adapter = TextInputOutputSwiftUIAdapter()
        adapter.display(model: .init(text: "10", trailingSymbol: "%"))
        let sut = SUITextInputStateModel(adapter: adapter)

        sut.applyUserText("100%")

        XCTAssertEqual(sut.text, "100%")
    }

    func test_chunkedFullModel_matchesUIKitTextAndValidityScope() {
        let adapter = TextInputOutputSwiftUIAdapter()
        let sut = SUITextInputStateModel(
            adapter: adapter,
            consumer: .chunkedTextField,
            chunkedCharacterCount: 4
        )

        adapter.display(model: .init(
            accessibilityIdentifier: "verification-code",
            text: "12",
            isValid: false,
            isEnabledForEditing: false,
            isTextSelectionDisabled: true,
            isUserInteractionEnabled: false,
            isSecureTextEntry: true,
            inputType: .numberPad,
            onPaste: { _ in },
            onTapBackspace: { }
        ))

        XCTAssertEqual(sut.text, "12")
        XCTAssertEqual(sut.chunkedCharacters, ["1", "2", "", ""])
        XCTAssertFalse(sut.isValid)
        XCTAssertTrue(sut.isEnabledForEditing)
        XCTAssertTrue(sut.isUserInteractionEnabled)
        XCTAssertFalse(sut.isTextSelectionDisabled)
        XCTAssertFalse(sut.isSecureTextEntry)
        XCTAssertEqual(sut.keyboardType, .default)
        XCTAssertNil(sut.accessibilityIdentifier)
        XCTAssertNil(sut.onTapBackspace)
        XCTAssertNil(sut.onPaste)
    }

    func test_disablingEditingRequestsResignLikeUIKitTextfield() {
        let adapter = TextInputOutputSwiftUIAdapter()
        let sut = SUITextInputStateModel(adapter: adapter)

        adapter.display(isEnabledForEditing: false)

        XCTAssertFalse(sut.isEnabledForEditing)
        XCTAssertTrue(sut.shouldResignFirstResponder)
    }

    func test_disablingInteractionRequestsResignLikeUIKitTextView() {
        let adapter = TextInputOutputSwiftUIAdapter()
        let sut = SUITextInputStateModel(adapter: adapter, consumer: .textView)

        adapter.display(isUserInteractionEnabled: false)

        XCTAssertFalse(sut.isUserInteractionEnabled)
        XCTAssertTrue(sut.shouldResignFirstResponder)
    }
}

private final class TextFieldDelegateStub: NSObject, UITextFieldDelegate {
    let shouldChange: Bool

    init(shouldChange: Bool) {
        self.shouldChange = shouldChange
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        shouldChange
    }
}

private final class TextViewDelegateStub: NSObject, UITextViewDelegate {
    let shouldChange: Bool

    init(shouldChange: Bool) {
        self.shouldChange = shouldChange
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        shouldChange
    }
}

private final class TextPasteDelegateStub: NSObject, UITextPasteDelegate {}
#endif
