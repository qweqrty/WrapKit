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

    public private(set) var customActionButtons: [Button] = []

    private let contentStackView = UIStackView()
    private let customActionsStackView = UIStackView()
    
    private var showConstant: CGFloat = 0
    public var keyboardHeight: CGFloat = 0
    
    // MARK: Accessibility
    private var a11yObservers: [NSObjectProtocol] = []
    private var isHoldingForA11y = false

    func startObservingVoiceOver() {
        stopObservingVoiceOver()

        guard UIAccessibility.isVoiceOverRunning else { return }

        let c = NotificationCenter.default

        a11yObservers.append(
            c.addObserver(forName: UIAccessibility.elementFocusedNotification,
                          object: nil,
                          queue: .main) { [weak self] note in
                guard let self else { return }

                let focused = note.userInfo?[UIAccessibility.focusedElementUserInfoKey]

                // Приводим focused к UIView если возможно
                let focusedView: UIView? = {
                    if let v = focused as? UIView { return v }
                    if let el = focused as? UIAccessibilityElement,
                       let container = el.accessibilityContainer as? UIView {
                        return container
                    }
                    return nil
                }()

                let isInsideToast = focusedView?.isDescendant(of: self) == true

                if isInsideToast {
                    self.holdForA11y()
                } else {
                    self.releaseA11yHold()
                }
            }
        )

        // Optional: если ты делаешь announcement — отпускать после окончания озвучки
        a11yObservers.append(
            c.addObserver(forName: UIAccessibility.announcementDidFinishNotification,
                          object: nil,
                          queue: .main) { [weak self] _ in
                self?.releaseA11yHold()
            }
        )
    }

    func stopObservingVoiceOver() {
        a11yObservers.forEach { NotificationCenter.default.removeObserver($0) }
        a11yObservers.removeAll()
    }

    private func holdForA11y() {
        guard !isHoldingForA11y else { return }
        isHoldingForA11y = true
        pauseHideTimer()
    }

    private func releaseA11yHold() {
        guard isHoldingForA11y else { return }
        isHoldingForA11y = false
        resumeHideTimer()
    }

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
        stopObservingVoiceOver()
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSubviews() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.zPosition = 100

        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        customActionsStackView.axis = .vertical
        customActionsStackView.spacing = 0
        customActionsStackView.isHidden = true
        customActionsStackView.layer.cornerRadius = 12
        customActionsStackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        customActionsStackView.clipsToBounds = true

        addSubview(contentStackView)
        contentStackView.addArrangedSubview(cardView)
        contentStackView.addArrangedSubview(customActionsStackView)
        alpha = 0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let shadowColor {
            dropShadow(shadowColor: shadowColor)
        }
    }

    private func setupConstraints() {
        contentStackView.fillSuperview()
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
    
    public func show(appWindow: UIWindow? = UIApplication.shared.windows.first, completion: (() -> Void)? = nil) {
        let window: UIWindow
        if let appWindow = appWindow {
            window = appWindow
        } else {
            let tempWindow = UIWindow(frame: UIScreen.main.bounds)
            tempWindow.makeKeyAndVisible()
            window = tempWindow
        }
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
            animations: { [weak self] in
                self?.alpha = 1
                self?.bottomConstraint?.constant = self?.showConstant ?? 0
                self?.layoutIfNeeded()
                self?.superview?.layoutIfNeeded()
            },
            completion: { [weak self] finished in
                guard let self = self else { return }
                guard finished else { return }
                self.alpha = 1
                self.startHideTimer()
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                window.bringSubviewToFront(self)
                self.startObservingVoiceOver()
                if UIAccessibility.isVoiceOverRunning {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                        guard let self else { return }
                        UIAccessibility.post(notification: .screenChanged, argument: self)
                    }
                }
                completion?()
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
                    self?.stopObservingVoiceOver()
                    self?.removeFromSuperview()
                    self?.onDismiss?()
                }
            )
        }
    }
}

extension ToastView: CommonToastOutput {
    public func display(_ toast: CommonToast) {
        switch toast {
        case .error(let toastModel):
            configureToast(toastModel, type: .error)
        case .success(let toastModel):
            configureToast(toastModel, type: .success)
        case .warning(let toastModel):
            configureToast(toastModel, type: .warning)
        case .custom(let customToast):
            configureCustomToast(customToast)
        }
    }
    
    public func hide() {
        hide(after: 0)
    }
    
    private func configureToast(_ toast: CommonToast.Toast, type: ToastType) {
        configureCustomButtons(nil, backgroundColor: nil)
        var model = toast.cardViewModel
        
        switch type {
        case .error:
            model.leadingImage = .init(
                size: .init(width: 32, height: 32),
                image: .asset(ImageFactory.systemImage(named: "xmark.circle.fill")),
            )
        case .success:
            model.leadingImage = .init(
                size: .init(width: 32, height: 32),
                image: .asset(ImageFactory.systemImage(named: "checkmark.circle.fill")),
            )
        case .warning:
            model.leadingImage = .init(
                size: .init(width: 32, height: 32),
                image: .asset(ImageFactory.systemImage(named: "exclamationmark.triangle.fill")),
            )
        }
        
        cardView.display(model: model)
        applyToastPress(toast.onPress)
        
        if let shadowColor = toast.shadowColor {
            self.shadowColor = shadowColor
        }
    }
    
    private func configureCustomToast(_ customToast: CommonToast.CustomToast) {
        var model = customToast.common.cardViewModel
        
        if let image = customToast.image {
            model.leadingImage = .init(
                size: .init(width: 32, height: 32),
                image: image
            )
        }
        
        if let backgroundColor = customToast.backgroundColor {
            model.style?.backgroundColor = backgroundColor
        }

        configureCustomButtons(
            customToast.buttons,
            backgroundColor: customToast.backgroundColor ?? model.style?.backgroundColor
        )
        
        cardView.display(model: model)
        applyToastPress(customToast.common.onPress)
        
        if let shadowColor = customToast.common.shadowColor {
            self.shadowColor = shadowColor
        }
    }

    private func applyToastPress(_ onPress: (() -> Void)?) {
        guard let onPress else { return }
        cardView.display(onPress: onPress)
        cardView.display(isUserInteractionEnabled: true)
    }

    private func configureCustomButtons(
        _ buttons: [CommonToast.CustomToast.Button]?,
        backgroundColor: Color?
    ) {
        customActionsStackView.arrangedSubviews.forEach { view in
            customActionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        customActionButtons.removeAll()

        let buttons = buttons ?? []
        customActionsStackView.isHidden = buttons.isEmpty
        guard !buttons.isEmpty else {
            customActionsStackView.backgroundColor = .clear
            return
        }

        customActionsStackView.backgroundColor = backgroundColor ?? .systemBackground

        buttons.enumerated().forEach { index, model in
            let button = Button()
            button.contentInset = CommonToastActionButtonAppearance.contentInsets.asUIEdgeInsets
            button.display(model: CommonToastActionButtonAppearance.model(for: model, index: index))
            button.contentHorizontalAlignment = .center
            customActionsStackView.addArrangedSubview(button)
            customActionButtons.append(button)
        }
    }
    
    private enum ToastType {
        case error, success, warning
    }
}

extension ToastView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

#endif
