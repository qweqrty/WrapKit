//
//  PairedSwitchControlSnapshotSUT.swift
//  WrapKit
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedSwitchControlSnapshotSUT: SwitchCotrolOutput, LoadingOutput, PairedSnapshotParitySource {
    let uiKitView: SwitchControl

    private let uiKitContainer: UIView
    private let swiftUIAdapter: SwitchCotrolOutputSwiftUIAdapter
    private var swiftUIStyle: SwitchControlPresentableModel.Style?

    init(
        uiKitContainer: UIView,
        uiKitView: SwitchControl = SwitchControl(),
        swiftUIAdapter: SwitchCotrolOutputSwiftUIAdapter = SwitchCotrolOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    var isLoading: Bool? {
        get { swiftUIAdapter.isLoading }
        set {
            uiKitView.isLoading = newValue
            swiftUIAdapter.isLoading = newValue
        }
    }

    var backgroundColor: UIColor? {
        get { uiKitView.backgroundColor }
        set {
            uiKitView.backgroundColor = newValue
            guard let newValue, let style = swiftUIStyle else { return }
            let effectiveStyle = style.replacingBackgroundColor(with: newValue)
            swiftUIStyle = effectiveStyle
            uiKitView.display(style: effectiveStyle)
            swiftUIAdapter.display(style: effectiveStyle)
        }
    }

    func display(isOn: Bool) {
        uiKitView.display(isOn: isOn)
        swiftUIAdapter.display(isOn: isOn)
    }

    func display(model: SwitchControlPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
        if let style = model?.style {
            swiftUIStyle = style
        }
    }

    func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?) {
        uiKitView.display(onPress: onPress)
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(isEnabled: Bool) {
        uiKitView.display(isEnabled: isEnabled)
        swiftUIAdapter.display(isEnabled: isEnabled)
    }

    func display(isLoading: Bool) {
        uiKitView.display(isLoading: isLoading)
        swiftUIAdapter.display(isLoading: isLoading)
    }

    func display(style: SwitchControlPresentableModel.Style?) {
        uiKitView.display(style: style)
        swiftUIAdapter.display(style: style)
        swiftUIStyle = style
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        uiKitContainer.snapshot(for: appearance.uiKitConfiguration)
    }

    func uiKitParitySnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let container = UIView(frame: uiKitContainer.bounds)
        container.backgroundColor = uiKitContainer.backgroundColor

        let paritySwitch = SwitchControl()
        paritySwitch.display(style: swiftUIStyle)
        if swiftUIStyle == nil {
            paritySwitch.backgroundColor = uiKitView.backgroundColor
        }
        paritySwitch.frame = CGRect(origin: .zero, size: paritySwitch.intrinsicContentSize)
        container.addSubview(paritySwitch)
        paritySwitch.display(isOn: uiKitView.isOn)
        paritySwitch.display(isEnabled: uiKitView.isEnabled)
        paritySwitch.display(isHidden: uiKitView.isHidden)

        return container.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredSwitchControlContainer(
            content: AnyView(SUISwitchControl(adapter: swiftUIAdapter))
        )
        .environment(\.colorScheme, appearance.colorScheme)

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
private struct SnapshotMirroredSwitchControlContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                content
                    .fixedSize()
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}

private extension SwitchControlPresentableModel.Style {
    func replacingBackgroundColor(with backgroundColor: UIColor) -> Self {
        .init(
            tintColor: tintColor,
            thumbTintColor: thumbTintColor,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shimmerStyle: shimmerStyle
        )
    }
}
#endif
