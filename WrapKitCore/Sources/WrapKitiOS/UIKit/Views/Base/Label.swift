//
//  Label.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class Label: UILabel {
   
    public init(
        backgroundColor: UIColor? = .clear,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = false,
        font: UIFont? = nil,
        textColor: UIColor = .darkText,
        textAlignment: NSTextAlignment = .natural,
        numberOfLines: Int = 0,
        minimumScaleFactor: CGFloat = 0,
        adjustsFontSizeToFitWidth: Bool = false,
        isUserInteractionEnabled: Bool = true
    ) {
        super.init(frame: .zero)

        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        if let font = font { self.font = font }
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.textAlignment = textAlignment
        self.minimumScaleFactor = minimumScaleFactor
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.isHidden = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = .systemFont(ofSize: 20)
        self.numberOfLines = 0
        self.minimumScaleFactor = 0
        self.adjustsFontSizeToFitWidth = false
        self.isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        gesture.name = String(describing: TextAttributes.self)
        return gesture
    }()
    
    public override var intrinsicContentSize: CGSize {
        if text == nil || text!.isEmpty {
            return CGSize(width: super.intrinsicContentSize.width, height: 0)
        } else {
            return super.intrinsicContentSize
        }
    }
    
    public override var text: String? {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private var attributes: [TextAttributes] = [] {
        didSet {
            guard !attributes.isEmpty else {
                attributedText = nil
                return
            }
            
            let combinedAttributedString = NSMutableAttributedString()
            
            for (index, (prev, current, _)) in attributes.withPreviousAndNext.enumerated() {
                combinedAttributedString.append(
                    NSAttributedString(
                        current.text,
                        font: current.font ?? font,
                        color: current.color ?? textColor,
                        lineSpacing: 4,
                        underlineStyle: current.underlineStyle ?? [],
                        textAlignment: current.textAlignment ?? textAlignment,
                        leadingImage: current.leadingImage,
                        leadingImageBounds: current.leadingImageBounds,
                        trailingImage: current.trailingImage,
                        trailingImageBounds: current.trailingImageBounds
                    )
                )
                let prevRange = prev?.range ?? .init(location: 0, length: 0)
                attributes[index].range = NSRange(location: prevRange.location + prevRange.length, length: current.text.count)
            }
            attributedText = combinedAttributedString
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Ensure we have valid attributed text and attributes
        guard let attributedText = attributedText, !attributes.isEmpty else {
            return super.hitTest(point, with: event)
        }

        // Create layout-related objects for accurate text hit-testing
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure text container for the label's layout
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.size = bounds.size

        // Calculate the location of the touch in the label
        let locationOfTouchInLabel = point
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (bounds.width - textBoundingBox.width) * aligmentOffset() - textBoundingBox.origin.x,
            y: (bounds.height - textBoundingBox.height) * aligmentOffset() - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )

        // Check if the touch is within the text bounding box
        guard textBoundingBox.contains(locationOfTouchInTextContainer) else {
            return super.hitTest(point, with: event) // Outside of text bounding box
        }

        // Determine the character index at the touch point
        let characterIndex = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        // Find the matching attribute for the touched range
        for attribute in attributes {
            guard let range = attribute.range else { continue }
            if NSLocationInRange(characterIndex, range) {
                return self // Return self to handle the tap
            }
        }

        return super.hitTest(point, with: event)
    }
    
    private func aligmentOffset() -> CGFloat {
        switch textAlignment {
        case .left, .natural, .justified:
            return 0.0
        case .center:
            return 0.5
        case .right:
            return 1.0
        @unknown default:
            return 0.0
        }
    }
    
    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        guard let attributedText = attributedText else { return }

        for attribute in attributes {
            guard let range = attribute.range else { continue }
            if gesture.didTapAttributedTextInLabel(label: self, textAlignment: attribute.textAlignment ?? textAlignment, inRange: range) {
                attribute.onTap?()
                return
             }
        }
    }

}

public extension Label {
    @discardableResult
    func append(_ attributedTexts: TextAttributes...) -> Self {
        attributedTexts.forEach { attribute in
            self.attributes.append(attribute)
        }
        return self
    }
    
    func removeAttributes() {
        self.attributes.removeAll()
        self.attributedText = nil
    }
}
#endif
