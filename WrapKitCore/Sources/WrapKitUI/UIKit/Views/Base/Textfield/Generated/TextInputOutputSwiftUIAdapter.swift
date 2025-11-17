// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
public class TextInputOutputSwiftUIAdapter: ObservableObject, TextInputOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: TextInputPresentableModel?
    }
    public func display(model: TextInputPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayTextState: DisplayTextState? = nil
    public struct DisplayTextState {
        public let text: String?
    }
    public func display(text: String?) {
        displayTextState = .init(
            text: text
        )
    }
    @Published public var startEditingState: StartEditingState? = nil
    public struct StartEditingState {
    }
    public func startEditing() {
        startEditingState = .init(
        )
    }
    @Published public var stopEditingState: StopEditingState? = nil
    public struct StopEditingState {
    }
    public func stopEditing() {
        stopEditingState = .init(
        )
    }
    @Published public var displayMaskState: DisplayMaskState? = nil
    public struct DisplayMaskState {
        public let mask: TextInputPresentableModel.Mask
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        displayMaskState = .init(
            mask: mask
        )
    }
    @Published public var displayIsValidState: DisplayIsValidState? = nil
    public struct DisplayIsValidState {
        public let isValid: Bool
    }
    public func display(isValid: Bool) {
        displayIsValidState = .init(
            isValid: isValid
        )
    }
    @Published public var displayIsEnabledForEditingState: DisplayIsEnabledForEditingState? = nil
    public struct DisplayIsEnabledForEditingState {
        public let isEnabledForEditing: Bool
    }
    public func display(isEnabledForEditing: Bool) {
        displayIsEnabledForEditingState = .init(
            isEnabledForEditing: isEnabledForEditing
        )
    }
    @Published public var displayIsTextSelectionDisabledState: DisplayIsTextSelectionDisabledState? = nil
    public struct DisplayIsTextSelectionDisabledState {
        public let isTextSelectionDisabled: Bool
    }
    public func display(isTextSelectionDisabled: Bool) {
        displayIsTextSelectionDisabledState = .init(
            isTextSelectionDisabled: isTextSelectionDisabled
        )
    }
    @Published public var displayPlaceholderState: DisplayPlaceholderState? = nil
    public struct DisplayPlaceholderState {
        public let placeholder: String?
    }
    public func display(placeholder: String?) {
        displayPlaceholderState = .init(
            placeholder: placeholder
        )
    }
    @Published public var displayIsUserInteractionEnabledState: DisplayIsUserInteractionEnabledState? = nil
    public struct DisplayIsUserInteractionEnabledState {
        public let isUserInteractionEnabled: Bool
    }
    public func display(isUserInteractionEnabled: Bool) {
        displayIsUserInteractionEnabledState = .init(
            isUserInteractionEnabled: isUserInteractionEnabled
        )
    }
    @Published public var displayIsSecureTextEntryState: DisplayIsSecureTextEntryState? = nil
    public struct DisplayIsSecureTextEntryState {
        public let isSecureTextEntry: Bool
    }
    public func display(isSecureTextEntry: Bool) {
        displayIsSecureTextEntryState = .init(
            isSecureTextEntry: isSecureTextEntry
        )
    }
    @Published public var displayLeadingViewOnPressState: DisplayLeadingViewOnPressState? = nil
    public struct DisplayLeadingViewOnPressState {
        public let leadingViewOnPress: (() -> Void)?
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        displayLeadingViewOnPressState = .init(
            leadingViewOnPress: leadingViewOnPress
        )
    }
    @Published public var displayTrailingViewOnPressState: DisplayTrailingViewOnPressState? = nil
    public struct DisplayTrailingViewOnPressState {
        public let trailingViewOnPress: (() -> Void)?
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        displayTrailingViewOnPressState = .init(
            trailingViewOnPress: trailingViewOnPress
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil
    public struct DisplayOnPressState {
        public let onPress: (() -> Void)?
    }
    public func display(onPress: (() -> Void)?) {
        displayOnPressState = .init(
            onPress: onPress
        )
    }
    @Published public var displayOnPasteState: DisplayOnPasteState? = nil
    public struct DisplayOnPasteState {
        public let onPaste: ((String?) -> Void)?
    }
    public func display(onPaste: ((String?) -> Void)?) {
        displayOnPasteState = .init(
            onPaste: onPaste
        )
    }
    @Published public var displayOnBecomeFirstResponderState: DisplayOnBecomeFirstResponderState? = nil
    public struct DisplayOnBecomeFirstResponderState {
        public let onBecomeFirstResponder: (() -> Void)?
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        displayOnBecomeFirstResponderState = .init(
            onBecomeFirstResponder: onBecomeFirstResponder
        )
    }
    @Published public var displayOnResignFirstResponderState: DisplayOnResignFirstResponderState? = nil
    public struct DisplayOnResignFirstResponderState {
        public let onResignFirstResponder: (() -> Void)?
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        displayOnResignFirstResponderState = .init(
            onResignFirstResponder: onResignFirstResponder
        )
    }
    @Published public var displayOnTapBackspaceState: DisplayOnTapBackspaceState? = nil
    public struct DisplayOnTapBackspaceState {
        public let onTapBackspace: (() -> Void)?
    }
    public func display(onTapBackspace: (() -> Void)?) {
        displayOnTapBackspaceState = .init(
            onTapBackspace: onTapBackspace
        )
    }
    @Published public var displayDidChangeTextState: DisplayDidChangeTextState? = nil
    public struct DisplayDidChangeTextState {
        public let didChangeText: [((String?) -> Void)]
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        displayDidChangeTextState = .init(
            didChangeText: didChangeText
        )
    }
    @Published public var displayTrailingViewIsHiddenState: DisplayTrailingViewIsHiddenState? = nil
    public struct DisplayTrailingViewIsHiddenState {
        public let trailingViewIsHidden: Bool
    }
    public func display(trailingViewIsHidden: Bool) {
        displayTrailingViewIsHiddenState = .init(
            trailingViewIsHidden: trailingViewIsHidden
        )
    }
    @Published public var displayLeadingViewIsHiddenState: DisplayLeadingViewIsHiddenState? = nil
    public struct DisplayLeadingViewIsHiddenState {
        public let leadingViewIsHidden: Bool
    }
    public func display(leadingViewIsHidden: Bool) {
        displayLeadingViewIsHiddenState = .init(
            leadingViewIsHidden: leadingViewIsHidden
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil
    public struct DisplayIsHiddenState {
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        displayIsHiddenState = .init(
            isHidden: isHidden
        )
    }
    @Published public var displayInputViewState: DisplayInputViewState? = nil
    public struct DisplayInputViewState {
        public let inputView: TextInputPresentableModel.InputView?
    }
    public func display(inputView: TextInputPresentableModel.InputView?) {
        displayInputViewState = .init(
            inputView: inputView
        )
    }
    @Published public var displayInputTypeState: DisplayInputTypeState? = nil
    public struct DisplayInputTypeState {
        public let inputType: KeyboardType
    }
    public func display(inputType: KeyboardType) {
        displayInputTypeState = .init(
            inputType: inputType
        )
    }
    @Published public var displayTrailingSymbolState: DisplayTrailingSymbolState? = nil
    public struct DisplayTrailingSymbolState {
        public let trailingSymbol: String?
    }
    public func display(trailingSymbol: String?) {
        displayTrailingSymbolState = .init(
            trailingSymbol: trailingSymbol
        )
    }
    @Published public var displayToolbarModelState: DisplayToolbarModelState? = nil
    public struct DisplayToolbarModelState {
        public let toolbarModel: ButtonPresentableModel?
    }
    public func display(toolbarModel: ButtonPresentableModel?) {
        displayToolbarModelState = .init(
            toolbarModel: toolbarModel
        )
    }
    @Published public var makeAccessoryViewAccessoryViewHeightConstraintsState: MakeAccessoryViewAccessoryViewHeightConstraintsState? = nil
    public struct MakeAccessoryViewAccessoryViewHeightConstraintsState {
        public let accessoryView: UIView
        public let height: CGFloat
        public let constraints: ((UIView, UIView) -> [NSLayoutConstraint])?
    }
    public func makeAccessoryView(accessoryView: UIView, height: CGFloat = 60, constraints: ((UIView, UIView) -> [NSLayoutConstraint])? = nil) {
        makeAccessoryViewAccessoryViewHeightConstraintsState = .init(
            accessoryView: accessoryView, 
            height: height, 
            constraints: constraints
        )
    }
}
