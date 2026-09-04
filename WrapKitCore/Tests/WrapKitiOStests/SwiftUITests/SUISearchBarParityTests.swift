#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
final class SUISearchBarParityTests: XCTestCase {
    private let containerWidth: CGFloat = 390
    private let contentInset: CGFloat = 8
    private let controlSize: CGFloat = 44
    private let spacing: CGFloat = 8

    @available(iOS 17.0, *)
    func test_bothSideControls_renderWithExactOuterAndInnerInsets() throws {
        let host = makeSearchBarHost(left: true, textField: true, right: true)
        let leading = try frame(ofLabel: "Search", in: host)
        let textField = try textFieldFrame(in: host)
        let trailing = try frame(ofLabel: "Clear", in: host)

        assertControl(leading, startsAt: host.frame.minX + contentInset)
        XCTAssertEqual(textField.minX - leading.maxX, spacing, accuracy: 0.001)
        XCTAssertEqual(trailing.minX - textField.maxX, spacing, accuracy: 0.001)
        assertControl(trailing, endsAt: host.frame.maxX - contentInset)
    }

    @available(iOS 17.0, *)
    func test_onlyLeadingControl_preservesOuterAndTextFieldInsets() throws {
        let host = makeSearchBarHost(left: true, textField: true, right: false)
        let leading = try frame(ofLabel: "Search", in: host)
        let textField = try textFieldFrame(in: host)

        assertControl(leading, startsAt: host.frame.minX + contentInset)
        XCTAssertEqual(textField.minX - leading.maxX, spacing, accuracy: 0.001)
        XCTAssertEqual(textField.maxX, host.frame.maxX - contentInset, accuracy: 0.001)
        XCTAssertNil(host.element(withIdentifier: "search.trailing"))
    }

    @available(iOS 17.0, *)
    func test_onlyTrailingControl_preservesTextFieldAndOuterInsets() throws {
        let host = makeSearchBarHost(left: false, textField: true, right: true)
        let textField = try textFieldFrame(in: host)
        let trailing = try frame(ofLabel: "Clear", in: host)

        XCTAssertEqual(textField.minX, host.frame.minX + contentInset, accuracy: 0.001)
        XCTAssertEqual(trailing.minX - textField.maxX, spacing, accuracy: 0.001)
        assertControl(trailing, endsAt: host.frame.maxX - contentInset)
        XCTAssertNil(host.element(withIdentifier: "search.leading"))
    }

    @available(iOS 17.0, *)
    func test_nilTextField_keepsInsetsAroundIntrinsicSideControlContent() throws {
        let host = makeSearchBarHost(left: true, textField: false, right: true)
        let leading = try frame(ofLabel: "Search", in: host)
        let trailing = try frame(ofLabel: "Clear", in: host)
        let intrinsicContentWidth = contentInset * 2 + controlSize * 2 + spacing

        assertControl(leading, startsAt: host.frame.minX + contentInset)
        XCTAssertEqual(trailing.minX - leading.maxX, spacing, accuracy: 0.001)
        assertControl(
            trailing,
            endsAt: host.frame.minX + intrinsicContentWidth - contentInset
        )
        XCTAssertNil(host.element(withIdentifier: "search.field"))
    }

    @available(iOS 17.0, *)
    func test_nilTextField_keepsBothRenderedSideCallbacksActive() throws {
        let adapter = SearchBarOutputSwiftUIAdapter()
        var actions: [String] = []
        adapter.display(model: .init(
            textField: nil,
            leftView: makeButton(
                identifier: "search.leading",
                accessibilityLabel: "Search",
                systemName: "magnifyingglass",
                backgroundColor: .systemRed,
                onPress: { actions.append("leading") }
            ),
            rightView: makeButton(
                identifier: "search.trailing",
                accessibilityLabel: "Clear",
                systemName: "xmark",
                backgroundColor: .systemGreen,
                onPress: { actions.append("trailing") }
            ),
            spacing: spacing
        ))
        let host = SwiftUIAccessibilityTestHost(
            rootView: makeSearchBar(adapter: adapter)
                .tint(.white)
                .frame(width: containerWidth, alignment: .leading)
                .ignoresSafeArea(),
            size: CGSize(width: containerWidth, height: 80)
        )

        let leading = try XCTUnwrap(host.element(withLabel: "Search"))
        let trailing = try XCTUnwrap(host.element(withLabel: "Clear"))
        XCTAssertTrue(leading.accessibilityActivate())
        XCTAssertTrue(trailing.accessibilityActivate())

        XCTAssertEqual(actions, ["leading", "trailing"])
    }

