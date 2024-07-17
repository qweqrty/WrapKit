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
        view.bottomSeparatorView.isHidden = true
        return view
    }()
    public let duration: TimeInterval
    public private(set) var cardViewConstraints: AnchoredConstraints?
    public var leadingConstraint: NSLayoutConstraint?
    
    static let tag = 228
    
    public enum Position {
        case top
        case middle
        case bottom(additionalBottomPadding: CGFloat = 0)
    }
    
    public init(duration: TimeInterval = 3.0) {
        self.duration = duration
        super.init(frame: .zero)
        self.tag = Self.tag
        setupSubviews()
        setupConstraints()
        setSwipe()
        setTapGesture()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        addSubview(cardView)
    }
    
    private func setupConstraints() {
        cardViewConstraints = cardView.fillSuperview(padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    public func removePastToastIfNeeded(from view: UIView) {
        view.viewWithTag(Self.tag)?.removeFromSuperview()
    }
    
    private func setSwipe() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwiped))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
    }
    
    private func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func didTap(gesture: UITapGestureRecognizer) {
        guard let toastSuperView = superview else { return }
        hide(after: 0, for: toastSuperView)
    }
    
    @objc
    private func didSwiped(gesture: UISwipeGestureRecognizer) {
        guard let toastSuperView = superview else { return }
        
        if gesture.direction == .right {
            hide(after: 0, for: toastSuperView)
        }
    }
    
    public func setPosition(on view: UIView, position: Position) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        switch position {
        case .top:
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        case .middle:
            centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        case .bottom(let additionalBottomPadding):
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15 - additionalBottomPadding).isActive = true
        }
        
        leadingConstraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIScreen.main.bounds.width)
        leadingConstraint?.isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        view.layoutIfNeeded()
    }
    
    public func animate(constant: CGFloat, inside view: UIView, completion: @escaping (Bool) -> Void) {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.leadingConstraint?.constant = constant
                view.layoutIfNeeded()
            },
            completion: completion
        )
    }
    
    public func hide(after duration: Double, for view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.animate(constant: UIScreen.main.bounds.width, inside: view) { finished in
                guard finished else { return }
                self.removeFromSuperview()
            }
        }
    }
}
#endif
