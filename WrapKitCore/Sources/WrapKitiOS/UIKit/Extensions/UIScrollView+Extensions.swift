//
//  UIScrollView+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 14/6/24.
//

import UIKit

public extension UIScrollView {
    func scrollToView(_ view: UIView, animated: Bool) {
        guard let targetFrame = view.superview?.convert(view.frame, to: self) else {
            return
        }

        var offset = CGPoint(x: 0, y: targetFrame.origin.y)
        
        if targetFrame.origin.y + targetFrame.size.height > self.contentSize.height {
            offset.y = self.contentSize.height - targetFrame.size.height
        } else if targetFrame.origin.y < 0 {
            offset.y = 0
        }

        if targetFrame.origin.y + targetFrame.size.height > self.bounds.size.height + self.contentOffset.y {
            offset.y = targetFrame.origin.y + targetFrame.size.height - self.bounds.size.height
        } else if targetFrame.origin.y < self.contentOffset.y {
            offset.y = targetFrame.origin.y
        }

        self.setContentOffset(offset, animated: animated)
    }
}
