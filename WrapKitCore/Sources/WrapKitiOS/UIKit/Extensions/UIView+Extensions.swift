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
    
    convenience init(isHidden: Bool) {
        self.init()
        
        self.isHidden = isHidden
    }
    
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
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = backgroundColor?.cgColor
        
        if let oldLayer = self.layer.sublayers?.first(where: { $0 is CAShapeLayer && $0 != mask }) {
            oldLayer.removeFromSuperlayer()
        }
        
        self.layer.insertSublayer(backgroundLayer, at: 0)
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
    
    func updateSemanticAttributes(isRTL: Bool) {
        semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        
        subviews.forEach { subview in
            subview.updateSemanticAttributes(isRTL: isRTL)
            if let stackView = subview as? UIStackView {
                stackView.arrangedSubviews.forEach { arrangedSubview in
                    arrangedSubview.updateSemanticAttributes(isRTL: isRTL)
                }
            }
        }
    }
    
    func dropShadow(
        path: CGPath? = nil,
        shadowColor: UIColor,
        shadowOpacity: Float = 0.07,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowRadius: CGFloat = 4,
        scale: Bool = true,
        shouldRasterize: Bool = false
    ) {
        DispatchQueue.main.async {
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
            
            self.layer.shadowPath = path ?? UIBezierPath(rect: self.bounds).cgPath
            self.layer.shouldRasterize = false
            self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
        
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
    
    func showLoadingView(_ loadingView: UIView? = nil, backgroundColor: UIColor = .clear, contentInset: UIEdgeInsets = .zero, size: CGSize? = nil) {
        if let previousLoadingContainerView = viewWithTag(345635463546) {
            previousLoadingContainerView.removeFromSuperview()
        }
        let loadingContainerView: UIView = {
            let view = UIView(backgroundColor: backgroundColor)
            view.tag = 345635463546
            addSubview(view)
            view.layer.cornerRadius = layer.cornerRadius
            view.fillSuperview()
            return view
        }()
        clipsToBounds = true
        let loadingView = loadingView ?? makeDefaultLoadingView()
        loadingContainerView.addSubview(loadingView)
        loadingView.anchor(
            .centerX(loadingContainerView.centerXAnchor, constant: contentInset.left - contentInset.right),
            .centerY(loadingContainerView.centerYAnchor, constant: contentInset.top - contentInset.bottom)
        )
        if let size = size {
            loadingView.constrainHeight(size.height)
            loadingView.constrainWidth(size.width)
        }
        isUserInteractionEnabled = false
    }
    
    func hideLoadingView() {
        guard let loadingContainerView = viewWithTag(345635463546) else { return }
        isUserInteractionEnabled = true
        loadingContainerView.removeFromSuperview()
    }
    
    private func makeDefaultLoadingView() -> UIView {
        let loadingView: UIActivityIndicatorView = {
            if #available(iOS 13.0, *) {
                let view = UIActivityIndicatorView(style: .medium)
                return view
            } else {
                let view = UIActivityIndicatorView(style: .white)
                return view
            }
        }()
        loadingView.startAnimating()
        return loadingView
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
    
    static let shimmerViewTag = 647364
    
    func showShimmer(
        _ shimmerView: ShimmerView? = nil,
        heightMultiplier: CGFloat? = nil,
        widthMultiplier: CGFloat? = nil
    ) {
        let bgColor = shimmerView == nil ? firstNonClearBackgroundColor ?? .clear : .clear
        let emptyView = UIView(backgroundColor: bgColor)
        let shimmerView = shimmerView ?? ShimmerView(backgroundColor: .clear, cornerRadius: 8)
        shimmerView.startShimmering()
        
        emptyView.tag = Self.shimmerViewTag
        addSubview(emptyView)
        emptyView.fillSuperview()
        
        emptyView.addSubview(shimmerView)
        
        shimmerView.alpha = 0
        
        if let heightMultiplier, let widthMultiplier {
            shimmerView.cornerRadius = 4
            shimmerView.anchor(
                .leading(leadingAnchor),
                .centerY(centerYAnchor),
                .widthTo(widthAnchor, widthMultiplier),
                .heightTo(heightAnchor, heightMultiplier)
            )
        }
        
        if let heightMultiplier, widthMultiplier == nil {
            shimmerView.cornerRadius = 4
            shimmerView.anchor(
                .leading(leadingAnchor),
                .trailing(trailingAnchor, constant: 12),
                .centerY(centerYAnchor),
                .heightTo(heightAnchor, heightMultiplier)
            )
        }
        
        if let widthMultiplier, heightMultiplier == nil {
            shimmerView.cornerRadius = 4
            shimmerView.anchor(
                .leading(leadingAnchor),
                .centerY(centerYAnchor),
                .widthTo(widthAnchor, widthMultiplier)
            )
        }
        
        if heightMultiplier == nil && widthMultiplier == nil {
            shimmerView.fillSuperview()
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
            shimmerView.alpha = 1
        }, completion: nil)
    }
    
    
    func hideShimmer() {
        guard let shimmerView = viewWithTag(Self.shimmerViewTag) else { return }
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
            shimmerView.alpha = 0
        }, completion: { _ in
            shimmerView.removeFromSuperview()
        })
    }
    
    var firstNonClearBackgroundColor: UIColor? {
        var currentView: UIView? = self
        while let view = currentView {
            if let bgColor = view.backgroundColor, bgColor != .clear {
                return bgColor
            }
            currentView = view.superview
        }
        return nil
    }
}
#endif
