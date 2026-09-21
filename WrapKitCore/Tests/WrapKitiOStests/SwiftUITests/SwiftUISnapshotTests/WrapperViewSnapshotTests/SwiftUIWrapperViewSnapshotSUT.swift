@testable import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17.0, *)
final class SwiftUIWrapperViewSnapshotSUT: SwiftUISnapshotSource {
    private let content: AnyView

    init(content: AnyView) {
        self.content = content
    }

    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredWrapperViewContainer(content: content)
            .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredWrapperViewContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
