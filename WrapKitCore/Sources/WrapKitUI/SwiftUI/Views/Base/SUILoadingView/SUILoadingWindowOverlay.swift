#if canImport(SwiftUI) && canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit
import Combine

/// Keeps the SwiftUI loader above the navigation chrome of its own hosting window.
public struct SUILoadingWindowOverlay: View {
    public static let accessibilityIdentifier = "wrapkit.loading.windowOverlay"

    private let adapter: LoadingOutputSwiftUIAdapter
    private let loadingView: SUILoadingView

    public init(adapter: LoadingOutputSwiftUIAdapter, loadingView: SUILoadingView) {
        self.adapter = adapter
        self.loadingView = loadingView
    }

    public var body: some View {
        LoadingWindowPresenter(adapter: adapter, loadingView: loadingView)
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
    }
}

private struct LoadingWindowPresenter: UIViewControllerRepresentable {
    let adapter: LoadingOutputSwiftUIAdapter
    let loadingView: SUILoadingView

    func makeUIViewController(context: Context) -> SUILoadingWindowController {
        let controller = SUILoadingWindowController()
        controller.configure(adapter: adapter, loadingView: loadingView)
        return controller
    }

    func updateUIViewController(_ controller: SUILoadingWindowController, context: Context) {
        controller.configure(adapter: adapter, loadingView: loadingView)
    }

    static func dismantleUIViewController(_ controller: SUILoadingWindowController, coordinator: ()) {
        controller.disconnect()
    }
}

final class SUILoadingWindowController: UIViewController {
    private var adapter: LoadingOutputSwiftUIAdapter?
    private var subscription: AnyCancellable?
    private var loadingView: SUILoadingView?
    private(set) var host: UIHostingController<AnyView>?
    private var isVisible = false
    private var isLoading = false

    override func loadView() {
        let anchor = LoadingWindowAnchorView()
        anchor.isUserInteractionEnabled = false
        anchor.windowDidChange = { [weak self] in self?.updateOverlay() }
        view = anchor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
        updateOverlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        removeOverlay()
    }

    func configure(adapter: LoadingOutputSwiftUIAdapter, loadingView: SUILoadingView) {
        self.loadingView = loadingView
        if self.adapter !== adapter {
            subscription = nil
            removeOverlay()
            self.adapter = adapter
            isLoading = adapter.isLoading == true
            subscription = adapter.$isLoading
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    self?.isLoading = value == true
                    self?.updateOverlay()
                }
        }
        updateOverlay()
    }

    func disconnect() {
        subscription = nil
        adapter = nil
        loadingView = nil
        isLoading = false
        removeOverlay()
    }

    private func updateOverlay() {
        guard isVisible, isLoading, let window = viewIfLoaded?.window, let loadingView else {
            removeOverlay()
            return
        }
        if let host, host.view.superview === window {
            host.rootView = AnyView(loadingView.ignoresSafeArea())
            return
        }
        removeOverlay()
        let host = UIHostingController(rootView: AnyView(loadingView.ignoresSafeArea()))
        self.host = host
        host.view.backgroundColor = .clear
        host.view.frame = window.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.accessibilityIdentifier = SUILoadingWindowOverlay.accessibilityIdentifier
        host.view.isAccessibilityElement = true
        // Modal accessibility excludes sibling window content without changing its saved AX state.
        host.view.accessibilityViewIsModal = true
        // A window sibling is outside UINavigationController's edge-pop gesture hierarchy.
        host.beginAppearanceTransition(true, animated: false)
        window.addSubview(host.view)
        host.endAppearanceTransition()
    }

    private func removeOverlay() {
        guard let host else { return }
        self.host = nil
        host.beginAppearanceTransition(false, animated: false)
        host.view.removeFromSuperview()
        host.endAppearanceTransition()
    }

    deinit {
        host?.view.removeFromSuperview()
    }
}

private final class LoadingWindowAnchorView: UIView {
    var windowDidChange: (() -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        windowDidChange?()
    }
}
#endif
