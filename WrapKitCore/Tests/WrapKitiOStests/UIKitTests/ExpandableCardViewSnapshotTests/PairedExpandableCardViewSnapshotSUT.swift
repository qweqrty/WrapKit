//
//  PairedExpandableCardViewSnapshotSUT.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 27/4/26.
//
import WrapKit
import SwiftUI

#if canImport(SwiftUI)
final class PairedExpandableCardViewSnapshotSUT: NSObject, ExpandableCardViewOutput {
    let uiKitView: ExpandableCardView
    private let swiftUIAdapter: ExpandableCardViewOutputSwiftUIAdapter

    private var lastModel: Pair<CardViewPresentableModel, CardViewPresentableModel?>?
    private var lastIsHidden: Bool = false

    init(
        uiKitView: ExpandableCardView = ExpandableCardView(),
        swiftUIAdapter: ExpandableCardViewOutputSwiftUIAdapter = ExpandableCardViewOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    var stackView: StackView { uiKitView.stackView }
    var primeCardView: CardView { uiKitView.primeCardView }
    var secondaryCardView: CardView { uiKitView.secondaryCardView }

    func layoutIfNeeded() {
        uiKitView.layoutIfNeeded()
    }

    func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        uiKitView.display(model: model)
        lastModel = model
        swiftUIAdapter.display(model: model)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        lastIsHidden = isHidden
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        uiKitView.layoutIfNeeded()

        let resolvedPrimeHeight = resolvedHeight(
            for: uiKitView.primeCardView,
            fallback: uiKitView.primeCardView.exactHeightConstraintConstant
        )
        let resolvedSecondaryHeight = resolvedHeight(
            for: uiKitView.secondaryCardView,
            fallback: uiKitView.secondaryCardView.exactHeightConstraintConstant
        )
        let containerHeight = resolvedHeight(
            for: uiKitView,
            fallback: 390
        ) ?? 390

        let rootView = SnapshotMirroredExpandableCardContainer(
            adapter: swiftUIAdapter,
            stackSpacing: uiKitView.stackView.spacing,
            primeCardHeight: resolvedPrimeHeight,
            secondaryCardHeight: uiKitView.secondaryCardView.isHidden ? nil : resolvedSecondaryHeight,
            containerHeight: containerHeight
        )
        .ignoresSafeArea(.all)

        let hostingController = SwiftUI.UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        container.backgroundColor = .clear
        container.isOpaque = false
        container.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        replaySwiftUIState()

        let warmup: TimeInterval = 0.15
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return container.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }

    private func resolvedHeight(for view: UIView, fallback: CGFloat?) -> CGFloat? {
        if let fallback, fallback > 0 {
            return fallback
        }

        let measuredHeight = view.bounds.height
        if measuredHeight > 0 {
            let scale = UIScreen.main.scale
            return (measuredHeight * scale).rounded() / scale
        }
        return nil
    }

    private func replaySwiftUIState() {
        let applyState = { [self] in
            if let lastModel {
                swiftUIAdapter.display(model: lastModel)
            }
            swiftUIAdapter.display(isHidden: lastIsHidden)
        }

        if Thread.isMainThread {
            applyState()
        } else {
            DispatchQueue.main.sync {
                applyState()
            }
        }
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredExpandableCardContainer: SwiftUI.View {
    let adapter: ExpandableCardViewOutputSwiftUIAdapter
    let stackSpacing: CGFloat
    let primeCardHeight: CGFloat?
    let secondaryCardHeight: CGFloat?
    let containerHeight: CGFloat

    var body: some View {
        SwiftUI.VStack(spacing: 0) {
            SUIExpandableCardView(
                adapter: adapter,
                stackSpacing: stackSpacing,
                primeCardHeight: primeCardHeight,
                secondaryCardHeight: secondaryCardHeight
            )
            .frame(maxWidth: .infinity, minHeight: containerHeight, maxHeight: containerHeight, alignment: .top)
            SwiftUI.Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}

private extension UIView {
    var exactHeightConstraintConstant: CGFloat? {
        constraints.first { constraint in
            constraint.firstAttribute == .height &&
            constraint.relation == .equal &&
            constraint.secondItem == nil
        }?.constant
    }
}
#endif
