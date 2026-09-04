//
//  SUITextViewSnapshotTests.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUITextViewSnapshotTests: XCTestCase {

    func test_Textview_default_state() {
        let snapshotName = "TEXTVIEW_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textview_default_state() {
        let snapshotName = "TEXTVIEW_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE.")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textview_mask_as_placeholder() {
        let snapshotName = "TEXTVIEW_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("O")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textview_mask_as_placeholder() {
        let snapshotName = "TEXTVIEW_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("O"), .literal("!")])
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textview_mask_pattern() {
        let snapshotName = "TEXTVIEW_MASK_PATTERN"
        let sut = makeSUT()

        let mask = makeFullPhoneMask(countryCode: "7")
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textview_mask_pattern() {
        let snapshotName = "TEXTVIEW_MASK_PATTERN"
        let sut = makeSUT()

        let mask = makeFullPhoneMask(countryCode: "8")
        let result = mask.applied(to: "")
        sut.display(placeholder: result.input + result.maskToInput)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_invalid_state() {
        let snapshotName = "TEXTVIEW_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid text")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_invalid_state() {
        let snapshotName = "TEXTVIEW_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid text")
        sut.display(isValid: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_valid_state() {
        let snapshotName = "TEXTVIEW_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid text")
        sut.display(isValid: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_valid_state() {
        let snapshotName = "TEXTVIEW_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid text")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_valid_to_invalid_transition() {
        let snapshotName = "TEXTVIEW_VALIDATION_TRANSITION"
        let sut = makeSUT()

        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.display(text: "test@")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_valid_to_invalid_transition() {
        let snapshotName = "TEXTVIEW_VALIDATION_TRANSITION"
        let sut = makeSUT()

        sut.display(text: "test@email")
        sut.display(isValid: true)
        sut.display(text: "test@e")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_invalid_with_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Enter valid email")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_invalid_with_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Enter valid email.")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_invalid_with_text_and_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_WITH_TEXT_AND_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_invalid_with_text_and_placeholder() {
        let snapshotName = "TEXTVIEW_INVALID_WITH_TEXT_AND_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "This placeholder won't be visible")
        sut.display(text: "Invalid input!.")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_with_placeholder() {
        let snapshotName = "TEXTVIEW_WITH_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Placeholder")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_with_placeholder() {
        let snapshotName = "TEXTVIEW_WITH_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Placeholder.")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_with_securityTextEntry() {
        let snapshotName = "TEXTVIEW_WITH_SECURITY_TEXT_ENTRY"
        let sut = makeSUT()

        sut.display(text: "password123")
        sut.display(isSecureTextEntry: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEARBUTTONACTIVE"
        let sut = makeSUT()

        sut.display(text: "Clear button")
        sut.display(isClearButtonActive: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_clearButtonActive() {
        let snapshotName = "TEXTVIEW_CLEARBUTTONACTIVE"
        let sut = makeSUT()

        sut.display(text: "Clear button.")
        sut.display(isClearButtonActive: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_TextView_trailingSymbol() {
        let snapshotName = "TEXTVIEW_TRAILINGSYMBOL"
        let sut = makeSUT()

        sut.display(text: "Clear button")
        sut.display(trailingSymbol: "X")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_TextView_trailingSymbol() {
        let snapshotName = "TEXTVIEW_TRAILINGSYMBOL"
        let sut = makeSUT()

        sut.display(text: "Clear button.")
        sut.display(trailingSymbol: "X")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_textview_emoji() {
        let snapshotName = "TEXTVIEW_EMOJI_STATE"
        let sut = makeSUT()

        sut.display(model: .init(text: "it's fine 🙂"))

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_textview_utfLikeText() {
        let snapshotName = "TEXTVIEW_FAKE_EMOJI_STATE"
        let sut = makeSUT()

        sut.display(model: .init(text: "Saima 500+O!TV- SALE 30%_850"))

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

}

@available(iOS 17.0, *)
extension SUITextViewSnapshotTests {
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
    ) -> SwiftUITextViewSnapshotSUT {
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
        let sut = SwiftUITextViewSnapshotSUT(
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
