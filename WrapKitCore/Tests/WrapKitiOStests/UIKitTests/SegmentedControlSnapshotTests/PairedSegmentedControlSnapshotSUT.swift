//
//  PairedSegmentedControlSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class PairedSegmentedControlSnapshotSUT {
    let uiKitView: SegmentedControl

    let adapter: SegmentedControlOutputSwiftUIAdapter
    private var appearance: SegmentedControlAppearance

    init(
        appearance: SegmentedControlAppearance,
        swiftUIAdapter: SegmentedControlOutputSwiftUIAdapter = SegmentedControlOutputSwiftUIAdapter()
    ) {
        self.appearance = appearance
        self.uiKitView = SegmentedControl(appearance: appearance)
        self.adapter = swiftUIAdapter
    }

    func display(appearence: SegmentedControlAppearance) {
        appearance = appearence
        uiKitView.display(appearence: appearence)
        adapter.display(appearence: appearence)
    }

    func display(segments: [SegmentControlModel]) {
        uiKitView.display(segments: segments)
        adapter.display(segments: segments)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let traitStyle: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        let rootView = SnapshotMirroredSegmentedControlContainer(
            adapter: adapter,
            appearance: resolvedAppearance(for: traitStyle),
            height: snapshotHeight
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

    private var snapshotHeight: CGFloat {
        let height = uiKitView.bounds.height
        guard height > 0 else { return uiKitView.intrinsicContentSize.height }
        return height
    }

    private func resolvedAppearance(for traitStyle: UIUserInterfaceStyle) -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: appearance.colors.textColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: traitStyle)),
                backgroundColor: appearance.colors.backgroundColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: traitStyle)),
                selectedBackgroundColor: appearance.colors.selectedBackgroundColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: traitStyle))
            ),
            font: appearance.font,
            cornerRadius: appearance.cornerRadius
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredSegmentedControlContainer: View {
    let adapter: SegmentedControlOutputSwiftUIAdapter
    let appearance: SegmentedControlAppearance
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            SUISegmentControlView(adapter: adapter, appearance: appearance)
                .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}

#endif
