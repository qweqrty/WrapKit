//
//  SUITextInputStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 28/4/26.
//

import Combine
import Foundation

public final class SUITextInputStateModel: ObservableObject {
    enum Consumer: Equatable {
        case textField
        case textView
        case chunkedTextField
    }

    @Published var text: String = "" {
        didSet { persistReplayCheckpoint() }
    }
    @Published var chunkedCharacters: [String] = []
    @Published var placeholder: String? = nil
    @Published var isHidden: Bool = false
    @Published var isValid: Bool = true
    @Published var isEnabledForEditing: Bool = true
    @Published var isUserInteractionEnabled: Bool = true
    @Published var isSecureTextEntry: Bool = false
    @Published var isTextSelectionDisabled: Bool = false
    @Published var isClearButtonActive: Bool = true
    @Published var isClearButtonConfigured: Bool = false
    @Published var isClearButtonHidden: Bool = true
    @Published var trailingViewIsHidden: Bool = false
    @Published var leadingViewIsHidden: Bool = false
    @Published var keyboardType: KeyboardType = .default
    @Published var trailingSymbol: String? = nil
    @Published var inputView: TextInputPresentableModel.InputView? = nil
    @Published var selectedInputDate = Date() {
        didSet { persistReplayCheckpoint() }
    }
    @Published var selectedInputPickerRows: [Int: Int] = [:] {
        didSet { persistReplayCheckpoint() }
    }
    @Published var inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel? = nil
    @Published var inputAccessoryDateOnDoneTapped: ((Date) -> Void)? = nil
    @Published var appearance: TextfieldAppearance? = nil
    @Published var isFocused: Bool = false {
        didSet { persistReplayCheckpoint() }
    }
    @Published var autocapitalizationType: TextAutocapitalizationType = .none
    @Published var mask: TextInputPresentableModel.Mask? = nil
    @Published var accessibilityIdentifier: String? = nil

    @Published var onBecomeFirstResponder: (() -> Void)? = nil
    @Published var onResignFirstResponder: (() -> Void)? = nil
    @Published var onTapBackspace: (() -> Void)? = nil
    @Published var onPaste: ((String?) -> Void)? = nil
    @Published var onPress: (() -> Void)? = nil
    @Published var leadingViewOnPress: (() -> Void)? = nil
    @Published var trailingViewOnPress: (() -> Void)? = nil
    @Published var didChangeText: [(String?) -> Void] = []

    // startEditing / stopEditing
    @Published var shouldBecomeFirstResponder: Bool = false {
        didSet { persistReplayCheckpoint() }
    }
    @Published var shouldResignFirstResponder: Bool = false {
        didSet { persistReplayCheckpoint() }
    }

    private let adapter: TextInputOutputSwiftUIAdapter

    private var outputReplayConsumer: TextInputOutputSwiftUIAdapter.OutputReplayConsumer?
    private let consumer: Consumer
    private var chunkedCharacterCount: Int?
    private var cancellables: Set<AnyCancellable> = []
    private var latestOutputSequenceByField: [OutputField: UInt64] = [:]
    private var latestFocusBecomeOutputSequence: UInt64 = 0
    private var latestFocusResignOutputSequence: UInt64 = 0

    private enum OutputField: Hashable {
        case visibility
        case accessibilityIdentifier
        case text
        case mask
        case validity
        case editingEnabled
        case textSelection
        case placeholder
        case userInteraction
        case secureTextEntry
        case autocapitalization
        case inputType
        case leadingViewOnPress
        case trailingViewOnPress
        case onPress
        case onPaste
        case onBecomeFirstResponder
        case onResignFirstResponder
        case onTapBackspace
        case didChangeText
        case trailingViewVisibility
        case leadingViewVisibility
        case inputView
        case inputAccessoryView
        case trailingSymbol
        case clearButton
        case focusCommand
    }

