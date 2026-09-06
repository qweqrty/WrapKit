import Foundation
import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 17.0, *)
final class SUITextfieldSnapshotTests: XCTestCase {

    func test_Textfield_default_state() {
        let snapshotName = "TEXTFIELD_DEFAULT_STATE"
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

    func test_fail_Textfield_default_state() {
        let snapshotName = "TEXTFIELD_DEFAULT_STATE"
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

    func test_Textfield_default_isHidden() {
        let snapshotName = "TEXTFIELD_DEFAULT_ISHIDDEN"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_default_isHidden() {
        let snapshotName = "TEXTFIELD_DEFAULT_ISHIDDEN"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_postOnPressCallback_visualState() {
        let snapshotName = "TEXTFIELD_DEFAULT_ONPRESS"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        let onPress: () -> Void = { [weak sut] in sut?.display(text: "PRESSED STATE") }
        sut.display(onPress: onPress)
        // The snapshot verifies only the Output state produced after the callback.
        onPress()

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_postOnPressCallback_visualState() {
        let snapshotName = "TEXTFIELD_DEFAULT_ONPRESS"
        let sut = makeSUT()

        sut.display(text: "DEFAULT STATE")
        let onPress: () -> Void = { [weak sut] in sut?.display(text: "PRESSED STATE.") }
        sut.display(onPress: onPress)
        // The snapshot verifies only the Output state produced after the callback.
        onPress()

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_postOnPasteCallback_visualState() {
        let snapshotName = "TEXTFIELD_ONPASTE"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        let onPaste: (String?) -> Void = { [weak sut] text in
            sut?.display(text: text)
            exp.fulfill()
        }
        sut.display(onPaste: onPaste)
        // The snapshot verifies only the Output state produced after the callback.
        onPaste("Text to paste")
        wait(for: [exp], timeout: 1.0)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_postOnPasteCallback_visualState() {
        let snapshotName = "TEXTFIELD_ONPASTE"
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        let onPaste: (String?) -> Void = { [weak sut] text in
            sut?.display(text: text)
            exp.fulfill()
        }
        sut.display(onPaste: onPaste)
        // The snapshot verifies only the Output state produced after the callback.
        onPaste("Text to paste.")
        wait(for: [exp], timeout: 1.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_postOnTapBackspaceCallback_visualState() {
        let snapshotName = "TEXTFIELD_ONTAPBACKSPACE"
        let sut = makeSUT()

        sut.display(text: "Text to delete")
        let onTapBackspace: () -> Void = { [weak sut] in sut?.display(text: "Text to delet") }
        sut.display(onTapBackspace: onTapBackspace)
        // The snapshot verifies only the Output state produced after the callback.
        onTapBackspace()

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_postOnTapBackspaceCallback_visualState() {
        let snapshotName = "TEXTFIELD_ONTAPBACKSPACE"
        let sut = makeSUT()

        sut.display(text: "Text to delete")
        let onTapBackspace: () -> Void = { [weak sut] in sut?.display(text: "Text to dele") }
        sut.display(onTapBackspace: onTapBackspace)
        // The snapshot verifies only the Output state produced after the callback.
        onTapBackspace()

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_leadingView() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW"
        let sut = makeSUT(leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_leadingView() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW"
        let sut = makeSUT(leadingSwiftUIView: makeSwiftUIIcon(systemName: "mmagnifyingglass.circle.fill"))

        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_leadingView_isHidden() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ISHIDDEN"
        let sut = makeSUT(leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(leadingViewIsHidden: true)
        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_leadingView_isHidden() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ISHIDDEN"
        let sut = makeSUT(leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(leadingViewIsHidden: false)
        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_trailingView_isHidden() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW_ISHIDDEN"
        let sut = makeSUT(trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(trailingViewIsHidden: true)
        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_trailingView_isHidden() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW_ISHIDDEN"
        let sut = makeSUT(trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(trailingViewIsHidden: false)
        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_trailingView() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW"
        let sut = makeSUT(trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass"))

        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_trailingView() {
        let snapshotName = "TEXTFIELD_TRAILINGVIEW"
        let sut = makeSUT(trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass.circle.fill"))

        sut.display(text: "Search query")

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_postLeadingViewOnPressCallback_visualState() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ONPRESS"
        let sut = makeSUT(
            leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        let onPress: () -> Void = { [weak sut] in sut?.display(text: "Leading pressed") }
        sut.display(leadingViewOnPress: onPress)
        // The snapshot verifies only the Output state produced after the callback.
        onPress()

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_postLeadingViewOnPressCallback_visualState() {
        let snapshotName = "TEXTFIELD_LEADINGVIEW_ONPRESS"
        let sut = makeSUT(
            leadingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        let onPress: () -> Void = { [weak sut] in sut?.display(text: "Leading pressed.") }
        sut.display(leadingViewOnPress: onPress)
        // The snapshot verifies only the Output state produced after the callback.
        onPress()

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_postTrailingViewOnPressCallback_visualState() {
        let snapshotName = "TEXTFIELD_TRAILING_ONPRESS"
        let sut = makeSUT(
            trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        let onPress: () -> Void = { [weak sut] in sut?.display(text: "Trailing pressed") }
        sut.display(trailingViewOnPress: onPress)
        // The snapshot verifies only the Output state produced after the callback.
        onPress()

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_postTrailingViewOnPressCallback_visualState() {
        let snapshotName = "TEXTFIELD_TRAILING_ONPRESS"
        let sut = makeSUT(
            trailingSwiftUIView: makeSwiftUIIcon(systemName: "magnifyingglass")
        )

        sut.display(text: "Search query")
        let onPress: () -> Void = { [weak sut] in sut?.display(text: "Trailing pressed.") }
        sut.display(trailingViewOnPress: onPress)
        // The snapshot verifies only the Output state produced after the callback.
        onPress()

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_isSecureText_false_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_FALSE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_isSecureText_false_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_FALSE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_isSecureText_true_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_TRUE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_isSecureText_true_text() {
        let snapshotName = "TEXTFIELD_ISSECURETEXT_TRUE_TEXT"
        let sut = makeSUT()

        sut.display(text: "MyPassword123")
        sut.display(isSecureTextEntry: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_invalid_state() {
        let snapshotName = "TEXTFIELD_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid input")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_invalid_state() {
        let snapshotName = "TEXTFIELD_INVALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Invalid input")
        sut.display(isValid: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_valid_state() {
        let snapshotName = "TEXTFIELD_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid input")
        sut.display(isValid: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_Textfield_valid_state() {
        let snapshotName = "TEXTFIELD_VALID_STATE"
        let sut = makeSUT()

        sut.display(text: "Valid input")
        sut.display(isValid: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_Textfield_mask_as_placeholder() {
        let snapshotName = "TEXTFIELD_MASK_PLACEHOLDER"
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

    func test_fail_Textfield_mask_as_placeholder() {
        let snapshotName = "TEXTFIELD_MASK_PLACEHOLDER"
        let sut = makeSUT()

        let mask = Mask(format: [.literal("H"), .literal("E"), .literal("L"), .literal("L"), .literal("o")])
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

    func test_Textfield_invalid_with_placeholder() {
        let snapshotName = "TEXTFIELD_INVALID_PLACEHOLDER"
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

    func test_fail_Textfield_invalid_with_placeholder() {
        let snapshotName = "TEXTFIELD_INVALID_PLACEHOLDER"
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

    func test_textfield_emoji() {
        let snapshotName = "TEXTFIELD_EMOJI_STATE"
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

    func test_textfield_utfLikeText() {
        let snapshotName = "TEXTFIELD_FAKE_EMOJI_STATE"
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

    func test_Textfield_trailing_symbol_with_mask() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeShortPhoneMask(countryCode: "7"), maskColor: .lightGray))
        sut.display(text: "123")
        sut.display(trailingSymbol: " (Mobile)")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_TRAILING_SYMBOL")
    }

    func test_fail_Textfield_trailing_symbol_with_mask() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeShortPhoneMask(countryCode: "7"), maskColor: .lightGray))
        sut.display(text: "123")
        sut.display(trailingSymbol: " (Mobile.)")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_TRAILING_SYMBOL", expectingMatch: false)
    }

    func test_Textfield_trailing_symbol_currency() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeCurrencyMask(), maskColor: .systemGray))
        sut.display(text: "1500")
        sut.display(trailingSymbol: " USD")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_CURRENCY_SYMBOL")
    }

    func test_fail_Textfield_trailing_symbol_currency() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeCurrencyMask(), maskColor: .systemGray))
        sut.display(text: "1500")
        sut.display(trailingSymbol: " USD.")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_CURRENCY_SYMBOL", expectingMatch: false)
    }

    func test_Textfield_phone_mask_partial() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makePhoneMask(countryCode: "7"), maskColor: .lightGray))
        sut.display(text: "123")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_PHONE_MASK_PARTIAL")
    }

    func test_fail_Textfield_phone_mask_partial() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makePhoneMask(countryCode: "8"), maskColor: .lightGray))
        sut.display(text: "123")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_PHONE_MASK_PARTIAL", expectingMatch: false)
    }

    func test_Textfield_phone_mask_full() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makePhoneMask(countryCode: "7"), maskColor: .lightGray))
        sut.display(text: "1234567890")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_PHONE_MASK_FULL")
    }

    func test_fail_Textfield_phone_mask_full() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makePhoneMask(countryCode: "8"), maskColor: .lightGray))
        sut.display(text: "1234567890")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_PHONE_MASK_FULL", expectingMatch: false)
    }

    func test_Textfield_phone_mask_empty() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makePhoneMask(countryCode: "7"), maskColor: .lightGray))
        sut.display(text: "")
        sut.display(placeholder: "Enter phone number")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_PHONE_MASK_EMPTY")
    }

    func test_fail_Textfield_phone_mask_empty() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makePhoneMask(countryCode: "7"), maskColor: .lightGray))
        sut.display(text: "123")
        sut.display(placeholder: "Enter phone number")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_PHONE_MASK_EMPTY", expectingMatch: false)
    }

    func test_Textfield_credit_card_mask() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeCreditCardMask(), maskColor: .systemGray))
        sut.display(text: "12345678")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_CARD_MASK")
    }

    func test_fail_Textfield_credit_card_mask() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeCreditCardMask(), maskColor: .systemGray))
        sut.display(text: "22345678")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_CARD_MASK", expectingMatch: false)
    }

    func test_Textfield_date_mask() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeDateMask(), maskColor: .systemGray3))
        sut.display(text: "1512")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_DATE_MASK")
    }

    func test_fail_Textfield_date_mask() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeDateMask(), maskColor: .systemGray3))
        sut.display(text: "1612")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_DATE_MASK", expectingMatch: false)
    }

    func test_Textfield_mask_with_color() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeCodeMask(), maskColor: .blue))
        sut.display(text: "12")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_BLUE")
    }

    func test_fail_Textfield_mask_with_color() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeCodeMask(), maskColor: .systemBlue))
        sut.display(text: "12")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_BLUE", expectingMatch: false)
    }

    func test_Textfield_mask_with_initial_literals_and_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeInitialLiteralsMask(), maskColor: .systemGray))
        sut.display(text: "98765")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_INITIAL_LITERALS")
    }

    func test_fail_Textfield_mask_with_initial_literals_and_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeInitialLiteralsMask(), maskColor: .systemGray))
        sut.display(text: "88765")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_INITIAL_LITERALS", expectingMatch: false)
    }

    func test_Textfield_mask_with_literals_and_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeLiteralPrefixMask(), maskColor: .systemGray))
        sut.display(text: "996553113555")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_CONSIDERS_LITERALS")
    }

    func test_fail_Textfield_mask_with_literals_and_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeLiteralPrefixMask(), maskColor: .systemGray))
        sut.display(text: "995553113555")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_CONSIDERS_LITERALS", expectingMatch: false)
    }

    func test_Textfield_mask_with_literals_and_complex_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeComplexLiteralMask(), maskColor: .systemGray))
        sut.display(text: "996553113555")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_CONSIDERS_COMPLEXT_LITERALS")
    }

    func test_fail_Textfield_mask_with_literals_and_complex_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeComplexLiteralMask(), maskColor: .systemGray))
        sut.display(text: "996653113555")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_CONSIDERS_COMPLEXT_LITERALS", expectingMatch: false)
    }

    func test_Textfield_mask_with_literals_and_almost_complex_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeComplexLiteralMask(), maskColor: .systemGray))
        sut.display(text: "96553113555")

        assertSnapshotPair(of: sut, named: "TEXTFIELD_MASK_CONSIDERS_ALMOST_COMPLEXT_LITERALS")
    }

    func test_fail_Textfield_mask_with_literals_and_almost_complex_presented_text() {
        let sut = makeSUT()
        sut.display(mask: .init(mask: makeComplexLiteralMask(), maskColor: .systemGray))
        sut.display(text: "97553113555")

        assertSnapshotPair(
            of: sut,
            named: "TEXTFIELD_MASK_CONSIDERS_ALMOST_COMPLEXT_LITERALS",
            expectingMatch: false
        )
    }

}

