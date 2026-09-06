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
    private let swiftUIAdapter: EmptyViewOutputSwiftUIAdapter
    var snapshotContainerBackgroundColor: UIColor = .clear

    init(
        swiftUIAdapter: EmptyViewOutputSwiftUIAdapter = EmptyViewOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(title: TextOutputPresentableModel?) {
        swiftUIAdapter.display(title: title)
    }

    func display(subtitle: TextOutputPresentableModel?) {
        swiftUIAdapter.display(subtitle: subtitle)
    }

    func display(buttonModel: ButtonPresentableModel?) {
        swiftUIAdapter.display(buttonModel: buttonModel)
    }

    func display(image: ImageViewPresentableModel?) {
        swiftUIAdapter.display(image: image)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(model: EmptyViewPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredEmptyViewContainer(
            content: AnyView(SUIEmptyView(adapter: swiftUIAdapter)),
            snapshotContainerBackgroundColor: snapshotContainerBackgroundColor
        )
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
private struct SnapshotMirroredEmptyViewContainer: View {
    let content: AnyView
    let snapshotContainerBackgroundColor: UIColor

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity)
                .background(SwiftUIColor(snapshotContainerBackgroundColor))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
