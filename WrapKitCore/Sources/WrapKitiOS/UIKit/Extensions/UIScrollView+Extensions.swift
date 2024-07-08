//
//  UIScrollView+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 14/6/24.
//

#if canImport(UIKit)
import UIKit

public extension UIScrollView {
    func scrollToView(_ view: UIView, animated: Bool) {
        guard let targetFrame = view.superview?.convert(view.frame, to: self) else {
            return
        }
        
        var offset = CGPoint(x: 0, y: targetFrame.origin.y - (self.frame.height / 2) + (targetFrame.height / 2))
        
        // Ensure the view is not scrolled out of bounds
        if targetFrame.origin.y + targetFrame.height > self.contentSize.height {
            offset.y = self.contentSize.height - self.frame.height
        } else if targetFrame.origin.y < 0 {
            offset.y = 0
        }
        
        // Ensure the view is fully visible within the scroll view
        if targetFrame.origin.y + targetFrame.height > self.bounds.height + self.contentOffset.y {
            offset.y = targetFrame.origin.y + targetFrame.height - self.bounds.height
        } else if targetFrame.origin.y < self.contentOffset.y {
            offset.y = targetFrame.origin.y
        }

        // Ensure the offset does not exceed content size bounds
        if offset.y > self.contentSize.height - self.bounds.height {
            offset.y = self.contentSize.height - self.bounds.height
        } else if offset.y < 0 {
            offset.y = 0
        }

        self.setContentOffset(offset, animated: animated)
    }
}
#endif
