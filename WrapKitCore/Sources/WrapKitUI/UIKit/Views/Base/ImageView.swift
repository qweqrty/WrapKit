//
//  ImageView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol ImageViewOutput: AnyObject {
    func display(model: ImageViewPresentableModel?, completion: ((Image?) -> Void)?)
    func display(image: ImageEnum?, completion: ((Image?) -> Void)?)
    func display(size: CGSize?)
    func display(onPress: (() -> Void)?)
    func display(onLongPress: (() -> Void)?)
    func display(contentModeIsFit: Bool)
    func display(borderWidth: CGFloat?)
    func display(borderColor: Color?)
    func display(cornerRadius: CGFloat?)
    func display(alpha: CGFloat?)
    func display(isHidden: Bool)
}

public extension ImageViewOutput {
    func display(model: ImageViewPresentableModel?) {
        display(model: model, completion: nil)
    }
    
    func display(image: ImageEnum?) {
        display(image: image, completion: nil)
    }
}

public struct ImageViewPresentableModel: HashableWithReflection {
    public let size: CGSize?
    public let image: ImageEnum?
    public let onPress: (() -> Void)?
    public let onLongPress: (() -> Void)?
    public let contentModeIsFit: Bool?
    public let borderWidth: CGFloat?
    public let borderColor: Color?
    public let cornerRadius: CGFloat?
    public let alpha: CGFloat?
    
    public init(
        size: CGSize? = nil,
        image: ImageEnum? = nil,
        onPress: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        contentModeIsFit: Bool? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        alpha: CGFloat? = nil
    ) {
        self.size = size
        self.image = image
        self.onPress = onPress
        self.onLongPress = onLongPress
        self.contentModeIsFit = contentModeIsFit
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.alpha = alpha
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUICore

open class ImageView: UIImageView {
    public var currentAnimator: UIViewPropertyAnimator?
    public var currentImageEnum: ImageEnum?

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
    
    public var viewWhileLoadingView: ViewUIKit? {
        didSet {
            viewWhileLoadingView?.removeFromSuperview()
            guard let viewWhileLoadingView else { return }
            addSubview(viewWhileLoadingView)
            viewWhileLoadingView.fillSuperview()
            viewWhileLoadingView.isHidden = true
        }
    }
    public var fallbackView: ViewUIKit? {
        didSet {
            fallbackView?.removeFromSuperview()
            guard let fallbackView else { return }
            addSubview(fallbackView)
            fallbackView.fillSuperview()
            fallbackView.isHidden = true
        }
    }
    
    public var wrongUrlPlaceholderImage: UIImage?
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch currentImageEnum {
        case .url(let lightUrl, let darkUrl): // changed
            if lightUrl == darkUrl {
                return
            }
            setImage(currentImageEnum)
        case .urlString(let light, let dark): // changed
            if light == dark {
                return
            }
            setImage(currentImageEnum)
        case .asset, .data:
            if #available(iOS 13.0, *), let image = self.image, image.renderingMode == .alwaysTemplate {
                setImage(.asset(self.image?.withTintColor(tintColor)))
            }
        case .none:
            break
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
    public func display(model: ImageViewPresentableModel?, completion: ((Image?) -> Void)? = nil) {
        isHidden = model == nil
        display(onPress: model?.onPress)
        display(onLongPress: model?.onLongPress)
        hideShimmer()
        if let image = model?.image { display(image: image, completion: completion) }
        if let size = model?.size {
            display(size: size)
        }
        
        switch model?.image {
        case .asset(let image) where model?.size == nil:
            display(size: image?.size)
        default:
            break
        }
        if let contentModeIsFit = model?.contentModeIsFit { display(contentModeIsFit: contentModeIsFit) }
        
        if let borderColor = model?.borderColor {
            display(borderColor: borderColor)
        }
        if let borderWidth = model?.borderWidth {
            display(borderWidth: borderWidth)
        }
        
        if let cornerRadius = model?.cornerRadius {
            display(cornerRadius: cornerRadius)
        }
        if let alpha = model?.alpha {
            display(alpha: alpha)
        }
    }
    
    public func display(size: CGSize?) {
        if let size = size {
            if let anchoredConstraints = anchoredConstraints {
                    anchoredConstraints.height?.constant = size.height
                    anchoredConstraints.width?.constant = size.width
            } else {
                anchoredConstraints = anchor(
                    .height(size.height, priority: .required),
                    .width(size.width, priority: .required)
                )
            }
        }
    }
    
    public func display(borderColor: UIColor?) {
        self.layer.borderColor = borderColor?.cgColor
    }
    
    public func display(borderWidth: CGFloat?) {
        guard let borderWidth else { return }
        self.layer.borderWidth = borderWidth
    }
    
    public func display(cornerRadius: CGFloat?) {
        guard let cornerRadius else { return }
        self.cornerRadius = cornerRadius
        self.layer.cornerRadius = cornerRadius
    }
    
    public func display(image: ImageEnum?, completion: ((Image?) -> Void)?) {
        self.setImage(image, closure: completion)
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
    
    public func display(alpha: CGFloat?) {
        guard let alpha else { return }
        self.alpha = alpha
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}
#endif
