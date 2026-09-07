import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUITextViewSnapshotSUT: TextInputOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private let appearance: TextfieldAppearance

    init(
        appearance: TextfieldAppearance,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter()
    ) {
        self.appearance = appearance
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: TextInputPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(text: String?) {
        swiftUIAdapter.display(text: text)
    }

    func startEditing() {
        swiftUIAdapter.startEditing()
    }

    func stopEditing() {
        swiftUIAdapter.stopEditing()
    }

    func display(mask: TextInputPresentableModel.Mask) {
        swiftUIAdapter.display(mask: mask)
    }

    func display(placeholder: String?) {
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(isValid: Bool) {
        swiftUIAdapter.display(isValid: isValid)
    }

    func display(isEnabledForEditing: Bool) {
        swiftUIAdapter.display(isEnabledForEditing: isEnabledForEditing)
    }

    func display(isTextSelectionDisabled: Bool) {
        swiftUIAdapter.display(isTextSelectionDisabled: isTextSelectionDisabled)
    }

    func display(isUserInteractionEnabled: Bool) {
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isSecureTextEntry: Bool) {
        swiftUIAdapter.display(isSecureTextEntry: isSecureTextEntry)
    }

    func display(isClearButtonActive: Bool) {
        swiftUIAdapter.display(isClearButtonActive: isClearButtonActive)
    }

    func display(trailingSymbol: String?) {
        swiftUIAdapter.display(trailingSymbol: trailingSymbol)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(onPress: (() -> Void)?) {
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(onPaste: ((String?) -> Void)?) {
        swiftUIAdapter.display(onPaste: onPaste)
    }

    func display(onBecomeFirstResponder: (() -> Void)?) {
        swiftUIAdapter.display(onBecomeFirstResponder: onBecomeFirstResponder)
    }

    func display(onResignFirstResponder: (() -> Void)?) {
        swiftUIAdapter.display(onResignFirstResponder: onResignFirstResponder)
    }

    func display(onTapBackspace: (() -> Void)?) {
        swiftUIAdapter.display(onTapBackspace: onTapBackspace)
    }

    func display(leadingViewOnPress: (() -> Void)?) {
        swiftUIAdapter.display(leadingViewOnPress: leadingViewOnPress)
    }

    func display(trailingViewOnPress: (() -> Void)?) {
        swiftUIAdapter.display(trailingViewOnPress: trailingViewOnPress)
    }

    func display(didChangeText: [((String?) -> Void)]) {
        swiftUIAdapter.display(didChangeText: didChangeText)
    }

    func display(trailingViewIsHidden: Bool) {
        swiftUIAdapter.display(trailingViewIsHidden: trailingViewIsHidden)
    }

    func display(leadingViewIsHidden: Bool) {
        swiftUIAdapter.display(leadingViewIsHidden: leadingViewIsHidden)
    }

    func display(inputView: TextInputPresentableModel.InputView?) {
        swiftUIAdapter.display(inputView: inputView)
    }

    func display(inputType: KeyboardType) {
        swiftUIAdapter.display(inputType: inputType)
    }

    func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        swiftUIAdapter.display(inputAccessoryView: inputAccessoryView)
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
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))

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
