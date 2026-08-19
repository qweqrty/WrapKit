//
//  PairedSwitchControlSnapshotSUT.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/5/26.
//


import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedSwitchControlSnapshotSUT {
    let uiKitView: SwitchControl
    private let swiftUIAdapter: SwitchCotrolOutputSwiftUIAdapter

    init(
        uiKitView: SwitchControl = SwitchControl(),
        swiftUIAdapter: SwitchCotrolOutputSwiftUIAdapter = SwitchCotrolOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    var backgroundColor: UIColor? {
        get { uiKitView.backgroundColor }
        set { uiKitView.backgroundColor = newValue }
    }

    func display(isOn: Bool) {
        uiKitView.display(isOn: isOn)
        swiftUIAdapter.display(isOn: isOn)
    }

    func display(isEnabled: Bool) {
        uiKitView.display(isEnabled: isEnabled)
        swiftUIAdapter.display(isEnabled: isEnabled)
    }

    func display(isLoading: Bool) {
        uiKitView.display(isLoading: isLoading)
        swiftUIAdapter.display(isLoading: isLoading)
    }

    func display(style: SwitchControlPresentableModel.Style?) {
        uiKitView.display(style: style)
        swiftUIAdapter.display(style: style)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = SnapshotMirroredSwitchControlContainer(adapter: swiftUIAdapter)
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
private struct SnapshotMirroredSwitchControlContainer: View {
    let adapter: SwitchCotrolOutputSwiftUIAdapter

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SUISwitchControl(adapter: adapter)
                    .frame(width: 200, height: 50)
                Spacer()
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
