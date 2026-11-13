#if canImport(SwiftUI) && canImport(UIKit)
    import Combine
    import SwiftUI
    import UIKit
    @testable import WrapKit
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
                    accessibilityIdentifier: "search.leading",
                    title: "Search",
                    onPress: { events.append("leading") }
                ),
                rightView: .init(
                    accessibilityIdentifier: "search.trailing",
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
            XCTAssertEqual(stateModel.leftButtonStateModel.presentable.accessibilityIdentifier, "search.leading")
            XCTAssertEqual(stateModel.rightButtonStateModel.presentable.accessibilityIdentifier, "search.trailing")
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

        func test_granularThenFullModelBeforeMount_replaysLatestValuesInPresenterOrder() {
            let adapter = SearchBarOutputSwiftUIAdapter()
            adapter.display(spacing: 4)
            adapter.display(placeholder: "Granular")
            adapter.display(model: .init(placeholder: "Model", spacing: 20))

            let stateModel = makeStateModel(adapter: adapter)

            XCTAssertEqual(stateModel.placeholder, "Model")
            XCTAssertEqual(stateModel.spacing, 20)
        }

        func test_fullModelThenGranularBeforeMount_replaysLatestValuesInPresenterOrder() {
            let adapter = SearchBarOutputSwiftUIAdapter()
            adapter.display(model: .init(placeholder: "Model", spacing: 20))
            adapter.display(spacing: 4)
            adapter.display(placeholder: "Granular")

            let stateModel = makeStateModel(adapter: adapter)

            XCTAssertEqual(stateModel.placeholder, "Granular")
            XCTAssertEqual(stateModel.spacing, 4)
        }

        func test_placeholderThenTextFieldBeforeMount_usesNestedPlaceholderFromLaterTextFieldModel() {
            let adapter = SearchBarOutputSwiftUIAdapter()
            adapter.display(placeholder: "Outer")
            adapter.display(textField: .init(placeholder: "Inner"))

            let stateModel = makeStateModel(adapter: adapter)
            let textFieldStateModel = SUITextInputStateModel(adapter: stateModel.textFieldAdapter)

            XCTAssertEqual(stateModel.placeholder, "Inner")
            XCTAssertEqual(textFieldStateModel.placeholder, "Inner")
        }

        func test_textFieldThenPlaceholderBeforeMount_usesLaterGranularPlaceholder() {
            let adapter = SearchBarOutputSwiftUIAdapter()
            adapter.display(textField: .init(placeholder: "Inner"))
            adapter.display(placeholder: "Outer")

            let stateModel = makeStateModel(adapter: adapter)
            let textFieldStateModel = SUITextInputStateModel(adapter: stateModel.textFieldAdapter)

            XCTAssertEqual(stateModel.placeholder, "Outer")
            XCTAssertEqual(textFieldStateModel.placeholder, "Outer")
        }

        func test_remountPreservesNestedTextDraftAndFocusState() {
            let adapter = SearchBarOutputSwiftUIAdapter()
            adapter.display(textField: .init(text: "Server value"))

            weak var firstSearchStateModel: SUISearchBarStateModel?
            weak var firstTextFieldStateModel: SUITextInputStateModel?
            autoreleasepool {
                let searchStateModel = makeStateModel(adapter: adapter)
                let textFieldStateModel = SUITextInputStateModel(
                    adapter: searchStateModel.textFieldAdapter
                )
                firstSearchStateModel = searchStateModel
                firstTextFieldStateModel = textFieldStateModel

                textFieldStateModel.applyUserText("User draft")
                textFieldStateModel.isFocused = true

                XCTAssertEqual(textFieldStateModel.text, "User draft")
                XCTAssertTrue(textFieldStateModel.isFocused)
            }
            XCTAssertNil(firstSearchStateModel)
            XCTAssertNil(firstTextFieldStateModel)

            let remountedSearchStateModel = makeStateModel(adapter: adapter)
            let remountedTextFieldStateModel = SUITextInputStateModel(
                adapter: remountedSearchStateModel.textFieldAdapter
            )

            XCTAssertEqual(remountedTextFieldStateModel.text, "User draft")
            XCTAssertTrue(remountedTextFieldStateModel.isFocused)
        }

        func test_focusedNestedTextFieldRejectsAndReleasesNewCallbacksWithoutLosingAcceptedOnes() {
            final class CallbackOwner {}

            let adapter = SearchBarOutputSwiftUIAdapter()
            let searchStateModel = makeStateModel(adapter: adapter)
            var acceptedCalls = 0
            adapter.display(model: .init(
                textField: .init(onPress: { acceptedCalls += 1 })
            ))
            var textFieldStateModel: SUITextInputStateModel? = .init(
                adapter: searchStateModel.textFieldAdapter
            )
            textFieldStateModel?.isFocused = true

            weak var ignoredOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                ignoredOwner = owner
                adapter.display(model: .init(
                    textField: .init(
                        inputView: .date(.init(
                            accessoryView: .init(
                                trailingButton: .init(onPress: { _ = owner })
                            ),
                            onChange: { _ in _ = owner },
                            onDoneTapped: { _ in _ = owner }
                        )),
                        inputAccessoryView: .init(
                            trailingButton: .init(onPress: { _ = owner })
                        ),
                        onPress: { _ = owner },
                        onPaste: { _ in _ = owner },
                        didChangeText: [{ _ in _ = owner }]
                    )
                ))
            }

            XCTAssertNil(ignoredOwner)
            XCTAssertNil(searchStateModel.textField?.onPress)
            textFieldStateModel?.onPress?()
            XCTAssertEqual(acceptedCalls, 1)

            textFieldStateModel = nil
            let remountedSearchStateModel = makeStateModel(adapter: adapter)
            let remountedTextFieldStateModel = SUITextInputStateModel(
                adapter: remountedSearchStateModel.textFieldAdapter
            )
            remountedTextFieldStateModel.onPress?()

            XCTAssertEqual(acceptedCalls, 2)
            XCTAssertNil(remountedTextFieldStateModel.inputView)
            XCTAssertNil(remountedTextFieldStateModel.inputAccessoryView)
        }

        func test_reentrantSupersededNestedTextFieldReleasesUndeliveredCallbacks() throws {
            final class CallbackOwner {}

            let adapter = SearchBarOutputSwiftUIAdapter()
            var acceptedCalls = 0
            weak var acceptedOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                acceptedOwner = owner
                adapter.display(textField: .init(
                    text: "Accepted",
                    onPress: {
                        _ = owner
                        acceptedCalls += 1
                    }
                ))
            }
            var observedOuterCallback = false
            var reentrantSubscription: AnyCancellable? = adapter.$displayTextFieldState
                .compactMap { $0 }
                .sink { state in
                    guard state.textField?.text == "Outer" else { return }
                    observedOuterCallback = state.textFieldReplayModel != nil
                    adapter.display(textField: .init(text: "Inner"))
                }
            let searchStateModel = makeStateModel(adapter: adapter)
            let textFieldStateModel = SUITextInputStateModel(
                adapter: searchStateModel.textFieldAdapter
            )
            let retainedAcceptedCallback = try XCTUnwrap(textFieldStateModel.onPress)

            XCTAssertNotNil(acceptedOwner)
            retainedAcceptedCallback()
            XCTAssertEqual(acceptedCalls, 1)

            weak var supersededOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                supersededOwner = owner
                adapter.display(textField: .init(
                    text: "Outer",
                    onPress: { _ = owner }
                ))
            }

            XCTAssertTrue(observedOuterCallback)
            XCTAssertNil(acceptedOwner)
            retainedAcceptedCallback()
            XCTAssertEqual(acceptedCalls, 1)
            XCTAssertEqual(textFieldStateModel.text, "Inner")
            XCTAssertNil(supersededOwner)
            withExtendedLifetime(reentrantSubscription) {}
            reentrantSubscription = nil
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
            XCTAssertNil(harness.host.element(withLabel: LayoutElement.trailing.accessibilityLabel))
        }

        @available(iOS 17.0, *)
        func test_onlyTrailingControl_preservesTextFieldAndOuterInsets() throws {
            let harness = makeSearchBarHost(left: false, textField: true, right: true)
            let textField = try frame(of: .textField, in: harness)
            let trailing = try frame(of: .trailing, in: harness)

            XCTAssertEqual(textField.minX, harness.host.frame.minX + contentInset, accuracy: 0.001)
            XCTAssertEqual(trailing.minX - textField.maxX, spacing, accuracy: 0.001)
            assertControl(trailing, endsAt: harness.host.frame.maxX - contentInset)
            XCTAssertNil(harness.host.element(withLabel: LayoutElement.leading.accessibilityLabel))
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
            XCTAssertNil(harness.host.firstSubview(of: UITextField.self))
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
            let leading = try XCTUnwrap(harness.host.element(withLabel: LayoutElement.leading.accessibilityLabel))
            let trailing = try XCTUnwrap(harness.host.element(withLabel: LayoutElement.trailing.accessibilityLabel))
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
        func makeStateModel(adapter: SearchBarOutputSwiftUIAdapter) -> SUISearchBarStateModel {
            SUISearchBarStateModel(
                adapter: adapter,
                appearance: makeAppearance(),
                spacing: spacing,
                cornerRadius: 12,
                padding: .init()
            )
        }

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
            let host = SwiftUIAccessibilityTestHost(
                rootView: makeSearchBar(adapter: adapter)
                    .tint(.white)
                    .frame(width: containerWidth, alignment: .leading)
                    .ignoresSafeArea(),
                size: CGSize(width: containerWidth, height: 80)
            )
            return .init(host: host)
        }

        @available(iOS 17.0, *)
        func frame(
            of element: LayoutElement,
            in harness: SearchBarTestHarness
        ) throws -> CGRect {
            switch element {
            case .leading, .trailing:
                return try XCTUnwrap(
                    harness.host.element(withLabel: element.accessibilityLabel)?.accessibilityFrame
                )
            case .textField:
                return try XCTUnwrap(harness.host.frame(ofFirstSubviewType: UITextField.self))
            }
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
    }

    private enum LayoutElement {
        case leading
        case textField
        case trailing

        var accessibilityLabel: String {
            switch self {
            case .leading:
                return "Search"
            case .textField:
                return "Search field"
            case .trailing:
                return "Clear"
            }
        }
    }
#endif
