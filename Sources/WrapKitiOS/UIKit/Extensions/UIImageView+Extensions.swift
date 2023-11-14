//
//  UIImageView+Extensions.swift
//  WrapKit
//
//  Created by Станислав Ли on 3/9/23.
//

#if canImport(UIKit)
import UIKit

public extension UIImageView {
    func setImageWithAnimation(image: UIImage?, with animation: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { [weak image] in
            self.image = image
        },
                          completion: nil)
    }
}
#endif
