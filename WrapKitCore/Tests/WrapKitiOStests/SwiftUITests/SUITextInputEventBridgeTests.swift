#if canImport(SwiftUI)
    import UIKit
    @testable import WrapKit
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

        func test_fullModelThenNil_hidesAndRetainsStateAndCallbacksLikeUIKit() {
            let adapter = TextInputOutputSwiftUIAdapter()
            var events: [String] = []
            adapter.display(model: .init(
                accessibilityIdentifier: "account.field",
                text: "Account",
                isValid: false,
                isEnabledForEditing: false,
                isTextSelectionDisabled: true,
                placeholder: "Name",
                isUserInteractionEnabled: false,
                isSecureTextEntry: true,
                trailingSymbol: "%",
                autocapitalizationType: .words,
                inputType: .emailAddress,
                leadingViewOnPress: { events.append("leading") },
                trailingViewOnPress: { events.append("trailing") },
                onPress: { events.append("press") },
                onPaste: { events.append("paste:\($0 ?? "nil")") },
                onBecomeFirstResponder: { events.append("focus") },
                onResignFirstResponder: { events.append("blur") },
                onTapBackspace: { events.append("backspace") },
                didChangeText: [{ events.append("change:\($0 ?? "nil")") }]
            ))
            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertFalse(sut.isHidden)
            XCTAssertEqual(sut.accessibilityIdentifier, "account.field")
            XCTAssertEqual(sut.text, "Account")
            XCTAssertEqual(sut.placeholder, "Name")
            XCTAssertFalse(sut.isValid)
            XCTAssertFalse(sut.isEnabledForEditing)
            XCTAssertTrue(sut.isTextSelectionDisabled)
            XCTAssertFalse(sut.isUserInteractionEnabled)
            XCTAssertTrue(sut.isSecureTextEntry)
            XCTAssertEqual(sut.trailingSymbol, "%")
            XCTAssertEqual(sut.keyboardType, .emailAddress)
            if case .words = sut.autocapitalizationType {
                // Expected.
            } else {
                XCTFail("Expected words autocapitalization")
            }

            adapter.display(model: nil)

            XCTAssertTrue(sut.isHidden)
            XCTAssertEqual(sut.accessibilityIdentifier, "account.field")
            XCTAssertEqual(sut.text, "Account")
            XCTAssertEqual(sut.placeholder, "Name")
            XCTAssertFalse(sut.isValid)
            XCTAssertFalse(sut.isEnabledForEditing)
            XCTAssertTrue(sut.isTextSelectionDisabled)
            XCTAssertFalse(sut.isUserInteractionEnabled)
            XCTAssertTrue(sut.isSecureTextEntry)
            XCTAssertEqual(sut.trailingSymbol, "%")
            XCTAssertEqual(sut.keyboardType, .emailAddress)

            sut.leadingViewOnPress?()
            sut.trailingViewOnPress?()
            sut.onPress?()
            sut.onPaste?("value")
            sut.onBecomeFirstResponder?()
            sut.onResignFirstResponder?()
            sut.onTapBackspace?()
            sut.didChangeText.forEach { $0("value") }
            XCTAssertEqual(events, [
                "leading",
                "trailing",
                "press",
                "paste:value",
                "focus",
                "blur",
                "backspace",
                "change:value",
            ])
        }

        func test_granularThenFullModelBeforeMount_replaysLatestValuesInPresenterOrder() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.display(text: "Granular")
            adapter.display(placeholder: "Granular placeholder")
            adapter.display(isSecureTextEntry: true)
            adapter.display(model: .init(
                text: "Model",
                placeholder: "Model placeholder",
                isSecureTextEntry: false
            ))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.text, "Model")
            XCTAssertEqual(sut.placeholder, "Model placeholder")
            XCTAssertFalse(sut.isSecureTextEntry)
        }

        func test_fullModelThenGranularBeforeMount_replaysLatestValuesInPresenterOrder() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.display(model: .init(
                text: "Model",
                placeholder: "Model placeholder",
                isSecureTextEntry: false
            ))
            adapter.display(text: "Granular")
            adapter.display(placeholder: nil)
            adapter.display(isSecureTextEntry: true)

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.text, "Granular")
            XCTAssertNil(sut.placeholder)
            XCTAssertTrue(sut.isSecureTextEntry)
        }

        func test_fullModelNilOptionalsBeforeMount_preserveEarlierGranularConfigurationLikeUIKit() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.display(isValid: false)
            adapter.display(isEnabledForEditing: false)
            adapter.display(isSecureTextEntry: true)
            adapter.display(model: .init(text: "Model"))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertFalse(sut.isValid)
            XCTAssertFalse(sut.isEnabledForEditing)
            XCTAssertTrue(sut.isSecureTextEntry)
        }

        func test_focusCommandsBeforeMount_replayInPresenterOrder() {
            let stopThenStartAdapter = TextInputOutputSwiftUIAdapter()
            stopThenStartAdapter.stopEditing()
            stopThenStartAdapter.startEditing()

            let stopThenStart = SUITextInputStateModel(adapter: stopThenStartAdapter)
            XCTAssertTrue(stopThenStart.shouldBecomeFirstResponder)
            XCTAssertFalse(stopThenStart.shouldResignFirstResponder)

            let startThenStopAdapter = TextInputOutputSwiftUIAdapter()
            startThenStopAdapter.startEditing()
            startThenStopAdapter.stopEditing()

            let startThenStop = SUITextInputStateModel(adapter: startThenStopAdapter)
            XCTAssertFalse(startThenStop.shouldBecomeFirstResponder)
            XCTAssertTrue(startThenStop.shouldResignFirstResponder)
        }

        func test_pendingFocusCommand_survivesRemountUntilConsumed() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.startEditing()

            var firstMount: SUITextInputStateModel? = .init(adapter: adapter)
            XCTAssertTrue(firstMount?.shouldBecomeFirstResponder == true)

            firstMount = nil
            var secondMount: SUITextInputStateModel? = .init(adapter: adapter)
            XCTAssertTrue(secondMount?.shouldBecomeFirstResponder == true)

            secondMount?.shouldBecomeFirstResponder = false
            secondMount = nil

            let thirdMount = SUITextInputStateModel(adapter: adapter)
            XCTAssertFalse(thirdMount.shouldBecomeFirstResponder)
            XCTAssertFalse(thirdMount.shouldResignFirstResponder)
        }

        func test_consumedFocusHistory_doesNotChangeLaterModelScopeAfterRemount() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.startEditing()

            var firstMount: SUITextInputStateModel? = .init(adapter: adapter)
            firstMount?.shouldBecomeFirstResponder = false
            firstMount?.isFocused = false
            firstMount = nil

            adapter.display(model: .init(
                text: "Unfocused update",
                placeholder: "Applied after resign",
                isSecureTextEntry: true
            ))

            let secondMount = SUITextInputStateModel(adapter: adapter)
            XCTAssertEqual(secondMount.placeholder, "Applied after resign")
            XCTAssertTrue(secondMount.isSecureTextEntry)
            XCTAssertFalse(secondMount.shouldBecomeFirstResponder)
        }

        func test_transientEditingDisable_resignRequestSurvivesRemount() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.display(isEnabledForEditing: false)
            adapter.display(isEnabledForEditing: true)

            var firstMount: SUITextInputStateModel? = .init(adapter: adapter)
            XCTAssertTrue(firstMount?.isEnabledForEditing == true)
            XCTAssertTrue(firstMount?.shouldResignFirstResponder == true)

            firstMount = nil
            let secondMount = SUITextInputStateModel(adapter: adapter)
            XCTAssertTrue(secondMount.isEnabledForEditing)
            XCTAssertTrue(secondMount.shouldResignFirstResponder)
            XCTAssertFalse(secondMount.shouldBecomeFirstResponder)
        }

        func test_modelAfterStartEditingBeforeMount_usesFocusedUIKitUpdateScope() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.display(placeholder: "Existing placeholder")
            adapter.startEditing()
            adapter.display(model: .init(
                text: "Focused update",
                isValid: false,
                placeholder: "Ignored while focused",
                isSecureTextEntry: true
            ))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.text, "Focused update")
            XCTAssertFalse(sut.isValid)
            XCTAssertEqual(sut.placeholder, "Existing placeholder")
            XCTAssertFalse(sut.isSecureTextEntry)
            XCTAssertTrue(sut.shouldBecomeFirstResponder)
        }

        @MainActor
        func test_focusedFullModelKeepsAcceptedCallbackAndReleasesEveryIgnoredCandidateCallback() {
            final class CallbackOwner {}

            let adapter = TextInputOutputSwiftUIAdapter()
            var acceptedCalls = 0
            adapter.display(model: .init(onPress: { acceptedCalls += 1 }))
            var mountedStateModel: SUITextInputStateModel? = .init(adapter: adapter)
            mountedStateModel?.isFocused = true

            weak var ignoredOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                ignoredOwner = owner
                adapter.display(model: .init(
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
                    onBecomeFirstResponder: { _ = owner },
                    didChangeText: [{ _ in _ = owner }]
                ))
            }

            XCTAssertNil(ignoredOwner)
            mountedStateModel?.onPress?()
            XCTAssertEqual(acceptedCalls, 1)

            mountedStateModel = nil
            let remountedStateModel = SUITextInputStateModel(adapter: adapter)
            remountedStateModel.onPress?()

            XCTAssertEqual(acceptedCalls, 2)
            XCTAssertNil(remountedStateModel.inputView)
            XCTAssertNil(remountedStateModel.inputAccessoryView)
        }

        @MainActor
        func test_premountAcceptedCallbackSurvivesLaterModelRejectedByFocusGuard() {
            final class CallbackOwner {}

            let adapter = TextInputOutputSwiftUIAdapter()
            var acceptedCalls = 0
            adapter.display(model: .init(onPress: { acceptedCalls += 1 }))
            adapter.startEditing()

            weak var rejectedOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                rejectedOwner = owner
                adapter.display(model: .init(onPress: { _ = owner }))
            }

            var firstStateModel: SUITextInputStateModel? = .init(adapter: adapter)

            XCTAssertNil(rejectedOwner)
            XCTAssertTrue(firstStateModel?.shouldBecomeFirstResponder == true)
            firstStateModel?.onPress?()
            XCTAssertEqual(acceptedCalls, 1)

            firstStateModel = nil
            let remountedStateModel = SUITextInputStateModel(adapter: adapter)
            remountedStateModel.onPress?()

            XCTAssertEqual(acceptedCalls, 2)
        }

        @MainActor
        func test_premountSupersededFullModelCallbacksAreReleasedAfterFirstMount() {
            final class CallbackOwner {}

            let adapter = TextInputOutputSwiftUIAdapter()
            weak var supersededOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                supersededOwner = owner
                adapter.display(model: .init(onPress: { _ = owner }))
            }

            weak var currentOwner: CallbackOwner?
            var currentCalls = 0
            do {
                let owner = CallbackOwner()
                currentOwner = owner
                adapter.display(model: .init(onPress: {
                    _ = owner
                    currentCalls += 1
                }))
            }

            let stateModel = SUITextInputStateModel(adapter: adapter)

            XCTAssertNil(supersededOwner)
            XCTAssertNotNil(currentOwner)
            stateModel.onPress?()
            XCTAssertEqual(currentCalls, 1)

            adapter.display(onPress: nil)
            XCTAssertNil(currentOwner)
        }

        @MainActor
        func test_fullModelCallbackCannotRunBeforeStateModelAcceptsIt() throws {
            let adapter = TextInputOutputSwiftUIAdapter()
            var calls = 0
            adapter.display(model: .init(onPress: { calls += 1 }))

            try XCTUnwrap(adapter.displayModelState?.model?.onPress)()
            XCTAssertEqual(calls, 0)

            let stateModel = SUITextInputStateModel(adapter: adapter)
            try XCTUnwrap(stateModel.onPress)()
            XCTAssertEqual(calls, 1)
        }

        @MainActor
        func test_dateInputViewReleasesTopAccessoryCallbackItOverrides() throws {
            final class CallbackOwner {}

            let adapter = TextInputOutputSwiftUIAdapter()
            weak var topAccessoryOwner: CallbackOwner?
            weak var dateAccessoryOwner: CallbackOwner?
            var dateAccessoryCalls = 0
            do {
                let topOwner = CallbackOwner()
                let dateOwner = CallbackOwner()
                topAccessoryOwner = topOwner
                dateAccessoryOwner = dateOwner
                adapter.display(model: .init(
                    inputView: .date(.init(
                        accessoryView: .init(
                            trailingButton: .init(onPress: {
                                _ = dateOwner
                                dateAccessoryCalls += 1
                            })
                        ),
                        onDoneTapped: { _ in
                            _ = dateOwner
                            dateAccessoryCalls += 1
                        }
                    )),
                    inputAccessoryView: .init(
                        trailingButton: .init(onPress: { _ = topOwner })
                    )
                ))
            }

            let stateModel = SUITextInputStateModel(adapter: adapter)

            XCTAssertNil(topAccessoryOwner)
            XCTAssertNotNil(dateAccessoryOwner)
            try XCTUnwrap(stateModel.inputAccessoryView?.trailingButton?.onPress)()
            try XCTUnwrap(stateModel.inputAccessoryDateOnDoneTapped)(Date())
            XCTAssertEqual(dateAccessoryCalls, 2)

            let retainedModel = try XCTUnwrap(adapter.displayModelState?.model)
            adapter.display(inputAccessoryView: nil)

            XCTAssertNil(dateAccessoryOwner)
            if case .date(let dateModel) = retainedModel.inputView {
                dateModel.accessoryView?.trailingButton?.onPress?()
                dateModel.onDoneTapped?(Date())
            } else {
                XCTFail("Expected date input view")
            }
            XCTAssertEqual(dateAccessoryCalls, 2)
        }

        @MainActor
        func test_focusedModelRejectsCustomPickerCallbacksWithoutCallingProviders() {
            final class CallbackOwner {}

            let adapter = TextInputOutputSwiftUIAdapter()
            let stateModel = SUITextInputStateModel(adapter: adapter)
            stateModel.isFocused = true
            var providerCalls = 0
            weak var ignoredOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                ignoredOwner = owner
                adapter.display(model: .init(inputView: .custom(.init(
                    componentsCount: {
                        providerCalls += 1
                        _ = owner
                        return 1
                    },
                    rowsCount: {
                        providerCalls += 1
                        _ = owner
                        return 1
                    },
                    titleForRowAt: { _ in _ = owner; return "Row" },
                    didSelectAt: { _ in _ = owner },
                    selectedRow: .init(
                        row: 0,
                        selectedRowCompletion: { _ in _ = owner }
                    )
                ))))
            }

            XCTAssertEqual(providerCalls, 0)
            XCTAssertNil(ignoredOwner)
            XCTAssertNil(stateModel.inputView)
        }

        @MainActor
        func test_invalidAcceptedCustomPickerSelectionReleasesItsCompletion() {
            final class CallbackOwner {}

            let adapter = TextInputOutputSwiftUIAdapter()
            weak var completionOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                completionOwner = owner
                adapter.display(model: .init(inputView: .custom(.init(
                    componentsCount: { 1 },
                    rowsCount: { 1 },
                    selectedRow: .init(
                        row: 2,
                        selectedRowCompletion: { _ in _ = owner }
                    )
                ))))
            }

            _ = SUITextInputStateModel(adapter: adapter)

            XCTAssertNil(completionOwner)
        }

        func test_modelAfterEditingWasDisabledBeforeMount_usesUnfocusedUIKitUpdateScope() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.startEditing()
            adapter.display(isEnabledForEditing: false)
            adapter.display(model: .init(
                text: "Unfocused update",
                placeholder: "Applied after resign",
                isSecureTextEntry: true
            ))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.text, "Unfocused update")
            XCTAssertEqual(sut.placeholder, "Applied after resign")
            XCTAssertTrue(sut.isSecureTextEntry)
            XCTAssertFalse(sut.isEnabledForEditing)
            XCTAssertFalse(sut.shouldBecomeFirstResponder)
            XCTAssertTrue(sut.shouldResignFirstResponder)
        }

        func test_modelAfterEditingWasDisabledAndReenabledBeforeMount_remainsUnfocused() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.startEditing()
            adapter.display(isEnabledForEditing: false)
            adapter.display(isEnabledForEditing: true)
            adapter.display(model: .init(
                text: "Unfocused update",
                placeholder: "Applied after resign",
                isSecureTextEntry: true
            ))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.placeholder, "Applied after resign")
            XCTAssertTrue(sut.isSecureTextEntry)
            XCTAssertTrue(sut.isEnabledForEditing)
            XCTAssertFalse(sut.shouldBecomeFirstResponder)
            XCTAssertTrue(sut.shouldResignFirstResponder)
        }

        func test_modelAfterInteractionWasDisabledBeforeMount_usesUnfocusedUIKitUpdateScope() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.startEditing()
            adapter.display(isUserInteractionEnabled: false)
            adapter.display(model: .init(
                text: "Unfocused update",
                placeholder: "Applied after resign",
                isSecureTextEntry: true
            ))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.text, "Unfocused update")
            XCTAssertEqual(sut.placeholder, "Applied after resign")
            XCTAssertTrue(sut.isSecureTextEntry)
            XCTAssertFalse(sut.isUserInteractionEnabled)
            XCTAssertFalse(sut.shouldBecomeFirstResponder)
            XCTAssertTrue(sut.shouldResignFirstResponder)
        }

        func test_modelAfterInteractionWasDisabledAndReenabledBeforeMount_remainsUnfocused() {
            let adapter = TextInputOutputSwiftUIAdapter()
            adapter.startEditing()
            adapter.display(isUserInteractionEnabled: false)
            adapter.display(isUserInteractionEnabled: true)
            adapter.display(model: .init(
                text: "Unfocused update",
                placeholder: "Applied after resign",
                isSecureTextEntry: true
            ))

            let sut = SUITextInputStateModel(adapter: adapter)

            XCTAssertEqual(sut.placeholder, "Applied after resign")
            XCTAssertTrue(sut.isSecureTextEntry)
            XCTAssertTrue(sut.isUserInteractionEnabled)
            XCTAssertFalse(sut.shouldBecomeFirstResponder)
            XCTAssertTrue(sut.shouldResignFirstResponder)
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
                onTapBackspace: {}
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

        func test_chunkedRemountUsesCurrentCountInsteadOfCheckpointConfiguration() {
            let adapter = TextInputOutputSwiftUIAdapter()
            var mountedStateModel: SUITextInputStateModel? = .init(
                adapter: adapter,
                consumer: .chunkedTextField,
                chunkedCharacterCount: 4
            )
            adapter.display(text: "1234")

            XCTAssertEqual(mountedStateModel?.chunkedCharacters, ["1", "2", "3", "4"])

            mountedStateModel = nil
            let remountedStateModel = SUITextInputStateModel(
                adapter: adapter,
                consumer: .chunkedTextField,
                chunkedCharacterCount: 6
            )

            XCTAssertEqual(
                remountedStateModel.chunkedCharacters,
                ["1", "2", "3", "4", "", ""]
            )
            XCTAssertEqual(remountedStateModel.text, "1234")
        }

        func test_dateInputViewRemountPreservesUserDraft() {
            let adapter = TextInputOutputSwiftUIAdapter()
            let initialDate = Date(timeIntervalSinceReferenceDate: 100)
            let editedDate = Date(timeIntervalSinceReferenceDate: 200)
            adapter.display(inputView: .date(.init(value: initialDate)))

            var firstStateModel: SUITextInputStateModel? = .init(adapter: adapter)
            XCTAssertEqual(firstStateModel?.selectedInputDate, initialDate)

            firstStateModel?.selectedInputDate = editedDate
            firstStateModel = nil

            let remountedStateModel = SUITextInputStateModel(adapter: adapter)
            XCTAssertEqual(remountedStateModel.selectedInputDate, editedDate)
        }

        func test_customInputViewRemountPreservesDraftAndDoesNotRepeatSelectionCompletion() {
            let adapter = TextInputOutputSwiftUIAdapter()
            var completedRows: [Int] = []
            adapter.display(inputView: .custom(.init(
                componentsCount: { 2 },
                rowsCount: { 3 },
                titleForRowAt: { "Row \($0)" },
                selectedRow: .init(
                    row: 2,
                    component: 1,
                    selectedRowCompletion: { completedRows.append($0) }
                )
            )))

            var firstStateModel: SUITextInputStateModel? = .init(adapter: adapter)
            XCTAssertEqual(firstStateModel?.selectedInputPickerRows, [0: 0, 1: 2])
            XCTAssertEqual(completedRows, [2])

            firstStateModel?.selectedInputPickerRows = [0: 0, 1: 1]
            firstStateModel = nil

            let remountedStateModel = SUITextInputStateModel(adapter: adapter)
            XCTAssertEqual(remountedStateModel.selectedInputPickerRows, [0: 0, 1: 1])
            XCTAssertEqual(completedRows, [2])
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

    func test_secureTextEntryUpdatesTextViewState() {
            let adapter = TextInputOutputSwiftUIAdapter()
            let sut = SUITextInputStateModel(adapter: adapter, consumer: .textView)

            adapter.display(isSecureTextEntry: true)
            XCTAssertTrue(sut.isSecureTextEntry)

            adapter.display(isSecureTextEntry: false)
        XCTAssertFalse(sut.isSecureTextEntry)
    }

    func test_clearButtonVisibility_tracksUserInputWhenActive() {
        let adapter = TextInputOutputSwiftUIAdapter()
        adapter.display(isClearButtonActive: true)
        let sut = SUITextInputStateModel(adapter: adapter)

        sut.applyUserText("A")
        XCTAssertFalse(sut.isClearButtonHidden)

        sut.applyUserText("")
        XCTAssertTrue(sut.isClearButtonHidden)
    }

        func test_startEditingRequestsBecomeFirstResponder() {
            let adapter = TextInputOutputSwiftUIAdapter()
            let sut = SUITextInputStateModel(adapter: adapter)

            adapter.startEditing()

            XCTAssertTrue(sut.shouldBecomeFirstResponder)
        }

        func test_stopEditingRequestsResignFirstResponder() {
            let adapter = TextInputOutputSwiftUIAdapter()
            let sut = SUITextInputStateModel(adapter: adapter)

            adapter.stopEditing()

            XCTAssertTrue(sut.shouldResignFirstResponder)
        }
    }

    private final class TextFieldDelegateStub: NSObject, UITextFieldDelegate {
        let shouldChange: Bool

        init(shouldChange: Bool) {
            self.shouldChange = shouldChange
        }

        func textField(
            _: UITextField,
            shouldChangeCharactersIn _: NSRange,
            replacementString _: String
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
            _: UITextView,
            shouldChangeTextIn _: NSRange,
            replacementText _: String
        ) -> Bool {
            shouldChange
        }
    }

    private final class TextPasteDelegateStub: NSObject, UITextPasteDelegate {}
#endif