    private struct OutputReplayCheckpoint {
        let text: String
        let chunkedCharacters: [String]
        let placeholder: String?
        let isHidden: Bool
        let isValid: Bool
        let isEnabledForEditing: Bool
        let isUserInteractionEnabled: Bool
        let isSecureTextEntry: Bool
        let isTextSelectionDisabled: Bool
        let isClearButtonActive: Bool
        let isClearButtonConfigured: Bool
        let isClearButtonHidden: Bool
        let trailingViewIsHidden: Bool
        let leadingViewIsHidden: Bool
        let keyboardType: KeyboardType
        let trailingSymbol: String?
        let inputView: TextInputPresentableModel.InputView?
        let selectedInputDate: Date
        let selectedInputPickerRows: [Int: Int]
        let inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
        let inputAccessoryDateOnDoneTapped: ((Date) -> Void)?
        let appearance: TextfieldAppearance?
        let isFocused: Bool
        let autocapitalizationType: TextAutocapitalizationType
        let mask: TextInputPresentableModel.Mask?
        let accessibilityIdentifier: String?
        let onBecomeFirstResponder: (() -> Void)?
        let onResignFirstResponder: (() -> Void)?
        let onTapBackspace: (() -> Void)?
        let onPaste: ((String?) -> Void)?
        let onPress: (() -> Void)?
        let leadingViewOnPress: (() -> Void)?
        let trailingViewOnPress: (() -> Void)?
        let didChangeText: [(String?) -> Void]
        let shouldBecomeFirstResponder: Bool
        let shouldResignFirstResponder: Bool
        let chunkedCharacterCount: Int?
        let latestOutputSequenceByField: [OutputField: UInt64]
        let latestFocusBecomeOutputSequence: UInt64
        let latestFocusResignOutputSequence: UInt64
    }

    public convenience init(adapter: TextInputOutputSwiftUIAdapter) {
        self.init(adapter: adapter, consumer: .textField)
    }

    init(
        adapter: TextInputOutputSwiftUIAdapter,
        consumer: Consumer,
        chunkedCharacterCount: Int? = nil
    ) {
        self.adapter = adapter
        self.consumer = consumer
        self.chunkedCharacterCount = chunkedCharacterCount.map { max(0, $0) }
        bindAdapter()
    }

    private func bindAdapter() {
        let configuredChunkedCharacterCount = chunkedCharacterCount
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let replayCheckpoint = adapter.outputReplayCheckpoint(as: OutputReplayCheckpoint.self, consumer: outputReplayConsumer)
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)

