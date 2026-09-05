//
//  SwiftUISegmentedControlSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUISegmentedControlSnapshotSUT: SegmentedControlOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: SegmentedControlOutputSwiftUIAdapter
    private var appearance: SegmentedControlAppearance
    private let snapshotHeight: CGFloat

    init(
        appearance: SegmentedControlAppearance,
        snapshotHeight: CGFloat,
        swiftUIAdapter: SegmentedControlOutputSwiftUIAdapter = SegmentedControlOutputSwiftUIAdapter()
    ) {
        self.appearance = appearance
        self.snapshotHeight = snapshotHeight
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(appearence: SegmentedControlAppearance) {
        appearance = appearence
        swiftUIAdapter.display(appearence: appearence)
    }

    func display(segments: [SegmentControlModel]) {
        swiftUIAdapter.display(segments: segments)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for snapshotAppearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredSegmentedControlContainer(
            content: AnyView(SUISegmentControlView(
                adapter: swiftUIAdapter,
                appearance: appearance
            )),
            height: snapshotHeight
        )
        .snapshotEnvironment(configuration: .iPhone(style: snapshotAppearance.colorScheme))
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = snapshotAppearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: snapshotAppearance.uiKitConfiguration)
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredSegmentedControlContainer: View {
    let content: AnyView
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(
                    maxWidth: .infinity,
                    minHeight: height,
                    maxHeight: height,
                    alignment: .top
                )
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
