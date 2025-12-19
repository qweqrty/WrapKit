// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class TextInputOutputSpy: TextInputOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: TextInputPresentableModel?)
        case displayText(text: String?)
        case startEditing
        case stopEditing
        case displayMask(mask: TextInputPresentableModel.Mask)
        case displayIsValid(isValid: Bool)
        case displayIsEnabledForEditing(isEnabledForEditing: Bool)
        case displayIsTextSelectionDisabled(isTextSelectionDisabled: Bool)
        case displayPlaceholder(placeholder: String?)
        case displayIsUserInteractionEnabled(isUserInteractionEnabled: Bool)
        case displayIsSecureTextEntry(isSecureTextEntry: Bool)
        case displayLeadingViewOnPress(leadingViewOnPress: (() -> Void)?)
        case displayTrailingViewOnPress(trailingViewOnPress: (() -> Void)?)
        case displayOnPress(onPress: (() -> Void)?)
        case displayOnPaste(onPaste: ((String?) -> Void)?)
        case displayOnBecomeFirstResponder(onBecomeFirstResponder: (() -> Void)?)
        case displayOnResignFirstResponder(onResignFirstResponder: (() -> Void)?)
        case displayOnTapBackspace(onTapBackspace: (() -> Void)?)
        case displayDidChangeText(didChangeText: [((String?) -> Void)])
        case displayTrailingViewIsHidden(trailingViewIsHidden: Bool)
        case displayLeadingViewIsHidden(leadingViewIsHidden: Bool)
        case displayIsHidden(isHidden: Bool)
        case displayInputView(inputView: TextInputPresentableModel.InputView?)
        case displayInputType(inputType: KeyboardType)
        case displayTrailingSymbol(trailingSymbol: String?)
        case displayInputAccessoryView(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?)
        case displayIsClearButtonActive(isClearButtonActive: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [TextInputPresentableModel?] = []
    public private(set) var capturedDisplayTextText: [String?] = []
    public private(set) var capturedDisplayMaskMask: [TextInputPresentableModel.Mask] = []
    public private(set) var capturedDisplayIsValidIsValid: [Bool] = []
    public private(set) var capturedDisplayIsEnabledForEditingIsEnabledForEditing: [Bool] = []
    public private(set) var capturedDisplayIsTextSelectionDisabledIsTextSelectionDisabled: [Bool] = []
    public private(set) var capturedDisplayPlaceholderPlaceholder: [String?] = []
    public private(set) var capturedDisplayIsUserInteractionEnabledIsUserInteractionEnabled: [Bool] = []
    public private(set) var capturedDisplayIsSecureTextEntryIsSecureTextEntry: [Bool] = []
    public private(set) var capturedDisplayLeadingViewOnPressLeadingViewOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayTrailingViewOnPressTrailingViewOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnPressOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnPasteOnPaste: [((String?) -> Void)?] = []
    public private(set) var capturedDisplayOnBecomeFirstResponderOnBecomeFirstResponder: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnResignFirstResponderOnResignFirstResponder: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnTapBackspaceOnTapBackspace: [(() -> Void)?] = []
    public private(set) var capturedDisplayDidChangeTextDidChangeText: [[((String?) -> Void)]] = []
    public private(set) var capturedDisplayTrailingViewIsHiddenTrailingViewIsHidden: [Bool] = []
    public private(set) var capturedDisplayLeadingViewIsHiddenLeadingViewIsHidden: [Bool] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []
    public private(set) var capturedDisplayInputViewInputView: [TextInputPresentableModel.InputView?] = []
    public private(set) var capturedDisplayInputTypeInputType: [KeyboardType] = []
    public private(set) var capturedDisplayTrailingSymbolTrailingSymbol: [String?] = []
    public private(set) var capturedDisplayInputAccessoryViewInputAccessoryView: [TextInputPresentableModel.AccessoryViewPresentableModel?] = []
    public private(set) var capturedDisplayIsClearButtonActiveIsClearButtonActive: [Bool] = []


    // MARK: - TextInputOutput methods
    public func display(model: TextInputPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(text: String?) {
        capturedDisplayTextText.append(text)
        messages.append(.displayText(text: text))
    }
    public func startEditing() {
        messages.append(.startEditing)
    }
    public func stopEditing() {
        messages.append(.stopEditing)
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        capturedDisplayMaskMask.append(mask)
        messages.append(.displayMask(mask: mask))
    }
    public func display(isValid: Bool) {
        capturedDisplayIsValidIsValid.append(isValid)
        messages.append(.displayIsValid(isValid: isValid))
    }
    public func display(isEnabledForEditing: Bool) {
        capturedDisplayIsEnabledForEditingIsEnabledForEditing.append(isEnabledForEditing)
        messages.append(.displayIsEnabledForEditing(isEnabledForEditing: isEnabledForEditing))
    }
    public func display(isTextSelectionDisabled: Bool) {
        capturedDisplayIsTextSelectionDisabledIsTextSelectionDisabled.append(isTextSelectionDisabled)
        messages.append(.displayIsTextSelectionDisabled(isTextSelectionDisabled: isTextSelectionDisabled))
    }
    public func display(placeholder: String?) {
        capturedDisplayPlaceholderPlaceholder.append(placeholder)
        messages.append(.displayPlaceholder(placeholder: placeholder))
    }
    public func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabledIsUserInteractionEnabled.append(isUserInteractionEnabled)
        messages.append(.displayIsUserInteractionEnabled(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isSecureTextEntry: Bool) {
        capturedDisplayIsSecureTextEntryIsSecureTextEntry.append(isSecureTextEntry)
        messages.append(.displayIsSecureTextEntry(isSecureTextEntry: isSecureTextEntry))
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        capturedDisplayLeadingViewOnPressLeadingViewOnPress.append(leadingViewOnPress)
        messages.append(.displayLeadingViewOnPress(leadingViewOnPress: leadingViewOnPress))
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        capturedDisplayTrailingViewOnPressTrailingViewOnPress.append(trailingViewOnPress)
        messages.append(.displayTrailingViewOnPress(trailingViewOnPress: trailingViewOnPress))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPressOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(onPaste: ((String?) -> Void)?) {
        capturedDisplayOnPasteOnPaste.append(onPaste)
        messages.append(.displayOnPaste(onPaste: onPaste))
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        capturedDisplayOnBecomeFirstResponderOnBecomeFirstResponder.append(onBecomeFirstResponder)
        messages.append(.displayOnBecomeFirstResponder(onBecomeFirstResponder: onBecomeFirstResponder))
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        capturedDisplayOnResignFirstResponderOnResignFirstResponder.append(onResignFirstResponder)
        messages.append(.displayOnResignFirstResponder(onResignFirstResponder: onResignFirstResponder))
    }
    public func display(onTapBackspace: (() -> Void)?) {
        capturedDisplayOnTapBackspaceOnTapBackspace.append(onTapBackspace)
        messages.append(.displayOnTapBackspace(onTapBackspace: onTapBackspace))
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        capturedDisplayDidChangeTextDidChangeText.append(didChangeText)
        messages.append(.displayDidChangeText(didChangeText: didChangeText))
    }
    public func display(trailingViewIsHidden: Bool) {
        capturedDisplayTrailingViewIsHiddenTrailingViewIsHidden.append(trailingViewIsHidden)
        messages.append(.displayTrailingViewIsHidden(trailingViewIsHidden: trailingViewIsHidden))
    }
    public func display(leadingViewIsHidden: Bool) {
        capturedDisplayLeadingViewIsHiddenLeadingViewIsHidden.append(leadingViewIsHidden)
        messages.append(.displayLeadingViewIsHidden(leadingViewIsHidden: leadingViewIsHidden))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }
    public func display(inputView: TextInputPresentableModel.InputView?) {
        capturedDisplayInputViewInputView.append(inputView)
        messages.append(.displayInputView(inputView: inputView))
    }
    public func display(inputType: KeyboardType) {
        capturedDisplayInputTypeInputType.append(inputType)
        messages.append(.displayInputType(inputType: inputType))
    }
    public func display(trailingSymbol: String?) {
        capturedDisplayTrailingSymbolTrailingSymbol.append(trailingSymbol)
        messages.append(.displayTrailingSymbol(trailingSymbol: trailingSymbol))
    }
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        capturedDisplayInputAccessoryViewInputAccessoryView.append(inputAccessoryView)
        messages.append(.displayInputAccessoryView(inputAccessoryView: inputAccessoryView))
    }
    public func display(isClearButtonActive: Bool) {
        capturedDisplayIsClearButtonActiveIsClearButtonActive.append(isClearButtonActive)
        messages.append(.displayIsClearButtonActive(isClearButtonActive: isClearButtonActive))
    }

    // MARK: - Properties
}
