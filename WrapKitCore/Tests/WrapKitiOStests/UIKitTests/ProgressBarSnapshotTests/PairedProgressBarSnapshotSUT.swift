import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedProgressBarSnapshotSUT: ProgressBarOutput, PairedSnapshotSource {
    let uiKitView: ProgressBarView

    private let uiKitContainer: UIView
    private let swiftUIAdapter: ProgressBarOutputSwiftUIAdapter

    init(
        uiKitContainer: UIView,
        uiKitView: ProgressBarView = ProgressBarView(),
        swiftUIAdapter: ProgressBarOutputSwiftUIAdapter = ProgressBarOutputSwiftUIAdapter()
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
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

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        uiKitContainer.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredProgressBarContainer(
            content: AnyView(SUIProgressBar(adaper: swiftUIAdapter))
        )
        .environment(\.colorScheme, appearance.colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
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
