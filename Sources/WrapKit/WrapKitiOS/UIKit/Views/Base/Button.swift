//
//  Button.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
import Pulsator

public enum PressAnimation: HashableWithReflection {
    case pulse(Color)
    case shrink
}

open class Button: UIButton {
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
    
    private lazy var pulsator = makePulsator()
    
    public var textColor: UIColor?
    public var textBackgroundColor: UIColor?
    public var pressedTextColor: UIColor?
    public var pressedBackgroundColor: UIColor?
    public var pressAnimations = Set<PressAnimation>()
    
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
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        layoutIfNeeded()
        pressAnimations.forEach {
            switch $0 {
            case .pulse(let color):
                pulsator.backgroundColor = color.cgColor
                pulsator.radius = max(frame.width, frame.height)
                pulsator.position = touches.first?.location(in: self) ?? .zero
                pulsator.start()
            default:
                break
            }
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.pressAnimations.forEach {
                switch $0 {
                case .shrink:
                    self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                default:
                    break
                }
            }
            self?.backgroundColor = self?.pressedBackgroundColor
            self?.setTitleColor(self?.pressedTextColor, for: .normal)
        }
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressAnimations.forEach {
            switch $0 {
            case .pulse:
                pulsator.stop()
            default:
                break
            }
        }
        
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.backgroundColor = textBackgroundColor
        self.setTitleColor(textColor, for: .normal)
        
        super.touchesCancelled(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressAnimations.forEach {
            switch $0 {
            case .pulse:
                pulsator.stop()
            default:
                break
            }
        }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.backgroundColor = self?.textBackgroundColor
            self?.setTitleColor(self?.textColor, for: .normal)
        }
        super.touchesEnded(touches, with: event)
    }
}

extension Button {
    func makePulsator() -> Pulsator {
        let pulsator = Pulsator()
        pulsator.numPulse = 3
        pulsator.keyTimeForHalfOpacity = 0.4
        layer.addSublayer(pulsator)
        return pulsator
    }
}

#endif
