//
//  UIImageView+Extensions.swift
//  WrapKit
//
//  Created by Станислав Ли on 3/9/23.
//

#if canImport(UIKit)
import UIKit

public extension UIImageView {
    func setImage(
        image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve,
        viewWhileLoading: UIView?
    ) {
        if let viewWhileLoading {
            addSubview(viewWhileLoading)
            viewWhileLoading.fillSuperview()
        }
        switch image {
        case .asset(let image):
            UIView.transition(with: self,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                self?.image = image
            },
                              completion: nil)
        case .url(let string):
            kf.setImage(with: URL(string: string)) { [weak viewWhileLoading] result in
                viewWhileLoading?.removeFromSuperview()
            }
        default:
            break
        }
    }
}
#endif
