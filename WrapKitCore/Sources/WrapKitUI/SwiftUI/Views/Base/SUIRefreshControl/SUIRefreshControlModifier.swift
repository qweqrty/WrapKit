//
//  SUIRefreshControlModifier.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 23/4/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct SUIRefreshControlModifier: ViewModifier {
    @StateObject var stateModel: SUIRefreshControlStateModel
    @State private var isHiddenByTableOutput = false

    public init(adapter: RefreshControlOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public func body(content: Content) -> some View {
        refreshControlContent(content)
            .onPreferenceChange(SUITableRefreshControlHiddenPreferenceKey.self) { isHidden in
                isHiddenByTableOutput = isHidden
            }
            // A nested refreshControl modifier is the nearest owner of this
            // request. Consume it here instead of disabling refresh controls
            // farther up the view hierarchy as well.
            .transformPreference(SUITableRefreshControlHiddenPreferenceKey.self) { isHidden in
                isHidden = false
            }
    }

    @ViewBuilder
    private func refreshControlContent(_ content: Content) -> some View {
        if #available(iOS 15.0, *) {
            if isHiddenByTableOutput {
                content
            } else {
                content
                    .refreshable {
                        stateModel.triggerRefresh()
                        await stateModel.waitForLoadingToFinish()
                    }
                    .if(true) { view in
                        if #available(iOS 16.0, *) {
                            view.tint(stateModel.tintColor.map { SwiftUIColor($0) })
                        } else {
                            view.accentColor(stateModel.tintColor.map { SwiftUIColor($0) })
                        }
                    }
                    .modifier(SUIRefreshControlAppearanceModifier(
                        tintColor: stateModel.tintColor,
                        zPosition: stateModel.zPosition,
                        isLoading: stateModel.isLoading
                    ))
            }
        } else {
            // Pull to refresh is unavailable before iOS 15.
            content
        }
    }
}

private struct SUIRefreshControlAppearanceModifier: ViewModifier {
    let tintColor: Color?
    let zPosition: CGFloat
    let isLoading: Bool

    func body(content: Content) -> some View {
#if canImport(UIKit)
        content.background(
            SUIRefreshControlAppearanceProbe(
                tintColor: tintColor,
                zPosition: zPosition,
                isLoading: isLoading
            )
            .frame(width: 0, height: 0)
        )
#else
        content
#endif
    }
}

#if canImport(UIKit)
private struct SUIRefreshControlAppearanceProbe: UIViewRepresentable {
    let tintColor: UIColor?
    let zPosition: CGFloat
    let isLoading: Bool

    func makeUIView(context: Context) -> SUIRefreshControlProbeView {
        let view = SUIRefreshControlProbeView()
        view.update(tintColor: tintColor, zPosition: zPosition, isLoading: isLoading)
        return view
    }

    func updateUIView(_ uiView: SUIRefreshControlProbeView, context: Context) {
        uiView.update(tintColor: tintColor, zPosition: zPosition, isLoading: isLoading)
    }
}

private final class SUIRefreshControlProbeView: UIView {
    private var configuredTintColor: UIColor?
    private var configuredZPosition: CGFloat = 0
    private var configuredIsLoading = false
    private var originalReplicatorSeedColors: [ObjectIdentifier: CGColor] = [:]

    func update(tintColor: UIColor?, zPosition: CGFloat, isLoading: Bool) {
        configuredTintColor = tintColor
        configuredZPosition = zPosition
        configuredIsLoading = isLoading
        applyAppearance()
        DispatchQueue.main.async { [weak self] in
            self?.applyAppearance()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        applyAppearance()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        applyAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyAppearance()
    }

    private func applyAppearance() {
        guard let refreshControl = nearestRefreshControl() else { return }
        refreshControl.tintColor = configuredTintColor
        refreshControl.layer.zPosition = configuredZPosition
        applyIndicatorTint(in: refreshControl)
        applyLoadingState(to: refreshControl)
    }

    private func applyLoadingState(to refreshControl: UIRefreshControl) {
        if configuredIsLoading, !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        } else if !configuredIsLoading, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    private func applyIndicatorTint(in refreshControl: UIRefreshControl) {
        refreshControl.suiRefreshDescendants.forEach { view in
            guard let indicator = view as? UIActivityIndicatorView else { return }
            indicator.color = configuredTintColor
            indicator.tintColor = configuredTintColor
        }
        refreshControl.layer.forEachSUIRefreshReplicatorSeedLayer { layer in
            let identifier = ObjectIdentifier(layer)
            if let configuredTintColor {
                if originalReplicatorSeedColors[identifier] == nil,
                   let backgroundColor = layer.backgroundColor {
                    originalReplicatorSeedColors[identifier] = backgroundColor
                }
                layer.backgroundColor = configuredTintColor.cgColor
            } else if let originalColor = originalReplicatorSeedColors.removeValue(forKey: identifier) {
                layer.backgroundColor = originalColor
            }
        }
    }

    private func nearestRefreshControl() -> UIRefreshControl? {
        var ancestor = superview
        while let view = ancestor {
            if let refreshControl = (view as? UIScrollView)?.refreshControl {
                return refreshControl
            }
            ancestor = view.superview
        }

        guard let window else { return nil }
        let probeCenter = convert(
            CGPoint(x: bounds.midX, y: bounds.midY),
            to: window
        )
        return window.suiRefreshScrollViews
            .compactMap { scrollView -> (UIRefreshControl, CGFloat)? in
                guard let refreshControl = scrollView.refreshControl else { return nil }
                let frame = scrollView.convert(scrollView.bounds, to: window)
                let distance = hypot(frame.midX - probeCenter.x, frame.midY - probeCenter.y)
                return (refreshControl, distance)
            }
            .min(by: { $0.1 < $1.1 })?
            .0
    }
}

private extension UIView {
    var suiRefreshDescendants: [UIView] {
        subviews + subviews.flatMap(\.suiRefreshDescendants)
    }
}

private extension CALayer {
    func forEachSUIRefreshReplicatorSeedLayer(_ body: (CALayer) -> Void) {
        if superlayer is CAReplicatorLayer, backgroundColor != nil {
            body(self)
        }
        sublayers?.forEach { $0.forEachSUIRefreshReplicatorSeedLayer(body) }
    }
}

private extension UIView {
    var suiRefreshScrollViews: [UIScrollView] {
        let current = (self as? UIScrollView).map { [$0] } ?? []
        return current + subviews.flatMap(\.suiRefreshScrollViews)
    }
}
#endif

public extension View {
    func refreshControl(adapter: RefreshControlOutputSwiftUIAdapter) -> some View {
        modifier(SUIRefreshControlModifier(adapter: adapter))
    }
}
