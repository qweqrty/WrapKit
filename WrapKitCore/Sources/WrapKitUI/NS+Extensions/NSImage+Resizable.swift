//
//  NSImage+Resizable.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 6/11/25.
//

#if canImport(UIKit)
import UIKit

public extension UIImage {
    func resized(rect: CGRect, container: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: container).image { _ in
            draw(in: rect)
        }
        .withRenderingModePreservingAccessibilityIdentifier(renderingMode)
    }
    
    func withRenderingModePreservingAccessibilityIdentifier(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        let identifier = self.accessibilityIdentifier
        let image = withRenderingMode(renderingMode)
        image.accessibilityIdentifier = identifier
        return image
    }
}

#endif

#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
import Cocoa
// temporarily public
extension NSImage {
    /// Resizes the NSImage to the specified size.
    /// - Parameter rect: The desired size for the resized image.
    /// - Returns: A new NSImage instance with the resized image, or nil if the original image data is unavailable.

    func resized(rect: CGRect, container: CGSize) -> NSImage {
        let newImage = NSImage(size: container)
        newImage.lockFocus()

        // Get the current graphics context
        guard let context = NSGraphicsContext.current else {
            newImage.unlockFocus()
            return self
        }

        // Set interpolation quality for smoother scaling
        context.imageInterpolation = .high

        // Apply the offset by adjusting the targetRect for the drawing
        let adjustedRect = NSRect(
            x: rect.origin.x,
            y: container.height - rect.origin.y - rect.height, // Adjust y-axis for the flipped coordinate system
            width: rect.width,
            height: rect.height
        )
        self.draw(in: adjustedRect)

        newImage.unlockFocus()
        return newImage
    }
}
#endif
