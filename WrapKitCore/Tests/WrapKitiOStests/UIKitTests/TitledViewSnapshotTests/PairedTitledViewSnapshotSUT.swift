//
//  PairedTitledViewSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class PairedTitledViewSnapshotSUT {
    let uiKitView: TitledView<UIView>

    private let swiftUIAdapter: TitledOutputSwiftUIAdapter

    init(
        uiKitView: TitledView<UIView> = TitledView(),
        swiftUIAdapter: TitledOutputSwiftUIAdapter = TitledOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: TitledViewPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        uiKitView.display(titles: titles)
        swiftUIAdapter.display(titles: titles)
    }

    func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        uiKitView.display(bottomTitles: bottomTitles)
        swiftUIAdapter.display(bottomTitles: bottomTitles)
    }

    func display(leadingBottomTitle: TextOutputPresentableModel?) {
        uiKitView.display(leadingBottomTitle: leadingBottomTitle)
        swiftUIAdapter.display(leadingBottomTitle: leadingBottomTitle)
    }

    func display(trailingBottomTitle: TextOutputPresentableModel?) {
        uiKitView.display(trailingBottomTitle: trailingBottomTitle)
        swiftUIAdapter.display(trailingBottomTitle: trailingBottomTitle)
    }

    func display(isUserInteractionEnabled: Bool) {
        uiKitView.display(isUserInteractionEnabled: isUserInteractionEnabled)
        swiftUIAdapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredTitledViewContainer(adapter: swiftUIAdapter)
            .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredTitledViewContainer: View {
    let adapter: TitledOutputSwiftUIAdapter

    var body: some View {
        VStack(spacing: 0) {
            SUITitledView(adapter: adapter)
                .frame(maxWidth: .infinity, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}

#endif
