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
    let uiKitButton: WrapKit.Button

    private let uiKitContainer: UIView
    private let swiftUIAdapter: ButtonOutputSwiftUIAdapter
    private let loadingAdapter: LoadingOutputSwiftUIAdapter
    private let swiftUIView: AnyView

    init(
        height: CGFloat = 60,
        uiKitButton: WrapKit.Button = WrapKit.Button(),
        swiftUIAdapter: ButtonOutputSwiftUIAdapter = ButtonOutputSwiftUIAdapter(),
        loadingAdapter: LoadingOutputSwiftUIAdapter = LoadingOutputSwiftUIAdapter()
    ) {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        container.addSubview(uiKitButton)
        uiKitButton.anchoredConstraints = uiKitButton.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(height, priority: .required)
        )
        container.layoutIfNeeded()

        self.uiKitContainer = container
        self.uiKitButton = uiKitButton
        self.swiftUIAdapter = swiftUIAdapter
        self.loadingAdapter = loadingAdapter
        swiftUIAdapter.display(height: height)
        let stateModel = SUIButtonStateModel(
            adapter: swiftUIAdapter,
            loadingAdapter: loadingAdapter
        )
        self.swiftUIView = AnyView(
            SUIButton(
                stateModel: stateModel,
                loadingIndicatorPhase: .fixed(
                    strokeStart: 0,
                    strokeEnd: 1,
                    rotation: .zero
                )
            )
        )
    }

    var wrongUrlPlaceholderImage: UIImage? {
        get { uiKitButton.wrongUrlPlaceholderImage }
        set { uiKitButton.wrongUrlPlaceholderImage = newValue }
    }

    func display(model: ButtonPresentableModel?) {
        uiKitButton.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(title: String?) {
        uiKitButton.display(title: title)
        swiftUIAdapter.display(title: title)
    }

    func display(image: UIImage?) {
        uiKitButton.display(image: image)
        swiftUIAdapter.display(image: image)
    }

    func display(style: WrapKit.ButtonStyle?) {
        uiKitButton.display(style: style)
        swiftUIAdapter.display(style: style)
    }

    func display(enabled: Bool) {
        uiKitButton.display(enabled: enabled)
        swiftUIAdapter.display(enabled: enabled)
    }

    func display(isHidden: Bool) {
        uiKitButton.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(isLoading: Bool) {
        uiKitButton.display(isLoading: isLoading)
        loadingAdapter.display(isLoading: isLoading)
    }

    var isLoading: Bool? {
        get { loadingAdapter.isLoading }
        set {
            uiKitButton.isLoading = newValue
            loadingAdapter.isLoading = newValue
        }
    }

    func display(spacing: CGFloat) {
        uiKitButton.display(spacing: spacing)
        swiftUIAdapter.display(spacing: spacing)
    }

    func display(height: CGFloat) {
        uiKitButton.display(height: height)
        swiftUIAdapter.display(height: height)
    }

    func display(onPress: (() -> Void)?) {
        uiKitButton.display(onPress: onPress)
        swiftUIAdapter.display(onPress: onPress)
    }

    func setImage(_ imageEnum: ImageEnum, completion: ((WrapKit.Image?) -> Void)?) {
        uiKitButton.setImage(imageEnum, completion: completion)
    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiKitButton.touchesBegan(touches, with: event)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let hostingController = makeSwiftUIHostingController(for: appearance)
        prepareForRendering(hostingController)

        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    private func makeSwiftUIHostingController(for appearance: SnapshotAppearance) -> UIViewController {
        let rootView = SnapshotMirroredButtonContainer(content: swiftUIView)
        .environment(\.colorScheme, appearance.colorScheme)
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
private struct SnapshotMirroredButtonContainer: View {
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
