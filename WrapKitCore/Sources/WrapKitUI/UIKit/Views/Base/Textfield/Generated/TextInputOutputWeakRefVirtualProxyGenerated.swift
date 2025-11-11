// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension TextInputOutput {
    public var weakReferenced: any TextInputOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: TextInputOutput where T: TextInputOutput {

    public func display(model: TextInputPresentableModel?) {
        object?.display(model: model)
    }
    public func display(text: String?) {
        object?.display(text: text)
    }
    public func startEditing() {
        object?.startEditing()
    }
    public func stopEditing() {
        object?.stopEditing()
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        object?.display(mask: mask)
    }
    public func display(isValid: Bool) {
        object?.display(isValid: isValid)
    }
    public func display(isEnabledForEditing: Bool) {
        object?.display(isEnabledForEditing: isEnabledForEditing)
    }
    public func display(isTextSelectionDisabled: Bool) {
        object?.display(isTextSelectionDisabled: isTextSelectionDisabled)
    }
    public func display(placeholder: String?) {
        object?.display(placeholder: placeholder)
    }
    public func display(isUserInteractionEnabled: Bool) {
        object?.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }
    public func display(isSecureTextEntry: Bool) {
        object?.display(isSecureTextEntry: isSecureTextEntry)
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        object?.display(leadingViewOnPress: leadingViewOnPress)
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        object?.display(trailingViewOnPress: trailingViewOnPress)
    }
    public func display(onPress: (() -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(onPaste: ((String?) -> Void)?) {
        object?.display(onPaste: onPaste)
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        object?.display(onBecomeFirstResponder: onBecomeFirstResponder)
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        object?.display(onResignFirstResponder: onResignFirstResponder)
    }
    public func display(onTapBackspace: (() -> Void)?) {
        object?.display(onTapBackspace: onTapBackspace)
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        object?.display(didChangeText: didChangeText)
    }
    public func display(trailingViewIsHidden: Bool) {
        object?.display(trailingViewIsHidden: trailingViewIsHidden)
    }
    public func display(leadingViewIsHidden: Bool) {
        object?.display(leadingViewIsHidden: leadingViewIsHidden)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }
    public func display(inputView: TextInputPresentableModel.InputView?) {
        object?.display(inputView: inputView)
    }
    public func display(inputType: KeyboardType) {
        object?.display(inputType: inputType)
    }
    public func display(trailingSymbol: String?) {
        object?.display(trailingSymbol: trailingSymbol)
    }
    public func display(toolbarModel: ButtonPresentableModel?) {
        object?.display(toolbarModel: toolbarModel)
    }
    public func display(isClearButtonActive: Bool) {
        object?.display(isClearButtonActive: isClearButtonActive)
    }
    public func display(toolbarModel: ButtonPresentableModel?) {
        object?.display(toolbarModel: toolbarModel)
    }

}
#endif
