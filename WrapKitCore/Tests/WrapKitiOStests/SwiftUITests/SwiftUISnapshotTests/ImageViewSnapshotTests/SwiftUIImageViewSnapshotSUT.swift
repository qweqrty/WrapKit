import Foundation
import SwiftUI
import WrapKit
import WrapKitTestUtils
import XCTest

final class SwiftUIImageViewSnapshotSUT: NSObject, ImageViewOutput, SwiftUISnapshotSource {
    private struct SwiftUIHost {
        let window: ImageSnapshotWindow
        let controller: UIViewController
    }

    let uiKitImageView = ImageView()
    let adapter = ImageViewOutputSwiftUIAdapter()
    let configuration = SwiftUIImageSnapshotConfiguration()
    private let uiKitContainer = UIView()

    private var lightHost: SwiftUIHost?
    private var darkHost: SwiftUIHost?
    private var lightSwiftUISnapshot: UIImage?
    private var darkSwiftUISnapshot: UIImage?

    override init() {
        super.init()

        uiKitContainer.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        uiKitContainer.backgroundColor = .clear
        uiKitContainer.addSubview(uiKitImageView)
        uiKitImageView.anchor(
            .top(uiKitContainer.topAnchor, constant: 0, priority: .required),
            .leading(uiKitContainer.leadingAnchor, constant: 0, priority: .required),
            .trailing(uiKitContainer.trailingAnchor, constant: 0, priority: .required),
            .height(150, priority: .required)
        )
        uiKitContainer.layoutIfNeeded()

        if #available(iOS 17, *) {
            lightHost = makeSwiftUIHost(for: .light)
            darkHost = makeSwiftUIHost(for: .dark)
            settleSwiftUIHostsBeforeOutput()
        }
    }

    deinit {
        if #available(iOS 17, *) {
            tearDownSwiftUIHost(lightHost)
            tearDownSwiftUIHost(darkHost)
        }
    }

    func cleanup() {
        invalidateSwiftUISnapshotCache()
        display(image: nil, completion: nil)
        display(onPress: nil)
        display(onLongPress: nil)
        display(size: nil)
        display(borderWidth: nil)
        display(borderColor: nil)
        display(cornerRadius: nil)
        display(alpha: nil)
        display(isHidden: true)

        uiKitImageView.viewWhileLoadingView = nil
        uiKitImageView.fallbackView = nil
        uiKitImageView.wrongUrlPlaceholderImage = nil
        configuration.backgroundColor = nil
        configuration.viewWhileLoadingView = nil
        configuration.fallbackView = nil
        configuration.wrongUrlPlaceholderImage = nil
    }

    var backgroundColor: UIColor? {
        get { uiKitImageView.backgroundColor }
        set {
            invalidateSwiftUISnapshotCache()
            uiKitImageView.backgroundColor = newValue
            configuration.backgroundColor = newValue
        }
    }

    var wrongUrlPlaceholderImage: UIImage? {
        get { uiKitImageView.wrongUrlPlaceholderImage }
        set {
            invalidateSwiftUISnapshotCache()
            uiKitImageView.wrongUrlPlaceholderImage = newValue
            configuration.wrongUrlPlaceholderImage = newValue
            settleSwiftUIConfigurationChange()
        }
    }

    var onPress: (() -> Void)? { uiKitImageView.onPress }
    var onLongPress: (() -> Void)? { uiKitImageView.onLongPress }

    func configureLoadingView(color: UIColor?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.viewWhileLoadingView = color.map { ViewUIKit(backgroundColor: $0) }
        configuration.viewWhileLoadingView = color.map { AnyView(SwiftUI.Color(uiColor: $0)) }
        settleSwiftUIConfigurationChange()
    }

    func configureFallbackView(color: UIColor?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.fallbackView = color.map { ViewUIKit(backgroundColor: $0) }
        configuration.fallbackView = color.map { AnyView(SwiftUI.Color(uiColor: $0)) }
        settleSwiftUIConfigurationChange()
    }

    func display(model: ImageViewPresentableModel?, completion: ((WrapKit.Image?) -> Void)?) {
        invalidateSwiftUISnapshotCache()
        let completions = makeSwiftUICompletions(completion)
        uiKitImageView.display(model: model, completion: completions.uiKit)
        adapter.display(model: model, completion: completions.swiftUI)
    }

    func display(image: ImageEnum?, completion: ((WrapKit.Image?) -> Void)?) {
        invalidateSwiftUISnapshotCache()
        let completions = makeSwiftUICompletions(completion)
        uiKitImageView.display(image: image, completion: completions.uiKit)
        adapter.display(image: image, completion: completions.swiftUI)
    }

    func display(size: CGSize?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(size: size)
        adapter.display(size: size)
    }

    func display(onPress: (() -> Void)?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(onPress: onPress)
        adapter.display(onPress: onPress)
    }

    func display(onLongPress: (() -> Void)?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(onLongPress: onLongPress)
        adapter.display(onLongPress: onLongPress)
    }

    func display(contentModeIsFit: Bool) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(contentModeIsFit: contentModeIsFit)
        adapter.display(contentModeIsFit: contentModeIsFit)
    }

    func display(borderWidth: CGFloat?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(borderWidth: borderWidth)
        adapter.display(borderWidth: borderWidth)
    }

    func display(borderColor: WrapKit.Color?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(borderColor: borderColor)
        adapter.display(borderColor: borderColor)
    }

    func display(cornerRadius: CGFloat?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(cornerRadius: cornerRadius)
        adapter.display(cornerRadius: cornerRadius)
    }

    func display(alpha: CGFloat?) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(alpha: alpha)
        adapter.display(alpha: alpha)
    }

    func display(isHidden: Bool) {
        invalidateSwiftUISnapshotCache()
        uiKitImageView.display(isHidden: isHidden)
        adapter.display(isHidden: isHidden)
    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiKitImageView.touchesBegan(touches, with: event)
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiKitImageView.touchesEnded(touches, with: event)
    }

    @available(iOS 17, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let style = appearance.colorScheme
        if let cachedSnapshot = cachedSwiftUISnapshot(for: style) {
            return cachedSnapshot
        }

        let otherStyle: ColorScheme = style == .dark ? .light : .dark
        guard let requestedHost = swiftUIHost(for: style),
              let otherHost = swiftUIHost(for: otherStyle) else {
            assertionFailure("SwiftUI image host must be prepared before sending Output events.")
            return UIImage()
        }

        let requestedSnapshot = captureSwiftUISnapshot(host: requestedHost, for: style)
        cacheSwiftUISnapshot(requestedSnapshot, for: style)

        let otherSnapshot = captureSwiftUISnapshot(host: otherHost, for: otherStyle)
        cacheSwiftUISnapshot(otherSnapshot, for: otherStyle)

        return requestedSnapshot
    }

    private func makeSwiftUICompletions(
        _ completion: ((WrapKit.Image?) -> Void)?
    ) -> (uiKit: ((WrapKit.Image?) -> Void)?, swiftUI: ((WrapKit.Image?) -> Void)?) {
        guard let completion else { return (nil, nil) }

        let swiftUIConsumerCount: Int
        if #available(iOS 17, *) {
            // The persistent light and dark hosts must both consume the event before the public
            // completion is released. Its image argument always remains UIKit's original result.
            swiftUIConsumerCount = 2
        } else {
            swiftUIConsumerCount = 0
        }

        let barrier = ImageCompletionBarrier(
            swiftUIConsumerCount: swiftUIConsumerCount,
            completion: completion
        )
        return (
            uiKit: { barrier.recordUIKitResult($0) },
            swiftUI: { barrier.recordSwiftUIResult($0) }
        )
    }

    private func swiftUIHost(for style: ColorScheme) -> SwiftUIHost? {
        style == .dark ? darkHost : lightHost
    }

    private func cachedSwiftUISnapshot(for style: ColorScheme) -> UIImage? {
        style == .dark ? darkSwiftUISnapshot : lightSwiftUISnapshot
    }

    private func cacheSwiftUISnapshot(_ snapshot: UIImage, for style: ColorScheme) {
        if style == .dark {
            darkSwiftUISnapshot = snapshot
        } else {
            lightSwiftUISnapshot = snapshot
        }
    }

    private func invalidateSwiftUISnapshotCache() {
        lightSwiftUISnapshot = nil
        darkSwiftUISnapshot = nil
    }

    private func settleSwiftUIConfigurationChange() {
        guard #available(iOS 17.0, *) else { return }

        let hosts = [lightHost, darkHost].compactMap { $0 }
        hosts.forEach {
            $0.window.setNeedsLayout()
            $0.window.layoutIfNeeded()
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hosts.forEach {
            $0.window.setNeedsLayout()
            $0.window.layoutIfNeeded()
        }
    }

    @available(iOS 17, *)
    private func captureSwiftUISnapshot(
        host: SwiftUIHost,
        for style: ColorScheme
    ) -> UIImage {
        host.window.makeKeyAndVisible()
        host.window.setNeedsLayout()
        host.window.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        host.window.setNeedsLayout()
        host.window.layoutIfNeeded()

        return snapshotInPlace(host.window, for: style)
    }

    @available(iOS 17, *)
    private func settleSwiftUIHostsBeforeOutput() {
        let hosts = [lightHost, darkHost].compactMap { $0 }
        hosts.forEach {
            $0.window.makeKeyAndVisible()
            $0.window.setNeedsLayout()
            $0.window.layoutIfNeeded()
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hosts.forEach {
            $0.window.setNeedsLayout()
            $0.window.layoutIfNeeded()
        }
    }

    @available(iOS 17, *)
    private func makeSwiftUIHost(for style: ColorScheme) -> SwiftUIHost {
        let swiftUIConfiguration = SUISnapshotConfiguration.iPhone(style: style)
        let snapshotConfiguration = SnapshotConfiguration.iPhone(
            style: style == .dark ? .dark : .light
        )
        let rootView = SwiftUIImageSnapshotContainer(
            adapter: adapter,
            configuration: configuration
        )
        .build(configuration: swiftUIConfiguration, background: .clear)

        let hostingController = UIHostingController(rootView: rootView.ignoresSafeArea(.all))
        let interfaceStyle: UIUserInterfaceStyle = style == .dark ? .dark : .light
        hostingController.overrideUserInterfaceStyle = interfaceStyle
        hostingController.view.backgroundColor = .clear
        hostingController.view.layoutMargins = snapshotConfiguration.layoutMargins

        let hostWindow = ImageSnapshotWindow(configuration: snapshotConfiguration)
        hostWindow.overrideUserInterfaceStyle = interfaceStyle
        hostWindow.backgroundColor = .clear
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            hostWindow.windowScene = windowScene
        }
        hostWindow.rootViewController = hostingController
        hostWindow.makeKeyAndVisible()
        hostWindow.setNeedsLayout()
        hostWindow.layoutIfNeeded()
        return SwiftUIHost(window: hostWindow, controller: hostingController)
    }

    @available(iOS 17, *)
    private func snapshotInPlace(_ window: UIWindow, for style: ColorScheme) -> UIImage {
        let configuration = SnapshotConfiguration.iPhone(
            style: style == .dark ? .dark : .light
        )
        let format = UIGraphicsImageRendererFormat(for: configuration.traitCollection)
        format.scale = configuration.traitCollection.displayScale
        format.preferredRange = .extended
        format.opaque = false

        return UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { context in
            if #available(iOS 26, *) {
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            } else {
                context.cgContext.setFillColorSpace(CGColorSpaceCreateDeviceRGB())
                window.layer.render(in: context.cgContext)
            }
        }
    }

    @available(iOS 17, *)
    private func tearDownSwiftUIHost(_ host: SwiftUIHost?) {
        guard let host else { return }
        host.window.rootViewController = nil
        host.window.isHidden = true
        host.window.resignKey()
        host.window.windowScene = nil
    }
}

