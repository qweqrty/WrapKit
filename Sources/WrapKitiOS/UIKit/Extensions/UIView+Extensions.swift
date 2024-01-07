//
//  UIView+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension UIView {
    static let CAGradientLayerName = "GradientBorderLayer"
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func shake(count: Float? = nil, for duration: TimeInterval? = nil, withTranslation translation: Float? = nil) {
        let defaultRepeatCount: Float = 2.0
        let defaultTotalDuration = 0.15
        let defaultTranslation = -10
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        animation.repeatCount = count ?? defaultRepeatCount
        animation.duration = (duration ?? defaultTotalDuration) / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? defaultTranslation
        layer.add(animation, forKey: "shake")
    }
    
    func dropShadow(
        shadowColor: UIColor,
        shadowOpacity: Float = 0.07,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowRadius: CGFloat = 4,
        scale: Bool = true,
        shouldRasterize: Bool = false
    ) {
        layer.masksToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func gradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = .init(x: 0.5, y: 0),
        endPoint: CGPoint = .init(x: 0.5, y: 1),
        cornerRadius: CGFloat = 0
    ) {
        // Remove any existing gradient layers
        layer.sublayers?.removeAll(where: { $0.name == UIView.CAGradientLayerName })
        // Gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = UIView.CAGradientLayerName
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: width / 2, dy: width / 2), cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    func showLoadingView(backgroundColor: UIColor) {
        let loadingContainerView: UIView = {
            let view = UIView(backgroundColor: backgroundColor)
            view.tag = 345635463546
            addSubview(view)
            view.layer.cornerRadius = layer.cornerRadius
            view.fillSuperview()
            return view
        }()
        clipsToBounds = true
        let loadingView: UIActivityIndicatorView = {
            if #available(iOS 13.0, *) {
                let view = UIActivityIndicatorView(style: .medium)
                loadingContainerView.addSubview(view)
                view.centerInSuperview()
                return view
            } else {
                let view = UIActivityIndicatorView(style: .white)
                loadingContainerView.addSubview(view)
                view.centerInSuperview()
                return view
            }
        }()
        isUserInteractionEnabled = false
        loadingView.startAnimating()
    }
    
    func hideLoadingView() {
        guard let loadingContainerView = viewWithTag(345635463546) else { return }
        isUserInteractionEnabled = true
        loadingContainerView.removeFromSuperview()
    }
    
    static func performAnimationsInSequence(_ animations: [(TimeInterval, () -> Void, ((Bool) -> Void)?)], completion: ((Bool) -> Void)? = nil) {
        guard !animations.isEmpty else {
            completion?(true)
            return
        }
        
        var animations = animations
        let animation = animations.removeFirst()
        
        UIView.animate(withDuration: animation.0, animations: {
            animation.1()
        }, completion: { finished in
            animation.2?(finished)
            UIView.performAnimationsInSequence(animations, completion: completion)
        })
    }
    
}
#endif
