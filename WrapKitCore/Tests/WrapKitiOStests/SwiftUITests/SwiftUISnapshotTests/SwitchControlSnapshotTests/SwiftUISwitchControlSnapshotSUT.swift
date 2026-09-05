//
//  SwiftUISwitchControlSnapshotSUT.swift
//  WrapKit
//

@testable import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUISwitchControlSnapshotSUT: SwitchCotrolOutput, LoadingOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: SwitchCotrolOutputSwiftUIAdapter
    private let shimmerPhase: SUIShimmerPhase

    init(
        swiftUIAdapter: SwitchCotrolOutputSwiftUIAdapter = SwitchCotrolOutputSwiftUIAdapter(),
        shimmerPhase: SUIShimmerPhase = .fixed(horizontalOffset: 0)
    ) {
        self.swiftUIAdapter = swiftUIAdapter
        self.shimmerPhase = shimmerPhase
    }

    var isLoading: Bool? {
        get { swiftUIAdapter.isLoading }
        set { swiftUIAdapter.isLoading = newValue }
    }

    func display(isOn: Bool) {
        swiftUIAdapter.display(isOn: isOn)
    }

    func display(model: SwitchControlPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?) {
        swiftUIAdapter.display(onPress: onPress)
    }

    func display(isEnabled: Bool) {
        swiftUIAdapter.display(isEnabled: isEnabled)
    }

    func display(isLoading: Bool) {
        swiftUIAdapter.display(isLoading: isLoading)
    }

    func display(style: SwitchControlPresentableModel.Style?) {
        swiftUIAdapter.display(style: style)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotSwitchControlContainer(
            content: AnyView(SUISwitchControl(
                adapter: swiftUIAdapter,
                shimmerPhase: shimmerPhase
            ))
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))

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
private struct SnapshotSwitchControlContainer: View {
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
#endif
