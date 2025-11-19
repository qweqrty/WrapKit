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
        let snapshotName = "TEXTFIELD_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_default_isHidden() {
        let snapshotName = "TEXTFIELD_DEFAULT_ISHIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        sut.display(isHidden: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // TODO: - Doent show clear button
    func test_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEABUTTONACTIVE"
        
        // GIVEN
        let clearButton = makeIcon(systemName: "star.fill")
        let (sut, container) = makeSUT(trailingView: .clear(trailingView: clearButton))
        
        // WHEN
        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)
        
        sut.sendActions(for: .editingChanged)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - display(trailingSymbol:) tests
    func test_Textfield_trailing_symbol_with_mask() {
        let snapshotName = "TEXTFIELD_TRAILING_SYMBOL"
        
        // GIVEN
        let mask = Mask(format: [
            .literal("+"),
            .literal("7"),
            .literal(" "),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let (sut, container) = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        
        // WHEN
        sut.text = "123"
        sut.sendActions(for: .editingChanged)
        sut.display(trailingSymbol: " (Mobile)") // ← Добавляем суффикс
        
        // THEN - должно показать: +7 123 (Mobile)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_trailing_symbol_currency() {
        let snapshotName = "TEXTFIELD_CURRENCY_SYMBOL"
        
        // GIVEN
        let mask = Mask(format: [
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits),
            .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
        ])
        
        let (sut, container) = makeSUT()
        sut.display(mask: .init(mask: mask, maskColor: .systemGray))
        
        // WHEN
        sut.text = "1500"
        sut.sendActions(for: .editingChanged)
        sut.display(trailingSymbol: " USD")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_default_onPress() {
        let snapshotName = "TEXTFIELD_DEFAULT_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "DEFAULT STATE")
        sut.display(onPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
        })
        
        sut.onPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_onPaste() {
        let snapshotName = "TEXTFIELD_ONPASTE"
        
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
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_onTapBackspace() {
        let snapshotName = "TEXTFIELD_ONTAPBACKSPACE"
        
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
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - leadin, trailing view tests
    func test_Textfield_leadingView() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW"
        
        // GIVEN
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        
        let (sut, container) = makeSUT(
            leadingView: leadingIcon,
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_leadingView_isHidden() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ISHIDDEN"
        
        // GIVEN
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        
        let (sut, container) = makeSUT(
            leadingView: leadingIcon,
        )
        
        // WHEN
        sut.display(leadingViewIsHidden: true)
        sut.display(text: "Search query")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_trailingView_isHidden() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW_ISHIDDEN"
        
        // GIVEN
        let trailingView = makeIcon(systemName: "magnifyingglass")
        
        let (sut, container) = makeSUT(
            trailingView: .custom(trailingView: trailingView),
        )
        
        // WHEN
        sut.display(trailingViewIsHidden: true)
        sut.display(text: "Search query")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_trailingView() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW"
        
        // GIVEN
        let trailingIcon = makeIcon(systemName: "magnifyingglass")
        
        let (sut, container) = makeSUT(
            trailingView: .custom(trailingView: trailingIcon),
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_leadingView_onPress() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ONPRESS"
        
        // GIVEN
        let leadingIcon = makeIcon(systemName: "magnifyingglass")
        
        let (sut, container) = makeSUT(
            leadingView: leadingIcon,
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        sut.display(leadingViewOnPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
        })
            
        sut.leadingViewOnPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_trailingView_onPress() {
        let snapshotName = "TEXTFIELD_TRAILING_ONPRESS"
        
        // GIVEN
        let trailingView = makeIcon(systemName: "magnifyingglass")
        
        let (sut, container) = makeSUT(
            trailingView: .custom(trailingView: trailingView),
        )
        
        // WHEN
        sut.display(text: "Search query")
        
        sut.display(trailingViewOnPress: { [weak sut] in
            sut?.appearance.colors.deselectedBackgroundColor = .red
        })
            
        sut.trailingViewOnPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - disply(isSecureTextEntry:) tests
    func test_Textfield_isSecureText_false_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_FALSE_TEXT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_isSecureText_true_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_TRUE_TEXT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - display(isValid:) tests
    func test_Textfield_invalid_state() {
        let snapshotName = "TEXTFIELD_INVALID_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Invalid input")
        sut.display(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_valid_state() {
        let snapshotName = "TEXTFIELD_VALID_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "Valid input")
        sut.display(isValid: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - display(mask:) tests
    func test_Textfield_mask_as_placeholder() {
        let snapshotName = "TEXTFIELD_MASK_PLACEHOLDER"
        
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
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_invalid_with_placeholder() {
        let snapshotName = "TEXTFIELD_INVALID_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_phone_mask_partial() {
        let snapshotName = "TEXTFIELD_PHONE_MASK_PARTIAL"
        
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
        
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        
        sut.text = "123"
        sut.sendActions(for: .editingChanged)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_phone_mask_full() {
        let snapshotName = "TEXTFIELD_PHONE_MASK_FULL"
        
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
        
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        
        sut.text = "1234567890"
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_phone_mask_empty() {
        let snapshotName = "TEXTFIELD_PHONE_MASK_EMPTY"
        
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
        
        sut.display(mask: .init(mask: mask, maskColor: .lightGray))
        sut.text = ""
        sut.display(placeholder: "Enter phone number")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_credit_card_mask() {
        let snapshotName = "TEXTFIELD_CARD_MASK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_date_mask() {
        let snapshotName = "TEXTFIELD_DATE_MASK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_Textfield_mask_with_color() {
        let snapshotName = "TEXTFIELD_MASK_BLUE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
}

extension TextfieldSnapshotTests {
    func makeSUT(
        leadingView: ViewUIKit? = nil,
        trailingView: Textfield.TrailingViewStyle? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: Textfield, container: UIView) {
        
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
        
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
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
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
