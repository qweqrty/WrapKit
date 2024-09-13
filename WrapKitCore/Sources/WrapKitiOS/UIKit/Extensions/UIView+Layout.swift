//
//  UIView+Layout.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

public struct AnchoredConstraints {
    public var heightGreaterThanConstant,
               heightLessThanConstant,
               widthGreaterThanConstant,
               widthLessThanConstant,
               widthTo,
               heightTo,
               widthLessThanOrEqualTo,
               heightToWidth,
               centerY,
               centerX,
               top,
               topLessThanEqual,
               topGreaterThanEqual,
               leading,
               bottom,
               trailing,
               width,
               height: NSLayoutConstraint?
}

@available(iOS 11.0, tvOS 11.0, *)
public enum Anchor {
    case top(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case topLessThanEqual(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case topGreaterThanEqual(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case centerY(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case heightToWidth(_ multiplier: CGFloat, priority: UILayoutPriority = .required)
    case heightGreaterThanConstant(_ constant: CGFloat = 0)
    case heightLessThanConstant(_ constant: CGFloat = 0)
    case widthGreaterThanConstant(_ constant: CGFloat = 0)
    case heightTo(_ anchor: NSLayoutDimension, _ multiplier: CGFloat = 1, priority: UILayoutPriority = .required)
    case widthLessThanOrEqualTo(_ anchor: NSLayoutDimension, multiplier: CGFloat = 1, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case widthTo(_ anchor: NSLayoutDimension, _ multiplier: CGFloat = 1, priority: UILayoutPriority = .required)
    case centerX(_ top: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case leading(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case leadingGreaterThanEqual(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case leadingLessThanEqual(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case bottom(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case bottomGreaterThanEqual(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case bottomLessThanEqual(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case trailing(_ trailing: NSLayoutXAxisAnchor, constant: CGFloat = 0, priority: UILayoutPriority = .required)
    case trailingGreaterThanEqual(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case trailingLessThanEqual(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case height(_ constant: CGFloat, priority: UILayoutPriority = .required)
    case width(_ constant: CGFloat, priority: UILayoutPriority = .required)
    case widthLessThanConstant(_ constant: CGFloat)
}

// Reference Video: https://youtu.be/iqpAP7s3b-8
@available(iOS 11.0, tvOS 11.0, *)
public extension UIView {
    convenience init(backgroundColor: UIColor = .clear, cornerRadius: CGFloat = 0) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func wrappedInView(padding: UIEdgeInsets = .zero) -> View {
        let view = View()
        view.addSubview(self)
        fillSuperview(padding: padding)
        return view
    }
    
    func wrapped(in view: UIView, padding: UIEdgeInsets = .zero) -> UIView {
        view.addSubview(self)
        fillSuperview(padding: padding)
        return view
    }
    
    func centeredInView(width: CGFloat? = nil, height: CGFloat? = nil) -> View {
        if let width { self.constrainWidth(width) }
        if let height { self.constrainHeight(height) }
        let view = View()
        view.addSubviews(self)
        anchor(
            .topGreaterThanEqual(view.topAnchor),
            .leadingGreaterThanEqual(view.leadingAnchor),
            .bottomLessThanEqual(view.bottomAnchor),
            .trailingLessThanEqual(view.trailingAnchor),
            .centerX(view.centerXAnchor),
            .centerY(view.centerYAnchor)
        )
        return view
    }
    
    @discardableResult
    func nextTo(_ yAxisAnchor: NSLayoutYAxisAnchor, insets: UIEdgeInsets = .zero, isLast: Bool = false) -> AnchoredConstraints {
        var anchoredConstraints = AnchoredConstraints()
        guard let superview = superview else { return anchoredConstraints }
        translatesAutoresizingMaskIntoConstraints = false
        anchoredConstraints = anchor(
            .top(yAxisAnchor, constant: insets.top),
            .leading(superview.leadingAnchor, constant: insets.left),
            .trailing(superview.trailingAnchor, constant: insets.right)
        )
        if isLast {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
            anchoredConstraints.bottom?.isActive = true
        }
        return anchoredConstraints
    }
    
    @discardableResult
    func anchor(anchors: [Anchor]) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchors.forEach { anchor in
            switch anchor {
            case .widthLessThanConstant(let constant):
                anchoredConstraints.widthLessThanConstant = widthAnchor.constraint(lessThanOrEqualToConstant: constant)
            case .heightGreaterThanConstant(let constant):
                anchoredConstraints.heightGreaterThanConstant = heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
            case .heightLessThanConstant(let constant):
                anchoredConstraints.heightLessThanConstant = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
            case .widthGreaterThanConstant(let constant):
                anchoredConstraints.widthGreaterThanConstant = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
            case .centerX(let anchor, let constant):
                anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: anchor, constant: constant)
            case .centerY(let anchor, let constant, let priority):
                anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: anchor, constant: constant)
                anchoredConstraints.centerY?.priority = priority
            case .top(let anchor, let constant, let priority):
                anchoredConstraints.top = topAnchor.constraint(equalTo: anchor, constant: constant)
                anchoredConstraints.top?.priority = priority
            case .topLessThanEqual(let anchor, let constant, let priority):
                anchoredConstraints.topLessThanEqual = topAnchor.constraint(lessThanOrEqualTo: anchor, constant: constant)
                anchoredConstraints.topLessThanEqual?.priority = priority
            case .topGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.topGreaterThanEqual = topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
            case .leading(let anchor, let constant, let priority):
                anchoredConstraints.leading = leadingAnchor.constraint(equalTo: anchor, constant: constant)
                anchoredConstraints.leading?.priority = priority
            case .leadingGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
            case .leadingLessThanEqual(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(lessThanOrEqualTo: anchor, constant: constant)
            case .bottom(let anchor, let constant, let priority):
                anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: anchor, constant: -constant)
                anchoredConstraints.bottom?.priority = priority
            case .bottomGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -constant)
            case .bottomLessThanEqual(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: -constant)
            case .trailing(let anchor, let constant, let priority):
                anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: anchor, constant: -constant)
                anchoredConstraints.trailing?.priority = priority
            case .trailingGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -constant)
            case .trailingLessThanEqual(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(lessThanOrEqualTo: anchor, constant: -constant)
            case .height(let constant, let priority):
                anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
                anchoredConstraints.height?.priority = priority
            case .widthLessThanOrEqualTo(let anchor, let multiplier, let constant, let priority):
                anchoredConstraints.widthLessThanOrEqualTo = widthAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
                anchoredConstraints.widthLessThanOrEqualTo?.priority = priority
            case .width(let constant, let priority):
                anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
                anchoredConstraints.width?.priority = priority
            case .heightToWidth(let multiplier, let priority):
                if multiplier > 0 {
                    anchoredConstraints.heightToWidth = heightAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier)
                    anchoredConstraints.heightToWidth?.priority = priority
                }
            case .heightTo(let anchor, let multiplier, let priority):
                if multiplier > 0 {
                    anchoredConstraints.heightTo = heightAnchor.constraint(equalTo: anchor, multiplier: multiplier)
                    anchoredConstraints.heightTo?.priority = priority
                }
            case .widthTo(let anchor, let multiplier, let priority):
                if multiplier > 0 {
                    anchoredConstraints.widthTo = widthAnchor.constraint(equalTo: anchor, multiplier: multiplier)
                    anchoredConstraints.widthTo?.priority = priority
                }
            }
        }
        [
            anchoredConstraints.centerY,
            anchoredConstraints.centerX,
            anchoredConstraints.top,
            anchoredConstraints.widthLessThanConstant,
            anchoredConstraints.topLessThanEqual,
            anchoredConstraints.topGreaterThanEqual,
            anchoredConstraints.widthGreaterThanConstant,
            anchoredConstraints.leading,
            anchoredConstraints.heightTo,
            anchoredConstraints.heightLessThanConstant,
            anchoredConstraints.widthLessThanOrEqualTo,
            anchoredConstraints.heightGreaterThanConstant,
            anchoredConstraints.bottom,
            anchoredConstraints.trailing,
            anchoredConstraints.width,
            anchoredConstraints.height,
            anchoredConstraints.widthTo,
            anchoredConstraints.heightToWidth
        ].forEach {
            $0?.isActive = true
        }
        return anchoredConstraints
    }
    
    @discardableResult
    func anchor(_ anchors: Anchor...) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchors.forEach { anchor in
            switch anchor {
            case .widthLessThanConstant(let constant):
                anchoredConstraints.widthLessThanConstant = widthAnchor.constraint(lessThanOrEqualToConstant: constant)
            case .heightGreaterThanConstant(let constant):
                anchoredConstraints.heightGreaterThanConstant = heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
            case .heightLessThanConstant(let constant):
                anchoredConstraints.heightLessThanConstant = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
            case .widthGreaterThanConstant(let constant):
                anchoredConstraints.widthGreaterThanConstant = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
            case .centerX(let anchor, let constant):
                anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: anchor, constant: constant)
            case .centerY(let anchor, let constant, let priority):
                anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: anchor, constant: constant)
                anchoredConstraints.centerY?.priority = priority
            case .top(let anchor, let constant, let priority):
                anchoredConstraints.top = topAnchor.constraint(equalTo: anchor, constant: constant)
                anchoredConstraints.top?.priority = priority
            case .topLessThanEqual(let anchor, let constant, let priority):
                anchoredConstraints.topLessThanEqual = topAnchor.constraint(lessThanOrEqualTo: anchor, constant: constant)
                anchoredConstraints.topLessThanEqual?.priority = priority
            case .topGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.topGreaterThanEqual = topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
            case .leading(let anchor, let constant, let priority):
                anchoredConstraints.leading = leadingAnchor.constraint(equalTo: anchor, constant: constant)
                anchoredConstraints.leading?.priority = priority
            case .leadingGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: constant)
            case .leadingLessThanEqual(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(lessThanOrEqualTo: anchor, constant: constant)
            case .bottom(let anchor, let constant, let priority):
                anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: anchor, constant: -constant)
                anchoredConstraints.bottom?.priority = priority
            case .bottomGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -constant)
            case .bottomLessThanEqual(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: -constant)
            case .trailing(let anchor, let constant, let priority):
                anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: anchor, constant: -constant)
                anchoredConstraints.trailing?.priority = priority
            case .trailingGreaterThanEqual(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -constant)
            case .trailingLessThanEqual(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(lessThanOrEqualTo: anchor, constant: -constant)
            case .height(let constant, let priority):
                anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
                anchoredConstraints.height?.priority = priority
            case .widthLessThanOrEqualTo(let anchor, let multiplier, let constant, let priority):
                anchoredConstraints.widthLessThanOrEqualTo = widthAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
                anchoredConstraints.widthLessThanOrEqualTo?.priority = priority
            case .width(let constant, let priority):
                anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
                anchoredConstraints.width?.priority = priority
            case .heightToWidth(let multiplier, let priority):
                if multiplier > 0 {
                    anchoredConstraints.heightToWidth = heightAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier)
                    anchoredConstraints.heightToWidth?.priority = priority
                }
            case .heightTo(let anchor, let multiplier, let priority):
                if multiplier > 0 {
                    anchoredConstraints.heightTo = heightAnchor.constraint(equalTo: anchor, multiplier: multiplier)
                    anchoredConstraints.heightTo?.priority = priority
                }
            case .widthTo(let anchor, let multiplier, let priority):
                if multiplier > 0 {
                    anchoredConstraints.widthTo = widthAnchor.constraint(equalTo: anchor, multiplier: multiplier)
                    anchoredConstraints.widthTo?.priority = priority
                }
            }
        }
        [
            anchoredConstraints.centerY,
            anchoredConstraints.centerX,
            anchoredConstraints.top,
            anchoredConstraints.widthLessThanConstant,
            anchoredConstraints.topLessThanEqual,
            anchoredConstraints.topGreaterThanEqual,
            anchoredConstraints.widthGreaterThanConstant,
            anchoredConstraints.leading,
            anchoredConstraints.heightTo,
            anchoredConstraints.heightLessThanConstant,
            anchoredConstraints.widthLessThanOrEqualTo,
            anchoredConstraints.heightGreaterThanConstant,
            anchoredConstraints.bottom,
            anchoredConstraints.trailing,
            anchoredConstraints.width,
            anchoredConstraints.height,
            anchoredConstraints.widthTo,
            anchoredConstraints.heightToWidth
        ].forEach {
            $0?.isActive = true
        }
        return anchoredConstraints
    }
    
    @discardableResult
    func anchor(
        top: NSLayoutYAxisAnchor?,
        leading: NSLayoutXAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        trailing: NSLayoutXAxisAnchor?,
        padding: UIEdgeInsets = .zero,
        size: CGSize = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [
            anchoredConstraints.top,
            anchoredConstraints.leading,
            anchoredConstraints.bottom,
            anchoredConstraints.trailing,
            anchoredConstraints.width,
            anchoredConstraints.height
        ].forEach { $0?.isActive = true }
        
        return anchoredConstraints
    }
    
    @discardableResult
    func fillSuperview(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewTopAnchor = superview?.topAnchor,
              let superviewBottomAnchor = superview?.bottomAnchor,
              let superviewLeadingAnchor = superview?.leadingAnchor,
              let superviewTrailingAnchor = superview?.trailingAnchor else {
            return anchoredConstraints
        }
        
        return anchor(
            top: superviewTopAnchor,
            leading: superviewLeadingAnchor,
            bottom: superviewBottomAnchor,
            trailing: superviewTrailingAnchor,
            padding: padding
        )
    }
    
    @discardableResult
    func fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewTopAnchor = superview?.safeAreaLayoutGuide.topAnchor,
              let superviewBottomAnchor = superview?.safeAreaLayoutGuide.bottomAnchor,
              let superviewLeadingAnchor = superview?.safeAreaLayoutGuide.leadingAnchor,
              let superviewTrailingAnchor = superview?.safeAreaLayoutGuide.trailingAnchor else {
            return anchoredConstraints
        }
        return anchor(
            top: superviewTopAnchor,
            leading: superviewLeadingAnchor,
            bottom: superviewBottomAnchor,
            trailing: superviewTrailingAnchor,
            padding: padding
        )
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(greaterThanOrEqualTo: superviewTopAnchor).isActive = true
        }
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(lessThanOrEqualTo: superviewBottomAnchor).isActive = true
        }
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(greaterThanOrEqualTo: superviewLeadingAnchor).isActive = true
        }
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(lessThanOrEqualTo: superviewTrailingAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerXTo(_ anchor: NSLayoutXAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func centerYTo(_ anchor: NSLayoutYAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func centerXToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
    }
    
    func centerYToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
    }
    
    @discardableResult
    func constrainHeight(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.height?.isActive = true
        return anchoredConstraints
    }
    
    @discardableResult
    func constrainWidth(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.width?.isActive = true
        return anchoredConstraints
    }
}
#endif
