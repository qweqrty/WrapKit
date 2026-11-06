@testable import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUIProgressBarSnapshotSUT: ProgressBarOutput, SwiftUISnapshotSource {
    private let swiftUIAdapter: ProgressBarOutputSwiftUIAdapter
    private var lightHostingController: UIHostingController<AnyView>?
    private var darkHostingController: UIHostingController<AnyView>?

    init(
        swiftUIAdapter: ProgressBarOutputSwiftUIAdapter = ProgressBarOutputSwiftUIAdapter()
    ) {
        self.swiftUIAdapter = swiftUIAdapter

        if #available(iOS 17.0, *) {
            lightHostingController = makeHostingController(for: .light)
            darkHostingController = makeHostingController(for: .dark)
            [lightHostingController, darkHostingController]
                .compactMap { $0 }
                .forEach(prepareForRendering)
        }
    }

    func display(model: ProgressBarPresentableModel?) {
        swiftUIAdapter.display(model: model)
    }

    func display(style: ProgressBarStyle?) {
        swiftUIAdapter.display(style: style)
    }

    func display(progress: CGFloat) {
        swiftUIAdapter.display(progress: progress)
    }

    func display(isHidden: Bool) {
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        guard let hostingController = hostingController(for: appearance) else {
            assertionFailure("SwiftUI progress host must be prepared before sending Output events.")
            return UIImage()
        }
        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    private func makeHostingController(
        for appearance: SnapshotAppearance
    ) -> UIHostingController<AnyView> {
        let rootView = SnapshotMirroredProgressBarContainer(
            content: AnyView(SUIProgressBar(adaper: swiftUIAdapter))
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
        let hostingController = UIHostingController(rootView: AnyView(rootView))
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear
        return hostingController
    }

    private func hostingController(
        for appearance: SnapshotAppearance
    ) -> UIHostingController<AnyView>? {
        switch appearance {
        case .light: return lightHostingController
        case .dark: return darkHostingController
        }
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
private struct SnapshotMirroredProgressBarContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
