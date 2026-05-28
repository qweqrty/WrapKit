import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedTextViewSnapshotSUT {
    let uiKitView: Textview
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter
    private let appearance: TextfieldAppearance

    init(
        appearance: TextfieldAppearance,
        uiKitView: Textview? = nil,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter()
    ) {
        self.appearance = appearance
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

    func display(onTapBackspace: (() -> Void)?) {
        uiKitView.display(onTapBackspace: onTapBackspace)
        swiftUIAdapter.display(onTapBackspace: onTapBackspace)
    }

    func updateAppearance(isValid: Bool) {
        uiKitView.updateAppearance(isValid: isValid)
    }

    func deleteBackward() {
        uiKitView.deleteBackward()
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {

        let rootView = SnapshotMirroredTextViewContainer(
            adapter: swiftUIAdapter,
            appearance: appearance
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
private struct SnapshotMirroredTextViewContainer: View {
    let adapter: TextInputOutputSwiftUIAdapter
    let appearance: TextfieldAppearance

    var body: some View {
        VStack(spacing: 0) {
            SUITextView(adapter: adapter, appearance: appearance)
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
