// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension TextInputOutput {
    public var mainQueueDispatched: any TextInputOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension TextInputOutput {
    public var weakReferenced: any TextInputOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: TextInputOutput where T: TextInputOutput {

    public func display(model: TextInputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(text: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(text: text)
        }
    }
    public func startEditing() {
        dispatch { [weak self] in
            self?.decoratee.startEditing()
        }
    }
    public func stopEditing() {
        dispatch { [weak self] in
            self?.decoratee.stopEditing()
        }
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        dispatch { [weak self] in
            self?.decoratee.display(mask: mask)
        }
    }
    public func display(isValid: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isValid: isValid)
        }
    }
    public func display(isEnabledForEditing: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isEnabledForEditing: isEnabledForEditing)
        }
    }
    public func display(isTextSelectionDisabled: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isTextSelectionDisabled: isTextSelectionDisabled)
        }
    }
    public func display(placeholder: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(placeholder: placeholder)
        }
    }
    public func display(isUserInteractionEnabled: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isUserInteractionEnabled: isUserInteractionEnabled)
        }
    }
    public func display(isSecureTextEntry: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isSecureTextEntry: isSecureTextEntry)
        }
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(leadingViewOnPress: leadingViewOnPress)
        }
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(trailingViewOnPress: trailingViewOnPress)
        }
    }
    public func display(onPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onPress: onPress)
        }
    }
    public func display(onPaste: ((String?) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onPaste: onPaste)
        }
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onBecomeFirstResponder: onBecomeFirstResponder)
        }
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onResignFirstResponder: onResignFirstResponder)
        }
    }
    public func display(onTapBackspace: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onTapBackspace: onTapBackspace)
        }
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        dispatch { [weak self] in
            self?.decoratee.display(didChangeText: didChangeText)
        }
    }
    public func display(trailingViewIsHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(trailingViewIsHidden: trailingViewIsHidden)
        }
    }
    public func display(leadingViewIsHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(leadingViewIsHidden: leadingViewIsHidden)
        }
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

}

#endif