private final class ImageSnapshotWindow: UIWindow {
    let configuration: SnapshotConfiguration

    init(configuration: SnapshotConfiguration) {
        self.configuration = configuration
        super.init(frame: CGRect(origin: .zero, size: configuration.size))
        layoutMargins = configuration.layoutMargins
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        configuration.traitCollection
    }
}

private final class ImageCompletionBarrier {
    private var remainingSwiftUIConsumerCount: Int
    private var didReceiveUIKitResult = false
    private var uiKitImage: WrapKit.Image?
    private var swiftUIImages: [WrapKit.Image?] = []
    private var completion: ((WrapKit.Image?) -> Void)?

    init(swiftUIConsumerCount: Int, completion: @escaping (WrapKit.Image?) -> Void) {
        remainingSwiftUIConsumerCount = swiftUIConsumerCount
        self.completion = completion
    }

    func recordUIKitResult(_ image: WrapKit.Image?) {
        guard !didReceiveUIKitResult else { return }
        didReceiveUIKitResult = true
        uiKitImage = image
        finishIfReady()
    }

    func recordSwiftUIResult(_ image: WrapKit.Image?) {
        guard remainingSwiftUIConsumerCount > 0 else { return }
        swiftUIImages.append(image)
        remainingSwiftUIConsumerCount -= 1
        finishIfReady()
    }

