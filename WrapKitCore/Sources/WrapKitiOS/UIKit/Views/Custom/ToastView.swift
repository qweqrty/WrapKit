#if canImport(UIKit)
import UIKit

open class ToastView: UIView {
    public lazy var cardView = {
        let view = CardView()
        view.leadingImageViewConstraints?.width?.constant = 32
        view.leadingImageViewConstraints?.height?.constant = 32
        view.trailingImageView.image = nil
        view.bottomSeparatorView.isHidden = true
        return view
    }()
    
    private var showConstant: CGFloat = 0
    public var keyboardHeight: CGFloat = 0

    private let spacing: CGFloat = 8
    public let duration: TimeInterval?
    private let position: CommonToast.Position
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    private lazy var horizontalPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleHorizontalSwipeGesture))
    private var hideTimer: Timer?
    private var remainingTime: TimeInterval? = nil
    public var shadowColor: UIColor?
    public var onDismiss: (() -> Void)?

    public var leadingConstraint: NSLayoutConstraint?
    public var bottomConstraint: NSLayoutConstraint?
    private var centerXConstraint: NSLayoutConstraint?

    public init(duration: TimeInterval? = 3.0, position: CommonToast.Position) {
        self.duration = duration
        self.position = position
        self.remainingTime = duration
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setSwipe()
        setupObservers()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func didEnterBackground() {
        pauseHideTimer()
        self.layer.removeAllAnimations()
    }

    @objc private func willEnterForeground() {
        resumeHideTimer()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        switch position {
        case .top:
            break
        case .bottom(let additionalBottomPadding):
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
                adjustForKeyboardVisibility(additionalBottomPadding: additionalBottomPadding)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        switch position {
        case .top:
            break
        case .bottom(let additionalBottomPadding):
            keyboardHeight = 0
            adjustForKeyboardVisibility(additionalBottomPadding: additionalBottomPadding)
        }
    }
    
    private func adjustForKeyboardVisibility(additionalBottomPadding: CGFloat) {
        guard let bottomConstraint = bottomConstraint else { return }
        
        let newBottomConstant = -frame.height - additionalBottomPadding - safeAreaInsets.bottom - keyboardHeight - 24
        
        UIView.animate(withDuration: 0.3, animations: {
            bottomConstraint.constant = newBottomConstant
            self.layoutIfNeeded()
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSubviews() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.zPosition = 100
        addSubview(cardView)
        alpha = 0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let shadowColor {
            dropShadow(shadowColor: shadowColor)
        }
    }

    private func setupConstraints() {
        cardView.fillSuperview()
    }

    private func setSwipe() {
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = true
        addGestureRecognizer(panGesture)

        horizontalPanGesture.delegate = self
        horizontalPanGesture.cancelsTouchesInView = true
        addGestureRecognizer(horizontalPanGesture)
    }

    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let panOffset = gesture.translation(in: self).y
        let initialAlpha: CGFloat = 1.0
        let velocity = gesture.velocity(in: self).y
        let velocityThreshold: CGFloat = 500

        switch gesture.state {
        case .began:
            pauseHideTimer()
        case .changed:
            bottomConstraint?.constant = position == .top
                ? min(showConstant + panOffset, showConstant)
                : max(showConstant + panOffset, showConstant)
            layoutIfNeeded()

            if case .bottom(_) = position, panOffset > 0 {
                let maxDistance = frame.height
                let distanceMoved = abs(panOffset)
                let newAlpha = max(1.0 - (distanceMoved / maxDistance), 0.0)
                self.alpha = newAlpha
            } else if position == .top, panOffset < 0 {
                let maxDistance = frame.height
                let distanceMoved = abs(panOffset)
                let newAlpha = max(1.0 - (distanceMoved / maxDistance), 0.0)
                self.alpha = newAlpha
            }
        case .ended, .cancelled, .failed:
            resumeHideTimer()
            let shouldDismiss = velocity > velocityThreshold || position == .top ? bottomConstraint?.constant ?? 0 < (showConstant / 1.5) : bottomConstraint?.constant ?? 0 > (showConstant / 1.5)
            UIView.animate(withDuration: 0.2, delay: .zero, options: [.curveEaseInOut, .allowUserInteraction]) {
                if shouldDismiss {
                    self.bottomConstraint?.constant = 0
                    self.alpha = 0
                    self.hide(after: 0)
                } else {
                    self.bottomConstraint?.constant = self.showConstant
                    self.alpha = initialAlpha // Restore to full opacity
                }
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
        default:
            break
        }
    }

    @objc private func handleHorizontalSwipeGesture(gesture: UIPanGestureRecognizer) {
        let panOffset = gesture.translation(in: self).x
        let velocity = gesture.velocity(in: self).x
        let velocityThreshold: CGFloat = 500

        switch gesture.state {
        case .began:
            pauseHideTimer()
        case .changed:
            leadingConstraint?.constant = panOffset
            layoutIfNeeded()
        case .ended, .cancelled, .failed:
            let shouldDismiss = abs(velocity) > velocityThreshold || abs(panOffset) > (frame.width / 3)
            
            UIView.animate(withDuration: 0.2, delay: .zero, options: [.curveEaseInOut, .allowUserInteraction]) {
                if shouldDismiss {
                    self.alpha = 0
                    self.leadingConstraint?.constant = panOffset > 0 ? self.frame.width : -self.frame.width
                } else {
                    self.alpha = 1.0
                    self.leadingConstraint?.constant = 0
                }
                self.layoutIfNeeded()
            } completion: { finished in
                if shouldDismiss {
                    self.hide(after: 0)
                }
            }
        default:
            break
        }
    }

    public func show() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        switch position {
        case .top:
            bottomConstraint = bottomAnchor.constraint(equalTo: window.topAnchor, constant: 0)
            bottomConstraint?.isActive = true
        case .bottom:
            bottomConstraint = topAnchor.constraint(equalTo: window.bottomAnchor, constant: 0)
            bottomConstraint?.isActive = true
        }
        leadingConstraint = centerXAnchor.constraint(equalTo: window.centerXAnchor)
        leadingConstraint?.isActive = true
        widthAnchor.constraint(equalTo: window.widthAnchor, constant: -spacing * 2).isActive = true

        layoutIfNeeded()
        window.layoutIfNeeded()

        switch position {
        case .top:
            showConstant = 20 + safeAreaInsets.top + frame.height
        case .bottom(let additionalBottomPadding):
            showConstant = -frame.height - 24 - safeAreaInsets.bottom - additionalBottomPadding - keyboardHeight
        }
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.alpha = 1
                self.bottomConstraint?.constant = self.showConstant
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            },
            completion: { [weak self] finished in
                guard let self = self else { return }
                guard finished else { return }
                self.alpha = 1
                self.startHideTimer()
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                window.bringSubviewToFront(self)
            }
        )
    }

    private func startHideTimer() {
        guard let remainingTime else { return }
        hideTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { [weak self] _ in
            self?.hide(after: 0)
        }
    }

    private func pauseHideTimer() {
        if let hideTimer = hideTimer, hideTimer.isValid {
            remainingTime = hideTimer.fireDate.timeIntervalSinceNow
            hideTimer.invalidate()
        }
    }

    private func resumeHideTimer() {
        startHideTimer()
    }

    public func hide(after duration: Double) {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.panGesture.isEnabled = false
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: {
                    self?.alpha = 0
                    self?.bottomConstraint?.constant = 0
                    self?.leadingConstraint?.constant = 0
                    self?.layoutIfNeeded()
                    self?.superview?.layoutIfNeeded()
                },
                completion: { [weak self] finished in
                    guard finished else { return }
                    self?.removeFromSuperview()
                    self?.onDismiss?()
                }
            )
        }
    }
}

extension ToastView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

#endif
