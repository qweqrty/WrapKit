//
//  SwiftUIEmptyViewSnapshotSUT.swift
//  WrapKit
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUIEmptyViewSnapshotSUT: EmptyViewOutput, SwiftUISnapshotSource {
    let uiKitView: WrapKit.EmptyView

    private let uiKitContainer: UIView
    private let swiftUIAdapter: EmptyViewOutputSwiftUIAdapter
    private var swiftUIBackgroundColor: UIColor = .clear
    private var swiftUIIsHidden = false

    init(
        uiKitContainer: UIView,
        uiKitView: WrapKit.EmptyView = EmptyView(),
        swiftUIAdapter: EmptyViewOutputSwiftUIAdapter = EmptyViewOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(title: TextOutputPresentableModel?) {
        uiKitView.display(title: title)
        swiftUIAdapter.display(title: title)
    }

    func display(subtitle: TextOutputPresentableModel?) {
        uiKitView.display(subtitle: subtitle)
        swiftUIAdapter.display(subtitle: subtitle)
    }

    func display(buttonModel: ButtonPresentableModel?) {
        uiKitView.display(buttonModel: buttonModel)
        swiftUIAdapter.display(buttonModel: buttonModel)
    }

    func display(image: ImageViewPresentableModel?) {
        uiKitView.display(image: image)
        swiftUIAdapter.display(image: image)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
        swiftUIIsHidden = isHidden
    }

    func display(model: EmptyViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(backgroundColor: UIColor) {
        uiKitView.backgroundColor = backgroundColor
        swiftUIBackgroundColor = backgroundColor
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredEmptyViewContainer(
            content: AnyView(SUIEmptyView(adapter: swiftUIAdapter)),
            backgroundColor: swiftUIBackgroundColor,
            isHidden: swiftUIIsHidden
        )
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
        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredEmptyViewContainer: View {
    let content: AnyView
    let backgroundColor: UIColor
    let isHidden: Bool

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity)
                .background(isHidden ? SwiftUIColor.clear : SwiftUIColor(backgroundColor))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
