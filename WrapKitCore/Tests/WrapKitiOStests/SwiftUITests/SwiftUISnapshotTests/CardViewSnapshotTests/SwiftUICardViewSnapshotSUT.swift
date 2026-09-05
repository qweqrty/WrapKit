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
    private let swiftUIAdapter: CardViewOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        swiftUIAdapter: CardViewOutputSwiftUIAdapter = CardViewOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter
        self.swiftUIView = AnyView(SUICardView(adapter: swiftUIAdapter))
    }

    func display(model: CardViewPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(style: CardViewPresentableModel.Style?) {
        swiftUIAdapter.display(style: style)
    }

    func display(backgroundImage: ImageViewPresentableModel?) {
        swiftUIAdapter.display(backgroundImage: backgroundImage)
    }

    func display(title: TextOutputPresentableModel?) {
        swiftUIAdapter.display(title: title)
    }

    func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        swiftUIAdapter.display(leadingTitles: leadingTitles)
    }

    func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        swiftUIAdapter.display(trailingTitles: trailingTitles)
    }

    func display(leadingImage: ImageViewPresentableModel?) {
        swiftUIAdapter.display(leadingImage: leadingImage)
    }

    func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        swiftUIAdapter.display(secondaryLeadingImage: secondaryLeadingImage)
    }

    func display(trailingImage: ImageViewPresentableModel?) {
        swiftUIAdapter.display(trailingImage: trailingImage)
    }

    func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        swiftUIAdapter.display(secondaryTrailingImage: secondaryTrailingImage)
    }

    func display(subTitle: TextOutputPresentableModel?) {
        swiftUIAdapter.display(subTitle: subTitle)
    }

    func display(valueTitle: TextOutputPresentableModel?) {
        swiftUIAdapter.display(valueTitle: valueTitle)
    }

    func display(bottomImage: ImageViewPresentableModel?) {
        swiftUIAdapter.display(bottomImage: bottomImage)
    }

    func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        swiftUIAdapter.display(bottomSeparator: bottomSeparator)
    }

    func display(switchControl: SwitchControlPresentableModel?) {
        swiftUIAdapter.display(switchControl: switchControl)
    }

    func display(onPress: (() -> Void)?) {
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(onLongPress: (() -> Void)?) {
        swiftUIAdapter.display(onLongPress: onLongPress)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(isUserInteractionEnabled: Bool?) {
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isGradientBorderEnabled: Bool) {
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
            .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
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
