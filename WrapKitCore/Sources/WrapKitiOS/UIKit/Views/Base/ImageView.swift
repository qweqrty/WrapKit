//
//  ImageView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol ImageViewOutput: AnyObject {
    func display(model: ImageViewPresentableModel?)
    func display(image: ImageEnum?)
    func display(size: CGSize?)
    func display(onPress: (() -> Void)?)
    func display(onLongPress: (() -> Void)?)
    func display(contentModeIsFit: Bool)
}

public struct ImageViewPresentableModel: HashableWithReflection {
    public let size: CGSize?
    public let image: ImageEnum?
    public let onPress: (() -> Void)?
    public let onLongPress: (() -> Void)?
    public let contentModeIsFit: Bool?
    
    public init(
        size: CGSize? = nil,
        image: ImageEnum? = nil,
        onPress: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        contentModeIsFit: Bool? = nil
    ) {
        self.size = size
        self.image = image
        self.onPress = onPress
        self.onLongPress = onLongPress
        self.contentModeIsFit = contentModeIsFit
    }
}

#if canImport(UIKit)
import UIKit

open class ImageView: UIImageView {
    public var currentAnimator: UIViewPropertyAnimator?

    open override var image: UIImage? {
        get {
            super.image
        }
        set {
            if newValue == nil {
                cancelCurrentAnimation()
                super.image = nil
            } else {
                super.image = newValue
            }
        }
    }
    
    open var anchoredConstraints: AnchoredConstraints?
    
    
    public func cancelCurrentAnimation() {
        currentAnimator?.stopAnimation(true) // Stop the animation and leave the view in its current state
        currentAnimator = nil
    }
    
    public var onPress: (() -> Void)? {
        didSet {
            removeGestureRecognizer(tapGestureRecognizer)
            guard onPress != nil else { return }
            addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    public var onLongPress: (() -> Void)? {
        didSet {
            removeGestureRecognizer(longPressRecognizer)
            guard onLongPress != nil else { return }
            addGestureRecognizer(longPressRecognizer)
        }
    }
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        recognizer.minimumPressDuration = 1
        return recognizer
    }()
    
    public override var tintColor: UIColor! {
        didSet {
            if let image = self.image {
                if #available(iOS 13.0, *) {
                    self.setImage(.asset(image.withTintColor(tintColor)))
                }
                super.tintColor = tintColor
            }
        }
    }
    
    public var viewWhileLoadingView: View? {
        didSet {
            viewWhileLoadingView?.removeFromSuperview()
            guard let viewWhileLoadingView else { return }
            addSubview(viewWhileLoadingView)
            viewWhileLoadingView.fillSuperview()
            viewWhileLoadingView.isHidden = true
        }
    }
    public var fallbackView: View? {
        didSet {
            fallbackView?.removeFromSuperview()
            guard let fallbackView else { return }
            addSubview(fallbackView)
            fallbackView.fillSuperview()
            fallbackView.isHidden = true
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *), let image = self.image, image.renderingMode == .alwaysTemplate {
            setImage(.asset(self.image?.withTintColor(tintColor)))
        }
    }
    
    public init(
        image: UIImage? = nil,
        contentMode: UIImageView.ContentMode = .scaleAspectFit,
        cornerRadius: CGFloat = 0,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0,
        tintColor: UIColor? = nil,
        isHidden: Bool = false
    ) {
        super.init(image: image)
        self.isHidden = isHidden
        self.contentMode = contentMode
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        self.cornerRadius = cornerRadius
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTap() {
        onPress?()
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress?()
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        layoutIfNeeded()
        super.touchesBegan(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        self.alpha = 0.5
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        super.touchesEnded(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
            self.alpha = 1.0
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        super.touchesCancelled(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
            self.alpha = 1.0
        }
    }
}

extension ImageView: ImageViewOutput {
    public func display(model: ImageViewPresentableModel?) {
        isHidden = model == nil
        display(onPress: model?.onPress)
        display(onLongPress: model?.onLongPress)
        if let image = model?.image { display(image: image) }
        if let size = model?.size {
            display(size: size)
        } else if let size = image?.size {
            display(size: size)
        }
        if let contentModeIsFit = model?.contentModeIsFit { display(contentModeIsFit: contentModeIsFit) }
    }
    
    public func display(size: CGSize?) {
        if let size = size {
            if let anchoredConstraints = anchoredConstraints {
                    anchoredConstraints.height?.constant = size.height
                    anchoredConstraints.width?.constant = size.width
            } else {
                anchoredConstraints = anchor(
                    .height(size.height, priority: .defaultHigh),
                    .width(size.width, priority: .defaultHigh)
                )
            }
        }
    }
    
    public func display(image: ImageEnum?) {
        self.setImage(image)
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(onLongPress: (() -> Void)?) {
        self.onLongPress = onLongPress
    }
    
    public func display(contentModeIsFit: Bool) {
        self.contentMode = contentModeIsFit == true ? .scaleAspectFit : .scaleAspectFill
    }
}
#endif
