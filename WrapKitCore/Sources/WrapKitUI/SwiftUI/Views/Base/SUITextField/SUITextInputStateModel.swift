//
//  SUITextInputStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 28/4/26.
//


import Combine
import UIKit

public final class SUITextInputStateModel: ObservableObject {
    @Published var text: String = ""
    @Published var placeholder: String? = nil
    @Published var isHidden: Bool = false
    @Published var isValid: Bool = true
    @Published var isEnabledForEditing: Bool = true
    @Published var isUserInteractionEnabled: Bool = true
    @Published var isSecureTextEntry: Bool = false
    @Published var isTextSelectionDisabled: Bool = false
    @Published var isClearButtonActive: Bool = true
    @Published var trailingViewIsHidden: Bool = false
    @Published var leadingViewIsHidden: Bool = false
    @Published var keyboardType: KeyboardType = .default
    @Published var trailingSymbol: String? = nil
    @Published var inputView: TextInputPresentableModel.InputView? = nil
    @Published var inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel? = nil
    @Published var appearance: TextfieldAppearance? = nil
    @Published var isFocused: Bool = false
    @Published var autocapitalizationType: TextAutocapitalizationType = .none
    @Published var mask: TextInputPresentableModel.Mask? = nil
    @Published var accessibilityIdentifier: String? = nil

    var onBecomeFirstResponder: (() -> Void)? = nil
    var onResignFirstResponder: (() -> Void)? = nil
    var onTapBackspace: (() -> Void)? = nil
    var onPaste: ((String?) -> Void)? = nil
    var onPress: (() -> Void)? = nil
    var leadingViewOnPress: (() -> Void)? = nil
    var trailingViewOnPress: (() -> Void)? = nil
    var didChangeText: [((String?) -> Void)] = []

    // startEditing / stopEditing
    @Published var shouldBecomeFirstResponder: Bool = false
    @Published var shouldResignFirstResponder: Bool = false

    private let adapter: TextInputOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: TextInputOutputSwiftUIAdapter) {
        self.adapter = adapter
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
                if let text = model.text { self.text = text.removingPercentEncoding ?? text }
                if let placeholder = model.placeholder { self.placeholder = placeholder }
                if let isValid = model.isValid { self.isValid = isValid }
                if let isEnabledForEditing = model.isEnabledForEditing { self.isEnabledForEditing = isEnabledForEditing }
                if let isUserInteractionEnabled = model.isUserInteractionEnabled { self.isUserInteractionEnabled = isUserInteractionEnabled }
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
                self.accessibilityIdentifier = model.accessibilityIdentifier
                self.inputAccessoryView = model.inputAccessoryView
                if let didChangeText = model.didChangeText { self.didChangeText = didChangeText }
                self.inputView = model.inputView
                self.inputAccessoryView = model.inputAccessoryView
                self.trailingSymbol = model.trailingSymbol
                self.mask = model.mask
            }
            .store(in: &cancellables)

        adapter.$displayTextState
            .compactMap { $0 }
            .sink { [weak self] value in
                let newText = value.text?.removingPercentEncoding ?? value.text ?? ""
                if self?.text != newText { self?.text = newText }
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
            .sink { [weak self] value in self?.isEnabledForEditing = value.isEnabledForEditing }
            .store(in: &cancellables)

        adapter.$displayIsUserInteractionEnabledState
            .compactMap { $0 }
            .sink { [weak self] value in self?.isUserInteractionEnabled = value.isUserInteractionEnabled }
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
            .sink { [weak self] value in self?.isClearButtonActive = value.isClearButtonActive }
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
            .sink { [weak self] value in self?.inputView = value.inputView }
            .store(in: &cancellables)

        adapter.$displayInputAccessoryViewState
            .compactMap { $0 }
            .sink { [weak self] value in self?.inputAccessoryView = value.inputAccessoryView }
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
}
