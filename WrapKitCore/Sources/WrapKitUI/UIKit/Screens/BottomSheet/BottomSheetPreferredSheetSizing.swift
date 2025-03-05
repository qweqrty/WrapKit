#if canImport(UIKit)
import UIKit

public enum BottomSheetPreferredSheetSizing {
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
#endif
