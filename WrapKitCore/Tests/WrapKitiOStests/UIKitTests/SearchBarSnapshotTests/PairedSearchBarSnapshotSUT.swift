//
//  PairedSearchBarSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class PairedSearchBarSnapshotSUT {
    let uiKitView: SearchBar

    private let swiftUIAdapter: SearchBarOutputSwiftUIAdapter
    private let textFieldAppearance: TextfieldAppearance
    private let spacing: CGFloat

    init(
        textField: Textfield,
        textFieldAppearance: TextfieldAppearance,
        spacing: CGFloat = 8,
        swiftUIAdapter: SearchBarOutputSwiftUIAdapter = SearchBarOutputSwiftUIAdapter()
    ) {
        self.uiKitView = SearchBar(textfield: textField, spacing: spacing)
        self.textFieldAppearance = textFieldAppearance
        self.spacing = spacing
        self.swiftUIAdapter = swiftUIAdapter
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
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredSearchBarContainer(
            adapter: swiftUIAdapter,
            textFieldAppearance: textFieldAppearance,
            spacing: spacing
        )
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredSearchBarContainer: View {
    let adapter: SearchBarOutputSwiftUIAdapter
    let textFieldAppearance: TextfieldAppearance
    let spacing: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            SUISearchBar(
                adapter: adapter,
                textFieldAppearance: textFieldAppearance,
                spacing: spacing
            )
            .frame(maxWidth: .infinity, alignment: .top)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
