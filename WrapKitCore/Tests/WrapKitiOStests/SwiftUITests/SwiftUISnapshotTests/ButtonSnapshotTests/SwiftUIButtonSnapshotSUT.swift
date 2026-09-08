//
//  SwiftUIButtonSnapshotSUT.swift
//  WrapKitTests
//

@testable import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUIButtonSnapshotSUT: ButtonOutput, LoadingOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: ButtonOutputSwiftUIAdapter
    private let loadingAdapter: LoadingOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        height: CGFloat = 60,
        swiftUIAdapter: ButtonOutputSwiftUIAdapter = ButtonOutputSwiftUIAdapter(),
        loadingAdapter: LoadingOutputSwiftUIAdapter = LoadingOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter
        self.loadingAdapter = loadingAdapter
        self.swiftUIView = AnyView(SUIButton(
            adapter: swiftUIAdapter,
            loadingAdapter: loadingAdapter
        ))
        swiftUIAdapter.display(height: height)
    }

    func display(model: ButtonPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(title: String?) {
        swiftUIAdapter.display(title: title)
    }

    func display(image: UIImage?) {
        swiftUIAdapter.display(image: image)
    }

    func display(style: WrapKit.ButtonStyle?) {
        swiftUIAdapter.display(style: style)
    }

    func display(enabled: Bool) {
        swiftUIAdapter.display(enabled: enabled)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(isLoading: Bool) {
        loadingAdapter.display(isLoading: isLoading)
    }

    var isLoading: Bool? {
        get { loadingAdapter.isLoading }
        set { loadingAdapter.isLoading = newValue }
    }

    func display(spacing: CGFloat) {
        swiftUIAdapter.display(spacing: spacing)
    }

    func display(height: CGFloat) {
        swiftUIAdapter.display(height: height)
    }

    func display(onPress: (() -> Void)?) {
        swiftUIAdapter.display(onPress: onPress)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let hostingController = makeSwiftUIHostingController(for: appearance)
        prepareForRendering(hostingController)

        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    private func makeSwiftUIHostingController(for appearance: SnapshotAppearance) -> UIViewController {
        let rootView = SnapshotButtonContainer(
            content: swiftUIView
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
        .transaction { transaction in
            transaction.disablesAnimations = true
            transaction.animation = nil
        }

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear
        return hostingController
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
private struct SnapshotButtonContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