        adapter.outputReplayPublisher(
            adapter.$displayModelState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(model: value.model, outputSequence: value.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTextState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.text, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.applyProgrammaticText(value.text)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsValidState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.validity, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.isValid = value.isValid
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.visibility, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.isHidden = value.isHidden
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayPlaceholderState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.placeholder, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.placeholder = value.placeholder
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsEnabledForEditingState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyEditingEnabled(value.isEnabledForEditing, outputSequence: value.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsUserInteractionEnabledState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyUserInteractionEnabled(
                    value.isUserInteractionEnabled,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsSecureTextEntryState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.secureTextEntry, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.isSecureTextEntry = value.isSecureTextEntry
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsTextSelectionDisabledState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.textSelection, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.isTextSelectionDisabled = value.isTextSelectionDisabled
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsClearButtonActiveState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.clearButton, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.isClearButtonConfigured = true
                self.isClearButtonActive = value.isClearButtonActive
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTrailingViewIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.trailingViewVisibility, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.trailingViewIsHidden = value.trailingViewIsHidden
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayLeadingViewIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.leadingViewVisibility, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.leadingViewIsHidden = value.leadingViewIsHidden
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayInputTypeState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.inputType, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.keyboardType = value.inputType
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTrailingSymbolState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.trailingSymbol, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.trailingSymbol = value.trailingSymbol
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayInputViewState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyInputView(value.inputView, outputSequence: value.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayInputAccessoryViewState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyInputAccessoryView(
                    value.inputAccessoryView,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnBecomeFirstResponderState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.onBecomeFirstResponder, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.onBecomeFirstResponder = value.onBecomeFirstResponder
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnResignFirstResponderState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.onResignFirstResponder, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.onResignFirstResponder = value.onResignFirstResponder
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnTapBackspaceState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.onTapBackspace, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.onTapBackspace = value.onTapBackspace
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnPasteState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.onPaste, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.onPaste = value.onPaste
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnPressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.onPress, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.onPress = value.onPress
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayLeadingViewOnPressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.leadingViewOnPress, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.leadingViewOnPress = value.leadingViewOnPress
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTrailingViewOnPressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.trailingViewOnPress, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.trailingViewOnPress = value.trailingViewOnPress
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayDidChangeTextState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.didChangeText, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.didChangeText = value.didChangeText
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$startEditingState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyFocusCommand(.become, outputSequence: value.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$stopEditingState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyFocusCommand(.resign, outputSequence: value.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayMaskState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, self.shouldApply(.mask, outputSequence: value.outputSequence) else { return }
                defer { self.persistReplayCheckpoint() }
                self.mask = value.mask
            }
            .store(in: &cancellables)

        adapter.outputReplayCheckpointRequestPublisher(consumer: outputReplayConsumer)
            .sink { [weak self] in self?.persistReplayCheckpoint() }
            .store(in: &cancellables)

        if let replayCheckpoint {
            restore(replayCheckpoint)
        }
        if let configuredChunkedCharacterCount {
            configureChunkedCharacterCount(configuredChunkedCharacterCount)
        }

        bufferedOutputReplayPublisher
            .sink { [weak adapter] event in
                adapter?.replayOutputEvent(event, consumer: outputReplayConsumer)
            }
            .store(in: &cancellables)

        persistReplayCheckpoint()
    }

    private func apply(model: TextInputPresentableModel?, outputSequence: UInt64) {
        defer {
            adapter.discardTextInputModelCallbackCandidate(outputSequence: outputSequence)
            persistReplayCheckpoint()
        }
        if shouldApply(.visibility, outputSequence: outputSequence) {
            isHidden = model == nil
        }
        guard let model else { return }

        if consumer == .textField,
           let accessibilityIdentifier = model.accessibilityIdentifier,
           shouldApply(.accessibilityIdentifier, outputSequence: outputSequence) {
            self.accessibilityIdentifier = accessibilityIdentifier
        }

        if consumer == .chunkedTextField {
            if shouldApply(.text, outputSequence: outputSequence) {
                applyProgrammaticText(model.text)
            }
            if let isValid = model.isValid,
               shouldApply(.validity, outputSequence: outputSequence) {
                self.isValid = isValid
            }
            return
        }

        if consumer == .textField,
           isFocused || wasFocusRequested(before: outputSequence) {
            if let text = model.text,
               shouldApply(.text, outputSequence: outputSequence) {
                applyProgrammaticText(text)
            }
            if let isValid = model.isValid,
               shouldApply(.validity, outputSequence: outputSequence) {
                self.isValid = isValid
            }
            return
        }

        if shouldApply(.text, outputSequence: outputSequence) {
            applyProgrammaticText(model.text)
        }
        if shouldApply(.placeholder, outputSequence: outputSequence) {
            placeholder = model.placeholder
        }
        if let isValid = model.isValid,
           shouldApply(.validity, outputSequence: outputSequence) {
            self.isValid = isValid
        }
        if let isEnabledForEditing = model.isEnabledForEditing {
            applyEditingEnabled(isEnabledForEditing, outputSequence: outputSequence)
        }
        if let isUserInteractionEnabled = model.isUserInteractionEnabled {
            applyUserInteractionEnabled(isUserInteractionEnabled, outputSequence: outputSequence)
        }
        if let isSecureTextEntry = model.isSecureTextEntry,
           shouldApply(.secureTextEntry, outputSequence: outputSequence) {
            self.isSecureTextEntry = isSecureTextEntry
        }
        if let isTextSelectionDisabled = model.isTextSelectionDisabled,
           shouldApply(.textSelection, outputSequence: outputSequence) {
            self.isTextSelectionDisabled = isTextSelectionDisabled
        }
        if let inputType = model.inputType,
           shouldApply(.inputType, outputSequence: outputSequence) {
            keyboardType = inputType
        }
        if let type = model.autocapitalizationType,
           shouldApply(.autocapitalization, outputSequence: outputSequence) {
            autocapitalizationType = type
        }
        if shouldApply(.onBecomeFirstResponder, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "onBecomeFirstResponder",
                outputSequence: outputSequence,
                accepted: true
            )
            onBecomeFirstResponder = model.onBecomeFirstResponder
        } else {
            resolveTextInputModelCallbackGroup(
                "onBecomeFirstResponder",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if shouldApply(.onResignFirstResponder, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "onResignFirstResponder",
                outputSequence: outputSequence,
                accepted: true
            )
            onResignFirstResponder = model.onResignFirstResponder
        } else {
            resolveTextInputModelCallbackGroup(
                "onResignFirstResponder",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if shouldApply(.onTapBackspace, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "onTapBackspace",
                outputSequence: outputSequence,
                accepted: true
            )
            onTapBackspace = model.onTapBackspace
        } else {
            resolveTextInputModelCallbackGroup(
                "onTapBackspace",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if shouldApply(.onPaste, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "onPaste",
                outputSequence: outputSequence,
                accepted: true
            )
            onPaste = model.onPaste
        } else {
            resolveTextInputModelCallbackGroup(
                "onPaste",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if shouldApply(.onPress, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "onPress",
                outputSequence: outputSequence,
                accepted: true
            )
            onPress = model.onPress
        } else {
            resolveTextInputModelCallbackGroup(
                "onPress",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if shouldApply(.leadingViewOnPress, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "leadingViewOnPress",
                outputSequence: outputSequence,
                accepted: true
            )
            leadingViewOnPress = model.leadingViewOnPress
        } else {
            resolveTextInputModelCallbackGroup(
                "leadingViewOnPress",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if shouldApply(.trailingViewOnPress, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "trailingViewOnPress",
                outputSequence: outputSequence,
                accepted: true
            )
            trailingViewOnPress = model.trailingViewOnPress
        } else {
            resolveTextInputModelCallbackGroup(
                "trailingViewOnPress",
                outputSequence: outputSequence,
                accepted: false
            )
        }
        if consumer != .textField,
           let accessibilityIdentifier = model.accessibilityIdentifier,
           shouldApply(.accessibilityIdentifier, outputSequence: outputSequence) {
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        if let didChangeText = model.didChangeText,
           shouldApply(.didChangeText, outputSequence: outputSequence) {
            resolveTextInputModelCallbackGroup(
                "didChangeText",
                outputSequence: outputSequence,
                accepted: true
            )
            self.didChangeText = didChangeText
        }
        let latestInputViewOutputSequence = latestOutputSequenceByField[.inputView] ?? 0
        let acceptsInputView = outputSequence > latestInputViewOutputSequence

        let acceptsInputAccessoryView = shouldApply(
            .inputAccessoryView,
            outputSequence: outputSequence
        )
        resolveTextInputModelCallbackGroup(
            "inputAccessoryView",
            outputSequence: outputSequence,
            accepted: acceptsInputAccessoryView
        )
        if acceptsInputAccessoryView {
            let dateOnDoneTapped: ((Date) -> Void)?
            if case .date(let dateModel) = model.inputView {
                dateOnDoneTapped = dateModel.onDoneTapped
            } else {
                dateOnDoneTapped = nil
            }
            applyAcceptedInputAccessoryView(
                model.inputAccessoryView,
                dateOnDoneTapped: dateOnDoneTapped
            )
        }

        resolveTextInputModelCallbackGroup(
            "inputView",
            outputSequence: outputSequence,
            accepted: acceptsInputView
        )
        if acceptsInputView {
            latestOutputSequenceByField[.inputView] = outputSequence
            applyAcceptedInputView(
                model.inputView,
                outputSequence: outputSequence,
                updatesInputAccessoryView: false
            )
        }
        if shouldApply(.trailingSymbol, outputSequence: outputSequence) {
            trailingSymbol = model.trailingSymbol
        }
        if let mask = model.mask,
           shouldApply(.mask, outputSequence: outputSequence) {
            self.mask = mask
        }
    }

    private func shouldApply(_ field: OutputField, outputSequence: UInt64) -> Bool {
        let latestOutputSequence = latestOutputSequenceByField[field] ?? 0
        guard outputSequence >= latestOutputSequence else { return false }
        latestOutputSequenceByField[field] = outputSequence
        return true
    }

    private func resolveTextInputModelCallbackGroup(
        _ path: String,
        outputSequence: UInt64,
        accepted: Bool
    ) {
        adapter.resolveTextInputModelCallbackGroup(
            outputSequence: outputSequence,
            path: path,
            accepted: accepted
        )
    }

    private func wasFocusRequested(before outputSequence: UInt64) -> Bool {
        guard shouldBecomeFirstResponder else { return false }

        let priorStartSequence = latestFocusBecomeOutputSequence < outputSequence
            ? latestFocusBecomeOutputSequence
            : 0
        let priorResignSequence = latestFocusResignOutputSequence < outputSequence
            ? latestFocusResignOutputSequence
            : 0
        return priorStartSequence > priorResignSequence
    }

    private func applyProgrammaticText(_ value: String?) {
        if consumer == .chunkedTextField {
            applyProgrammaticChunkedText(value)
            return
        }

        let newText = value?.removingPercentEncoding ?? value ?? ""
        if text != newText {
            text = newText
        }
    }

    private func applyEditingEnabled(_ isEnabled: Bool, outputSequence: UInt64) {
        defer { persistReplayCheckpoint() }
        guard shouldApply(.editingEnabled, outputSequence: outputSequence) else { return }
        isEnabledForEditing = isEnabled
        if !isEnabled {
            applyFocusCommand(.resign, outputSequence: outputSequence)
        }
    }

    private func applyUserInteractionEnabled(_ isEnabled: Bool, outputSequence: UInt64) {
        defer { persistReplayCheckpoint() }
        guard shouldApply(.userInteraction, outputSequence: outputSequence) else { return }
        isUserInteractionEnabled = isEnabled
        if !isEnabled {
            applyFocusCommand(.resign, outputSequence: outputSequence)
        }
    }

    private enum FocusCommand {
        case become
        case resign
    }

    private func applyFocusCommand(_ command: FocusCommand, outputSequence: UInt64) {
        defer { persistReplayCheckpoint() }
        guard shouldApply(.focusCommand, outputSequence: outputSequence) else { return }
        switch command {
        case .become:
            latestFocusBecomeOutputSequence = outputSequence
            shouldResignFirstResponder = false
            shouldBecomeFirstResponder = true
        case .resign:
            latestFocusResignOutputSequence = outputSequence
            shouldBecomeFirstResponder = false
            shouldResignFirstResponder = true
        }
    }

    func applyUserText(_ value: String) {
        defer { persistReplayCheckpoint() }
        text = value
        if consumer == .textField, isClearButtonConfigured, isClearButtonActive {
            isClearButtonHidden = value.isEmpty
        }
        didChangeText.forEach { $0(value) }
    }

    func configureChunkedCharacterCount(_ count: Int) {
        defer { persistReplayCheckpoint() }
        guard consumer == .chunkedTextField else { return }

        let count = max(0, count)
        guard chunkedCharacterCount != count else { return }

        chunkedCharacterCount = count
        let source = chunkedCharacters.isEmpty ? Array(text).map(String.init) : chunkedCharacters
        let normalized = normalizedChunkedCharacters(source, count: count)
        if chunkedCharacters != normalized {
            chunkedCharacters = normalized
        }

        let joined = normalized.joined()
        if text != joined {
            text = joined
        }
    }

    func applyChunkedUserCharacters(_ characters: [String]) {
        defer { persistReplayCheckpoint() }
        guard consumer == .chunkedTextField else { return }

        let targetCount = chunkedCharacterCount ?? max(chunkedCharacters.count, characters.count)
        let normalized = normalizedChunkedCharacters(characters, count: targetCount)
        if chunkedCharacters != normalized {
            chunkedCharacters = normalized
        }

        let joined = normalized.joined()
        if text != joined {
            text = joined
        }
        didChangeText.forEach { $0(joined) }
    }

    private func applyProgrammaticChunkedText(_ value: String?) {
        let newCharacters = Array(value ?? "").map(String.init)
        let targetCount = chunkedCharacterCount ?? max(chunkedCharacters.count, newCharacters.count)

        guard !newCharacters.isEmpty else {
            let cleared = Array(repeating: "", count: targetCount)
            if chunkedCharacters != cleared {
                chunkedCharacters = cleared
            }
            if !text.isEmpty {
                text = ""
            }
            return
        }

        var mergedCharacters = normalizedChunkedCharacters(chunkedCharacters, count: targetCount)
        for index in 0 ..< min(newCharacters.count, targetCount) {
            mergedCharacters[index] = newCharacters[index]
        }

        if chunkedCharacters != mergedCharacters {
            chunkedCharacters = mergedCharacters
        }
        let joined = mergedCharacters.joined()
        if text != joined {
            text = joined
        }
    }

    private func normalizedChunkedCharacters(_ source: [String], count: Int) -> [String] {
        (0 ..< count).map { index in
            guard source.indices.contains(index) else { return "" }
            return String(source[index].prefix(1))
        }
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        text = checkpoint.text
        chunkedCharacters = checkpoint.chunkedCharacters
        placeholder = checkpoint.placeholder
        isHidden = checkpoint.isHidden
        isValid = checkpoint.isValid
        isEnabledForEditing = checkpoint.isEnabledForEditing
        isUserInteractionEnabled = checkpoint.isUserInteractionEnabled
        isSecureTextEntry = checkpoint.isSecureTextEntry
        isTextSelectionDisabled = checkpoint.isTextSelectionDisabled
        isClearButtonActive = checkpoint.isClearButtonActive
        isClearButtonConfigured = checkpoint.isClearButtonConfigured
        isClearButtonHidden = checkpoint.isClearButtonHidden
        trailingViewIsHidden = checkpoint.trailingViewIsHidden
        leadingViewIsHidden = checkpoint.leadingViewIsHidden
        keyboardType = checkpoint.keyboardType
        trailingSymbol = checkpoint.trailingSymbol
        inputView = checkpoint.inputView
        selectedInputDate = checkpoint.selectedInputDate
        selectedInputPickerRows = checkpoint.selectedInputPickerRows
        inputAccessoryView = checkpoint.inputAccessoryView
        inputAccessoryDateOnDoneTapped = checkpoint.inputAccessoryDateOnDoneTapped
        appearance = checkpoint.appearance
        isFocused = checkpoint.isFocused
        autocapitalizationType = checkpoint.autocapitalizationType
        mask = checkpoint.mask
        accessibilityIdentifier = checkpoint.accessibilityIdentifier
        onBecomeFirstResponder = checkpoint.onBecomeFirstResponder
        onResignFirstResponder = checkpoint.onResignFirstResponder
        onTapBackspace = checkpoint.onTapBackspace
        onPaste = checkpoint.onPaste
        onPress = checkpoint.onPress
        leadingViewOnPress = checkpoint.leadingViewOnPress
        trailingViewOnPress = checkpoint.trailingViewOnPress
        didChangeText = checkpoint.didChangeText
        shouldBecomeFirstResponder = checkpoint.shouldBecomeFirstResponder
        shouldResignFirstResponder = checkpoint.shouldResignFirstResponder
        chunkedCharacterCount = checkpoint.chunkedCharacterCount
        latestOutputSequenceByField = checkpoint.latestOutputSequenceByField
        latestFocusBecomeOutputSequence = checkpoint.latestFocusBecomeOutputSequence
        latestFocusResignOutputSequence = checkpoint.latestFocusResignOutputSequence
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer,
            OutputReplayCheckpoint(
                text: text,
                chunkedCharacters: chunkedCharacters,
                placeholder: placeholder,
                isHidden: isHidden,
                isValid: isValid,
                isEnabledForEditing: isEnabledForEditing,
                isUserInteractionEnabled: isUserInteractionEnabled,
                isSecureTextEntry: isSecureTextEntry,
                isTextSelectionDisabled: isTextSelectionDisabled,
                isClearButtonActive: isClearButtonActive,
                isClearButtonConfigured: isClearButtonConfigured,
                isClearButtonHidden: isClearButtonHidden,
                trailingViewIsHidden: trailingViewIsHidden,
                leadingViewIsHidden: leadingViewIsHidden,
                keyboardType: keyboardType,
                trailingSymbol: trailingSymbol,
                inputView: inputView,
                selectedInputDate: selectedInputDate,
                selectedInputPickerRows: selectedInputPickerRows,
                inputAccessoryView: inputAccessoryView,
                inputAccessoryDateOnDoneTapped: inputAccessoryDateOnDoneTapped,
                appearance: appearance,
                isFocused: isFocused,
                autocapitalizationType: autocapitalizationType,
                mask: mask,
                accessibilityIdentifier: accessibilityIdentifier,
                onBecomeFirstResponder: onBecomeFirstResponder,
                onResignFirstResponder: onResignFirstResponder,
                onTapBackspace: onTapBackspace,
                onPaste: onPaste,
                onPress: onPress,
                leadingViewOnPress: leadingViewOnPress,
                trailingViewOnPress: trailingViewOnPress,
                didChangeText: didChangeText,
                shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                shouldResignFirstResponder: shouldResignFirstResponder,
                chunkedCharacterCount: chunkedCharacterCount,
                latestOutputSequenceByField: latestOutputSequenceByField,
                latestFocusBecomeOutputSequence: latestFocusBecomeOutputSequence,
                latestFocusResignOutputSequence: latestFocusResignOutputSequence
            )
        )
    }

    private func applyInputAccessoryView(
        _ accessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?,
        outputSequence: UInt64
    ) {
        defer { persistReplayCheckpoint() }
        guard shouldApply(.inputAccessoryView, outputSequence: outputSequence) else { return }
        applyAcceptedInputAccessoryView(accessoryView)
    }

    private func applyAcceptedInputAccessoryView(
        _ accessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?,
        dateOnDoneTapped: ((Date) -> Void)? = nil
    ) {
        inputAccessoryView = accessoryView
        inputAccessoryDateOnDoneTapped = accessoryView == nil ? nil : dateOnDoneTapped
    }

    private func applyInputView(
        _ newInputView: TextInputPresentableModel.InputView?,
        outputSequence: UInt64
    ) {
        defer { persistReplayCheckpoint() }
        let latestInputViewOutputSequence = latestOutputSequenceByField[.inputView] ?? 0
        guard outputSequence > latestInputViewOutputSequence else { return }
        latestOutputSequenceByField[.inputView] = outputSequence
        applyAcceptedInputView(newInputView, outputSequence: outputSequence)
    }

    private func applyAcceptedInputView(
        _ newInputView: TextInputPresentableModel.InputView?,
        outputSequence: UInt64,
        updatesInputAccessoryView: Bool = true
    ) {
        switch newInputView {
        case .date(let model):
            inputView = .date(.init(
                minDate: model.minDate,
                maxDate: model.maxDate,
                mode: model.mode,
                value: model.value,
                onChange: model.onChange
            ))
            selectedInputDate = model.value
            selectedInputPickerRows = [:]
            guard updatesInputAccessoryView else { return }
            guard shouldApply(.inputAccessoryView, outputSequence: outputSequence) else { return }
            inputAccessoryView = model.accessoryView
            inputAccessoryDateOnDoneTapped = model.accessoryView == nil ? nil : model.onDoneTapped
        case .custom(let model):
            inputView = newInputView
            let componentsCount = max(model.componentsCount?() ?? 0, 0)
            selectedInputPickerRows = Dictionary(
                uniqueKeysWithValues: (0 ..< componentsCount).map { ($0, 0) }
            )
            guard let selectedRow = model.selectedRow,
                  selectedRow.component >= 0,
                  selectedRow.component < componentsCount,
                  selectedRow.row >= 0,
                  selectedRow.row < max(model.rowsCount?() ?? 0, 0)
            else {
                adapter.invalidateTextInputModelCallback(
                    path: "inputView.custom.selectedRow.completion"
                )
                return
            }
            selectedInputPickerRows[selectedRow.component] = selectedRow.row
            selectedRow.selectedRowCompletion?(selectedRow.row)
        case nil:
            inputView = nil
            selectedInputPickerRows = [:]
        }
    }
}
