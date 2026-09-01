//
//  PairedNavigationBarSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class PairedNavigationBarSnapshotSUT: NSObject, HeaderOutput, PairedSnapshotSource {
    let uiKitView: NavigationBar

    private let uiKitContainer: UIView
    private let swiftUIAdapter: HeaderOutputSwiftUIAdapter

    init(
        uiKitContainer: UIView,
        uiKitView: NavigationBar = NavigationBar(),
        swiftUIAdapter: HeaderOutputSwiftUIAdapter = HeaderOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: HeaderPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(style: HeaderPresentableModel.Style?) {
        uiKitView.display(style: style)
        swiftUIAdapter.display(style: style)
    }

    func display(centerView: HeaderPresentableModel.CenterView?) {
        uiKitView.display(centerView: centerView)
        swiftUIAdapter.display(centerView: centerView)
    }

    func display(leadingCard: CardViewPresentableModel?) {
        uiKitView.display(leadingCard: leadingCard)
        swiftUIAdapter.display(leadingCard: leadingCard)
    }

    func display(primeTrailingImage: ButtonPresentableModel?) {
        uiKitView.display(primeTrailingImage: primeTrailingImage)
        swiftUIAdapter.display(primeTrailingImage: primeTrailingImage)
    }

    func display(secondaryTrailingImage: ButtonPresentableModel?) {
        uiKitView.display(secondaryTrailingImage: secondaryTrailingImage)
        swiftUIAdapter.display(secondaryTrailingImage: secondaryTrailingImage)
    }

    func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        uiKitView.display(tertiaryTrailingImage: tertiaryTrailingImage)
        swiftUIAdapter.display(tertiaryTrailingImage: tertiaryTrailingImage)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        uiKitContainer.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredNavigationBarContainer(adapter: swiftUIAdapter)
            .environment(\.colorScheme, appearance.colorScheme)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredNavigationBarContainer: View {
    @ObservedObject var adapter: HeaderOutputSwiftUIAdapter

    var body: some View {
        VStack(spacing: 0) {
            SUINavigationBar(adapter: adapter)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(headerBackground.ignoresSafeArea(edges: .top))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }

    private var headerBackground: SwiftUIColor {
        let color = adapter.displayStyleState?.style?.backgroundColor
            ?? adapter.displayModelState?.model.style?.backgroundColor
            ?? .clear
        return SwiftUIColor(color)
    }
}
#endif
