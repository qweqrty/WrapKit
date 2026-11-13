//
//  SwiftUITitledViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUITitledViewSnapshotSUT: TitledOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: TitledOutputSwiftUIAdapter

    init(
        swiftUIAdapter: TitledOutputSwiftUIAdapter = TitledOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: TitledViewPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        swiftUIAdapter.display(titles: titles)
    }

    func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        swiftUIAdapter.display(bottomTitles: bottomTitles)
    }

    func display(leadingBottomTitle: TextOutputPresentableModel?) {
        swiftUIAdapter.display(leadingBottomTitle: leadingBottomTitle)
    }

    func display(trailingBottomTitle: TextOutputPresentableModel?) {
        swiftUIAdapter.display(trailingBottomTitle: trailingBottomTitle)
    }

    func display(isUserInteractionEnabled: Bool) {
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredTitledViewContainer(
            content: AnyView(SUITitledView(adapter: swiftUIAdapter))
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
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
