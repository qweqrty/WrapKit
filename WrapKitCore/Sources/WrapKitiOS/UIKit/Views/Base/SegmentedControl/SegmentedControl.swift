import Foundation

public struct SegmentedControlAppearance {
    public init(
        colors: Colors,
        font: Font,
        border: Border,
        cornerRadius: CGFloat
    ) {
        self.colors = colors
        self.font = font
        self.border = border
        self.cornerRadius = cornerRadius
    }
    
    public struct Colors {
        public init(
            textColor: Color,
            selectedBorderColor: Color,
            borderColor: Color,
            backgroundColor: Color,
            selectedBackgroundColor: Color
        ) {
            self.textColor = textColor
            self.selectedBorderColor = selectedBorderColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.borderColor = borderColor
            self.backgroundColor = backgroundColor
        }
        
        public var textColor: Color
        public var selectedBorderColor: Color
        public var selectedBackgroundColor: Color
        public var borderColor: Color
        public var backgroundColor: Color
    }
    
    public struct Border {
        public init(idleBorderWidth: CGFloat, selectedBorderWidth: CGFloat) {
            self.idleBorderWidth = idleBorderWidth
            self.selectedBorderWidth = selectedBorderWidth
        }
        
        public var idleBorderWidth: CGFloat
        public var selectedBorderWidth: CGFloat
    }
    
    public var colors: Colors
    public var font: Font
    public var border: Border
    public var cornerRadius: CGFloat
}

#if canImport(UIKit)
import UIKit

public class SegmentedControl: UISegmentedControl {
    public var appearance: SegmentedControlAppearance {
        didSet { applyAppearance() }
    }
    
    public init(
        appearance: SegmentedControlAppearance,
        items: [Any]? = nil
    ) {
        self.appearance = appearance
        super.init(items: items)
        applyAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyAppearance() {
        self.backgroundColor = appearance.colors.backgroundColor
        self.layer.borderColor = appearance.colors.borderColor.cgColor
        self.layer.borderWidth = appearance.border.idleBorderWidth
        self.layer.cornerRadius = appearance.cornerRadius
        self.cornerRadius = appearance.cornerRadius
        self.selectedSegmentTintColor = appearance.colors.selectedBackgroundColor
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: appearance.colors.textColor,
            .font: appearance.font
        ]
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: appearance.colors.selectedBorderColor,
            .font: appearance.font
        ]
        self.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        if self.selectedSegmentIndex != UISegmentedControl.noSegment {
            self.layer.borderWidth = appearance.border.selectedBorderWidth
        }
    }
}
#endif