@available(iOS 17.0, *)
extension SUITextfieldSnapshotTests {
    func assertSnapshotPair(
        of sut: SwiftUITextfieldSnapshotSUT,
        named snapshotName: String,
        expectingMatch: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let prefix = if #available(iOS 26, *) { "SwiftUI_iOS26" } else { "SwiftUI_iOS18.5" }

        for appearance in SnapshotAppearance.allCases {
            let suffix = switch appearance {
            case .light: "LIGHT"
            case .dark: "DARK"
            }
            let name = "\(prefix)_\(snapshotName)_\(suffix)"
            let snapshot = sut.swiftUISnapshot(for: appearance)
            if expectingMatch {
                assert(
                    snapshot: snapshot,
                    named: name,
                    precision: SwiftUISnapshotPrecision.standard,
                    file: file,
                    line: line
                )
            } else {
                assertFail(
                    snapshot: snapshot,
                    named: name,
                    precision: SwiftUISnapshotPrecision.fail,
                    file: file,
                    line: line
                )
            }
        }
    }

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

    func makeShortPhoneMask(countryCode: Character) -> Mask {
        Mask(format: [
            .literal("+"),
            .literal(countryCode),
            .literal(" "),
            decimalSpecifier,
            decimalSpecifier,
            decimalSpecifier
        ])
    }

