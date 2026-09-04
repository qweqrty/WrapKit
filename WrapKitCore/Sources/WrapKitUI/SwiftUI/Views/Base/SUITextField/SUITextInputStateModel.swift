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

    @Published var text: String = ""
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
    @Published var inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel? = nil
    @Published var inputAccessoryDateOnDoneTapped: ((Date) -> Void)? = nil
    @Published var appearance: TextfieldAppearance? = nil
    @Published var isFocused: Bool = false
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
    @Published var didChangeText: [((String?) -> Void)] = []

    // startEditing / stopEditing
    @Published var shouldBecomeFirstResponder: Bool = false
    @Published var shouldResignFirstResponder: Bool = false

    private let adapter: TextInputOutputSwiftUIAdapter
    private let consumer: Consumer
    private var chunkedCharacterCount: Int?
    private var cancellables: Set<AnyCancellable> = []

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
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, let model = value.model else {
                    self?.isHidden = true
                    return
                }
                self.isHidden = false
                if self.consumer == .textField,
                   let accessibilityIdentifier = model.accessibilityIdentifier {
                    self.accessibilityIdentifier = accessibilityIdentifier
                }
                if self.consumer == .chunkedTextField {
                    self.applyProgrammaticText(model.text)
                    if let isValid = model.isValid { self.isValid = isValid }
                    return
                }
                if self.consumer == .textField, self.isFocused {
                    if let text = model.text {
                        self.applyProgrammaticText(text)
                    }
                    if let isValid = model.isValid { self.isValid = isValid }
                    return
                }
                self.applyProgrammaticText(model.text)
                self.placeholder = model.placeholder
                if let isValid = model.isValid { self.isValid = isValid }
                if let isEnabledForEditing = model.isEnabledForEditing {
                    self.applyEditingEnabled(isEnabledForEditing)
                }
                if let isUserInteractionEnabled = model.isUserInteractionEnabled {
                    self.applyUserInteractionEnabled(isUserInteractionEnabled)
                }
                if let isSecureTextEntry = model.isSecureTextEntry { self.isSecureTextEntry = isSecureTextEntry }
                if let isTextSelectionDisabled = model.isTextSelectionDisabled { self.isTextSelectionDisabled = isTextSelectionDisabled }
                if let inputType = model.inputType { self.keyboardType = inputType }
                if let type = model.autocapitalizationType { self.autocapitalizationType = type }
                self.onBecomeFirstResponder = model.onBecomeFirstResponder
                self.onResignFirstResponder = model.onResignFirstResponder
                self.onTapBackspace = model.onTapBackspace
                self.onPaste = model.onPaste
                self.onPress = model.onPress
                self.leadingViewOnPress = model.leadingViewOnPress
                self.trailingViewOnPress = model.trailingViewOnPress
                if self.consumer != .textField,
                   let accessibilityIdentifier = model.accessibilityIdentifier {
                    self.accessibilityIdentifier = accessibilityIdentifier
                }
                if let didChangeText = model.didChangeText { self.didChangeText = didChangeText }
                self.applyInputAccessoryView(model.inputAccessoryView)
                self.applyInputView(model.inputView)
                self.trailingSymbol = model.trailingSymbol
                if let mask = model.mask { self.mask = mask }
            }
            .store(in: &cancellables)

        adapter.$displayTextState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyProgrammaticText(value.text)
            }
            .store(in: &cancellables)

        adapter.$displayIsValidState
            .compactMap { $0 }
            .sink { [weak self] value in self?.isValid = value.isValid }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in self?.isHidden = value.isHidden }
            .store(in: &cancellables)

        adapter.$displayPlaceholderState
            .compactMap { $0 }
            .sink { [weak self] value in self?.placeholder = value.placeholder }
            .store(in: &cancellables)

        adapter.$displayIsEnabledForEditingState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyEditingEnabled(value.isEnabledForEditing)
            }
            .store(in: &cancellables)

        adapter.$displayIsUserInteractionEnabledState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyUserInteractionEnabled(value.isUserInteractionEnabled)
            }
            .store(in: &cancellables)

        adapter.$displayIsSecureTextEntryState
            .compactMap { $0 }
            .sink { [weak self] value in self?.isSecureTextEntry = value.isSecureTextEntry }
            .store(in: &cancellables)

        adapter.$displayIsTextSelectionDisabledState
            .compactMap { $0 }
            .sink { [weak self] value in self?.isTextSelectionDisabled = value.isTextSelectionDisabled }
            .store(in: &cancellables)

        adapter.$displayIsClearButtonActiveState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isClearButtonConfigured = true
                self?.isClearButtonActive = value.isClearButtonActive
            }
            .store(in: &cancellables)

        adapter.$displayTrailingViewIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in self?.trailingViewIsHidden = value.trailingViewIsHidden }
            .store(in: &cancellables)

        adapter.$displayLeadingViewIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in self?.leadingViewIsHidden = value.leadingViewIsHidden }
            .store(in: &cancellables)

        adapter.$displayInputTypeState
            .compactMap { $0 }
            .sink { [weak self] value in self?.keyboardType = value.inputType }
            .store(in: &cancellables)

        adapter.$displayTrailingSymbolState
            .compactMap { $0 }
            .sink { [weak self] value in self?.trailingSymbol = value.trailingSymbol }
            .store(in: &cancellables)

        adapter.$displayInputViewState
            .compactMap { $0 }
            .sink { [weak self] value in self?.applyInputView(value.inputView) }
            .store(in: &cancellables)

        adapter.$displayInputAccessoryViewState
            .compactMap { $0 }
            .sink { [weak self] value in self?.applyInputAccessoryView(value.inputAccessoryView) }
            .store(in: &cancellables)

        adapter.$displayOnBecomeFirstResponderState
            .compactMap { $0 }
            .sink { [weak self] value in self?.onBecomeFirstResponder = value.onBecomeFirstResponder }
            .store(in: &cancellables)

        adapter.$displayOnResignFirstResponderState
            .compactMap { $0 }
            .sink { [weak self] value in self?.onResignFirstResponder = value.onResignFirstResponder }
            .store(in: &cancellables)

        adapter.$displayOnTapBackspaceState
            .compactMap { $0 }
            .sink { [weak self] value in self?.onTapBackspace = value.onTapBackspace }
            .store(in: &cancellables)

        adapter.$displayOnPasteState
            .compactMap { $0 }
            .sink { [weak self] value in self?.onPaste = value.onPaste }
            .store(in: &cancellables)

        adapter.$displayOnPressState
            .compactMap { $0 }
            .sink { [weak self] value in self?.onPress = value.onPress }
            .store(in: &cancellables)

        adapter.$displayLeadingViewOnPressState
            .compactMap { $0 }
            .sink { [weak self] value in self?.leadingViewOnPress = value.leadingViewOnPress }
            .store(in: &cancellables)

        adapter.$displayTrailingViewOnPressState
            .compactMap { $0 }
            .sink { [weak self] value in self?.trailingViewOnPress = value.trailingViewOnPress }
            .store(in: &cancellables)

        adapter.$displayDidChangeTextState
            .compactMap { $0 }
            .sink { [weak self] value in self?.didChangeText = value.didChangeText }
            .store(in: &cancellables)

        adapter.$startEditingState
            .compactMap { $0 }
            .sink { [weak self] _ in self?.shouldBecomeFirstResponder = true }
            .store(in: &cancellables)

        adapter.$stopEditingState
            .compactMap { $0 }
            .sink { [weak self] _ in self?.shouldResignFirstResponder = true }
            .store(in: &cancellables)
        
        adapter.$displayMaskState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.mask = value.mask
            }
            .store(in: &cancellables)
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

    private func applyEditingEnabled(_ isEnabled: Bool) {
        isEnabledForEditing = isEnabled
        if !isEnabled {
            shouldResignFirstResponder = true
        }
    }

    private func applyUserInteractionEnabled(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        if !isEnabled {
            shouldResignFirstResponder = true
        }
    }

    func applyUserText(_ value: String) {
        text = value
        if consumer == .textField, isClearButtonConfigured, isClearButtonActive {
            isClearButtonHidden = value.isEmpty
        }
        didChangeText.forEach { $0(value) }
    }

    func configureChunkedCharacterCount(_ count: Int) {
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
        for index in 0..<min(newCharacters.count, targetCount) {
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
        (0..<count).map { index in
            guard source.indices.contains(index) else { return "" }
            return String(source[index].prefix(1))
        }
    }

    private func applyInputAccessoryView(
        _ accessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
    ) {
        inputAccessoryView = accessoryView
        inputAccessoryDateOnDoneTapped = nil
    }

    private func applyInputView(_ newInputView: TextInputPresentableModel.InputView?) {
        inputView = newInputView

        guard case .date(let model) = newInputView else { return }
        inputAccessoryView = model.accessoryView
        inputAccessoryDateOnDoneTapped = model.accessoryView == nil ? nil : model.onDoneTapped
    }
}
