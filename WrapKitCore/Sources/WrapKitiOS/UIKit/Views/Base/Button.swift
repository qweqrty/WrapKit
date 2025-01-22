//
//  Button.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public struct ButtonStyle {
    public let backgroundColor: Color?
    public let titleColor: Color?
    public let borderColor: Color?
    public let pressedColor: Color?
    public let pressedTintColor: Color?
    
    public init(
        backgroundColor: Color? = nil,
        titleColor: Color? = nil,
        borderColor: Color? = nil,
        pressedColor: Color? = nil,
        pressedTintColor: Color? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.borderColor = borderColor
        self.pressedColor = pressedColor
        self.pressedTintColor = pressedTintColor
    }
}

public protocol ButtonOutput: AnyObject {
    func display(model: ButtonPresentableModel?)
    func display(spacing: CGFloat)
    func display(onPress: (() -> Void)?)
}

public struct ButtonPresentableModel {
    public let height: CGFloat?
    public let title: String?
    public let spacing: CGFloat
    public let onPress: (() -> Void)?
    public let style: ButtonStyle?
    
    public init(
        title: String?,
        spacing: CGFloat = 0,
        onPress: (() -> Void)? = nil,
        height: CGFloat? = nil,
        style: ButtonStyle? = nil
    ) {
        self.spacing = spacing
        self.onPress = onPress
        self.title = title
        self.height = height
        self.style = style
    }
}

#if canImport(UIKit)
import UIKit

public enum PressAnimation: HashableWithReflection {
    case shrink
}

open class Button: UIButton {
    var currentAnimator: UIViewPropertyAnimator?
    
    public var onPress: (() -> Void)? {
        didSet {
            removeTarget(self, action: #selector(onTap), for: .touchUpInside)
            guard onPress != nil else { return }
            addTarget(self, action: #selector(onTap), for: .touchUpInside)
        }
    }
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
    
    public var style: ButtonStyle?
    public var textColor: UIColor?
    public var textBackgroundColor: UIColor?
    public var pressedTextColor: UIColor?
    public var pressedBackgroundColor: UIColor?
    public var pressAnimations = Set<PressAnimation>()
    open var anchoredConstraints: AnchoredConstraints?
    
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
        pressedTextColor: UIColor? = nil,
        pressedBacgroundColor: UIColor? = nil,
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
        self.textColor = textColor
        self.textBackgroundColor = backgroundColor
        self.contentHorizontalAlignment = contentHorizontalAlignment
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.contentInset = contentInset
        self.isHidden = isHidden
        self.pressedTextColor = pressedTextColor
        self.pressedBackgroundColor = pressedBacgroundColor
        updateSpacings()
    }
    
    @objc private func onTap() {
        onPress?()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hasTargetActions = allTargets.contains { target in
            actions(forTarget: target, forControlEvent: .touchUpInside) != nil
        }
        if #available(iOS 14.0, *) {
            let hasMenu = menu != nil
            if !hasMenu && !hasTargetActions {
                return false
            }
            return super.point(inside: point, with: event)
        } else if !hasTargetActions {
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.pressAnimations.forEach {
                switch $0 {
                case .shrink:
                    self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                default:
                    break
                }
            }
            self?.backgroundColor = self?.pressedBackgroundColor ?? self?.textBackgroundColor
            self?.setTitleColor(self?.pressedTextColor ?? self?.textColor, for: .normal)
        }
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.backgroundColor = textBackgroundColor
        self.setTitleColor(textColor, for: .normal)
        
        super.touchesCancelled(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.backgroundColor = self?.textBackgroundColor
            self?.setTitleColor(self?.textColor, for: .normal)
        }
        super.touchesEnded(touches, with: event)
    }
}

extension Button: ButtonOutput {
    public func display(model: ButtonPresentableModel?) {
        isHidden = model == nil
        guard let spacing = model?.spacing else { return }
        self.spacing = spacing
        self.setTitle(model?.title, for: .normal)
        if let anchoredConstraints = anchoredConstraints, let height = model?.height {
            anchoredConstraints.height?.constant = height
        } else if let height = model?.height {
            anchor(.height(height))
        }
        if let style = model?.style {
            self.style = style
        }
        onPress = model?.onPress
    }
    
    public func display(title: String?) {
        self.setTitle(title, for: .normal)
    }
    
    public func display(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
    }
}
#endif
