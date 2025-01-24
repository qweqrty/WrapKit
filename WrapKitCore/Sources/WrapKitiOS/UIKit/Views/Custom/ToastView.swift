#if canImport(UIKit)
import UIKit

public enum DirectionType {
    case horizontal
    case vertical
}

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
    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
    private var hideTimer: Timer?
    private var remainingTime: TimeInterval? = nil
    public var shadowColor: UIColor?
    public var onDismiss: (() -> Void)?

    public var leadingConstraint: NSLayoutConstraint?
    public var bottomConstraint: NSLayoutConstraint?

    private var gestureDirection: DirectionType?

    public init(duration: TimeInterval? = 3.0, position: CommonToast.Position) {
        self.duration = duration
        self.position = position
        self.remainingTime = duration
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupGestures()
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

    private func setupGestures() {
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = true
        addGestureRecognizer(panGesture)

        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
    }

    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let panOffsetX = gesture.translation(in: self).x
        let panOffsetY = gesture.translation(in: self).y
        let velocityX = gesture.velocity(in: self).x
        let velocityY = gesture.velocity(in: self).y
        let velocityThreshold: CGFloat = 500

        switch gesture.state {
        case .began:
            pauseHideTimer()
            gestureDirection = nil
        case .changed:
            if gestureDirection == nil {
                if abs(panOffsetX) > abs(panOffsetY) {
                    gestureDirection = .horizontal
                } else {
                    gestureDirection = .vertical
                }
            }

            if gestureDirection == .horizontal {
                leadingConstraint?.constant = panOffsetX
                self.alpha = max(1.0 - abs(panOffsetX) / frame.width, 0.0)
                layoutIfNeeded()
            } else if gestureDirection == .vertical {
                if position == .top && panOffsetY > 0 {
                    return
                } else if case .bottom = position, panOffsetY < 0 {
                    return
                } else {
                    bottomConstraint?.constant = max(showConstant + panOffsetY, showConstant)
                    self.alpha = max(1.0 - abs(panOffsetY) / frame.height, 0.0)
                    layoutIfNeeded()
                }
            }
        case .ended, .cancelled, .failed:
            if gestureDirection == .horizontal {
                let shouldDismiss = abs(panOffsetX) > (frame.width / 3) || abs(velocityX) > velocityThreshold
                UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseInOut, .allowUserInteraction]) {
                    if shouldDismiss {
                        self.alpha = 0
                        self.transform = CGAffineTransform(translationX: panOffsetX > 0 ? self.frame.width : -self.frame.width, y: 0)
                    } else {
                        self.alpha = 1.0
                        self.leadingConstraint?.constant = 0
                        self.transform = .identity
                    }
                    self.layoutIfNeeded()
                } completion: { finished in
                    if shouldDismiss {
                        self.hide(after: 0)
                    }
                }
            } else if gestureDirection == .vertical {
                let shouldDismiss = (position == .top && abs(panOffsetY) > frame.height / 3 && panOffsetY < 0) || (position == .bottom() && panOffsetY > frame.height / 3) || abs(velocityY) > velocityThreshold
                UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseInOut, .allowUserInteraction]) {
                    if shouldDismiss {
                        self.alpha = 0
                        self.transform = CGAffineTransform(translationX: 0, y: (self.position == .top ? -self.frame.height : self.frame.height))
                    } else {
                        self.alpha = 1.0
                        self.bottomConstraint?.constant = self.showConstant
                        self.transform = .identity
                    }
                    self.layoutIfNeeded()
                } completion: { finished in
                    if shouldDismiss {
                        self.hide(after: 0)
                    }
                }
            }
            gestureDirection = nil
            resumeHideTimer()
        default:
            break
        }
    }

    @objc private func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            pauseHideTimer()
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.alpha = 1.0
            }
        case .ended, .cancelled:
            resumeHideTimer()
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
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
        centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
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
                    if self?.position == .top {
                        self?.transform = CGAffineTransform(translationX: 0, y: -(self?.frame.height ?? 0))
                    } else {
                        self?.transform = CGAffineTransform(translationX: 0, y: self?.frame.height ?? 0)
                    }
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

