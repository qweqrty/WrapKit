import UIKit

open class ProtectedView: UIView {
    private var didApplyScreenShield = false
    private var overlayView: UIView?

    private var captureObserver: NSObjectProtocol?
    private var willResignActiveObserver: NSObjectProtocol?
    private var didEnterBackgroundObserver: NSObjectProtocol?
    private var willEnterForegroundObserver: NSObjectProtocol?
    private var didBecomeActiveObserver: NSObjectProtocol?

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            installOverlayIfNeeded()
            startObserving()
            applyScreenShieldIfNeeded()
            updateProtectionState()
        } else {
            stopObserving()
        }
    }

    deinit {
        stopObserving()
    }

    private func installOverlayIfNeeded() {
        guard overlayView == nil else { return }

        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .systemBackground
        overlayView.isUserInteractionEnabled = false
        overlayView.isHidden = true

        addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        self.overlayView = overlayView
    }

    private func applyScreenShieldIfNeeded() {
        guard !didApplyScreenShield else { return }
        didApplyScreenShield = true
        ScreenShield.shared.protect(view: self)
    }

    private func startObserving() {
        guard captureObserver == nil else { return }

        captureObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProtectionState()
        }

        willResignActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showOverlay()
        }

        didEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showOverlay()
        }

        willEnterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProtectionState()
        }

        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProtectionState()
        }
    }

    private func stopObserving() {
        let center = NotificationCenter.default

        if let captureObserver {
            center.removeObserver(captureObserver)
        }

        if let willResignActiveObserver {
            center.removeObserver(willResignActiveObserver)
        }

        if let didEnterBackgroundObserver {
            center.removeObserver(didEnterBackgroundObserver)
        }

        if let willEnterForegroundObserver {
            center.removeObserver(willEnterForegroundObserver)
        }

        if let didBecomeActiveObserver {
            center.removeObserver(didBecomeActiveObserver)
        }

        captureObserver = nil
        willResignActiveObserver = nil
        didEnterBackgroundObserver = nil
        willEnterForegroundObserver = nil
        didBecomeActiveObserver = nil
    }

    private func updateProtectionState() {
        let isCaptured = window?.screen.isCaptured ?? UIScreen.main.isCaptured
        overlayView?.isHidden = !isCaptured
    }

    private func showOverlay() {
        overlayView?.isHidden = false
    }
}
