//
//  PairedToastViewSnapshotSUT.swift
//  WrapKitTests
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedToastViewSnapshotSUT {
    let uiKitView: ToastView
    private let swiftUIAdapter: CommonToastOutputSwiftUIAdapter
    private var lastToast: CommonToast?

    init(
        uiKitView: ToastView = ToastView(duration: nil, position: .top),
        swiftUIAdapter: CommonToastOutputSwiftUIAdapter = CommonToastOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    var cardView: CardView {
        uiKitView.cardView
    }

    func display(_ toast: CommonToast) {
        lastToast = toast
        uiKitView.display(toast)
        swiftUIAdapter.display(toast)
    }

    func hide() {
        uiKitView.hide()
        swiftUIAdapter.hide()
    }

    func show(appWindow: UIWindow?, completion: (() -> Void)? = nil) {
        uiKitView.show(appWindow: appWindow, completion: completion)
    }

    func removeFromSuperview() {
        uiKitView.removeFromSuperview()
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredToastContainer(
            adapter: swiftUIAdapter,
            toastWidth: 363,
            colorScheme: colorScheme
        )
            .environment(\.colorScheme, colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        replaySwiftUIState()

        let warmup: TimeInterval = 0.2
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }

    private func replaySwiftUIState() {
        guard let lastToast else { return }

        if Thread.isMainThread {
            swiftUIAdapter.display(lastToast)
        } else {
            DispatchQueue.main.sync {
                swiftUIAdapter.display(lastToast)
            }
        }
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredToastContainer: View {
    let adapter: CommonToastOutputSwiftUIAdapter
    let toastWidth: CGFloat
    let colorScheme: ColorScheme

    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundColor
            SUIToastView(adapter: adapter)
                .frame(width: toastWidth, height: 812, alignment: .topLeading)
        }
        .frame(width: 375, height: 812, alignment: .topLeading)
        .background(backgroundColor)
    }

    private var backgroundColor: SwiftUIColor {
        colorScheme == .dark ? .black : .white
    }
}
#endif
