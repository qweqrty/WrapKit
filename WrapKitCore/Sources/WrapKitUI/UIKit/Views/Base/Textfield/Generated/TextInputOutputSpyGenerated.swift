// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

final class TextInputOutputSpy: TextInputOutput {
    enum Message: HashableWithReflection {
        case display(model: TextInputPresentableModel?)
        case display(text: String?)
        case startEditing()
        case stopEditing()
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

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [TextInputPresentableModel?] = []
    private(set) var capturedDisplayText: [String?] = []
    private(set) var capturedDisplayMask: [TextInputPresentableModel.Mask] = []
    private(set) var capturedDisplayIsValid: [Bool] = []
    private(set) var capturedDisplayIsEnabledForEditing: [Bool] = []
    private(set) var capturedDisplayIsTextSelectionDisabled: [Bool] = []
    private(set) var capturedDisplayPlaceholder: [String?] = []
    private(set) var capturedDisplayIsUserInteractionEnabled: [Bool] = []
    private(set) var capturedDisplayIsSecureTextEntry: [Bool] = []
    private(set) var capturedDisplayLeadingViewOnPress: [(() -> Void)?] = []
    private(set) var capturedDisplayTrailingViewOnPress: [(() -> Void)?] = []
    private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    private(set) var capturedDisplayOnPaste: [((String?) -> Void)?] = []
    private(set) var capturedDisplayOnBecomeFirstResponder: [(() -> Void)?] = []
    private(set) var capturedDisplayOnResignFirstResponder: [(() -> Void)?] = []
    private(set) var capturedDisplayOnTapBackspace: [(() -> Void)?] = []
    private(set) var capturedDisplayDidChangeText: [[((String?) -> Void)]] = []
    private(set) var capturedDisplayTrailingViewIsHidden: [Bool] = []
    private(set) var capturedDisplayLeadingViewIsHidden: [Bool] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []
    private(set) var capturedDisplayInputView: [TextInputPresentableModel.InputView?] = []
    private(set) var capturedDisplayInputType: [KeyboardType] = []
    private(set) var capturedDisplayTrailingSymbol: [String?] = []
    private(set) var capturedDisplayToolbarModel: [ButtonPresentableModel?] = []
    private(set) var capturedDisplayIsClearButtonActive: [Bool] = []
    private(set) var capturedMakeAccessoryViewAccessoryView: [UIView] = []
    private(set) var capturedMakeAccessoryViewHeight: [CGFloat] = []
    private(set) var capturedMakeAccessoryViewConstraints: [((UIView, UIView) -> [NSLayoutConstraint])?] = []


    // MARK: - TextInputOutput methods
    func display(model: TextInputPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(text: String?) {
        capturedDisplayText.append(text)
        messages.append(.display(text: text))
    }
    func startEditing() {
        messages.append(.startEditing())
    }
    func stopEditing() {
        messages.append(.stopEditing())
    }
    func display(mask: TextInputPresentableModel.Mask) {
        capturedDisplayMask.append(mask)
        messages.append(.display(mask: mask))
    }
    func display(isValid: Bool) {
        capturedDisplayIsValid.append(isValid)
        messages.append(.display(isValid: isValid))
    }
    func display(isEnabledForEditing: Bool) {
        capturedDisplayIsEnabledForEditing.append(isEnabledForEditing)
        messages.append(.display(isEnabledForEditing: isEnabledForEditing))
    }
    func display(isTextSelectionDisabled: Bool) {
        capturedDisplayIsTextSelectionDisabled.append(isTextSelectionDisabled)
        messages.append(.display(isTextSelectionDisabled: isTextSelectionDisabled))
    }
    func display(placeholder: String?) {
        capturedDisplayPlaceholder.append(placeholder)
        messages.append(.display(placeholder: placeholder))
    }
    func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabled.append(isUserInteractionEnabled)
        messages.append(.display(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    func display(isSecureTextEntry: Bool) {
        capturedDisplayIsSecureTextEntry.append(isSecureTextEntry)
        messages.append(.display(isSecureTextEntry: isSecureTextEntry))
    }
    func display(leadingViewOnPress: (() -> Void)?) {
        capturedDisplayLeadingViewOnPress.append(leadingViewOnPress)
        messages.append(.display(leadingViewOnPress: leadingViewOnPress))
    }
    func display(trailingViewOnPress: (() -> Void)?) {
        capturedDisplayTrailingViewOnPress.append(trailingViewOnPress)
        messages.append(.display(trailingViewOnPress: trailingViewOnPress))
    }
    func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    func display(onPaste: ((String?) -> Void)?) {
        capturedDisplayOnPaste.append(onPaste)
        messages.append(.display(onPaste: onPaste))
    }
    func display(onBecomeFirstResponder: (() -> Void)?) {
        capturedDisplayOnBecomeFirstResponder.append(onBecomeFirstResponder)
        messages.append(.display(onBecomeFirstResponder: onBecomeFirstResponder))
    }
    func display(onResignFirstResponder: (() -> Void)?) {
        capturedDisplayOnResignFirstResponder.append(onResignFirstResponder)
        messages.append(.display(onResignFirstResponder: onResignFirstResponder))
    }
    func display(onTapBackspace: (() -> Void)?) {
        capturedDisplayOnTapBackspace.append(onTapBackspace)
        messages.append(.display(onTapBackspace: onTapBackspace))
    }
    func display(didChangeText: [((String?) -> Void)]) {
        capturedDisplayDidChangeText.append(didChangeText)
        messages.append(.display(didChangeText: didChangeText))
    }
    func display(trailingViewIsHidden: Bool) {
        capturedDisplayTrailingViewIsHidden.append(trailingViewIsHidden)
        messages.append(.display(trailingViewIsHidden: trailingViewIsHidden))
    }
    func display(leadingViewIsHidden: Bool) {
        capturedDisplayLeadingViewIsHidden.append(leadingViewIsHidden)
        messages.append(.display(leadingViewIsHidden: leadingViewIsHidden))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }
    func display(inputView: TextInputPresentableModel.InputView?) {
        capturedDisplayInputView.append(inputView)
        messages.append(.display(inputView: inputView))
    }
    func display(inputType: KeyboardType) {
        capturedDisplayInputType.append(inputType)
        messages.append(.display(inputType: inputType))
    }
    func display(trailingSymbol: String?) {
        capturedDisplayTrailingSymbol.append(trailingSymbol)
        messages.append(.display(trailingSymbol: trailingSymbol))
    }
    func display(toolbarModel: ButtonPresentableModel?) {
        capturedDisplayToolbarModel.append(toolbarModel)
        messages.append(.display(toolbarModel: toolbarModel))
    }
    func display(isClearButtonActive: Bool) {
        capturedDisplayIsClearButtonActive.append(isClearButtonActive)
        messages.append(.display(isClearButtonActive: isClearButtonActive))
    }
    func makeAccessoryView(accessoryView: UIView, height: CGFloat = 60, constraints: ((UIView, UIView) -> [NSLayoutConstraint])? = nil) {
        capturedMakeAccessoryViewAccessoryView.append(accessoryView)
        capturedMakeAccessoryViewHeight.append(height)
        capturedMakeAccessoryViewConstraints.append(constraints)
        messages.append(.makeAccessoryView(accessoryView: accessoryView, height: height, constraints: constraints))
    }

    // MARK: - Properties
}
