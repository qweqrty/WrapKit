//
//  SwiftUIButtonSnapshotSUT.swift
//  WrapKitTests
//

@testable import WrapKit
import WrapKitTestUtils
import UIKit
import XCTest

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

@MainActor
final class FilledGlassButtonSnapshotHost {
    private let rootViewController: UIViewController
    private let window: FilledGlassButtonSnapshotWindow
    private weak var previousKeyWindow: UIWindow?
    private var isTornDown = false

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let foregroundScene = scenes.first { $0.activationState == .foregroundActive }
        previousKeyWindow = scenes.flatMap(\.windows).first(where: \.isKeyWindow)
        let frame = CGRect(x: 0, y: 0, width: 320, height: 120)
        window = FilledGlassButtonSnapshotWindow(frame: frame)
        if #available(iOS 26, *) {
            XCTAssertNotNil(foregroundScene, "Glass snapshots require an active window scene.")
            window.windowScene = foregroundScene
        }
        window.frame = frame
        window.layoutMargins = .zero
        window.rootViewController = rootViewController
        rootViewController.view.frame = window.bounds
        rootViewController.view.layoutMargins = .zero
        window.makeKeyAndVisible()
    }

    func snapshot(
        style: UIUserInterfaceStyle,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> UIImage {
        XCTAssertFalse(isTornDown, "The snapshot host has already been torn down.", file: file, line: line)
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }

        window.snapshotStyle = style
        window.overrideUserInterfaceStyle = style
        rootViewController.overrideUserInterfaceStyle = style
        rootViewController.view.frame = window.bounds
        layout()
        if #available(iOS 26, *) {
            XCTAssertEqual(UIApplication.shared.applicationState, .active, file: file, line: line)
            XCTAssertEqual(window.windowScene?.activationState, .foregroundActive, file: file, line: line)
            XCTAssertTrue(window.isKeyWindow, "Glass snapshots require the active key window.", file: file, line: line)
            XCTAssertEqual(window.traitCollection.activeAppearance, .active, file: file, line: line)
        }

        // Wait after attachment, not while the hosting view is still outside a window.
        let deadline = ProcessInfo.processInfo.systemUptime + 2
        let warmup: TimeInterval = isAvailableOS26 ? 0.6 : 0.1
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        var previousPNG: Data?
        var matchingFrames = 0
        var lastImage: UIImage?
        repeat {
            layout()
            let image = capture(file: file, line: line)
            guard let png = image.pngData() else {
                XCTFail("The button snapshot could not be encoded.", file: file, line: line)
                return image
            }
            matchingFrames = png == previousPNG ? matchingFrames + 1 : 1
            previousPNG = png
            lastImage = image
            if matchingFrames >= 3 { return image }
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        } while ProcessInfo.processInfo.systemUptime < deadline

        XCTFail("The button snapshot did not settle within two seconds.", file: file, line: line)
        return lastImage ?? capture(file: file, line: line)
    }

    func tearDown() {
        guard !isTornDown else { return }
        isTornDown = true
        window.rootViewController = nil
        window.isHidden = true
        window.resignKey()
        window.windowScene = nil
        previousKeyWindow?.makeKeyAndVisible()
    }

    private func layout() {
        window.setNeedsLayout()
        rootViewController.view.setNeedsLayout()
        window.layoutIfNeeded()
        rootViewController.view.layoutIfNeeded()
    }

    private func capture(file: StaticString, line: UInt) -> UIImage {
        let format = UIGraphicsImageRendererFormat(for: window.traitCollection)
        format.scale = 3
        // Native glass is compared in fixed SDR rather than adaptive extended range.
        format.preferredRange = isAvailableOS26 ? .standard : .extended
        format.opaque = false
        return UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { context in
            if #available(iOS 26, *) {
                if !window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) {
                    XCTFail("The button snapshot hierarchy could not be rendered.", file: file, line: line)
                }
            } else {
                context.cgContext.setFillColorSpace(CGColorSpaceCreateDeviceRGB())
                window.layer.render(in: context.cgContext)
            }
        }
    }
}

private final class FilledGlassButtonSnapshotWindow: UIWindow {
    var snapshotStyle: UIUserInterfaceStyle = .light

    override var safeAreaInsets: UIEdgeInsets { .zero }

    override var traitCollection: UITraitCollection {
        UITraitCollection(traitsFrom: [
            SnapshotConfiguration.iPhone(style: snapshotStyle).traitCollection,
            UITraitCollection(activeAppearance: .active)
        ])
    }
}
#endif
