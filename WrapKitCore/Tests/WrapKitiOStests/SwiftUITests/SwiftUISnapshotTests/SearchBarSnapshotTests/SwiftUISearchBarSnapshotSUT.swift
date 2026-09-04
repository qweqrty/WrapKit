//
//  SwiftUISearchBarSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUISearchBarSnapshotSUT: SearchBarOutput, SwiftUISnapshotSource {
    let uiKitView: SearchBar

    private let uiKitContainer: UIView
    private let swiftUIAdapter: SearchBarOutputSwiftUIAdapter
    private let textFieldAppearance: TextfieldAppearance
    private let spacing: CGFloat
    private let contentInsets: WrapKit.EdgeInsets

    init(
        textField: Textfield,
        textFieldAppearance: TextfieldAppearance,
        uiKitContainer: UIView,
        spacing: CGFloat = 8,
        contentInsets: WrapKit.EdgeInsets = .zero,
        swiftUIAdapter: SearchBarOutputSwiftUIAdapter = SearchBarOutputSwiftUIAdapter()
    ) {
        self.uiKitView = withLiquidGlassDisabled {
            SearchBar(
                textfield: textField,
                spacing: spacing,
                contentInsets: contentInsets
            )
        }
        self.uiKitContainer = uiKitContainer
        self.swiftUIAdapter = swiftUIAdapter
        self.textFieldAppearance = textFieldAppearance
        self.spacing = spacing
        self.contentInsets = contentInsets
    }

    func display(model: SearchBarPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(textField: TextInputPresentableModel?) {
        uiKitView.display(textField: textField)
        swiftUIAdapter.display(textField: textField)
    }

    func display(leftView: ButtonPresentableModel?) {
        uiKitView.display(leftView: leftView)
        swiftUIAdapter.display(leftView: leftView)
    }

    func display(rightView: ButtonPresentableModel?) {
        uiKitView.display(rightView: rightView)
        swiftUIAdapter.display(rightView: rightView)
    }

    func display(placeholder: String?) {
        uiKitView.display(placeholder: placeholder)
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(backgroundColor: WrapKit.Color?) {
        uiKitView.display(backgroundColor: backgroundColor)
        swiftUIAdapter.display(backgroundColor: backgroundColor)
    }

    func display(spacing: CGFloat) {
        uiKitView.display(spacing: spacing)
        swiftUIAdapter.display(spacing: spacing)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        withLiquidGlassDisabled {
            let rootView = SnapshotMirroredSearchBarContainer(
                adapter: swiftUIAdapter,
                textFieldAppearance: textFieldAppearance,
                spacing: spacing,
                contentInsets: contentInsets
            )
            .environment(\.colorScheme, appearance.colorScheme)
            .ignoresSafeArea(.all)

            let hostingController = UIHostingController(rootView: rootView)
            hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
            hostingController.view.backgroundColor = .clear

            let warmup: TimeInterval = 0.3
            RunLoop.main.run(until: Date().addingTimeInterval(warmup))
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(warmup))

            return hostingController.snapshot(for: appearance.uiKitConfiguration)
        }
    }
}

private func withLiquidGlassDisabled<T>(_ operation: () -> T) -> T {
    let wasLiquidGlassEnabled = isLiquidGlassEnabled
    isLiquidGlassEnabled = false
    defer { isLiquidGlassEnabled = wasLiquidGlassEnabled }
    return operation()
}

@available(iOS 17.0, *)
private struct SnapshotMirroredSearchBarContainer: View {
    let adapter: SearchBarOutputSwiftUIAdapter
    let textFieldAppearance: TextfieldAppearance
    let spacing: CGFloat
    let contentInsets: WrapKit.EdgeInsets

    var body: some View {
        VStack(spacing: 0) {
            SUISearchBar(
                adapter: adapter,
                textFieldAppearance: textFieldAppearance,
                spacing: spacing,
                contentInsets: contentInsets
            )
            .frame(maxWidth: .infinity, alignment: .top)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
