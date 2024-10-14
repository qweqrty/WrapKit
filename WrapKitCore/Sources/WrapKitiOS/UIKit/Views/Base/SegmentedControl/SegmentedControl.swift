import Foundation

public struct SegmentedControlAppearance {
    public init(
        colors: Colors,
        font: Font,
        cornerRadius: CGFloat
    ) {
        self.colors = colors
        self.font = font
        self.cornerRadius = cornerRadius
    }
    
    public struct Colors {
        public init(
            textColor: Color,
            backgroundColor: Color,
            selectedBackgroundColor: Color
        ) {
            self.textColor = textColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.backgroundColor = backgroundColor
        }
        
        public var textColor: Color
        public var selectedBackgroundColor: Color
        public var backgroundColor: Color
    }
    
    public var colors: Colors
    public var font: Font
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
        self.layer.cornerRadius = appearance.cornerRadius
        self.cornerRadius = appearance.cornerRadius
        self.selectedSegmentTintColor = appearance.colors.selectedBackgroundColor
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: appearance.colors.textColor,
            .font: appearance.font
        ]
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
    }
}
#endif