    @available(iOS 17.0, *)
    func test_modelDisplayedBeforeMount_replaysTextIntoNativeField() throws {
        let adapter = SearchBarOutputSwiftUIAdapter()
        adapter.display(model: .init(
            textField: .init(
                accessibilityIdentifier: "search.field",
                text: "Prefilled"
            )
        ))

        let host = SwiftUIAccessibilityTestHost(
            rootView: makeSearchBar(adapter: adapter)
                .frame(width: containerWidth, alignment: .leading)
                .ignoresSafeArea(),
            size: CGSize(width: containerWidth, height: 80)
        )

        XCTAssertEqual(
            try XCTUnwrap(host.firstSubview(of: UITextField.self)).text,
            "Prefilled"
        )
    }
}

private extension SUISearchBarParityTests {
    @available(iOS 17.0, *)
    func makeSearchBarHost(
        left: Bool,
        textField: Bool,
        right: Bool
    ) -> SwiftUIAccessibilityTestHost {
        let adapter = SearchBarOutputSwiftUIAdapter()
        adapter.display(model: .init(
            textField: textField
                ? .init(accessibilityIdentifier: "search.field")
                : nil,
            leftView: left ? makeButton(
                identifier: "search.leading",
                accessibilityLabel: "Search",
                systemName: "magnifyingglass",
                backgroundColor: .systemRed
            ) : nil,
            rightView: right ? makeButton(
                identifier: "search.trailing",
                accessibilityLabel: "Clear",
                systemName: "xmark",
                backgroundColor: .systemGreen
            ) : nil,
            spacing: spacing
        ))

        return SwiftUIAccessibilityTestHost(
            rootView: makeSearchBar(adapter: adapter)
                .tint(.white)
                .frame(width: containerWidth, alignment: .leading)
                .ignoresSafeArea(),
            size: CGSize(width: containerWidth, height: 80)
        )
    }

    @available(iOS 17.0, *)
    func frame(
        ofLabel accessibilityLabel: String,
        in host: SwiftUIAccessibilityTestHost
    ) throws -> CGRect {
        try XCTUnwrap(
            host.element(withLabel: accessibilityLabel)
        ).accessibilityFrame
    }

    @available(iOS 17.0, *)
    func textFieldFrame(in host: SwiftUIAccessibilityTestHost) throws -> CGRect {
        try XCTUnwrap(host.frame(ofFirstSubviewType: UITextField.self))
    }

    func makeSearchBar(adapter: SearchBarOutputSwiftUIAdapter) -> SUISearchBar {
        SUISearchBar(
            adapter: adapter,
            textFieldAppearance: makeAppearance(),
            spacing: spacing,
            cornerRadius: 0,
            padding: .init(),
            contentInsets: .init(horizontal: contentInset, vertical: 0)
        )
    }

    func makeAppearance() -> TextfieldAppearance {
        .init(
            colors: .init(
                textColor: .white,
                selectedBorderColor: .clear,
                selectedBackgroundColor: .systemBlue,
                selectedErrorBorderColor: .clear,
                errorBorderColor: .clear,
                errorBackgroundColor: .systemBlue,
                deselectedBorderColor: .clear,
                deselectedBackgroundColor: .systemBlue,
                disabledTextColor: .white,
                disabledBackgroundColor: .systemBlue
            ),
            font: .systemFont(ofSize: 17),
            border: .init(idleBorderWidth: 0, selectedBorderWidth: 0)
        )
    }

    func makeButton(
        identifier: String,
        accessibilityLabel: String,
        systemName: String,
        backgroundColor: WrapKit.Color,
        onPress: (() -> Void)? = nil
    ) -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: identifier,
            accessibility: .init(label: accessibilityLabel),
            image: ImageFactory.systemImage(named: systemName),
            height: controlSize,
            width: controlSize,
            style: .init(
                backgroundColor: backgroundColor,
                titleColor: .white,
                cornerStyle: .none
            ),
            onPress: onPress
        )
    }

    func assertControl(
        _ frame: CGRect,
        startsAt expectedMinX: CGFloat? = nil,
        endsAt expectedMaxX: CGFloat? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if let expectedMinX {
            XCTAssertEqual(frame.minX, expectedMinX, accuracy: 0.001, file: file, line: line)
        }
        if let expectedMaxX {
            XCTAssertEqual(frame.maxX, expectedMaxX, accuracy: 0.001, file: file, line: line)
        }
        XCTAssertEqual(frame.width, controlSize, accuracy: 0.001, file: file, line: line)
    }
}
#endif
