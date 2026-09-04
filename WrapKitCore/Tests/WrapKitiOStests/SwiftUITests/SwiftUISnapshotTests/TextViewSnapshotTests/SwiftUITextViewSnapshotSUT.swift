import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUITextViewSnapshotSUT: TextInputOutput, SwiftUISnapshotSource {
    let uiKitView: Textview
    private let uiKitContainer: UIView
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private var appearance: TextfieldAppearance

    init(
        appearance: TextfieldAppearance,
        uiKitContainer: UIView,
        uiKitView: Textview? = nil,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter()
    ) {
        self.appearance = appearance
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView ?? Textview(appearance: appearance)
        self.swiftUIAdapter = swiftUIAdapter
    }

    var onPress: (() -> Void)? {
        get { uiKitView.onPress }
    }

    var onPaste: ((String?) -> Void)? {
        get { uiKitView.onPaste }
    }

    var onTapBackspace: (() -> Void)? {
        get { uiKitView.onTapBackspace }
    }

    var placeholderLabel: UILabel {
        uiKitView.placeholderLabel
    }

    func setDeselectedBackgroundColor(_ color: WrapKit.Color) {
        uiKitView.appearance.colors.deselectedBackgroundColor = color
        appearance.colors.deselectedBackgroundColor = color
    }

    func display(model: TextInputPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(text: String?) {
        uiKitView.display(text: text)
        swiftUIAdapter.display(text: text)
    }

    func startEditing() {
        uiKitView.startEditing()
        swiftUIAdapter.startEditing()
    }

    func stopEditing() {
        uiKitView.stopEditing()
        swiftUIAdapter.stopEditing()
    }

    func display(mask: TextInputPresentableModel.Mask) {
        uiKitView.display(mask: mask)
        swiftUIAdapter.display(mask: mask)
    }

    func display(placeholder: String?) {
        uiKitView.display(placeholder: placeholder)
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(isValid: Bool) {
        uiKitView.display(isValid: isValid)
        swiftUIAdapter.display(isValid: isValid)
    }

    func display(isEnabledForEditing: Bool) {
        uiKitView.display(isEnabledForEditing: isEnabledForEditing)
        swiftUIAdapter.display(isEnabledForEditing: isEnabledForEditing)
    }

    func display(isTextSelectionDisabled: Bool) {
        uiKitView.display(isTextSelectionDisabled: isTextSelectionDisabled)
        swiftUIAdapter.display(isTextSelectionDisabled: isTextSelectionDisabled)
    }

    func display(isUserInteractionEnabled: Bool) {
        uiKitView.display(isUserInteractionEnabled: isUserInteractionEnabled)
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isSecureTextEntry: Bool) {
        uiKitView.display(isSecureTextEntry: isSecureTextEntry)
        swiftUIAdapter.display(isSecureTextEntry: isSecureTextEntry)
    }

    func display(isClearButtonActive: Bool) {
        uiKitView.display(isClearButtonActive: isClearButtonActive)
        swiftUIAdapter.display(isClearButtonActive: isClearButtonActive)
    }

    func display(trailingSymbol: String?) {
        uiKitView.display(trailingSymbol: trailingSymbol)
        swiftUIAdapter.display(trailingSymbol: trailingSymbol)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(onPress: (() -> Void)?) {
        uiKitView.display(onPress: onPress)
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(onPaste: ((String?) -> Void)?) {
        uiKitView.display(onPaste: onPaste)
        swiftUIAdapter.display(onPaste: onPaste)
    }

    func display(onBecomeFirstResponder: (() -> Void)?) {
        uiKitView.display(onBecomeFirstResponder: onBecomeFirstResponder)
        swiftUIAdapter.display(onBecomeFirstResponder: onBecomeFirstResponder)
    }

    func display(onResignFirstResponder: (() -> Void)?) {
        uiKitView.display(onResignFirstResponder: onResignFirstResponder)
        swiftUIAdapter.display(onResignFirstResponder: onResignFirstResponder)
    }

    func display(onTapBackspace: (() -> Void)?) {
        uiKitView.display(onTapBackspace: onTapBackspace)
        swiftUIAdapter.display(onTapBackspace: onTapBackspace)
    }

    func display(leadingViewOnPress: (() -> Void)?) {
        uiKitView.display(leadingViewOnPress: leadingViewOnPress)
        swiftUIAdapter.display(leadingViewOnPress: leadingViewOnPress)
    }

    func display(trailingViewOnPress: (() -> Void)?) {
        uiKitView.display(trailingViewOnPress: trailingViewOnPress)
        swiftUIAdapter.display(trailingViewOnPress: trailingViewOnPress)
    }

    func display(didChangeText: [((String?) -> Void)]) {
        uiKitView.display(didChangeText: didChangeText)
        swiftUIAdapter.display(didChangeText: didChangeText)
    }

    func display(trailingViewIsHidden: Bool) {
        uiKitView.display(trailingViewIsHidden: trailingViewIsHidden)
        swiftUIAdapter.display(trailingViewIsHidden: trailingViewIsHidden)
    }

    func display(leadingViewIsHidden: Bool) {
        uiKitView.display(leadingViewIsHidden: leadingViewIsHidden)
        swiftUIAdapter.display(leadingViewIsHidden: leadingViewIsHidden)
    }

    func display(inputView: TextInputPresentableModel.InputView?) {
        uiKitView.display(inputView: inputView)
        swiftUIAdapter.display(inputView: inputView)
    }

    func display(inputType: KeyboardType) {
        uiKitView.display(inputType: inputType)
        swiftUIAdapter.display(inputType: inputType)
    }

    func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        uiKitView.display(inputAccessoryView: inputAccessoryView)
        swiftUIAdapter.display(inputAccessoryView: inputAccessoryView)
    }

    func deleteBackward() {
        uiKitView.deleteBackward()
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {

        let rootView = SnapshotMirroredTextViewContainer(
            content: AnyView(
                SUITextView(
                    adapter: swiftUIAdapter,
                    appearance: self.appearance
                )
            )
        )
        .environment(\.colorScheme, appearance.colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear
        if #unavailable(iOS 26.0) {
            let safeAreaInsets = appearance.uiKitConfiguration.safeAreaInsets
            hostingController.additionalSafeAreaInsets = UIEdgeInsets(
                top: -safeAreaInsets.top,
                left: -safeAreaInsets.left,
                bottom: -safeAreaInsets.bottom,
                right: -safeAreaInsets.right
            )
        }

        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredTextViewContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity)
                .frame(height: 300)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
