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

public struct SegmentControlModel {
    public var title: String
    public var index: Int
    public var onTap: ((Int) -> Void)?
    public let accessibilityIdentifier: String?
    
    public init(
        accessibilityIdentifer: String? = nil,
        title: String,
        index: Int,
        onTap: ((Int) -> Void)? = nil
    ) {
        self.title = title
        self.index = index
        self.onTap = onTap
        self.accessibilityIdentifier = accessibilityIdentifer
    }
}

public protocol SegmentedControlOutput: AnyObject {
    func display(appearence: SegmentedControlAppearance)
    func display(segments: [SegmentControlModel])
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = appearance.cornerRadius
        layer.masksToBounds = true
        
        if #unavailable(iOS 26) {
            guard numberOfSegments < subviews.count,
                  let selectedSegment = subviews[numberOfSegments] as? UIImageView,
                  selectedSegmentIndex != UISegmentedControl.noSegment else { return }

            let inset: CGFloat = 4
            let segmentWidth = bounds.width / CGFloat(numberOfSegments)
            let xOffset = CGFloat(selectedSegmentIndex) * segmentWidth

            selectedSegment.image = nil
            selectedSegment.backgroundColor = selectedSegmentTintColor
            selectedSegment.layer.removeAnimation(forKey: "SelectionBounds")
            selectedSegment.layer.cornerRadius = appearance.cornerRadius - inset
            selectedSegment.frame = CGRect(
                x: xOffset + inset,
                y: inset,
                width: segmentWidth - inset * 2,
                height: bounds.height - inset * 2
            )
        }
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

extension SegmentedControl: SegmentedControlOutput {
    public func display(appearence: SegmentedControlAppearance) {
        self.appearance = appearence
    }
    
    public func display(segments: [SegmentControlModel]) {
        self.removeAllSegments()
        for (index, item) in segments.enumerated() {
            let action = UIAction(title: item.title) { _ in
                item.onTap?(index)
            }
            action.accessibilityIdentifier = item.accessibilityIdentifier
            self.insertSegment(action: action, at: index, animated: false)
        }
        self.selectedSegmentIndex = 0
    }
}
#endif
