//
//  PairedChunkedTextFieldSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class PairedChunkedTextFieldSnapshotSUT: TextInputOutput, PairedSnapshotSource {
    let uiKitView: ChunkedTextField

    private let uiKitContainer: UIView
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        count: Int,
        appearance: TextfieldAppearance,
        uiKitView: ChunkedTextField? = nil,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter()
    ) {
        let resolvedUIKitView = uiKitView ?? ChunkedTextField(
            count: count,
            appearance: appearance
        )
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        container.addSubview(resolvedUIKitView)
        resolvedUIKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )
        container.layoutIfNeeded()

        self.uiKitView = resolvedUIKitView
        self.uiKitContainer = container
        self.swiftUIView = AnyView(
            SUIChunkedTextField(
                adapter: swiftUIAdapter,
                count: count,
                appearance: appearance
            )
        )
        self.swiftUIAdapter = swiftUIAdapter
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

    func display(placeholder: String?) {
        uiKitView.display(placeholder: placeholder)
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(isUserInteractionEnabled: Bool) {
        uiKitView.display(isUserInteractionEnabled: isUserInteractionEnabled)
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isSecureTextEntry: Bool) {
        uiKitView.display(isSecureTextEntry: isSecureTextEntry)
        swiftUIAdapter.display(isSecureTextEntry: isSecureTextEntry)
    }

    func display(leadingViewOnPress: (() -> Void)?) {
        uiKitView.display(leadingViewOnPress: leadingViewOnPress)
        swiftUIAdapter.display(leadingViewOnPress: leadingViewOnPress)
    }

    func display(trailingViewOnPress: (() -> Void)?) {
        uiKitView.display(trailingViewOnPress: trailingViewOnPress)
        swiftUIAdapter.display(trailingViewOnPress: trailingViewOnPress)
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

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(inputView: TextInputPresentableModel.InputView?) {
        uiKitView.display(inputView: inputView)
        swiftUIAdapter.display(inputView: inputView)
    }

    func display(inputType: KeyboardType) {
        uiKitView.display(inputType: inputType)
        swiftUIAdapter.display(inputType: inputType)
    }

    func display(trailingSymbol: String?) {
        uiKitView.display(trailingSymbol: trailingSymbol)
        swiftUIAdapter.display(trailingSymbol: trailingSymbol)
    }

    func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        uiKitView.display(inputAccessoryView: inputAccessoryView)
        swiftUIAdapter.display(inputAccessoryView: inputAccessoryView)
    }

    func display(isClearButtonActive: Bool) {
        uiKitView.display(isClearButtonActive: isClearButtonActive)
        swiftUIAdapter.display(isClearButtonActive: isClearButtonActive)
    }

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        uiKitContainer.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredChunkedTextFieldContainer(
            content: swiftUIView,
            height: max(uiKitView.bounds.height, 52)
        )
            .environment(\.colorScheme, appearance.colorScheme)
            .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))

        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredChunkedTextFieldContainer: View {
    let content: AnyView
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(
                    maxWidth: .infinity,
                    minHeight: height,
                    maxHeight: height,
                    alignment: .top
                )
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
