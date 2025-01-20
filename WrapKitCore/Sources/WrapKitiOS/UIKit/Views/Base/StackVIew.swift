//
//  StackVIew.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol StackViewOutput: AnyObject {
    func display(model: StackViewPresentableModel)
}

public enum StackViewAxis: HashableWithReflection {
    case vertical
    case horizontal
}

public enum StackViewDistribution: HashableWithReflection {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing
    case equalCentering
}

public enum StackViewAlignment: HashableWithReflection {
    case fill
    case leading
    case top
    case firstBaseline
    case center
    case trailing
    case bottom
    case lastBaseline
}

public struct StackViewPresentableModel {
    public let axis: StackViewAxis?
    public let distribution: StackViewDistribution?
    public let alignment: StackViewAlignment?
    
    public init(
        axis: StackViewAxis? = nil,
        distribution: StackViewDistribution? = nil,
        alignment: StackViewAlignment? = nil
    ) {
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
    }
}

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
        clipToBounds: Bool = false,
        isHidden: Bool = false
    ) {
        super.init(frame: .zero)
        self.distribution = distribution
        self.isHidden = isHidden
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.clipsToBounds = clipToBounds
        self.layoutMargins = contentInset
        self.isLayoutMarginsRelativeArrangement = true
        self.isUserInteractionEnabled = true
        self.insetsLayoutMarginsFromSafeArea = false
        // there's no need to add subview to set background color in the first place if it's .clear
        if backgroundColor != .clear {
            self.backgroundColor = backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.isLayoutMarginsRelativeArrangement = true
        self.insetsLayoutMarginsFromSafeArea = false
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

extension StackView: StackViewOutput {
    public func display(model: StackViewPresentableModel) {
        self.distribution = mapDistribution(model.distribution)
        self.axis = mapAxis(model.axis)
        self.alignment = mapAlignment(model.alignment)
    }
    
    private func mapDistribution(_ distribution: StackViewDistribution?) -> UIStackView.Distribution {
        switch distribution {
        case .fill:
            return .fill
        case .fillEqually:
            return .fillEqually
        case .fillProportionally:
            return .fillProportionally
        case .equalSpacing:
            return .equalSpacing
        case .equalCentering:
            return .equalCentering
        case .none:
            return .fill
        }
    }
    
    private func mapAxis(_ axis: StackViewAxis?) -> NSLayoutConstraint.Axis {
        switch axis {
        case .vertical:
            return .vertical
        case .horizontal:
            return .horizontal
        case nil:
            return .horizontal
        }
    }
    
    private func mapAlignment(_ alignment: StackViewAlignment?) -> UIStackView.Alignment {
        switch alignment {
        case .fill:
            return .fill
        case .leading:
            return .leading
        case .top:
            return .top
        case .firstBaseline:
            return .firstBaseline
        case .center:
            return .center
        case .trailing:
            return .trailing
        case .bottom:
            return .bottom
        case .lastBaseline:
            return .lastBaseline
        case nil:
            return .fill
        }
    }
}
#endif
