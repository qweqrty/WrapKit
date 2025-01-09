//
//  UITapGestureRecognizer+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, textAlignment: NSTextAlignment, inRange targetRange: NSRange) -> Bool {
        // Ensure the label has attributed text
        guard let attributedText = label.attributedText else { return false }

        // Create layout-related objects
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure the text container
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Calculate the location of the touch within the label
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        // Calculate offset to adjust for alignment within the label's bounds
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * aligmentOffset(for: textAlignment) - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * aligmentOffset(for: textAlignment) - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )

        // Ensure the touch is within the text bounding box
        guard layoutManager.glyphIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceThroughGlyph: nil) < layoutManager.numberOfGlyphs else {
            return false
        }

        // Determine the character index at the touch point
        let characterIndex = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        // Ensure the character index is within the attributed text range
        guard characterIndex < attributedText.length else {
            return false
        }

        // Check if the character index falls within the target range
        return NSLocationInRange(characterIndex, targetRange)
    }
    
    private func aligmentOffset(for textAlignment: NSTextAlignment) -> CGFloat {
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
}

#endif
