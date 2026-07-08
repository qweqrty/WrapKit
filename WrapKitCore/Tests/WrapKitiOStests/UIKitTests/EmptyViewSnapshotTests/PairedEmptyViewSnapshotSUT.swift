//
//  PairedEmptyViewSnapshotSUT.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 25/5/26.
//


import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedEmptyViewSnapshotSUT {
    let uiKitView: WrapKit.EmptyView
    private let swiftUIAdapter: EmptyViewOutputSwiftUIAdapter

    init(
        uiKitView: WrapKit.EmptyView = EmptyView(),
        swiftUIAdapter: EmptyViewOutputSwiftUIAdapter = EmptyViewOutputSwiftUIAdapter()
    ) {
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
    }

    func display(model: EmptyViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredEmptyViewContainer(adapter: swiftUIAdapter)
            .environment(\.colorScheme, colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        hostingController.view.backgroundColor = .cyan

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
private struct SnapshotMirroredEmptyViewContainer: View {
    let adapter: EmptyViewOutputSwiftUIAdapter

    var body: some View {
        VStack(spacing: 0) {
            SUIEmptyView(adapter: adapter)
                .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.cyan))
        .ignoresSafeArea(.all)
    }
}
#endif
