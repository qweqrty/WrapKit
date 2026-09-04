//
//  PairedTitledViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedTitledViewSnapshotSUT: TitledOutput, PairedSnapshotSource {
    let uiKitView: TitledView<UIView>

    private let uiKitContainer: UIView
    private let swiftUIAdapter: TitledOutputSwiftUIAdapter

    init(
        uiKitContainer: UIView,
        uiKitView: TitledView<UIView> = TitledView(),
        swiftUIAdapter: TitledOutputSwiftUIAdapter = TitledOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: TitledViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        uiKitView.display(titles: titles)
        swiftUIAdapter.display(titles: titles)
    }

    func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        uiKitView.display(bottomTitles: bottomTitles)
        swiftUIAdapter.display(bottomTitles: bottomTitles)
    }

    func display(leadingBottomTitle: TextOutputPresentableModel?) {
        uiKitView.display(leadingBottomTitle: leadingBottomTitle)
        swiftUIAdapter.display(leadingBottomTitle: leadingBottomTitle)
    }

    func display(trailingBottomTitle: TextOutputPresentableModel?) {
        uiKitView.display(trailingBottomTitle: trailingBottomTitle)
        swiftUIAdapter.display(trailingBottomTitle: trailingBottomTitle)
    }

    func display(isUserInteractionEnabled: Bool) {
        uiKitView.display(isUserInteractionEnabled: isUserInteractionEnabled)
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
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
        let rootView = SnapshotMirroredTitledViewContainer(
            content: AnyView(SUITitledView(adapter: swiftUIAdapter))
        )
        .environment(\.colorScheme, appearance.colorScheme)
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredTitledViewContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
