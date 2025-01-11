//
//  UIButton+Extensions.swift
//  WrapKit
//
//  Created by Станислав Ли on 3/9/23.
//

#if canImport(UIKit)
import UIKit
import Kingfisher

public extension UIButton {
    func setImageWithAnimation(_ newImage: UIImage?, for state: UIControl.State, with animation: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(with: self, duration: 0.3, options: animation, animations: {
            self.setImage(newImage, for: state)
        }, completion: nil)
    }
    
    func setImage(_ imageEnum: ImageEnum) {
        switch imageEnum {
        case .asset(let image):
            self.setImage(image, for: .normal)
        case .data(let data):
            guard let data = data else { return }
            self.setImage(UIImage(data: data), for: .normal)
        case .url(let url):
            guard let url = url else { return }
            KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
                switch result {
                case .success(let image):
                    self?.setImage(image.image, for: .normal)
                case .failure(let error):
                    return
                }
            }
        case .urlString(let string):
            guard let string else { return }
            guard let url = URL(string: string) else { return }
            KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
                switch result {
                case .success(let image):
                    self?.setImage(image.image, for: .normal)
                case .failure(let error):
                    return
                }
            }
        }
    }
}
#endif
