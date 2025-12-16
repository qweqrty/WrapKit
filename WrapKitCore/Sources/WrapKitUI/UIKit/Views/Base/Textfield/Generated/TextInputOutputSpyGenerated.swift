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
        case display(model: TextInputPresentableModel?)
        case display(text: String?)
        case startEditing
        case stopEditing
        case display(mask: TextInputPresentableModel.Mask)
        case display(isValid: Bool)
        case display(isEnabledForEditing: Bool)
        case display(isTextSelectionDisabled: Bool)
        case display(placeholder: String?)
        case display(isUserInteractionEnabled: Bool)
        case display(isSecureTextEntry: Bool)
        case display(leadingViewOnPress: (() -> Void)?)
        case display(trailingViewOnPress: (() -> Void)?)
        case display(onPress: (() -> Void)?)
        case display(onPaste: ((String?) -> Void)?)
        case display(onBecomeFirstResponder: (() -> Void)?)
        case display(onResignFirstResponder: (() -> Void)?)
        case display(onTapBackspace: (() -> Void)?)
        case display(didChangeText: [((String?) -> Void)])
        case display(trailingViewIsHidden: Bool)
        case display(leadingViewIsHidden: Bool)
        case display(isHidden: Bool)
        case display(inputView: TextInputPresentableModel.InputView?)
        case display(inputType: KeyboardType)
        case display(trailingSymbol: String?)
        case display(toolbarModel: ButtonPresentableModel?)
        case display(isClearButtonActive: Bool)
        case makeAccessoryView(accessoryView: UIView, height: CGFloat, constraints: ((UIView, UIView) -> [NSLayoutConstraint])?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [TextInputPresentableModel?] = []
    public private(set) var capturedDisplayText: [String?] = []
    public private(set) var capturedDisplayMask: [TextInputPresentableModel.Mask] = []
    public private(set) var capturedDisplayIsValid: [Bool] = []
    public private(set) var capturedDisplayIsEnabledForEditing: [Bool] = []
    public private(set) var capturedDisplayIsTextSelectionDisabled: [Bool] = []
    public private(set) var capturedDisplayPlaceholder: [String?] = []
    public private(set) var capturedDisplayIsUserInteractionEnabled: [Bool] = []
    public private(set) var capturedDisplayIsSecureTextEntry: [Bool] = []
    public private(set) var capturedDisplayLeadingViewOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayTrailingViewOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnPaste: [((String?) -> Void)?] = []
    public private(set) var capturedDisplayOnBecomeFirstResponder: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnResignFirstResponder: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnTapBackspace: [(() -> Void)?] = []
    public private(set) var capturedDisplayDidChangeText: [[((String?) -> Void)]] = []
    public private(set) var capturedDisplayTrailingViewIsHidden: [Bool] = []
    public private(set) var capturedDisplayLeadingViewIsHidden: [Bool] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []
    public private(set) var capturedDisplayInputView: [TextInputPresentableModel.InputView?] = []
    public private(set) var capturedDisplayInputType: [KeyboardType] = []
    public private(set) var capturedDisplayTrailingSymbol: [String?] = []
    public private(set) var capturedDisplayToolbarModel: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayIsClearButtonActive: [Bool] = []
    public private(set) var capturedMakeAccessoryViewAccessoryView: [UIView] = []
    public private(set) var capturedMakeAccessoryViewHeight: [CGFloat] = []
    public private(set) var capturedMakeAccessoryViewConstraints: [((UIView, UIView) -> [NSLayoutConstraint])?] = []


    // MARK: - TextInputOutput methods
    public func display(model: TextInputPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(text: String?) {
        capturedDisplayText.append(text)
        messages.append(.display(text: text))
    }
    public func startEditing() {
        messages.append(.startEditing)
    }
    public func stopEditing() {
        messages.append(.stopEditing)
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        capturedDisplayMask.append(mask)
        messages.append(.display(mask: mask))
    }
    public func display(isValid: Bool) {
        capturedDisplayIsValid.append(isValid)
        messages.append(.display(isValid: isValid))
    }
    public func display(isEnabledForEditing: Bool) {
        capturedDisplayIsEnabledForEditing.append(isEnabledForEditing)
        messages.append(.display(isEnabledForEditing: isEnabledForEditing))
    }
    public func display(isTextSelectionDisabled: Bool) {
        capturedDisplayIsTextSelectionDisabled.append(isTextSelectionDisabled)
        messages.append(.display(isTextSelectionDisabled: isTextSelectionDisabled))
    }
    public func display(placeholder: String?) {
        capturedDisplayPlaceholder.append(placeholder)
        messages.append(.display(placeholder: placeholder))
    }
    public func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabled.append(isUserInteractionEnabled)
        messages.append(.display(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isSecureTextEntry: Bool) {
        capturedDisplayIsSecureTextEntry.append(isSecureTextEntry)
        messages.append(.display(isSecureTextEntry: isSecureTextEntry))
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        capturedDisplayLeadingViewOnPress.append(leadingViewOnPress)
        messages.append(.display(leadingViewOnPress: leadingViewOnPress))
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        capturedDisplayTrailingViewOnPress.append(trailingViewOnPress)
        messages.append(.display(trailingViewOnPress: trailingViewOnPress))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    public func display(onPaste: ((String?) -> Void)?) {
        capturedDisplayOnPaste.append(onPaste)
        messages.append(.display(onPaste: onPaste))
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        capturedDisplayOnBecomeFirstResponder.append(onBecomeFirstResponder)
        messages.append(.display(onBecomeFirstResponder: onBecomeFirstResponder))
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        capturedDisplayOnResignFirstResponder.append(onResignFirstResponder)
        messages.append(.display(onResignFirstResponder: onResignFirstResponder))
    }
    public func display(onTapBackspace: (() -> Void)?) {
        capturedDisplayOnTapBackspace.append(onTapBackspace)
        messages.append(.display(onTapBackspace: onTapBackspace))
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        capturedDisplayDidChangeText.append(didChangeText)
        messages.append(.display(didChangeText: didChangeText))
    }
    public func display(trailingViewIsHidden: Bool) {
        capturedDisplayTrailingViewIsHidden.append(trailingViewIsHidden)
        messages.append(.display(trailingViewIsHidden: trailingViewIsHidden))
    }
    public func display(leadingViewIsHidden: Bool) {
        capturedDisplayLeadingViewIsHidden.append(leadingViewIsHidden)
        messages.append(.display(leadingViewIsHidden: leadingViewIsHidden))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }
    public func display(inputView: TextInputPresentableModel.InputView?) {
        capturedDisplayInputView.append(inputView)
        messages.append(.display(inputView: inputView))
    }
    public func display(inputType: KeyboardType) {
        capturedDisplayInputType.append(inputType)
        messages.append(.display(inputType: inputType))
    }
    public func display(trailingSymbol: String?) {
        capturedDisplayTrailingSymbol.append(trailingSymbol)
        messages.append(.display(trailingSymbol: trailingSymbol))
    }
    public func display(toolbarModel: ButtonPresentableModel?) {
        capturedDisplayToolbarModel.append(toolbarModel)
        messages.append(.display(toolbarModel: toolbarModel))
    }
    public func display(isClearButtonActive: Bool) {
        capturedDisplayIsClearButtonActive.append(isClearButtonActive)
        messages.append(.display(isClearButtonActive: isClearButtonActive))
    }
    public func makeAccessoryView(accessoryView: UIView, height: CGFloat = 60, constraints: ((UIView, UIView) -> [NSLayoutConstraint])? = nil) {
        capturedMakeAccessoryViewAccessoryView.append(accessoryView)
        capturedMakeAccessoryViewHeight.append(height)
        capturedMakeAccessoryViewConstraints.append(constraints)
        messages.append(.makeAccessoryView(accessoryView: accessoryView, height: height, constraints: constraints))
    }

    // MARK: - Properties
}
