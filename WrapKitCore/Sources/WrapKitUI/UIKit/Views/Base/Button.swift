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
    public let borderWidth: CGFloat
    public let borderColor: Color?
    public let pressedColor: Color?
    public let pressedTintColor: Color?
    public let font: Font?
    public let cornerRadius: CGFloat
    
    public init(
        backgroundColor: Color? = nil,
        titleColor: Color? = nil,
        borderWidth: CGFloat = 0,
        borderColor: Color? = nil,
        pressedColor: Color? = nil,
        pressedTintColor: Color? = nil,
        font: Font? = nil,
        cornerRadius: CGFloat = 12
    ) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.borderColor = borderColor
        self.pressedColor = pressedColor
        self.pressedTintColor = pressedTintColor
        self.font = font
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
}

public protocol ButtonOutput: AnyObject {
    func display(model: ButtonPresentableModel?)
    func display(enabled: Bool)
    func display(image: Image?)
    func display(style: ButtonStyle?)
    func display(title: String?)
    func display(spacing: CGFloat)
    func display(onPress: (() -> Void)?)
    func display(height: CGFloat)
    func display(isHidden: Bool)
}

public struct ButtonPresentableModel {
    public let height: CGFloat?
    public let title: String?
    public let image: Image?
    public let spacing: CGFloat?
    public let onPress: (() -> Void)?
    public let style: ButtonStyle?
    public let enabled: Bool?
    
    public init(
        title: String? = nil,
        image: Image? = nil,
        spacing: CGFloat? = nil,
        height: CGFloat? = nil,
        style: ButtonStyle? = nil,
        enabled: Bool? = nil,
        onPress: (() -> Void)? = nil
    ) {
        self.spacing = spacing
        self.image = image
        self.onPress = onPress
        self.title = title
        self.height = height
        self.style = style
        self.enabled = enabled
    }
}

#if canImport(UIKit)
import UIKit

extension Button: ButtonOutput {
    public func display(model: ButtonPresentableModel?) {
        isHidden = model == nil
        if let spacing = model?.spacing { display(spacing: spacing) }
        display(title: model?.title)
        display(image: model?.image)
        if let height = model?.height { display(height: height) }
        display(style: model?.style)
        display(onPress: model?.onPress)
        if let enabled = model?.enabled {
            updateAppearance(enabled: enabled)
        }
    }
    
    public func display(image: Image?) {
        setImage(image, for: .normal)
    }
    
    public func display(enabled: Bool) {
        updateAppearance(enabled: enabled)
    }
    
    public func display(height: CGFloat) {
        if let anchoredConstraints = anchoredConstraints {
            anchoredConstraints.height?.constant = height
        } else {
            anchoredConstraints = anchor(.height(height))
        }
    }
    
    public func display(style: ButtonStyle?) {
        guard let style = style else { return }
        if let textColor = style.titleColor { self.setTitleColor(textColor, for: .normal) }
        if let titleLabelFont = style.font { self.titleLabel?.font = titleLabelFont }
        self.textColor = style.titleColor
        self.textBackgroundColor = style.backgroundColor
        self.backgroundColor = style.backgroundColor
        self.pressedTextColor = style.pressedTintColor
        self.pressedBackgroundColor = style.pressedColor
        self.layer.borderColor = style.borderColor?.cgColor
        self.layer.borderWidth = style.borderWidth
        self.layer.cornerRadius = style.cornerRadius
    }
    
    public func display(title: String?) {
        self.setTitle(title?.removingPercentEncoding ?? title, for: .normal)
    }
    
    public func display(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

public enum PressAnimation: HashableWithReflection {
    case shrink
}

open class Button: UIButton {
    var currentAnimator: UIViewPropertyAnimator?
    public var currentImageEnum: ImageEnum?
    
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

    public var textColor: UIColor? {
        didSet {
            setTitleColor(textColor, for: .normal)
        }
    }
    public var textBackgroundColor: UIColor? {
        didSet {
            backgroundColor = textBackgroundColor
        }
    }
    public var pressedTextColor: UIColor?
    public var pressedBackgroundColor: UIColor?
    public var pressAnimations = Set<PressAnimation>()
    public var wrongUrlPlaceholderImage: UIImage?
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
        style: ButtonStyle,
        title: String? = nil,
        enabled: Bool = true
    ) {
        self.init(
            textColor: style.titleColor,
            backgroundColor: style.backgroundColor ?? .clear,
            pressedTextColor: style.pressedTintColor,
            pressedBacgroundColor: style.pressedColor
        )
        
        setTitle(title, for: .normal)
        cornerRadius = 12  // MARK: - TODO
        isUserInteractionEnabled = enabled
        updateAppearance(enabled: enabled)
        display(style: style)
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
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch currentImageEnum {
        case .url, .urlString:
            setImage(currentImageEnum, completion: nil)
        default:
            break
        }
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
    
    open func updateAppearance(enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
        titleLabel?.alpha = enabled ? 1.0 : 0.5
    }
}
#endif
