//
//  ImageView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ImageView: UIImageView {
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
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()
    
    lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        recognizer.minimumPressDuration = 1
        recognizer.cancelsTouchesInView = false
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
        super.init(image: nil)
        setImage(.asset(image))
        self.isHidden = isHidden
        self.contentMode = contentMode
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        self.cornerRadius = cornerRadius
    }
    
    public override init(image: UIImage?) {
        super.init(image: nil)
        setImage(.asset(image))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setImage(.asset(nil))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTap() {
        onPress?()
    }
    
    @objc private func didLongPress() {
        onLongPress?()
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
#endif