    func makeCurrencyMask() -> Mask {
        Mask(format: Array(repeating: decimalSpecifier, count: 4))
    }

    func makeCreditCardMask() -> Mask {
        let group = Array(repeating: decimalSpecifier, count: 4)
        return Mask(format: group + [.literal(" ")] + group + [.literal(" ")] + group + [.literal(" ")] + group)
    }

    func makeDateMask() -> Mask {
        let dayOrMonth: MaskedCharacter = .specifier(
            placeholder: "D",
            allowedCharacters: .decimalDigits
        )
        let month: MaskedCharacter = .specifier(
            placeholder: "M",
            allowedCharacters: .decimalDigits
        )
        let year: MaskedCharacter = .specifier(
            placeholder: "Y",
            allowedCharacters: .decimalDigits
        )
        return Mask(format: [
            dayOrMonth,
            dayOrMonth,
            .literal("/"),
            month,
            month,
            .literal("/"),
            year,
            year,
            year,
            year
        ])
    }

    func makeCodeMask() -> Mask {
        Mask(format: [
            .literal("C"),
            .literal("O"),
            .literal("D"),
            .literal("E"),
            .literal(":"),
            .literal(" "),
            decimalSpecifier,
            decimalSpecifier,
            decimalSpecifier
        ])
    }

