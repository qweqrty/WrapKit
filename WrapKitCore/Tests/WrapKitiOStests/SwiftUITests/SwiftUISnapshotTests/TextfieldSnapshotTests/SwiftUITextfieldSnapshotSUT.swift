//
//  SwiftUITextfieldSnapshotSUT.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/5/26.
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUITextfieldSnapshotSUT: TextInputOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private let appearance: TextfieldAppearance
    private let leadingSwiftUIView: AnyView?
    private let trailingSwiftUIView: AnyView?

    init(
        appearance: TextfieldAppearance,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter(),
        leadingSwiftUIView: AnyView? = nil,
        trailingSwiftUIView: AnyView? = nil
    ) {
        self.appearance = appearance
        self.swiftUIAdapter = swiftUIAdapter
        self.leadingSwiftUIView = leadingSwiftUIView
        self.trailingSwiftUIView = trailingSwiftUIView
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

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
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

    func display(leadingViewIsHidden: Bool) {
        swiftUIAdapter.display(leadingViewIsHidden: leadingViewIsHidden)
    }

    func display(trailingViewIsHidden: Bool) {
        swiftUIAdapter.display(trailingViewIsHidden: trailingViewIsHidden)
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

    func display(leadingViewOnPress: (() -> Void)?) {
        swiftUIAdapter.display(leadingViewOnPress: leadingViewOnPress)
    }

    func display(trailingViewOnPress: (() -> Void)?) {
        swiftUIAdapter.display(trailingViewOnPress: trailingViewOnPress)
    }

    func display(mask: TextInputPresentableModel.Mask) {
        swiftUIAdapter.display(mask: mask)
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
        swiftUISnapshot(for: appearance, rendering: .automatic)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance, rendering: SnapshotRendering) -> UIImage {
        let rootView = SnapshotTextfieldContainer(
            content: AnyView(
                SUITextField(
                    adapter: swiftUIAdapter,
                    appearance: self.appearance,
                    leadingView: leadingSwiftUIView,
                    trailingView: trailingSwiftUIView
                )
            )
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(for: appearance.uiKitConfiguration, rendering: rendering)
    }
}

@available(iOS 17.0, *)
private struct SnapshotTextfieldContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content.frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
