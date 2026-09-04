//
//  SwiftUICardViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUICardViewSnapshotSUT: CardViewOutput, SwiftUISnapshotSource {
    let uiKitView: CardView
    private let uiKitContainer: UIView
    private let swiftUIAdapter: CardViewOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        uiKitContainer: UIView,
        uiKitView: CardView = CardView(),
        swiftUIAdapter: CardViewOutputSwiftUIAdapter = CardViewOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
        self.swiftUIView = AnyView(SUICardView(adapter: swiftUIAdapter))
    }

    func display(model: CardViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(style: CardViewPresentableModel.Style?) {
        uiKitView.display(style: style)
        swiftUIAdapter.display(style: style)
    }

    func display(backgroundImage: ImageViewPresentableModel?) {
        uiKitView.display(backgroundImage: backgroundImage)
        swiftUIAdapter.display(backgroundImage: backgroundImage)
    }

    func display(title: TextOutputPresentableModel?) {
        uiKitView.display(title: title)
        swiftUIAdapter.display(title: title)
    }

    func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        uiKitView.display(leadingTitles: leadingTitles)
        swiftUIAdapter.display(leadingTitles: leadingTitles)
    }

    func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        uiKitView.display(trailingTitles: trailingTitles)
        swiftUIAdapter.display(trailingTitles: trailingTitles)
    }

    func display(leadingImage: ImageViewPresentableModel?) {
        uiKitView.display(leadingImage: leadingImage)
        swiftUIAdapter.display(leadingImage: leadingImage)
    }

    func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        uiKitView.display(secondaryLeadingImage: secondaryLeadingImage)
        swiftUIAdapter.display(secondaryLeadingImage: secondaryLeadingImage)
    }

    func display(trailingImage: ImageViewPresentableModel?) {
        uiKitView.display(trailingImage: trailingImage)
        swiftUIAdapter.display(trailingImage: trailingImage)
    }

    func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        uiKitView.display(secondaryTrailingImage: secondaryTrailingImage)
        swiftUIAdapter.display(secondaryTrailingImage: secondaryTrailingImage)
    }

    func display(subTitle: TextOutputPresentableModel?) {
        uiKitView.display(subTitle: subTitle)
        swiftUIAdapter.display(subTitle: subTitle)
    }

    func display(valueTitle: TextOutputPresentableModel?) {
        uiKitView.display(valueTitle: valueTitle)
        swiftUIAdapter.display(valueTitle: valueTitle)
    }

    func display(bottomImage: ImageViewPresentableModel?) {
        uiKitView.display(bottomImage: bottomImage)
        swiftUIAdapter.display(bottomImage: bottomImage)
    }

    func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        uiKitView.display(bottomSeparator: bottomSeparator)
        swiftUIAdapter.display(bottomSeparator: bottomSeparator)
    }

    func display(switchControl: SwitchControlPresentableModel?) {
        uiKitView.display(switchControl: switchControl)
        swiftUIAdapter.display(switchControl: switchControl)
    }

    func display(onPress: (() -> Void)?) {
        uiKitView.display(onPress: onPress)
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(onLongPress: (() -> Void)?) {
        uiKitView.display(onLongPress: onLongPress)
        swiftUIAdapter.display(onLongPress: onLongPress)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(isUserInteractionEnabled: Bool?) {
        uiKitView.display(isUserInteractionEnabled: isUserInteractionEnabled)
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isGradientBorderEnabled: Bool) {
        uiKitView.display(isGradientBorderEnabled: isGradientBorderEnabled)
        swiftUIAdapter.display(isGradientBorderEnabled: isGradientBorderEnabled)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let hostingController = makeSwiftUIHostingController(for: appearance)
        prepareForRendering(hostingController)

        return hostingController.snapshot(
            for: appearance.uiKitConfiguration
        )
    }

    func invokeSwiftUIStoredOnPressOutputForPostStateSnapshot() -> Bool {
        guard let onPress = swiftUIAdapter.displayOnPressState?.onPress else { return false }
        onPress()
        return true
    }

    func invokeSwiftUIStoredOnLongPressOutputForPostStateSnapshot() -> Bool {
        guard let onLongPress = swiftUIAdapter.displayOnLongPressState?.onLongPress else { return false }
        onLongPress()
        return true
    }

    @available(iOS 17.0, *)
    private func makeSwiftUIHostingController(for appearance: SnapshotAppearance) -> UIViewController {
        let rootView = SnapshotMirroredCardContainer(content: swiftUIView)
            .environment(\.colorScheme, appearance.colorScheme)
            .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear
        return hostingController
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        let warmup: TimeInterval = 0.12
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
    }

}

@available(iOS 17.0, *)
private struct SnapshotMirroredCardContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}

#endif
