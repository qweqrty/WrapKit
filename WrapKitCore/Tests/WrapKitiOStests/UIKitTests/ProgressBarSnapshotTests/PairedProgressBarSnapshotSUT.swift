import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedProgressBarSnapshotSUT {
    let uiKitView: ProgressBarView
    private let swiftUIAdapter: ProgressBarOutputSwiftUIAdapter

    init(
        uiKitView: ProgressBarView = ProgressBarView(),
        swiftUIAdapter: ProgressBarOutputSwiftUIAdapter = ProgressBarOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
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

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredProgressBarContainer(adapter: swiftUIAdapter)
            .environment(\.colorScheme, colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        hostingController.view.backgroundColor = .clear

        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredProgressBarContainer: View {
    let adapter: ProgressBarOutputSwiftUIAdapter

    var body: some View {
        VStack(spacing: 0) {
            SUIProgressBar(adaper: adapter)
                .frame(maxWidth: .infinity, maxHeight: 50)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