    private func finishIfReady() {
        guard didReceiveUIKitResult, remainingSwiftUIConsumerCount == 0 else { return }
        for swiftUIImage in swiftUIImages {
            XCTAssertEqual(
                swiftUIImage?.pngData(),
                uiKitImage?.pngData(),
                "SwiftUI and UIKit ImageViewOutput completions must return the same image."
            )
        }
        let completion = completion
        self.completion = nil
        completion?(uiKitImage)
    }
}

final class SwiftUIImageSnapshotConfiguration: ObservableObject {
    @Published var backgroundColor: UIColor?
    @Published var viewWhileLoadingView: AnyView?
    @Published var fallbackView: AnyView?
    @Published var wrongUrlPlaceholderImage: UIImage?
}

private struct SwiftUIImageSnapshotContainer: View {
    let adapter: ImageViewOutputSwiftUIAdapter
    @ObservedObject var configuration: SwiftUIImageSnapshotConfiguration

    var body: some View {
        VStack(spacing: 0) {
            SUIImageView(
                adapter: adapter,
                viewWhileLoadingView: configuration.viewWhileLoadingView,
                fallbackView: configuration.fallbackView,
                wrongUrlPlaceholderImage: configuration.wrongUrlPlaceholderImage,
                backgroundColor: configuration.backgroundColor.map { SwiftUI.Color(uiColor: $0) }
            )
            .frame(height: 150, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
    }
}
