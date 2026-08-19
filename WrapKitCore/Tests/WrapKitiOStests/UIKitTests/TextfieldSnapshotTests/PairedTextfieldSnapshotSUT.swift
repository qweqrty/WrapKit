//
//  PairedTextfieldSnapshotSUT.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/5/26.
//


import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedTextfieldSnapshotSUT {
    let uiKitView: Textfield
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private let appearance: TextfieldAppearance
    private let leadingSwiftUIView: AnyView?
    private let trailingSwiftUIView: AnyView?

    init(
        appearance: TextfieldAppearance,
        uiKitView: Textfield,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter(),
        leadingSwiftUIView: AnyView? = nil,
        trailingSwiftUIView: AnyView? = nil
    ) {
        self.appearance = appearance
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
        self.leadingSwiftUIView = leadingSwiftUIView
        self.trailingSwiftUIView = trailingSwiftUIView
    }

    var onPress: (() -> Void)? { uiKitView.onPress }
    var onPaste: ((String?) -> Void)? { uiKitView.onPaste }
    var leadingViewOnPress: (() -> Void)? { uiKitView.leadingViewOnPress }
    var trailingViewOnPress: (() -> Void)? { uiKitView.trailingViewOnPress }

    func display(model: TextInputPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(text: String?) {
        uiKitView.display(text: text)
        swiftUIAdapter.display(text: text)
    }

    func display(placeholder: String?) {
        uiKitView.display(placeholder: placeholder)
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(isValid: Bool) {
        uiKitView.display(isValid: isValid)
        swiftUIAdapter.display(isValid: isValid)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
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

    func display(leadingViewIsHidden: Bool) {
        uiKitView.display(leadingViewIsHidden: leadingViewIsHidden)
        swiftUIAdapter.display(leadingViewIsHidden: leadingViewIsHidden)
    }

    func display(trailingViewIsHidden: Bool) {
        uiKitView.display(trailingViewIsHidden: trailingViewIsHidden)
        swiftUIAdapter.display(trailingViewIsHidden: trailingViewIsHidden)
    }

    func display(onPress: (() -> Void)?) {
        uiKitView.display(onPress: onPress)
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(onPaste: ((String?) -> Void)?) {
        uiKitView.display(onPaste: onPaste)
        swiftUIAdapter.display(onPaste: onPaste)
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

    func display(mask: TextInputPresentableModel.Mask) {
        uiKitView.display(mask: mask)
        swiftUIAdapter.display(mask: mask)
    }

    func simulateUserTyping(_ string: String) {
        uiKitView.simulateUserTyping(string)
        // SwiftUI текст синхронизируем через display(text:)
        swiftUIAdapter.display(text: uiKitView.text)
    }

    func deleteBackward() {
        uiKitView.deleteBackward()
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredTextfieldContainer(
            adapter: swiftUIAdapter,
            appearance: appearance,
            leadingView: leadingSwiftUIView,
            trailingView: trailingSwiftUIView
        )
        .environment(\.colorScheme, colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        hostingController.view.backgroundColor = .clear

        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredTextfieldContainer: View {
    let adapter: TextInputOutputSwiftUIAdapter
    let appearance: TextfieldAppearance
    let leadingView: AnyView?
    let trailingView: AnyView?

    var body: some View {
        VStack(spacing: 0) {
            SUITextField(
                adapter: adapter,
                appearance: appearance,
                leadingView: leadingView,
                trailingView: trailingView
            )
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.clear)
        .ignoresSafeArea(.all)
    }
}
#endif