//
//  UITapGestureRecognizer+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension NSLayoutManager {
    static func didTapAttributedTextInLabel(
        point: CGPoint,
        layoutManager: NSLayoutManager,
        textStorage: NSTextStorage,
        textContainer: NSTextContainer,
        textAlignment: NSTextAlignment,
        inRange targetRange: NSRange
    ) -> Bool {
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        // Calculate offset to adjust for alignment within the label's bounds
        let textContainerOffset = CGPoint(
            x: (textContainer.size.width - textBoundingBox.size.width) * aligmentOffset(for: textAlignment) - textBoundingBox.origin.x,
            y: (textContainer.size.height - textBoundingBox.size.height) * aligmentOffset(for: textAlignment) - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: point.x - textContainerOffset.x,
            y: point.y - textContainerOffset.y
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
        guard characterIndex < textStorage.length else { return false }

        // Check if the character index falls within the target range
        return NSLocationInRange(characterIndex, targetRange)
    }
    
    private static func aligmentOffset(for textAlignment: NSTextAlignment) -> CGFloat {
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
