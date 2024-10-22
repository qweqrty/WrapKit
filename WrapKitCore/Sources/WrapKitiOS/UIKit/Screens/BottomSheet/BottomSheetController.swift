#if canImport(UIKit)
import UIKit

open class BottomSheetController<View: UIView>: ViewController<View> {
    public enum PreferredSheetSizing {
        case fit // Fit, based on the view's constraints
        case small
        case medium
        case large
        case fill
        case custom(value: CGFloat)
        
        /// В .custom нужно указать процент высоты боттом щита относительно высоты экрана. Можете записать в дробном виде 0.3, или в виде числа
        /// 30 (это будет эквивалентно 30%).
        public var size: CGFloat {
            switch self {
            case .fit:
                return 0
            case .small:
                return 0.25
            case .medium:
                return 0.5
            case .large:
                return 0.85
            case .fill:
                return 1
            case .custom(let value):
                return validateCustomSize(value)
            }
        }
        
        private func validateCustomSize(_ value: CGFloat) -> CGFloat {
            guard value >= 0 else {
                return 0
            }
            
            guard value <= 100 else {
                return 1
            }
            
            guard value <= 1 else {
                return value / 100
            }
            
            return value
        }
    }

    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
        preferredSheetTopInset: preferredSheetTopInset,
        preferredSheetLeftInset: preferredSheetLeftInset,
        preferredSheetRightInset: preferredSheetRightInset,
        preferredSheetBottomInset: preferredSheetBottomInset,
        preferredSheetCornerRadius: preferredSheetCornerRadius,
        preferredSheetSizingFactor: preferredSheetSizing.size,
        preferredSheetBackdropColor: preferredSheetBackdropColor
    )
    
    open func animateBottomSheet(from y1: CGFloat, to y2: CGFloat) {
        UIView.animateKeyframes(withDuration: 0.8, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                self.view.frame = CGRect(x: 0, y: y1,
                                         width: self.view.frame.width, height: self.view.frame.height)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                self.view.frame = CGRect(x: 0, y: y2,
                                         width: self.view.frame.width, height: self.view.frame.height)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
                self.view.frame = CGRect(x: 0, y: y1,
                                         width: self.view.frame.width, height: self.view.frame.height)
            }
        }
    }
    
    open override var additionalSafeAreaInsets: UIEdgeInsets {
        get {
            .init(
                top: super.additionalSafeAreaInsets.top + preferredSheetCornerRadius,
                left: super.additionalSafeAreaInsets.left,
                bottom: super.additionalSafeAreaInsets.bottom,
                right: super.additionalSafeAreaInsets.right
            )
        }
        set {
            super.additionalSafeAreaInsets = newValue
        }
    }
    
    open override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            .custom
        }
        set { }
    }
    
    open override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            bottomSheetTransitioningDelegate
        }
        set { }
    }
    
    open func setPreferredSizeInsets(top: CGFloat = 24, left: CGFloat = 0,
                                     bottom: CGFloat = 0, right: CGFloat = 0, radius: CGFloat = 12) {
        bottomSheetTransitioningDelegate.preferredSheetBottomInset = bottom
        bottomSheetTransitioningDelegate.preferredSheetTopInset = top
        bottomSheetTransitioningDelegate.preferredSheetLeftInset = left
        bottomSheetTransitioningDelegate.preferredSheetRightInset = right
        bottomSheetTransitioningDelegate.preferredSheetCornerRadius = radius
    }
    
    open var preferredSheetTopInset: CGFloat = 24 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetTopInset = preferredSheetTopInset
        }
    }
    
    open var preferredSheetLeftInset: CGFloat = 0 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetLeftInset = preferredSheetLeftInset
        }
    }
    
    open var preferredSheetRightInset: CGFloat = 0 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetRightInset = preferredSheetRightInset
        }
    }
    
    open var preferredSheetBottomInset: CGFloat = 0 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBottomInset = preferredSheetBottomInset
        }
    }
    
    open var preferredSheetCornerRadius: CGFloat = 12 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }
    
    open var preferredSheetSizing: PreferredSheetSizing = .fit {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.size
        }
    }
    
    open var preferredSheetBackdropColor: UIColor = .label {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackdropColor = preferredSheetBackdropColor
        }
    }
    
    open  var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapToDismissEnabled = tapToDismissEnabled
        }
    }
    
    open var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.panToDismissEnabled = panToDismissEnabled
        }
    }
}

#endif
