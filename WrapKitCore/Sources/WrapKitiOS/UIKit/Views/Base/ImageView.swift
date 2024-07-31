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
            isUserInteractionEnabled = onPress != nil
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            if let image = self.image {
                if #available(iOS 13.0, *) {
                    self.image = image.withTintColor(tintColor)
                }
                super.tintColor = tintColor
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *), let image = self.image, image.renderingMode == .alwaysTemplate {
            self.image = self.image?.withTintColor(tintColor)
        }
    }
    
    public init(
        image: UIImage? = nil,
        contentMode: UIImageView.ContentMode = .scaleAspectFit,
        cornerRadius: CGFloat = 0,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0,
        tintColor: UIColor? = nil,
        isHidden: Bool = false,
        isUserInteractionEnabled: Bool = false
    ) {
        super.init(image: nil)
        
        if let image = image {
            self.image = image
        }
        self.isHidden = isHidden
        self.contentMode = contentMode
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        self.cornerRadius = cornerRadius
        self.isUserInteractionEnabled = isUserInteractionEnabled
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap() {
        onPress?()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard onPress != nil else { return }
        self.alpha = 0.5
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }
}
#endif
