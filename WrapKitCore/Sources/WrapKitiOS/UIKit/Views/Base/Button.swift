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
    public var onPress: (() -> Void)?
    public var spacing: CGFloat = 0 {
        didSet {
            updateSpacings()
        }
    }
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            updateSpacings()
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.3, delay: .leastNonzeroMagnitude, options: .allowUserInteraction) {
                    self.alpha = 0.7
                }
                onPress?()
            } else {
                UIView.animate(withDuration: 0.3, delay: .leastNonzeroMagnitude, options: .allowUserInteraction) {
                    self.alpha = 1.0
                }
            }
        }
    }
    
    private func updateSpacings() {
        let isRTL = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .rightToLeft
        if isRTL {
            contentEdgeInsets = .init(top: contentInset.top, left: contentInset.left + spacing * 2, bottom: contentInset.bottom, right: contentInset.right)
            titleEdgeInsets = .init(top: 0, left: -spacing, bottom: 0, right: spacing)
        } else {
            contentEdgeInsets = .init(top: contentInset.top, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right + spacing * 2)
            titleEdgeInsets = .init(top: 0, left: spacing, bottom: 0, right: -spacing)
        }
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            updateSpacings()
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
        contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .center,
        isHidden: Bool = false,
        isUserInteractionEnabled: Bool = true,
        lineBreakingMode: NSLineBreakMode = .byTruncatingTail,
        type: UIButton.ButtonType = .system
    ) {
        self.init(type: type)
        if let tintColor = tintColor { self.tintColor = tintColor }
        if let image = image { setImage(image, for: .normal) }
        if let textColor = textColor { self.setTitleColor(textColor, for: .normal) }
        if let titleLabelFont = titleLabelFont { self.titleLabel?.font = titleLabelFont }
        
        self.contentHorizontalAlignment = contentHorizontalAlignment
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.contentInset = contentInset
        self.isHidden = isHidden
        updateSpacings()
    }
}
#endif
