import Foundation
import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import SwiftUI
#endif

final class TextfieldSnapshotTests: XCTestCase {

    func test_Textfield_default_state() {
        let snapshotName = "TEXTFIELD_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_default_state() {
        let snapshotName = "TEXTFIELD_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE.")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_default_isHidden() {
        let snapshotName = "TEXTFIELD_DEFAULT_ISHIDDEN"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        sut.display(isHidden: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_default_isHidden() {
        let snapshotName = "TEXTFIELD_DEFAULT_ISHIDDEN"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        sut.display(isHidden: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEABUTTONACTIVE"
        let clearButton = makeIcon(systemName: "star.fill")
        let sut = makeSUT(
            trailingView: .clear(trailingView: clearButton),
            trailingSwiftUIView: makeSwiftUIIcon(systemName: "star.fill")
        )

        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEABUTTONACTIVE"
        let clearButton = makeIcon(systemName: "star.fill")
        let sut = makeSUT(
            trailingView: .clear(trailingView: clearButton),
            trailingSwiftUIView: makeSwiftUIIcon(systemName: "star.fill")
        )

        sut.display(text: "Clear button.")
        sut.display(isClearButtonActive: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_trailing_symbol_with_mask() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_TRAILING_SYMBOL"
        let mask = Mask(format: [
            .literal("+"), .literal("7"), .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        let sut = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("123")
        sut.display(trailingSymbol: " (Mobile)")

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_trailing_symbol_with_mask() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_TRAILING_SYMBOL"
        let mask = Mask(format: [
            .literal("+"), .literal("7"), .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        let sut = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("123")
        sut.display(trailingSymbol: " (Mobile.)")

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textfield_trailing_symbol_currency() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_CURRENCY_SYMBOL"
        let mask = Mask(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        let sut = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .systemGray))
        sut.simulateUserTyping("1500")
        sut.display(trailingSymbol: " USD")

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_trailing_symbol_currency() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_CURRENCY_SYMBOL"
        let mask = Mask(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        let sut = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .systemGray))
        sut.simulateUserTyping("1500")
        sut.display(trailingSymbol: " USD.")

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textfield_default_onPress() {
        let snapshotName = "TEXTFIELD_DEFAULT_ONPRESS"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        sut.display(onPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
        })
        sut.onPress?()

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_default_onPress() {
        let snapshotName = "TEXTFIELD_DEFAULT_ONPRESS"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        sut.display(onPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.systemRed)
        })
        sut.onPress?()

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_onPaste() {
        let snapshotName = "TEXTFIELD_ONPASTE"
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

    func test_fail_Textfield_onPaste() {
        let snapshotName = "TEXTFIELD_ONPASTE"
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

    func test_Textfield_onTapBackspace() {
        let exclusionReason = "Native SwiftUI TextField on iOS 15 does not expose deleteBackward, so this UIKit-driven callback cannot be replayed without replacing the renderer."
        let snapshotName = "TEXTFIELD_ONTAPBACKSPACE"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(text: "Text to delete")
        sut.display(onTapBackspace: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
            exp.fulfill()
        })
        sut.deleteBackward()
        wait(for: [exp], timeout: 1.0)

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_onTapBackspace() {
        let exclusionReason = "Native SwiftUI TextField on iOS 15 does not expose deleteBackward, so this UIKit-driven callback cannot be replayed without replacing the renderer."
        let snapshotName = "TEXTFIELD_ONTAPBACKSPACE"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(text: "Text to delete.")
        sut.display(onTapBackspace: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
            exp.fulfill()
        })
        sut.deleteBackward()
        wait(for: [exp], timeout: 1.0)

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textfield_leadingView() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW"
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(leadingView: leadingIcon, leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(text: "Search query")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_leadingView() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW"
        let leadingIcon = makeIcon(systemName: "mmagnifyingglass.circle.fill")
        let sut = makeSUT(leadingView: leadingIcon, leadingSwiftUIView: makeSwiftUIIcon(systemName: "mmagnifyingglass.circle.fill"))

        sut.display(text: "Search query")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_leadingView_isHidden() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ISHIDDEN"
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(leadingView: leadingIcon, leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(leadingViewIsHidden: true)
        sut.display(text: "Search query")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_leadingView_isHidden() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ISHIDDEN"
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(leadingView: leadingIcon, leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(leadingViewIsHidden: false)
        sut.display(text: "Search query")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_trailingView_isHidden() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW_ISHIDDEN"
        let trailingView = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(trailingView: .custom(trailingView: trailingView), trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(trailingViewIsHidden: true)
        sut.display(text: "Search query")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_trailingView_isHidden() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW_ISHIDDEN"
        let trailingView = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(trailingView: .custom(trailingView: trailingView), trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(trailingViewIsHidden: false)
        sut.display(text: "Search query")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_trailingView() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW"
        let trailingIcon = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(trailingView: .custom(trailingView: trailingIcon), trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(text: "Search query")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_trailingView() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW"
        let trailingIcon = makeIcon(systemName: "magnifyingglass.circle.fill")
        let sut = makeSUT(trailingView: .custom(trailingView: trailingIcon), trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass.circle.fill"))

        sut.display(text: "Search query")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_leadingView_onPress() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ONPRESS"
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(
            leadingView: leadingIcon,
            leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        sut.display(leadingViewOnPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
        })
        sut.leadingViewOnPress?()

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_leadingView_onPress() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ONPRESS"
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(
            leadingView: leadingIcon,
            leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        sut.display(leadingViewOnPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.systemRed)
        })
        sut.leadingViewOnPress?()

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_trailingView_onPress() {
        let snapshotName = "TEXTFIELD_TRAILING_ONPRESS"
        let trailingView = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(
            trailingView: .custom(trailingView: trailingView),
            trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        sut.display(trailingViewOnPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.red)
        })
        sut.trailingViewOnPress?()

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_trailingView_onPress() {
        let snapshotName = "TEXTFIELD_TRAILING_ONPRESS"
        let trailingView = makeIcon(systemName: "magnifyingglass")
        let sut = makeSUT(
            trailingView: .custom(trailingView: trailingView),
            trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        sut.display(trailingViewOnPress: { [weak sut] in
            sut?.setDeselectedBackgroundColor(.systemRed)
        })
        sut.trailingViewOnPress?()

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_isSecureText_false_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_FALSE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_isSecureText_false_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_FALSE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_isSecureText_true_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_TRUE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_isSecureText_true_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_TRUE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_invalid_state() {
        let snapshotName = "TEXTFIELD_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid input")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_invalid_state() {
        let snapshotName = "TEXTFIELD_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid input")
        sut.display(isValid: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_valid_state() {
        let snapshotName = "TEXTFIELD_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid input")
        sut.display(isValid: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_valid_state() {
        let snapshotName = "TEXTFIELD_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid input")
        sut.display(isValid: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_mask_as_placeholder() {
        let snapshotName = "TEXTFIELD_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("O")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_mask_as_placeholder() {
        let snapshotName = "TEXTFIELD_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("o")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_invalid_with_placeholder() {
        let snapshotName = "TEXTFIELD_INVALID_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_Textfield_invalid_with_placeholder() {
        let snapshotName = "TEXTFIELD_INVALID_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Enter valid email.")
        sut.display(isValid: false)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_textfield_emoji() {
        let snapshotName = "TEXTFIELD_EMOJI_STATE"
        let sut = makeSUT()

        sut.display(model: .init(text: "it's fine 🙂"))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_textfield_utfLikeText() {
        let snapshotName = "TEXTFIELD_FAKE_EMOJI_STATE"
        let sut = makeSUT()

        sut.display(model: .init(text: "Saima 500+O!TV- SALE 30%_850"))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_Textfield_phone_mask_partial() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_PHONE_MASK_PARTIAL"
        let sut = makeSUT()
        let mask = makePhoneMask(countryCode: "7")
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("123")

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_phone_mask_partial() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_PHONE_MASK_PARTIAL"
        let sut = makeSUT()
        let mask = makePhoneMask(countryCode: "8")
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("123")

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textfield_phone_mask_full() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_PHONE_MASK_FULL"
        let sut = makeSUT()
        let mask = makePhoneMask(countryCode: "7")
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("1234567890")

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_phone_mask_full() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_PHONE_MASK_FULL"
        let sut = makeSUT()
        let mask = makePhoneMask(countryCode: "8")
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("1234567890")

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textfield_phone_mask_empty() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_PHONE_MASK_EMPTY"
        let sut = makeSUT()
        let mask = makePhoneMask(countryCode: "7")
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("")
        sut.display(placeholder: "Enter phone number")

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_phone_mask_empty() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_PHONE_MASK_EMPTY"
        let sut = makeSUT()
        let mask = makePhoneMask(countryCode: "7")
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.simulateUserTyping("123")
        sut.display(placeholder: "Enter phone number")

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_Textfield_mask_with_color() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_MASK_BLUE"
        let sut = makeSUT()
        let mask = Mask(format: [
            .literal("C"), .literal("O"), .literal("D"), .literal("E"), .literal(":"), .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        sut.display(mask: .init(mask: mask, maskColor: .blue))
        sut.simulateUserTyping("12")

        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }

    func test_fail_Textfield_mask_with_color() {
        let exclusionReason = "masked user input needs an independent SwiftUI interaction driver"
        let snapshotName = "TEXTFIELD_MASK_BLUE"
        let sut = makeSUT()
        let mask = Mask(format: [
            .literal("C"), .literal("O"), .literal("D"), .literal("E"), .literal(":"), .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        sut.display(mask: .init(mask: mask, maskColor: .systemBlue))
        sut.simulateUserTyping("12")

        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: exclusionReason)
    }
}

extension TextfieldSnapshotTests {
    func makeSwiftUIIcon(systemName: String) -> AnyView {
        let image = makeSnapshotIconImage(systemName: systemName)
        return AnyView(
            Image(uiImage: image)
                .resizable()
                .frame(width: 24, height: 24)
                .fixedSize(horizontal: true, vertical: true)
        )
    }

    func makePhoneMask(countryCode: String) -> Mask {
        let code: Character = countryCode.first ?? "7"
        return Mask(format: [
            .literal("+"), .literal(code), .literal(" "), .literal("("),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(")"), .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
    }

    func makeSUT(
        leadingView: ViewUIKit? = nil,
        trailingView: Textfield.TrailingViewStyle? = nil,
        leadingSwiftUIView: AnyView? = nil,
        trailingSwiftUIView: AnyView? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PairedTextfieldSnapshotSUT {
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
            border: .init(idleBorderWidth: 2, selectedBorderWidth: 3),
            placeholder: .init(color: .systemGray, font: .systemFont(ofSize: 20))
        )

        let uiKitView = Textfield(
            appearance: appearance,
            leadingView: leadingView,
            trailingView: trailingView
        )

        let container = makeContainer()
        let sut = PairedTextfieldSnapshotSUT(
            appearance: appearance,
            uiKitContainer: container,
            uiKitView: uiKitView,
            leadingSwiftUIView: leadingSwiftUIView,
            trailingSwiftUIView: trailingSwiftUIView
        )
        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeIcon(systemName: String, tintColor: UIColor = .systemGray) -> ViewUIKit {
        let container = ViewUIKit()
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }

    func makeSnapshotIconImage(
        systemName: String,
        tintColor: UIColor = .systemGray
    ) -> UIImage {
        guard let symbol = UIImage(systemName: systemName),
              symbol.size.width > 0,
              symbol.size.height > 0 else { return UIImage() }

        let canvasSize = CGSize(width: 24, height: 24)
        let scale = min(
            canvasSize.width / symbol.size.width,
            canvasSize.height / symbol.size.height
        )
        let renderedSize = CGSize(
            width: symbol.size.width * scale,
            height: symbol.size.height * scale
        )
        let drawRect = CGRect(
            x: (canvasSize.width - renderedSize.width) / 2,
            y: (canvasSize.height - renderedSize.height) / 2,
            width: renderedSize.width,
            height: renderedSize.height
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        format.preferredRange = .standard

        return UIGraphicsImageRenderer(size: canvasSize, format: format).image { _ in
            symbol
                .withTintColor(tintColor, renderingMode: .alwaysOriginal)
                .draw(in: drawRect)
        }
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}

extension UITextField {
    func simulateUserTyping(_ string: String) {
        if !isFirstResponder { _ = becomeFirstResponder() }
        ensureCaretExists()
        for ch in string {
            simulateUserReplace(selectedNSRangeOrCaret(), with: String(ch))
        }
    }

    func simulateUserReplace(_ range: NSRange, with replacement: String) {
        let current = text ?? ""
        if let delegate = delegate,
           delegate.responds(to: #selector(UITextFieldDelegate.textField(_:shouldChangeCharactersIn:replacementString:))) {
            let allowed = delegate.textField?(self, shouldChangeCharactersIn: range, replacementString: replacement) ?? true
            guard allowed else { return }
        }
        if let r = Range(range, in: current) {
            text = current.replacingCharacters(in: r, with: replacement)
        } else {
            text = current + replacement
        }
        let newCaretOffset = range.location + replacement.count
        if let newPos = position(from: beginningOfDocument, offset: newCaretOffset) {
            selectedTextRange = textRange(from: newPos, to: newPos)
        }
        sendActions(for: .editingChanged)
    }

    private func ensureCaretExists() {
        if selectedTextRange == nil {
            let end = endOfDocument
            selectedTextRange = textRange(from: end, to: end)
        }
    }

    private func selectedNSRangeOrCaret() -> NSRange {
        ensureCaretExists()
        guard let range = selectedTextRange else {
            return NSRange(location: (text ?? "").count, length: 0)
        }
        let loc = offset(from: beginningOfDocument, to: range.start)
        let len = offset(from: range.start, to: range.end)
        return NSRange(location: loc, length: len)
    }
}
