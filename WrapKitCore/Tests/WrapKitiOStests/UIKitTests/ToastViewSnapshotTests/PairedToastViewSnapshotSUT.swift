//
//  PairedToastViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedToastViewSnapshotSUT: CommonToastOutput, PairedSnapshotSource {
    private struct SwiftUIHost {
        let window: UIWindow
        let controller: UIViewController
    }

    let uiKitView: ToastView
    private let uiKitContainer: UIWindow
    private let swiftUIAdapter: CommonToastOutputSwiftUIAdapter
    private var lightSwiftUIHost: SwiftUIHost?
    private var darkSwiftUIHost: SwiftUIHost?
    private var lightSwiftUISnapshot: UIImage?
    private var darkSwiftUISnapshot: UIImage?

    init(
        uiKitContainer: UIWindow,
        uiKitView: ToastView = ToastView(duration: nil, position: .top),
        swiftUIAdapter: CommonToastOutputSwiftUIAdapter = CommonToastOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter

        if #available(iOS 17.0, *) {
            lightSwiftUIHost = makeSwiftUIHost(adapter: swiftUIAdapter, for: .light)
            darkSwiftUIHost = makeSwiftUIHost(adapter: swiftUIAdapter, for: .dark)
            settleSwiftUIHostsBeforeOutput()
        }
    }

    func display(_ toast: CommonToast) {
        invalidateSwiftUISnapshotCache()
        uiKitView.display(toast)
        swiftUIAdapter.display(toast)
    }

    func hide() {
        invalidateSwiftUISnapshotCache()
        uiKitView.hide()
        swiftUIAdapter.hide()
    }

    func show(appWindow: UIWindow?, completion: (() -> Void)? = nil) {
        uiKitView.show(appWindow: appWindow, completion: completion)
    }

    func removeFromSuperview() {
        uiKitView.removeFromSuperview()
    }

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        uiKitContainer.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let colorScheme = appearance.colorScheme
        if let cachedSnapshot = cachedSwiftUISnapshot(for: colorScheme) {
            return cachedSnapshot
        }

        let otherColorScheme: ColorScheme = colorScheme == .dark ? .light : .dark
        guard let requestedHost = swiftUIHost(for: colorScheme),
              let otherHost = swiftUIHost(for: otherColorScheme) else {
            assertionFailure("SwiftUI toast host must be prepared before sending Output events.")
            return UIImage()
        }

        let requestedSnapshot = captureSwiftUISnapshot(host: requestedHost, for: colorScheme)
        cacheSwiftUISnapshot(requestedSnapshot, for: colorScheme)

        let otherSnapshot = captureSwiftUISnapshot(host: otherHost, for: otherColorScheme)
        cacheSwiftUISnapshot(otherSnapshot, for: otherColorScheme)

        return requestedSnapshot
    }

    @available(iOS 17.0, *)
    private func captureSwiftUISnapshot(
        host: SwiftUIHost,
        for colorScheme: ColorScheme
    ) -> UIImage {
        host.window.makeKeyAndVisible()
        host.window.setNeedsLayout()
        host.window.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        host.window.setNeedsLayout()
        host.window.layoutIfNeeded()

        return snapshotInPlace(host.window, for: colorScheme)
    }

    private func swiftUIHost(for colorScheme: ColorScheme) -> SwiftUIHost? {
        colorScheme == .dark ? darkSwiftUIHost : lightSwiftUIHost
    }

    private func cachedSwiftUISnapshot(for colorScheme: ColorScheme) -> UIImage? {
        colorScheme == .dark ? darkSwiftUISnapshot : lightSwiftUISnapshot
    }

    private func cacheSwiftUISnapshot(_ snapshot: UIImage, for colorScheme: ColorScheme) {
        if colorScheme == .dark {
            darkSwiftUISnapshot = snapshot
        } else {
            lightSwiftUISnapshot = snapshot
        }
    }

    private func invalidateSwiftUISnapshotCache() {
        lightSwiftUISnapshot = nil
        darkSwiftUISnapshot = nil
    }

    @available(iOS 17.0, *)
    private func settleSwiftUIHostsBeforeOutput() {
        let hosts = [lightSwiftUIHost, darkSwiftUIHost].compactMap { $0 }
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

    @available(iOS 17.0, *)
    private func makeSwiftUIHost(
        adapter: CommonToastOutputSwiftUIAdapter,
        for colorScheme: ColorScheme
    ) -> SwiftUIHost {
        let rootView = SnapshotMirroredToastContainer(adapter: adapter)
            .environment(\.colorScheme, colorScheme)
        let hostingController = UIHostingController(rootView: rootView)
        let interfaceStyle: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        hostingController.overrideUserInterfaceStyle = interfaceStyle
        hostingController.view.backgroundColor = .clear

        let hostWindow = UIWindow(
            frame: CGRect(origin: .zero, size: SUISnapshotConfiguration.size)
        )
        hostWindow.overrideUserInterfaceStyle = interfaceStyle
        hostWindow.backgroundColor = .white
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

    @available(iOS 17.0, *)
    private func snapshotInPlace(_ window: UIWindow, for colorScheme: ColorScheme) -> UIImage {
        let configuration = SnapshotConfiguration.iPhone(
            style: colorScheme == .dark ? .dark : .light
        )
        let format = UIGraphicsImageRendererFormat(for: configuration.traitCollection)
        format.scale = configuration.traitCollection.displayScale
        format.preferredRange = .extended
        format.opaque = false

        return UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredToastContainer: View {
    let adapter: CommonToastOutputSwiftUIAdapter

    var body: some View {
        ZStack(alignment: .topLeading) {
            SwiftUIColor.white
            SUIToastView(adapter: adapter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SwiftUIColor.white)
        .ignoresSafeArea(.all)
    }
}
#endif
