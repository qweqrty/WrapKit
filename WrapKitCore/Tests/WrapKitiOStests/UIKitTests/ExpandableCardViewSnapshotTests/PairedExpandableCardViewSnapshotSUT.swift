//
//  PairedExpandableCardViewSnapshotSUT.swift
//  WrapKit
//

import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedExpandableCardViewSnapshotSUT: NSObject, ExpandableCardViewOutput, PairedSnapshotSource {
    let uiKitView: ExpandableCardView

    private let uiKitContainer: UIView
    private let swiftUIAdapter: ExpandableCardViewOutputSwiftUIAdapter
    private let snapshotContainerHeight: CGFloat
    private var snapshotStackSpacing: CGFloat = 0
    private var snapshotPrimeCardHeight: CGFloat?
    private var snapshotSecondaryCardHeight: CGFloat?

    init(
        uiKitContainer: UIView,
        uiKitView: ExpandableCardView = ExpandableCardView(),
        swiftUIAdapter: ExpandableCardViewOutputSwiftUIAdapter = ExpandableCardViewOutputSwiftUIAdapter(),
        snapshotContainerHeight: CGFloat = 390
    ) {
        self.uiKitContainer = uiKitContainer
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
        self.snapshotContainerHeight = snapshotContainerHeight
    }

    func layoutIfNeeded() {
        uiKitView.layoutIfNeeded()
    }

    func configureSnapshotLayout(
        stackSpacing: CGFloat,
        primeCardHeight: CGFloat? = nil,
        secondaryCardHeight: CGFloat? = nil
    ) {
        snapshotStackSpacing = stackSpacing
        snapshotPrimeCardHeight = primeCardHeight
        snapshotSecondaryCardHeight = secondaryCardHeight

        uiKitView.stackView.spacing = stackSpacing
        if let primeCardHeight {
            uiKitView.primeCardView.constrainHeight(primeCardHeight)
        }
        if let secondaryCardHeight {
            uiKitView.secondaryCardView.constrainHeight(secondaryCardHeight)
        }
    }

    func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        uiKitView.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        uiKitContainer.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let content = SUIExpandableCardView(
            adapter: swiftUIAdapter,
            stackSpacing: snapshotStackSpacing,
            primeCardHeight: snapshotPrimeCardHeight,
            secondaryCardHeight: snapshotSecondaryCardHeight
        )
        let rootView = SnapshotMirroredExpandableCardContainer(
            content: AnyView(content),
            containerHeight: snapshotContainerHeight
        )
        .environment(\.colorScheme, appearance.colorScheme)
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        let warmup: TimeInterval = 0.15
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredExpandableCardContainer: View {
    let content: AnyView
    let containerHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(
                    maxWidth: .infinity,
                    minHeight: containerHeight,
                    maxHeight: containerHeight,
                    alignment: .top
                )
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
