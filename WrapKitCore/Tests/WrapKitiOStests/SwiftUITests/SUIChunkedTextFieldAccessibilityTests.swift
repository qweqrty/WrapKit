#if !os(macOS) && !os(tvOS) && !os(watchOS)
import SwiftUI
import UIKit
import WrapKit
import XCTest

@available(iOS 17.0, *)
@MainActor
final class SUIChunkedTextFieldAccessibilityTests: XCTestCase {
    func test_accessibilityIdentifier_namesEveryCellByIndex() {
        let host = SwiftUIAccessibilityTestHost(rootView: makeSUT(adapter: TextInputOutputSwiftUIAdapter()))

        for index in 0..<4 {
            XCTAssertNotNil(host.element(withIdentifier: "code.\(index)"), host.diagnosticDescription)
        }
        XCTAssertNil(host.element(withIdentifier: "code.4"))
    }

    func test_displayModel_keepsAccessibilityIdentifierAndIgnoresModelIdentifierLikeUIKit() {
        let adapter = TextInputOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(rootView: makeSUT(adapter: adapter))

        adapter.display(model: .init(accessibilityIdentifier: "model", text: "12"))
        host.settle()

        XCTAssertNotNil(host.element(withIdentifier: "code.0"), host.diagnosticDescription)
        XCTAssertNil(host.element(withIdentifier: "model.0"))
    }
}

@available(iOS 17.0, *)
private extension SUIChunkedTextFieldAccessibilityTests {
    func makeSUT(adapter: TextInputOutputSwiftUIAdapter) -> some View {
        SUIChunkedTextField(
            adapter: adapter,
            count: 4,
            appearance: TextfieldAppearance(
                colors: .init(
                    textColor: .black,
                    selectedBorderColor: .blue,
                    selectedBackgroundColor: .white,
                    selectedErrorBorderColor: .red,
                    errorBorderColor: .red,
                    errorBackgroundColor: .white,
                    deselectedBorderColor: .gray,
                    deselectedBackgroundColor: .white,
                    disabledTextColor: .gray,
                    disabledBackgroundColor: .lightGray
                ),
                font: .systemFont(ofSize: 24),
                border: .init(idleBorderWidth: 1, selectedBorderWidth: 2),
                placeholder: .init(color: .gray, font: .systemFont(ofSize: 20))
            ),
            accessibilityIdentifier: "code"
        )
    }
}
#endif
