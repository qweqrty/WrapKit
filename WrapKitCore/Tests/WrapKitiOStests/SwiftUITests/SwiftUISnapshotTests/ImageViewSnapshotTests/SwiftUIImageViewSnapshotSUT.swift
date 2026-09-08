import Foundation
import SwiftUI
@testable import WrapKit
import WrapKitTestUtils

final class SwiftUIImageViewSnapshotSUT: NSObject, ImageViewOutput, SwiftUISnapshotSource {
    private struct SwiftUIHost {
        let window: ImageSnapshotWindow
        let controller: UIViewController
    }

    private let lightAdapter = ImageViewOutputSwiftUIAdapter()
    private let darkAdapter = ImageViewOutputSwiftUIAdapter()
    let configuration = SwiftUIImageSnapshotConfiguration()

    private var configuredBackgroundColor: UIColor?

    private var lightHost: SwiftUIHost?
    private var darkHost: SwiftUIHost?
    private var lightSwiftUISnapshot: UIImage?
    private var darkSwiftUISnapshot: UIImage?

    override init() {
        super.init()

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

        configuredBackgroundColor = nil
        configuration.backgroundColor = nil
        configuration.viewWhileLoadingView = nil
        configuration.fallbackView = nil
        configuration.wrongUrlPlaceholderImage = nil
    }

    var backgroundColor: UIColor? {
        get { configuredBackgroundColor }
        set {
            invalidateSwiftUISnapshotCache()
            configuredBackgroundColor = newValue
            configuration.backgroundColor = newValue
        }
    }

    var wrongUrlPlaceholderImage: UIImage? {
        get { configuration.wrongUrlPlaceholderImage }
        set {
            invalidateSwiftUISnapshotCache()
            configuration.wrongUrlPlaceholderImage = newValue
            settleSwiftUIConfigurationChange()
        }
    }

    func configureLoadingView(color: UIColor?) {
        invalidateSwiftUISnapshotCache()
        configuration.viewWhileLoadingView = color.map { AnyView(SwiftUI.Color(uiColor: $0)) }
        settleSwiftUIConfigurationChange()
    }

    func configureFallbackView(color: UIColor?) {
        invalidateSwiftUISnapshotCache()
        configuration.fallbackView = color.map { AnyView(SwiftUI.Color(uiColor: $0)) }
        settleSwiftUIConfigurationChange()
    }

    func display(model: ImageViewPresentableModel?, completion: ((WrapKit.Image?) -> Void)?) {
        invalidateSwiftUISnapshotCache()
        let completion = makeSwiftUICompletion(completion)
        adapters.forEach { $0.display(model: model, completion: completion) }
    }

    func display(image: ImageEnum?, completion: ((WrapKit.Image?) -> Void)?) {
        invalidateSwiftUISnapshotCache()
        let completion = makeSwiftUICompletion(completion)
        adapters.forEach { $0.display(image: image, completion: completion) }
    }

    func display(size: CGSize?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(size: size) }
    }

    func display(onPress: (() -> Void)?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(onPress: onPress) }
    }

    func display(onLongPress: (() -> Void)?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(onLongPress: onLongPress) }
    }

    func display(contentModeIsFit: Bool) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(contentModeIsFit: contentModeIsFit) }
    }

    func display(borderWidth: CGFloat?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(borderWidth: borderWidth) }
    }

    func display(borderColor: WrapKit.Color?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(borderColor: borderColor) }
    }

    func display(cornerRadius: CGFloat?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(cornerRadius: cornerRadius) }
    }

    func display(alpha: CGFloat?) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(alpha: alpha) }
    }

    func display(isHidden: Bool) {
        invalidateSwiftUISnapshotCache()
        adapters.forEach { $0.display(isHidden: isHidden) }
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

    private func makeSwiftUICompletion(
        _ completion: ((WrapKit.Image?) -> Void)?
    ) -> ((WrapKit.Image?) -> Void)? {
        guard let completion else { return nil }

        let swiftUIConsumerCount: Int
        if #available(iOS 17, *) {
            swiftUIConsumerCount = 2
        } else {
            swiftUIConsumerCount = 1
        }

        let barrier = ImageCompletionBarrier(
            consumerCount: swiftUIConsumerCount,
            completion: completion
        )
        return { barrier.recordSwiftUIResult($0) }
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

    private var adapters: [ImageViewOutputSwiftUIAdapter] {
        [lightAdapter, darkAdapter]
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
            adapter: style == .dark ? darkAdapter : lightAdapter,
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
    private var remainingConsumerCount: Int
    private var didRecordResult = false
    private var firstSwiftUIImage: WrapKit.Image?
    private var allConsumersLoadedImage = true
    private var completion: ((WrapKit.Image?) -> Void)?

    init(consumerCount: Int, completion: @escaping (WrapKit.Image?) -> Void) {
        remainingConsumerCount = consumerCount
        self.completion = completion
    }

    func recordSwiftUIResult(_ image: WrapKit.Image?) {
        guard remainingConsumerCount > 0 else { return }
        allConsumersLoadedImage = allConsumersLoadedImage && image != nil
        if !didRecordResult {
            didRecordResult = true
            firstSwiftUIImage = image
        }
        remainingConsumerCount -= 1
        guard remainingConsumerCount == 0 else { return }

        let completion = completion
        self.completion = nil
        completion?(allConsumersLoadedImage ? firstSwiftUIImage : nil)
    }
}

final class SwiftUIImageSnapshotConfiguration: ObservableObject {
    @Published var backgroundColor: UIColor?
    @Published var viewWhileLoadingView: AnyView?
    @Published var fallbackView: AnyView?
    @Published var wrongUrlPlaceholderImage: UIImage?
}

private struct SwiftUIImageSnapshotContainer: View {
    @StateObject private var stateModel: SUIImageViewStateModel
    @ObservedObject var configuration: SwiftUIImageSnapshotConfiguration

    init(
        adapter: ImageViewOutputSwiftUIAdapter,
        configuration: SwiftUIImageSnapshotConfiguration
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: 0) {
            SUIImageView(
                stateModel: stateModel,
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
