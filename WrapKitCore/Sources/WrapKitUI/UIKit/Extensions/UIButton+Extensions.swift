//
//  UIButton+Extensions.swift
//  WrapKit
//
//  Created by Станислав Ли on 3/9/23.
//

#if canImport(UIKit)
import UIKit

public extension UIButton {
    func setImageWithAnimation(_ newImage: UIImage?, for state: UIControl.State, with animation: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(with: self, duration: 0.3, options: animation, animations: {
            self.setImage(newImage, for: state)
        }, completion: nil)
    }
}
#endif
