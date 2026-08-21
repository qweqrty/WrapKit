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

#if canImport(UIKit) && !os(watchOS)
import UIKit

public class SegmentedControl: UISegmentedControl {
    private let legacySelectionInset: CGFloat = 4
    private let legacySelectionView = UIView()

    public var appearance: SegmentedControlAppearance {
        didSet { applyAppearance() }
    }
    
    public init(
        appearance: SegmentedControlAppearance,
        items: [Any]? = nil
    ) {
        self.appearance = appearance
        super.init(items: items)
        configureLegacySelectionView()
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
            layoutLegacySelectionView()
        }
    }
    
    private func applyAppearance() {
        self.backgroundColor = appearance.colors.backgroundColor
        self.layer.cornerRadius = appearance.cornerRadius
        self.cornerRadius = appearance.cornerRadius

        if #available(iOS 26, *) {
            self.selectedSegmentTintColor = appearance.colors.selectedBackgroundColor
        } else {
            self.selectedSegmentTintColor = .clear
            legacySelectionView.backgroundColor = appearance.colors.selectedBackgroundColor
            legacySelectionView.layer.cornerRadius = max(
                0,
                appearance.cornerRadius - legacySelectionInset
            )
            setNeedsLayout()
        }

        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: appearance.colors.textColor,
            .font: appearance.font
        ]
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        self.setTitleTextAttributes(normalTextAttributes, for: .selected)
    }

    private func configureLegacySelectionView() {
        guard #unavailable(iOS 26) else { return }

        let transparentImage = UIGraphicsImageRenderer(
            size: CGSize(width: 1, height: 1)
        ).image { _ in }
        for state in [UIControl.State.normal, .selected, .highlighted] {
            setBackgroundImage(
                transparentImage,
                for: state,
                barMetrics: .default
            )
        }
        let dividerStates: [(UIControl.State, UIControl.State)] = [
            (.normal, .normal),
            (.selected, .normal),
            (.normal, .selected),
            (.selected, .selected)
        ]
        dividerStates.forEach { leftState, rightState in
            setDividerImage(
                transparentImage,
                forLeftSegmentState: leftState,
                rightSegmentState: rightState,
                barMetrics: .default
            )
        }

        legacySelectionView.isUserInteractionEnabled = false
        legacySelectionView.accessibilityElementsHidden = true
        insertSubview(legacySelectionView, at: 0)
    }

    private func layoutLegacySelectionView() {
        guard numberOfSegments > 0,
              selectedSegmentIndex >= 0,
              selectedSegmentIndex < numberOfSegments else {
            legacySelectionView.isHidden = true
            return
        }

        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        let width = segmentWidth - legacySelectionInset * 2
        let height = bounds.height - legacySelectionInset * 2
        guard width > 0, height > 0 else {
            legacySelectionView.isHidden = true
            return
        }

        legacySelectionView.isHidden = false
        legacySelectionView.frame = CGRect(
            x: CGFloat(selectedSegmentIndex) * segmentWidth + legacySelectionInset,
            y: legacySelectionInset,
            width: width,
            height: height
        )
        sendSubviewToBack(legacySelectionView)
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

        if #unavailable(iOS 26) {
            setNeedsLayout()
        }
    }
}
#endif
