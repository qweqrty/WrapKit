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

    func test_fullModelThenNil_hidesContainerAndRetainsNestedStateAndActionsLikeUIKit() {
        let adapter = SearchBarOutputSwiftUIAdapter()
        let stateModel = SUISearchBarStateModel(
            adapter: adapter,
            appearance: makeAppearance(),
            spacing: spacing,
            cornerRadius: 12,
            padding: .init()
        )
        let textFieldStateModel = SUITextInputStateModel(adapter: stateModel.textFieldAdapter)
        var events: [String] = []

        adapter.display(model: .init(
            textField: .init(
                accessibilityIdentifier: "search.field",
                text: "Query",
                onPress: { events.append("field") }
            ),
            leftView: .init(
                title: "Search",
                onPress: { events.append("leading") }
            ),
            rightView: .init(
                title: "Clear",
                onPress: { events.append("trailing") }
            ),
            placeholder: "Search items",
            backgroundColor: .systemYellow,
            spacing: 12
        ))

        XCTAssertFalse(stateModel.isHidden)
        XCTAssertFalse(stateModel.isTextFieldHidden)
        XCTAssertEqual(stateModel.textField?.text, "Query")
        XCTAssertEqual(textFieldStateModel.text, "Query")
        XCTAssertEqual(textFieldStateModel.placeholder, "Search items")
        XCTAssertEqual(stateModel.leftView?.title, "Search")
        XCTAssertEqual(stateModel.rightView?.title, "Clear")
        XCTAssertEqual(stateModel.placeholder, "Search items")
        XCTAssertTrue(stateModel.backgroundColor?.isEqual(UIColor.systemYellow) == true)
        XCTAssertEqual(stateModel.spacing, 12)

        adapter.display(model: nil)

        XCTAssertTrue(stateModel.isHidden)
        XCTAssertFalse(stateModel.isTextFieldHidden)
        XCTAssertFalse(textFieldStateModel.isHidden)
        XCTAssertEqual(stateModel.textField?.text, "Query")
        XCTAssertEqual(textFieldStateModel.text, "Query")
        XCTAssertEqual(textFieldStateModel.placeholder, "Search items")
        XCTAssertEqual(stateModel.leftView?.title, "Search")
        XCTAssertEqual(stateModel.rightView?.title, "Clear")
        XCTAssertEqual(stateModel.placeholder, "Search items")
        XCTAssertTrue(stateModel.backgroundColor?.isEqual(UIColor.systemYellow) == true)
        XCTAssertEqual(stateModel.spacing, 12)

        textFieldStateModel.onPress?()
        stateModel.leftButtonStateModel.presentable.onPress?()
        stateModel.rightButtonStateModel.presentable.onPress?()
        XCTAssertEqual(events, ["field", "leading", "trailing"])
    }

    @available(iOS 17.0, *)
    func test_bothSideControls_renderWithExactOuterAndInnerInsets() throws {
        let harness = makeSearchBarHost(left: true, textField: true, right: true)
        let leading = try frame(of: .leading, in: harness)
        let textField = try frame(of: .textField, in: harness)
        let trailing = try frame(of: .trailing, in: harness)

        assertControl(leading, startsAt: harness.host.frame.minX + contentInset)
        XCTAssertEqual(textField.minX - leading.maxX, spacing, accuracy: 0.001)
        XCTAssertEqual(trailing.minX - textField.maxX, spacing, accuracy: 0.001)
        assertControl(trailing, endsAt: harness.host.frame.maxX - contentInset)
    }

    @available(iOS 17.0, *)
    func test_onlyLeadingControl_preservesOuterAndTextFieldInsets() throws {
        let harness = makeSearchBarHost(left: true, textField: true, right: false)
        let leading = try frame(of: .leading, in: harness)
        let textField = try frame(of: .textField, in: harness)

        assertControl(leading, startsAt: harness.host.frame.minX + contentInset)
        XCTAssertEqual(textField.minX - leading.maxX, spacing, accuracy: 0.001)
        XCTAssertEqual(textField.maxX, harness.host.frame.maxX - contentInset, accuracy: 0.001)
        XCTAssertNil(harness.layoutProbe.frame(for: .trailing))
    }

    @available(iOS 17.0, *)
    func test_onlyTrailingControl_preservesTextFieldAndOuterInsets() throws {
        let harness = makeSearchBarHost(left: false, textField: true, right: true)
        let textField = try frame(of: .textField, in: harness)
        let trailing = try frame(of: .trailing, in: harness)

        XCTAssertEqual(textField.minX, harness.host.frame.minX + contentInset, accuracy: 0.001)
        XCTAssertEqual(trailing.minX - textField.maxX, spacing, accuracy: 0.001)
        assertControl(trailing, endsAt: harness.host.frame.maxX - contentInset)
        XCTAssertNil(harness.layoutProbe.frame(for: .leading))
    }

    @available(iOS 17.0, *)
    func test_nilTextField_keepsInsetsAroundIntrinsicSideControlContent() throws {
        let harness = makeSearchBarHost(left: true, textField: false, right: true)
        let leading = try frame(of: .leading, in: harness)
        let trailing = try frame(of: .trailing, in: harness)
        let intrinsicContentWidth = contentInset * 2 + controlSize * 2 + spacing

        assertControl(leading, startsAt: harness.host.frame.minX + contentInset)
        XCTAssertEqual(trailing.minX - leading.maxX, spacing, accuracy: 0.001)
        assertControl(
            trailing,
            endsAt: harness.host.frame.minX + intrinsicContentWidth - contentInset
        )
        XCTAssertNil(harness.layoutProbe.frame(for: .textField))
    }

    @available(iOS 17.0, *)
    func test_nilTextField_keepsBothRenderedSideCallbacksActive() throws {
        var actions: [String] = []
        let harness = makeSearchBarHost(
            left: true,
            textField: false,
            right: true,
            leftOnPress: { actions.append("leading") },
            rightOnPress: { actions.append("trailing") }
        )

        _ = try frame(of: .leading, in: harness)
        _ = try frame(of: .trailing, in: harness)
        let leading = try XCTUnwrap(harness.host.element(withLabel: "Search"))
        let trailing = try XCTUnwrap(harness.host.element(withLabel: "Clear"))
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
        right: Bool,
        leftOnPress: (() -> Void)? = nil,
        rightOnPress: (() -> Void)? = nil
    ) -> SearchBarTestHarness {
        let adapter = SearchBarOutputSwiftUIAdapter()
        adapter.display(model: .init(
            textField: textField
                ? .init(accessibilityIdentifier: "search.field")
                : nil,
            leftView: left ? makeButton(
                identifier: "search.leading",
                accessibilityLabel: "Search",
                systemName: "magnifyingglass",
                backgroundColor: .systemRed,
                onPress: leftOnPress
            ) : nil,
            rightView: right ? makeButton(
                identifier: "search.trailing",
                accessibilityLabel: "Clear",
                systemName: "xmark",
                backgroundColor: .systemGreen,
                onPress: rightOnPress
            ) : nil,
            spacing: spacing
        ))
        let stateModel = SUISearchBarStateModel(
            adapter: adapter,
            appearance: makeAppearance(),
            spacing: spacing,
            cornerRadius: 0,
            padding: .init()
        )
        let layoutProbe = SUISearchBarLayoutProbe()

        let host = SwiftUIAccessibilityTestHost(
            rootView: SUISearchBar(
                stateModel: stateModel,
                contentInsets: .init(horizontal: contentInset, vertical: 0),
                layoutProbe: layoutProbe
            )
                .tint(.white)
                .frame(width: containerWidth, alignment: .leading)
                .ignoresSafeArea(),
            size: CGSize(width: containerWidth, height: 80)
        )
        return .init(host: host, stateModel: stateModel, layoutProbe: layoutProbe)
    }

    @available(iOS 17.0, *)
    func frame(
        of element: SUISearchBarLayoutElement,
        in harness: SearchBarTestHarness
    ) throws -> CGRect {
        try XCTUnwrap(harness.layoutProbe.frame(for: element))
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

@available(iOS 17.0, *)
private struct SearchBarTestHarness {
    let host: SwiftUIAccessibilityTestHost
    let stateModel: SUISearchBarStateModel
    let layoutProbe: SUISearchBarLayoutProbe
}
#endif
