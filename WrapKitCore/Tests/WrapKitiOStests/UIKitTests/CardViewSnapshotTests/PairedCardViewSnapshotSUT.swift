//
//  PairedCardViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedCardViewSnapshotSUT {
    let uiKitView: CardView
    private let swiftUIAdapter: CardViewOutputSwiftUIAdapter
    private var standaloneBackgroundColor: WrapKit.Color?
    private var lastStyle: CardViewPresentableModel.Style?

    init(
        uiKitView: CardView = CardView(),
        swiftUIAdapter: CardViewOutputSwiftUIAdapter = CardViewOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    var backgroundColor: WrapKit.Color? {
        get { uiKitView.backgroundColor }
        set {
            uiKitView.backgroundColor = newValue
            standaloneBackgroundColor = newValue
            if var style = lastStyle, let newValue {
                style.backgroundColor = newValue
                swiftUIAdapter.display(style: style)
            }
        }
    }

    var onPress: (() -> Void)? {
        get { uiKitView.onPress }
        set {
            uiKitView.onPress = newValue
            swiftUIAdapter.display(onPress: newValue)
        }
    }

    var onLongPress: (() -> Void)? {
        get { uiKitView.onLongPress }
        set {
            uiKitView.onLongPress = newValue
            swiftUIAdapter.display(onLongPress: newValue)
        }
    }

    func display(model: CardViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(style: CardViewPresentableModel.Style?) {
        uiKitView.display(style: style)
        lastStyle = style
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
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredCardContainer(
            adapter: swiftUIAdapter,
            standaloneBackgroundColor: standaloneBackgroundColor
        )
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        let warmup: TimeInterval = 0.12
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
private struct SnapshotMirroredCardContainer: View {
    let adapter: CardViewOutputSwiftUIAdapter
    let standaloneBackgroundColor: WrapKit.Color?

    var body: some View {
        VStack(spacing: 0) {
            SUICardView(adapter: adapter)
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .top)
                .background(SwiftUIColor(standaloneBackgroundColor ?? .clear))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
