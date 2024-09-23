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
        stopGradientBorderAnimation()
        animations.forEach {
            switch $0 {
            case .gradientBorder(let colors):
                startGradientBorderAnimation(with: colors)
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        animations.forEach {
            switch $0 {
            case .gradientBorder:
                gradientBorderLayer.frame = CGRect(
                    origin: CGPoint.zero,
                    size: CGSize(
                        width: frame.width,
                        height: frame.height
                    )
                )
                (gradientBorderLayer.mask as? CAShapeLayer)?.path = UIBezierPath(
                    roundedRect: CGRect(
                        x: 0,
                        y: 0,
                        width: frame.width,
                        height: frame.height
                    ),
                    cornerRadius: cornerRadius
                ).cgPath
            }
        }
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
    
    public init(
        backgroundColor: UIColor? = nil,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = true
    ) {
        super.init(frame: .zero)
        
        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
extension View: CAAnimationDelegate {
    private func startGradientBorderAnimation(with colors: [UIColor]) {
        guard gradientBorderLayer.superlayer == nil else { return }
        gradientBorderLayer.locations = (0..<colors.count).map {
            NSNumber(value: Double($0) / Double(colors.count))
        }
        gradientBorderLayer.colors = colors
        gradientBorderLayer.cornerRadius = cornerRadius
        layer.addSublayer(gradientBorderLayer)
        updateGradientBorderAnimation()
    }
    
    private func updateGradientBorderAnimation() {
        gradientBorderLayer.removeAnimation(forKey: "gradientBorderAnimation")
        
        guard let previousColors = gradientBorderLayer.colors else { return }
        guard var newColors = gradientBorderLayer.colors else { return }
        let lastColor = newColors.removeLast()
        newColors.insert(lastColor, at: 0)
        gradientBorderLayer.colors = newColors
        
        let colorsAnimation = CABasicAnimation(keyPath: "colors")
        colorsAnimation.fromValue = previousColors.map { ($0 as? UIColor)?.cgColor }
        colorsAnimation.toValue = newColors.map { ($0 as? UIColor)?.cgColor }
        colorsAnimation.repeatCount = 1
        colorsAnimation.duration = 0.3
        colorsAnimation.isRemovedOnCompletion = false
        colorsAnimation.fillMode = .both
        colorsAnimation.delegate = self
        
        gradientBorderLayer.add(colorsAnimation, forKey: "gradientBorderAnimation")
    }

    private func stopGradientBorderAnimation() {
        gradientBorderLayer.removeAnimation(forKey: "gradientBorderAnimation")
        gradientBorderLayer.removeFromSuperlayer()
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        updateGradientBorderAnimation()
    }
    
    func makeGradientBorderLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .conic
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        let shape = CAShapeLayer()
        shape.lineWidth = 4.0
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        return gradient
    }
}

#endif
