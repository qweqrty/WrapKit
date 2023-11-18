//
//  StackVIew.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class StackView: UIStackView {
    public init(
        backgroundColor: UIColor = .clear,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 0,
        contentInset: UIEdgeInsets = .zero,
        isHidden: Bool = false
    ) {
        super.init(frame: .zero)
        self.distribution = distribution
        self.isHidden = isHidden
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.layoutMargins = contentInset
        self.isLayoutMarginsRelativeArrangement = true
        self.isUserInteractionEnabled = true
        // there's no need to add subview to set background color in the first place if it's .clear
        if backgroundColor != .clear {
            self.backgroundColor = backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.isLayoutMarginsRelativeArrangement = true
        self.distribution = .fill
        self.alignment = .fill
        self.axis = .horizontal
        self.spacing = 0
        self.layoutMargins = .zero
        self.isHidden = false
    }
    
    override public var backgroundColor: UIColor? {
        didSet {
            let subView = UIView(frame: .zero)
            subView.backgroundColor = backgroundColor
            subView.fillSuperview()
        }
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
