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
        DispatchQueue.main.async { [weak self] in
            self?.layer.masksToBounds = false
            self?.layer.shadowColor = shadowColor.cgColor
            self?.layer.shadowOpacity = shadowOpacity
            self?.layer.shadowOffset = shadowOffset
            self?.layer.shadowRadius = shadowRadius
            
            self?.layer.shadowPath = path ?? UIBezierPath(rect: self?.bounds ?? .zero).cgPath
            self?.layer.shouldRasterize = false
            self?.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
        
    }
    
    func gradientBackgroundColor(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = .init(x: 0.5, y: 0),
        endPoint: CGPoint = .init(x: 0.5, y: 1)
    ) {
        // Remove any existing gradient layers
        layer.sublayers?.removeAll(where: { $0.name == UIView.CAGradientLayerName })

        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = UIView.CAGradientLayerName
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint

        // Create a shape layer for the border
        let maskLayer = CAShapeLayer()
        let roundedRectPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        maskLayer.path = roundedRectPath.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = width
        gradientLayer.mask = maskLayer
        
        // Apply corner radius to the view itself
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        // Add the gradient layer
        layer.addSublayer(gradientLayer)
    }
    
    func showLoadingView(_ loadingView: UIView? = nil, backgroundColor: UIColor = .clear, contentInset: UIEdgeInsets = .zero, size: CGSize? = nil) {
        UIView.performWithoutAnimation {
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
            loadingContainerView.layoutIfNeeded()
        }
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
        let bgColor = shimmerView == nil ? .clear : (firstNonClearBackgroundColor ?? .clear)
        let emptyView = UIView(backgroundColor: bgColor)
        let shimmerContent = shimmerView ?? ShimmerView(backgroundColor: .clear)
        shimmerContent.startShimmering()
        
        emptyView.tag = Self.shimmerViewTag
        addSubview(emptyView)
        emptyView.fillSuperview()
        
        emptyView.addSubview(shimmerContent)
        
        shimmerContent.alpha = 0
        shimmerContent.cornerRadius = shimmerView?.cornerRadius ?? 4
        
        if let heightMultiplier, let widthMultiplier {
            shimmerContent.anchor(
                .leading(leadingAnchor),
                .centerY(centerYAnchor),
                .widthTo(widthAnchor, widthMultiplier),
                .heightTo(heightAnchor, heightMultiplier)
            )
        }
        
        if let heightMultiplier, widthMultiplier == nil {
            shimmerContent.anchor(
                .leading(leadingAnchor),
                .trailing(trailingAnchor, constant: 12),
                .centerY(centerYAnchor),
                .heightTo(heightAnchor, heightMultiplier)
            )
        }
        
        if let widthMultiplier, heightMultiplier == nil {
            shimmerContent.anchor(
                .leading(leadingAnchor),
                .centerY(centerYAnchor),
                .widthTo(widthAnchor, widthMultiplier)
            )
        }
        
        if heightMultiplier == nil && widthMultiplier == nil {
            shimmerContent.fillSuperview()
        }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                shimmerContent.alpha = 1
            }, completion: { finished in
                guard finished else { return }
                shimmerContent.alpha = 1
            })
    }
    
    func hideShimmer() {
        guard let shimmerContent = viewWithTag(Self.shimmerViewTag) else { return }
        shimmerContent.removeFromSuperview()
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
    
    /// Returns an array of all subviews recursively, including nested ones.
    var allSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.allSubviews }
    }
    
    /// Adds a tap gesture recognizer to dismiss the keyboard when tapping anywhere on the view.
    func addTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
}
#endif