    func makeInitialLiteralsMask() -> Mask {
        Mask(format: [
            .literal("+"),
            .literal("9"),
            .literal("9"),
            .literal("6"),
            .literal(" "),
            decimalSpecifier,
            decimalSpecifier,
            decimalSpecifier,
            .literal("-"),
            decimalSpecifier,
            decimalSpecifier
        ])
    }

    func makeLiteralPrefixMask() -> Mask {
        Mask(format: [
            .literal("+"),
            .literal("9"),
            .literal("9"),
            .literal("6")
        ] + Array(repeating: decimalSpecifier, count: 9))
    }

    func makeComplexLiteralMask() -> Mask {
        let group = Array(repeating: decimalSpecifier, count: 3)
        return Mask(format: [
            .literal("+"),
            .literal("9"),
            .literal("9"),
            .literal("6"),
            .literal(" ")
        ] + group + [.literal(" ")] + group + [.literal(" ")] + group)
    }

    private var decimalSpecifier: MaskedCharacter {
        .specifier(placeholder: "#", allowedCharacters: .decimalDigits)
    }

    func makeSUT(
        leadingSwiftUIView: AnyView? = nil,
        trailingSwiftUIView: AnyView? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUITextfieldSnapshotSUT {
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

        let sut = SwiftUITextfieldSnapshotSUT(
            appearance: appearance,
            leadingSwiftUIView: leadingSwiftUIView,
            trailingSwiftUIView: trailingSwiftUIView
        )

        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
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
        format.scale = SnapshotRenderDefaults.scale
        format.opaque = false
        format.preferredRange = .standard

        return UIGraphicsImageRenderer(size: canvasSize, format: format).image { _ in
            symbol
                .withTintColor(tintColor, renderingMode: .alwaysOriginal)
                .draw(in: drawRect)
        }
    }

}
