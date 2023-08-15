//
//  Button.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

// MARK: image.leading = superview.leading
open class Button: UIButton {
    @objc private func didSelect() { onPress?() }
    
    public var onPress: (() -> Void)?
    public var spacing: CGFloat = 0 {
        didSet {
            contentEdgeInsets.right = contentEdgeInsets.right + spacing
            titleEdgeInsets.right = titleEdgeInsets.right - spacing
        }
    }
    
    public override var contentEdgeInsets: UIEdgeInsets {
        get { return super.contentEdgeInsets }
        set {
            var newValue = newValue
            newValue.right = newValue.right + spacing
            super.contentEdgeInsets = newValue
        }
    }
    
    public override var titleEdgeInsets: UIEdgeInsets {
        get {
            return super.titleEdgeInsets
        }
        set {
            var newValue = newValue
            newValue.right = newValue.right - spacing
            super.titleEdgeInsets = newValue
        }
    }
    
    public convenience init(
        image: UIImage? = nil,
        tintColor: UIColor? = nil,
        textColor: UIColor? = nil,
        titleLabelFont: UIFont? = nil,
        backgroundColor: UIColor = .clear,
        contentInset: UIEdgeInsets = .zero,
        spacing: CGFloat = 0,
        isHidden: Bool = false,
        isUserInteractionEnabled: Bool = true,
        lineBreakingMode: NSLineBreakMode = .byTruncatingTail,
        type: UIButton.ButtonType = .system
    ) {
        self.init(type: type)
        addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        if let image = image { setImage(image, for: .normal) }
        if let tintColor = tintColor { self.tintColor = tintColor }
        if let textColor = textColor { self.setTitleColor(textColor, for: .normal) }
        if let titleLabelFont = titleLabelFont { self.titleLabel?.font = titleLabelFont }
        
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.contentEdgeInsets = .init(top: contentInset.top, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right + spacing)
        self.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: titleEdgeInsets.right - spacing)
        self.isHidden = isHidden
        
    }
}
#endif
