//
//  PairedChunkedTextFieldSnapshotSUT.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils

#if canImport(SwiftUI)
import SwiftUI

final class PairedChunkedTextFieldSnapshotSUT {
    let uiKitView: ChunkedTextField

    private let count: Int
    private let appearance: TextfieldAppearance
    private let swiftUIAdapter: TextInputOutputSwiftUIAdapter

    init(
        count: Int,
        appearance: TextfieldAppearance,
        uiKitView: ChunkedTextField? = nil,
        swiftUIAdapter: TextInputOutputSwiftUIAdapter = TextInputOutputSwiftUIAdapter()
    ) {
        self.count = count
        self.appearance = appearance
        self.uiKitView = uiKitView ?? ChunkedTextField(count: count, appearance: appearance)
        self.swiftUIAdapter = swiftUIAdapter
    }

    func display(model: TextInputPresentableModel?) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(text: String?) {
        uiKitView.display(text: text)
        swiftUIAdapter.display(text: text)
    }

    func display(isValid: Bool) {
        uiKitView.display(isValid: isValid)
        swiftUIAdapter.display(isValid: isValid)
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
        let height = max(uiKitView.bounds.height, 52)
        let rootView = SnapshotMirroredChunkedTextFieldContainer(
            count: count,
            appearance: appearance,
            adapter: swiftUIAdapter,
            height: height
        )
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredChunkedTextFieldContainer: View {
    let count: Int
    let appearance: TextfieldAppearance
    let adapter: TextInputOutputSwiftUIAdapter
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            SUIChunkedTextField(
                count: count,
                appearance: appearance,
                adapter: adapter
            )
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
