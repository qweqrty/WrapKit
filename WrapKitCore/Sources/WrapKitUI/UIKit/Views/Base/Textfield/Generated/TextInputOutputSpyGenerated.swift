// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

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
    public private(set) var capturedDisplayModel: [(TextInputPresentableModel?)] = []
    public private(set) var capturedDisplayText: [(String?)] = []
    public private(set) var capturedStartEditing: [Void] = []
    public private(set) var capturedStopEditing: [Void] = []
    public private(set) var capturedDisplayMask: [(TextInputPresentableModel.Mask)] = []
    public private(set) var capturedDisplayIsValid: [(Bool)] = []
    public private(set) var capturedDisplayIsEnabledForEditing: [(Bool)] = []
    public private(set) var capturedDisplayIsTextSelectionDisabled: [(Bool)] = []
    public private(set) var capturedDisplayPlaceholder: [(String?)] = []
    public private(set) var capturedDisplayIsUserInteractionEnabled: [(Bool)] = []
    public private(set) var capturedDisplayIsSecureTextEntry: [(Bool)] = []
    public private(set) var capturedDisplayLeadingViewOnPress: [((() -> Void)?)] = []
    public private(set) var capturedDisplayTrailingViewOnPress: [((() -> Void)?)] = []
    public private(set) var capturedDisplayOnPress: [((() -> Void)?)] = []
    public private(set) var capturedDisplayOnPaste: [(((String?) -> Void)?)] = []
    public private(set) var capturedDisplayOnBecomeFirstResponder: [((() -> Void)?)] = []
    public private(set) var capturedDisplayOnResignFirstResponder: [((() -> Void)?)] = []
    public private(set) var capturedDisplayOnTapBackspace: [((() -> Void)?)] = []
    public private(set) var capturedDisplayDidChangeText: [([((String?) -> Void)])] = []
    public private(set) var capturedDisplayTrailingViewIsHidden: [(Bool)] = []
    public private(set) var capturedDisplayLeadingViewIsHidden: [(Bool)] = []
    public private(set) var capturedDisplayIsHidden: [(Bool)] = []
    public private(set) var capturedDisplayInputView: [(TextInputPresentableModel.InputView?)] = []
    public private(set) var capturedDisplayInputType: [(KeyboardType)] = []
    public private(set) var capturedDisplayTrailingSymbol: [(String?)] = []
    public private(set) var capturedDisplayInputAccessoryView: [(TextInputPresentableModel.AccessoryViewPresentableModel?)] = []
    public private(set) var capturedDisplayIsClearButtonActive: [(Bool)] = []

    // MARK: - TextInputOutput methods
    public func display(model: TextInputPresentableModel?) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(text: String?) {
        capturedDisplayText.append((text))
        messages.append(.displayText(text: text))
    }
    public func startEditing() {
        capturedStartEditing.append(())
        messages.append(.startEditing)
    }
    public func stopEditing() {
        capturedStopEditing.append(())
        messages.append(.stopEditing)
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        capturedDisplayMask.append((mask))
        messages.append(.displayMask(mask: mask))
    }
    public func display(isValid: Bool) {
        capturedDisplayIsValid.append((isValid))
        messages.append(.displayIsValid(isValid: isValid))
    }
    public func display(isEnabledForEditing: Bool) {
        capturedDisplayIsEnabledForEditing.append((isEnabledForEditing))
        messages.append(.displayIsEnabledForEditing(isEnabledForEditing: isEnabledForEditing))
    }
    public func display(isTextSelectionDisabled: Bool) {
        capturedDisplayIsTextSelectionDisabled.append((isTextSelectionDisabled))
        messages.append(.displayIsTextSelectionDisabled(isTextSelectionDisabled: isTextSelectionDisabled))
    }
    public func display(placeholder: String?) {
        capturedDisplayPlaceholder.append((placeholder))
        messages.append(.displayPlaceholder(placeholder: placeholder))
    }
    public func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabled.append((isUserInteractionEnabled))
        messages.append(.displayIsUserInteractionEnabled(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isSecureTextEntry: Bool) {
        capturedDisplayIsSecureTextEntry.append((isSecureTextEntry))
        messages.append(.displayIsSecureTextEntry(isSecureTextEntry: isSecureTextEntry))
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        capturedDisplayLeadingViewOnPress.append((leadingViewOnPress))
        messages.append(.displayLeadingViewOnPress(leadingViewOnPress: leadingViewOnPress))
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        capturedDisplayTrailingViewOnPress.append((trailingViewOnPress))
        messages.append(.displayTrailingViewOnPress(trailingViewOnPress: trailingViewOnPress))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append((onPress))
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(onPaste: ((String?) -> Void)?) {
        capturedDisplayOnPaste.append((onPaste))
        messages.append(.displayOnPaste(onPaste: onPaste))
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        capturedDisplayOnBecomeFirstResponder.append((onBecomeFirstResponder))
        messages.append(.displayOnBecomeFirstResponder(onBecomeFirstResponder: onBecomeFirstResponder))
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        capturedDisplayOnResignFirstResponder.append((onResignFirstResponder))
        messages.append(.displayOnResignFirstResponder(onResignFirstResponder: onResignFirstResponder))
    }
    public func display(onTapBackspace: (() -> Void)?) {
        capturedDisplayOnTapBackspace.append((onTapBackspace))
        messages.append(.displayOnTapBackspace(onTapBackspace: onTapBackspace))
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        capturedDisplayDidChangeText.append((didChangeText))
        messages.append(.displayDidChangeText(didChangeText: didChangeText))
    }
    public func display(trailingViewIsHidden: Bool) {
        capturedDisplayTrailingViewIsHidden.append((trailingViewIsHidden))
        messages.append(.displayTrailingViewIsHidden(trailingViewIsHidden: trailingViewIsHidden))
    }
    public func display(leadingViewIsHidden: Bool) {
        capturedDisplayLeadingViewIsHidden.append((leadingViewIsHidden))
        messages.append(.displayLeadingViewIsHidden(leadingViewIsHidden: leadingViewIsHidden))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append((isHidden))
        messages.append(.displayIsHidden(isHidden: isHidden))
    }
    public func display(inputView: TextInputPresentableModel.InputView?) {
        capturedDisplayInputView.append((inputView))
        messages.append(.displayInputView(inputView: inputView))
    }
    public func display(inputType: KeyboardType) {
        capturedDisplayInputType.append((inputType))
        messages.append(.displayInputType(inputType: inputType))
    }
    public func display(trailingSymbol: String?) {
        capturedDisplayTrailingSymbol.append((trailingSymbol))
        messages.append(.displayTrailingSymbol(trailingSymbol: trailingSymbol))
    }
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        capturedDisplayInputAccessoryView.append((inputAccessoryView))
        messages.append(.displayInputAccessoryView(inputAccessoryView: inputAccessoryView))
    }
    public func display(isClearButtonActive: Bool) {
        capturedDisplayIsClearButtonActive.append((isClearButtonActive))
        messages.append(.displayIsClearButtonActive(isClearButtonActive: isClearButtonActive))
    }

    // MARK: - Properties
}
