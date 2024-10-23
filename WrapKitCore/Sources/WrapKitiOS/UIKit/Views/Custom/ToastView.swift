//
//  ToastView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

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
    public let duration: TimeInterval
    private let position: CommonToast.Position
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    private var hideTimer: Timer?
    private var remainingTime: TimeInterval = 0
    public var shadowColor: UIColor?
    public var onDismiss: (() -> Void)?

    public var leadingConstraint: NSLayoutConstraint?
    public var bottomConstraint: NSLayoutConstraint?

    public init(duration: TimeInterval = 3.0, position: CommonToast.Position) {
        self.duration = duration
        self.position = position
        self.remainingTime = duration
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setSwipe()
        setTapGesture()
        setupObservers()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
            adjustForKeyboardVisibility(additionalBottomPadding: additionalBottomPadding)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        switch position {
        case .top:
            break
        case .bottom(let additionalBottomPadding):
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
    }

    private func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
    }

    @objc private func didTap(gesture: UITapGestureRecognizer) {
        hide(after: 0)
    }

    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let panOffset = gesture.translation(in: self).y
        
        switch gesture.state {
        case .began:
            pauseHideTimer()
        case .changed:
            bottomConstraint?.constant = position == .top ? min(showConstant + panOffset, showConstant) : max(showConstant + panOffset, showConstant)
            layoutIfNeeded()
        case .ended, .cancelled, .failed:
            resumeHideTimer()
            let bottomConstant = bottomConstraint?.constant ?? 0
            UIView.animate(withDuration: 0.2, delay: .zero, options: [.curveEaseInOut, .allowUserInteraction]) {
                if (bottomConstant) > (self.showConstant / 1.5) {
                    self.bottomConstraint?.constant = 0
                    self.hide(after: 0)
                } else {
                    self.bottomConstraint?.constant = self.showConstant
                }
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
        default:
            break
        }
    }

    public func show() {
        guard let window = UIApplication.window else { return }
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
        window.bringSubviewToFront(self)

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
                guard finished else { return }
                self?.alpha = 1
                self?.startHideTimer()
                self?.layoutIfNeeded()
                self?.superview?.layoutIfNeeded()
            }
        )
    }

    private func startHideTimer() {
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
