//
//  View.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class View: UIView {
    public enum Animation: HashableWithReflection {
        case gradientBorder([Color])
    }
    
    public var animations: Set<Animation> = [] { didSet { applyAnimations() } }
    private lazy var gradientBorderLayer = makeGradientBorderLayer()

    private func applyAnimations() {
        animations.forEach {
            switch $0 {
            case .gradientBorder(let colors):
                startGradientBorderAnimation(with: colors)
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        gradientBorderLayer.frame = bounds
        (gradientBorderLayer.mask as? CAShapeLayer)?.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: CGFloat(cornerRadius)
        ).cgPath
    }

    // Gesture and interaction handling
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

    @objc private func didTap() {
        onPress?()
    }

    @objc private func didLongPress() {
        onLongPress?()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        self.alpha = 0.5
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
}
// Animation: Gradient border
extension View {
    private func startGradientBorderAnimation(with colors: [UIColor]) {
        guard gradientBorderLayer.superlayer == nil else { return }
        gradientBorderLayer.colors = colors.map { $0.cgColor }
        gradientBorderLayer.locations = (0..<colors.count).map {
            NSNumber(value: Double($0) / Double(colors.count))
        }
        gradientBorderLayer.cornerRadius = cornerRadius
        layer.addSublayer(gradientBorderLayer)

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        gradientBorderLayer.add(animation, forKey: "gradientBorderAnimation")
        setNeedsLayout()
    }

    private func stopGradientBorderAnimation() {
        gradientBorderLayer.removeAnimation(forKey: "gradientBorderAnimation")
        gradientBorderLayer.removeFromSuperlayer()
    }
    
    func makeGradientBorderLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .conic
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        let shape = CAShapeLayer()
        shape.lineWidth = 4.0
        shape.strokeColor = UIColor.clear.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        return gradient
    }
}
#endif
