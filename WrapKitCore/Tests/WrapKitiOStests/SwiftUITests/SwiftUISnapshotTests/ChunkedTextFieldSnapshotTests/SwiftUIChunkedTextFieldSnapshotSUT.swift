//
//  SwiftUIChunkedTextFieldSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUIChunkedTextFieldSnapshotSUT: TextInputOutput, SwiftUISnapshotSource {
    private static let swiftUISnapshotHeight: CGFloat = 52

    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        count: Int,
        appearance: TextfieldAppearance,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter()
    ) {
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

    func display(isValid: Bool) {
        swiftUIAdapter.display(isValid: isValid)
    }

    func display(isEnabledForEditing: Bool) {
        swiftUIAdapter.display(isEnabledForEditing: isEnabledForEditing)
    }

    func display(isTextSelectionDisabled: Bool) {
        swiftUIAdapter.display(isTextSelectionDisabled: isTextSelectionDisabled)
    }

    func display(placeholder: String?) {
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(isUserInteractionEnabled: Bool) {
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isSecureTextEntry: Bool) {
        swiftUIAdapter.display(isSecureTextEntry: isSecureTextEntry)
    }

    func display(leadingViewOnPress: (() -> Void)?) {
        swiftUIAdapter.display(leadingViewOnPress: leadingViewOnPress)
    }

    func display(trailingViewOnPress: (() -> Void)?) {
        swiftUIAdapter.display(trailingViewOnPress: trailingViewOnPress)
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

    func display(didChangeText: [((String?) -> Void)]) {
        swiftUIAdapter.display(didChangeText: didChangeText)
    }

    func display(trailingViewIsHidden: Bool) {
        swiftUIAdapter.display(trailingViewIsHidden: trailingViewIsHidden)
    }

    func display(leadingViewIsHidden: Bool) {
        swiftUIAdapter.display(leadingViewIsHidden: leadingViewIsHidden)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(inputView: TextInputPresentableModel.InputView?) {
        swiftUIAdapter.display(inputView: inputView)
    }

    func display(inputType: KeyboardType) {
        swiftUIAdapter.display(inputType: inputType)
    }

    func display(trailingSymbol: String?) {
        swiftUIAdapter.display(trailingSymbol: trailingSymbol)
    }

    func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        swiftUIAdapter.display(inputAccessoryView: inputAccessoryView)
    }

    func display(isClearButtonActive: Bool) {
        swiftUIAdapter.display(isClearButtonActive: isClearButtonActive)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredChunkedTextFieldContainer(
            content: swiftUIView,
            height: Self.swiftUISnapshotHeight
        )
            .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
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
