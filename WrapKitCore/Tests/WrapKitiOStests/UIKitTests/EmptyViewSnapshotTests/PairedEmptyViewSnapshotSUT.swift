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
    private var swiftUIBackgroundColor: UIColor = .clear
    private var swiftUIIsHidden = false

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
        swiftUIIsHidden = isHidden
    }

    func display(model: EmptyViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
        swiftUIIsHidden = model == nil
    }

    func display(backgroundColor: UIColor) {
        uiKitView.backgroundColor = backgroundColor
        swiftUIBackgroundColor = backgroundColor
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredEmptyViewContainer(
            adapter: swiftUIAdapter,
            backgroundColor: swiftUIBackgroundColor,
            isHidden: swiftUIIsHidden,
            height: uiKitView.bounds.height
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
private struct SnapshotMirroredEmptyViewContainer: View {
    let adapter: EmptyViewOutputSwiftUIAdapter
    let backgroundColor: UIColor
    let isHidden: Bool
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            SUIEmptyView(adapter: adapter)
                .frame(maxWidth: .infinity)
                .frame(height: height, alignment: .top)
                .background(isHidden ? SwiftUIColor.clear : SwiftUIColor(backgroundColor))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
