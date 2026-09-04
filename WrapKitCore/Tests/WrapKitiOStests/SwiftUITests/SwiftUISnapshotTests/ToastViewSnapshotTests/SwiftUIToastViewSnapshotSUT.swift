//
//  SwiftUIToastViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUIToastViewSnapshotSUT: CommonToastOutput, SwiftUISnapshotSource {
    private struct SwiftUIHost {
        let window: UIWindow
        let controller: UIViewController
    }

    private var toast: CommonToast?

    func display(_ toast: CommonToast) {
        self.toast = toast
    }

    func hide() {
        toast = nil
    }

    func show(appWindow: UIWindow?, completion: (() -> Void)? = nil) {
        completion?()
    }

    func removeFromSuperview() {}

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let colorScheme = appearance.colorScheme
        let adapter = CommonToastOutputSwiftUIAdapter()
        let host = makeSwiftUIHost(adapter: adapter, for: colorScheme)
        if let toast {
            adapter.display(toast)
        }
        return captureSwiftUISnapshot(host: host, for: colorScheme)
    }

    @available(iOS 17.0, *)
    private func captureSwiftUISnapshot(
        host: SwiftUIHost,
        for colorScheme: ColorScheme
    ) -> UIImage {
        host.window.makeKeyAndVisible()
        host.window.setNeedsLayout()
        host.window.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        host.window.setNeedsLayout()
        host.window.layoutIfNeeded()

        return snapshotInPlace(host.window, for: colorScheme)
    }

    @available(iOS 17.0, *)
    private func makeSwiftUIHost(
        adapter: CommonToastOutputSwiftUIAdapter,
        for colorScheme: ColorScheme
    ) -> SwiftUIHost {
        let rootView = SnapshotMirroredToastContainer(adapter: adapter)
            .environment(\.colorScheme, colorScheme)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
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
