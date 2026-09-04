@testable import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class SwiftUIProgressBarSnapshotSUT: ProgressBarOutput, SwiftUISnapshotSource {
    let uiKitView: ProgressBarView

    private let uiKitContainer: UIView
    private let swiftUIAdapter: ProgressBarOutputSwiftUIAdapter
    private let swiftUIStateModel: SUIProgressBarStateModel
    private var lightHostingController: UIHostingController<AnyView>?
    private var darkHostingController: UIHostingController<AnyView>?

    init(
        uiKitContainer: UIView,
        uiKitView: ProgressBarView = ProgressBarView(),
        swiftUIAdapter: ProgressBarOutputSwiftUIAdapter = ProgressBarOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
        self.swiftUIStateModel = SUIProgressBarStateModel(adapter: swiftUIAdapter)

        if #available(iOS 17.0, *) {
            lightHostingController = makeHostingController(for: .light)
            darkHostingController = makeHostingController(for: .dark)
            [lightHostingController, darkHostingController]
                .compactMap { $0 }
                .forEach(prepareForRendering)
        }
    }

    func display(model: ProgressBarPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(style: ProgressBarStyle?) {
        uiKitView.display(style: style)
        swiftUIAdapter.display(style: style)
    }

    func display(progress: CGFloat) {
        uiKitView.display(progress: progress)
        swiftUIAdapter.display(progress: progress)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func applyCornerStyle(_ cornerStyle: CornerStyle) {
        uiKitView.applyCornerStyle(cornerStyle)
    }

    func gradientBackgroundColor(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint,
        endPoint: CGPoint
    ) {
        uiKitContainer.setNeedsLayout()
        uiKitContainer.layoutIfNeeded()
        uiKitView.gradientBackgroundColor(
            width: width,
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
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
    func retainedLayoutGeometry(for appearance: SnapshotAppearance) -> (
        uiKitFillHeight: CGFloat,
        uiKitTrackHeight: CGFloat,
        swiftUIFillHeight: CGFloat,
        swiftUITrackHeight: CGFloat
    ) {
        uiKitContainer.setNeedsLayout()
        uiKitContainer.layoutIfNeeded()
        if let hostingController = hostingController(for: appearance) {
            prepareForRendering(hostingController)
        }
        let swiftUIFillHeight = swiftUIStateModel.layoutHeight
        let styleFillHeight = swiftUIStateModel.style?.height ?? 4
        let swiftUITrackHeight = swiftUIStateModel.style?.trackHeight
            ?? (styleFillHeight - (styleFillHeight / 3).rounded(.up))
        return (
            uiKitView.progressView.bounds.height,
            uiKitView.trackView.bounds.height,
            swiftUIFillHeight,
            swiftUITrackHeight
        )
    }

    @available(iOS 17.0, *)
    private func makeHostingController(
        for appearance: SnapshotAppearance
    ) -> UIHostingController<AnyView> {
        let rootView = SnapshotMirroredProgressBarContainer(
            content: AnyView(SUIProgressBar(stateModel: swiftUIStateModel))
        )
        .environment(\.colorScheme, appearance.colorScheme)
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
