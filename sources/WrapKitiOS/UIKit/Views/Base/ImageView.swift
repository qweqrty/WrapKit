//
//  ImageView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ImageView: UIImageView {
    var onPress: (() -> Void)?
    
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    public var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    public init(
        image: UIImage? = nil,
        contentMode: UIImageView.ContentMode = .scaleAspectFit,
        cornerRadius: CGFloat = 0,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0,
        tintColor: UIColor = .black,
        isHidden: Bool = false
    ) {
        super.init(image: nil)
        
        if let image = image {
            if #available(iOS 13.0, *) {
                self.image = image.withTintColor(tintColor)
            } else {
                self.image = image
            }
        }
        self.isHidden = isHidden
        self.contentMode = contentMode
        self.tintColor = tintColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private lazy var completionAnimation: ((Bool) -> Void) = { [weak self] finished in
        guard finished else { return }
        self?.isUserInteractionEnabled = true
        self?.onPress?()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onPress != nil else {
            super.touchesBegan(touches, with: event)
            return
        }
        isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 0.5
            }, completion: self.completionAnimation)
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onPress != nil else {
            super.touchesEnded(touches, with: event)
            return
        }
        isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: self.completionAnimation)
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onPress != nil else {
            super.touchesCancelled(touches, with: event)
            return
        }
        isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: self.completionAnimation)
        }
    }
}

#endif
