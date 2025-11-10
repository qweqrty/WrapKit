//
//  TextfieldSnapshotTests.swift
//  WrapKitTests
//
//  Created by sunflow on 10/11/25.
//

import Foundation
import WrapKit
import WrapKitTestUtils
import XCTest

final class TextfieldSnapshotTests: XCTestCase {
    func test_Textfield_default_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_DEFAULT_STATE_DARK")
    }
    
    func test_Textfield_default_isHidden() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        sut.display(isHidden: true)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_DEFAULT_ISHIDDEN_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_DEFAULT_ISHIDDEN_DARK")
    }
    
    // TODO: - Doent show clear button
    func test_TextView_clearButtonActive() {
        // GIVEN
        let clearButton = makeIcon(systemName: "star.fill")
        let sut = makeSUT(trailingView: .clear(trailingView: clearButton))
        
        // WHEN
        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)
        
        sut.sendActions(for: .editingChanged)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTVIEW_CLEABUTTONACTIVE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTVIEW_CLEABUTTONACTIVE_DARK")
    }
    
    // MARK: - display(trailingSymbol:) tests
    func test_Textfield_trailing_symbol_with_mask() {
        // GIVEN
        let mask = Mask(format: [
            .literal("+"),
            .literal("7"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let sut = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        
        // WHEN
        sut.text = "123"
        sut.sendActions(for: .editingChanged)
        sut.display(trailingSymbol: " (Mobile)") // ← Добавляем суффикс
        
        // THEN - должно показать: +7 123 (Mobile)
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_TRAILING_SYMBOL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_TRAILING_SYMBOL_DARK")
    }
    
    func test_Textfield_trailing_symbol_currency() {
        // GIVEN
        let mask = Mask(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let sut = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .systemGray))
        
        // WHEN
        sut.text = "1500"
        sut.sendActions(for: .editingChanged)
        sut.display(trailingSymbol: " USD")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_CURRENCY_SYMBOL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_CURRENCY_SYMBOL_DARK")
    }
    
    func test_Textfield_default_onPress() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        sut.display(onPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
        })
        
        sut.onPress?()
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_DEFAULT_ONPRESS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_DEFAULT_ONPRESS_DARK")
    }
    
    func test_Textfield_onPaste() {
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_ONPASTE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_ONPASTE_DARK")
    }
    
    func test_Textfield_onTapBackspace() {
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
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_ONTAPBACKSPACE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_ONTAPBACKSPACE_DARK")
    }
    
    // MARK: - leadin, trailing view tests
    func test_Textfield_leadingView() {
        // GIVEN
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        
        let sut = makeSUT(
            leadingView: leadingIcon,
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_LEADINGVIEW__LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_LEADINGVIEW_DARK")
    }
    
    func test_Textfield_leadingView_isHidden() {
        // GIVEN
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        
        let sut = makeSUT(
            leadingView: leadingIcon,
        )
        
        // WHEN
        sut.display(leadingViewIsHidden: true)
        sut.display(text: "Search query")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_LEADINGVIEW_ISHIDDEN_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_LEADINGVIEW_ISHIDDEN_DARK")
    }
    
    func test_Textfield_trailingView_isHidden() {
        // GIVEN
        let trailingView = makeIcon(systemName: "magnifyingglass")
        
        let sut = makeSUT(
            trailingView: .custom(trailingView: trailingView),
        )
        
        // WHEN
        sut.display(trailingViewIsHidden: true)
        sut.display(text: "Search query")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_TRAILINGVIEW_ISHIDDEN_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_TRAILINGVIEW_ISHIDDEN_DARK")
    }
    
    func test_Textfield_trailingView() {
        // GIVEN
        let trailingIcon = makeIcon(systemName: "magnifyingglass")
        
        let sut = makeSUT(
            trailingView: .custom(trailingView: trailingIcon),
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_TRAILINGVIEW_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_TRAILINGVIEW_DARK")
    }
    
    func test_Textfield_leadingView_onPress() {
        // GIVEN
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        
        let sut = makeSUT(
            leadingView: leadingIcon,
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        sut.display(leadingViewOnPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
        })
            
        sut.leadingViewOnPress?()
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_LEADINGVIEW_ONPRESS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_LEADINGVIEW_ONPRESS_DARK")
    }
    
    func test_Textfield_trailingView_onPress() {
        // GIVEN
        let trailingView = makeIcon(systemName: "magnifyingglass")
        
        let sut = makeSUT(
            trailingView: .custom(trailingView: trailingView),
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        sut.display(trailingViewOnPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
        })
            
        sut.trailingViewOnPress?()
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_TRAILING_ONPRESS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_TRAILING_ONPRESS_DARK")
    }
    
    // MARK: - disply(isSecureTextEntry:) tests
    func test_Textfield_isSecureText_false_text() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_ISSECURETEXT_FALSE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_ISSECURETEXT_FALSEL_DARK")
    }
    
    func test_Textfield_isSecureText_true_text() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: true)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_ISSECURETEXT_TRUE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_ISSECURETEXT_TRUE_DARK")
    }
    
    // MARK: - display(isValid:) tests
    func test_Textfield_invalid_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "Invalid input")
        sut.display(isValid: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_INVALID_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_INVALID_DARK")
    }
    
    func test_Textfield_valid_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "Valid input")
        sut.display(isValid: true)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_VALID_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_VALID_DARK")
    }
    
    // MARK: - display(mask:) tests
    func test_Textfield_mask_as_placeholder() {
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_MASK_PLACEHOLDER_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_MASK_PLACEHOLDER_DARK")
    }
    
    func test_Textfield_invalid_with_placeholder() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_INVALID_PLACEHOLDER_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_INVALID_PLACEHOLDER_DARK")
    }
    
    func test_Textfield_phone_mask_partial() {
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
        
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        
        sut.text = "123"
        sut.sendActions(for: .editingChanged)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_PHONE_MASK_PARTIAL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_PHONE_MASK_PARTIAL_DARK")
    }
    
    func test_Textfield_phone_mask_full() {
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
        
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        
        sut.text = "1234567890"
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_PHONE_MASK_FULL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_PHONE_MASK_FULL_DARK")
    }
    
    func test_Textfield_phone_mask_empty() {
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
        
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.text = ""
        sut.display(placeholder: "Enter phone number")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_PHONE_MASK_EMPTY_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_PHONE_MASK_EMPTY_DARK")
    }
    
    func test_Textfield_credit_card_mask() {
        // GIVEN
        let sut = makeSUT()
        
        let mask = Mask(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        sut.display(mask: .init(mask: mask, maskColor: .systemGray))
        
        sut.text = "12345678"
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_CARD_MASK_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_CARD_MASK_DARK")
    }
    
    func test_Textfield_date_mask() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .specifier(placeholder: "D", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "D", allowedCharacters: .decimalDigits),
            .literal("/"),
            .specifier(placeholder: "M", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "M", allowedCharacters: .decimalDigits),
            .literal("/"),
            .specifier(placeholder: "Y", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "Y", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "Y", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "Y", allowedCharacters: .decimalDigits)
        ])
        
        sut.display(mask: .init(mask: mask, maskColor: .systemGray3))
        
        sut.text = "1512"
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_DATE_MASK_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_DATE_MASK_DARK")
    }
    
    func test_Textfield_mask_with_color() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let mask = Mask(format: [
            .literal("C"),
            .literal("O"),
            .literal("D"),
            .literal("E"),
            .literal(":"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        sut.display(mask: .init(mask: mask, maskColor: .blue))
        
        sut.text = "12"
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TEXTFIELD_MASK_BLUE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TEXTFIELD_MASK_BLUE_DARK")
    }
}

extension TextfieldSnapshotTests {
    func makeSUT(
        leadingView: ViewUIKit? = nil,
        trailingView: Textfield.TrailingViewStyle? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Textfield {
        
        let sut = Textfield(appearance:
                .init(
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
                        selectedBorderWidth: 3),
                    placeholder: .init(
                        color: .systemGray,
                        font: .systemFont(ofSize: 20))
                ),
                    leadingView: leadingView,
                    trailingView: trailingView
        )
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
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
    
    func makeLeadingLabel(text: String) -> ViewUIKit {
        let container = ViewUIKit()
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
}
