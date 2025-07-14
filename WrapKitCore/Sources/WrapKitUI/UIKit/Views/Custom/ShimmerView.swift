//
//  ShimmerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/11/23.
//

public struct ShimmerStyle {
    var backgroundColor: Color
    var gradientColorOne: Color
    var gradientColorTwo: Color
    var cornerRadius: Float
    
    public init(
        backgroundColor: Color,
        gradientColorOne: Color,
        gradientColorTwo: Color,
        cornerRadius: Float
    ) {
        self.backgroundColor = backgroundColor
        self.gradientColorOne = gradientColorOne
        self.gradientColorTwo = gradientColorTwo
        self.cornerRadius = cornerRadius
    }
}

#if canImport(UIKit)
import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var shimmerView = "shimmerView"
    }
    
    private var shimmerView: ShimmerView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shimmerView) as? ShimmerView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shimmerView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class ShimmerView: UIView {
    
    open var style: ShimmerStyle? {
        didSet {
            guard let style else { return }
            backgroundColor = style.backgroundColor
            gradientColorOne = style.gradientColorOne
            gradientColorTwo = style.gradientColorTwo
            cornerRadius = style.cornerRadius
        }
    }
    open var gradientColorOne: UIColor = .clear {
        didSet {
            setupGradientLayer()
        }
    }
    open var gradientColorTwo: UIColor = UIColor(white: 0.95, alpha: 0.6) {
        didSet {
            setupGradientLayer()
        }
    }
    private let gradientLayer = CAGradientLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
        layer.addSublayer(gradientLayer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
        layer.addSublayer(gradientLayer)
    }

    private func setupGradientLayer() {
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.colors = [
            gradientColorOne.cgColor,
            gradientColorTwo.cgColor,
            gradientColorOne.cgColor
        ]

        gradientLayer.locations = [0.0, 0.5, 1.0]
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    open func startShimmering(withDelay delay: TimeInterval = 2.8) {
        let animation = CAKeyframeAnimation(keyPath: "locations")

        animation.values = [
            [-1.0, -0.5, 0.0],
            [1.0, 1.5, 2.0],
            [1.0, 1.5, 2.0]
        ]

        let endAnimationTime = 1.4 / (1.4 + delay)
        animation.keyTimes = [
            0.0,
            NSNumber(value: endAnimationTime),
            1.0
        ]

        animation.duration = 1.4 + delay
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards

        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    open func stopShimmering() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}

#endif
