//
//  SwiftUINavigationBarSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUINavigationBarSnapshotSUT: NSObject, HeaderOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: HeaderOutputSwiftUIAdapter

    init(
        swiftUIAdapter: HeaderOutputSwiftUIAdapter = HeaderOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: HeaderPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(style: HeaderPresentableModel.Style?) {
        swiftUIAdapter.display(style: style)
    }

    func display(centerView: HeaderPresentableModel.CenterView?) {
        swiftUIAdapter.display(centerView: centerView)
    }

    func display(leadingCard: CardViewPresentableModel?) {
        swiftUIAdapter.display(leadingCard: leadingCard)
    }

    func display(primeTrailingImage: ButtonPresentableModel?) {
        swiftUIAdapter.display(primeTrailingImage: primeTrailingImage)
    }

    func display(secondaryTrailingImage: ButtonPresentableModel?) {
        swiftUIAdapter.display(secondaryTrailingImage: secondaryTrailingImage)
    }

    func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        swiftUIAdapter.display(tertiaryTrailingImage: tertiaryTrailingImage)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredNavigationBarContainer(adapter: swiftUIAdapter)
            .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
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
