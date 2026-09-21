//
//  SwiftUISearchBarSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
@testable import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUISearchBarSnapshotSUT: SearchBarOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: SearchBarOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        textFieldAppearance: TextfieldAppearance,
        spacing: CGFloat = 8,
        contentInsets: WrapKit.EdgeInsets = .zero,
        swiftUIAdapter: SearchBarOutputSwiftUIAdapter = SearchBarOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter
        self.swiftUIView = AnyView(
            SUISearchBar(
                adapter: swiftUIAdapter,
                textFieldAppearance: textFieldAppearance,
                spacing: spacing,
                contentInsets: contentInsets
            )
        )
    }

    func display(model: SearchBarPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(textField: TextInputPresentableModel?) {
        swiftUIAdapter.display(textField: textField)
    }

    func display(leftView: ButtonPresentableModel?) {
        swiftUIAdapter.display(leftView: leftView)
    }

    func display(rightView: ButtonPresentableModel?) {
        swiftUIAdapter.display(rightView: rightView)
    }

    func display(placeholder: String?) {
        swiftUIAdapter.display(placeholder: placeholder)
    }

    func display(backgroundColor: WrapKit.Color?) {
        swiftUIAdapter.display(backgroundColor: backgroundColor)
    }

    func display(spacing: CGFloat) {
        swiftUIAdapter.display(spacing: spacing)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotSearchBarContainer(
            content: swiftUIView
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
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

@available(iOS 17.0, *)
private struct SnapshotSearchBarContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, alignment: .top)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300, alignment: .top)
        .background(SwiftUIColor(UIColor.systemBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
#endif
