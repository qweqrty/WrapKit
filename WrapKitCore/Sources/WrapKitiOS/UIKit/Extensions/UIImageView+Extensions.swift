//
//  UIImageView+Extensions.swift
//  WrapKit
//
//  Created by Станислав Ли on 3/9/23.
//

#if canImport(UIKit)
import UIKit
import Kingfisher

public extension UIImageView {
    func setImage(
        image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve,
        viewWhileLoading: UIView? = nil,
        fallbackView: View? = nil
    ) {
        switch image {
        case .asset(let image):
            animatedSet(image)
        case .url(let url):
            guard let url else { return }
            loadImage(url, viewWhileLoading: viewWhileLoading, fallbackView: fallbackView)
        case .urlString(let string):
            guard let string else { return }
            guard let url = URL(string: string) else { return }
            loadImage(url, viewWhileLoading: viewWhileLoading, fallbackView: fallbackView)
        case .data(let data):
            guard let data else { return }
            animatedSet(UIImage(data: data))
        case .none:
            break
        }
    }
    
    private func loadImage(_ url: URL, viewWhileLoading: UIView?, fallbackView: View?) {
        fallbackView?.removeFromSuperview()
        if let viewWhileLoading {
            addSubview(viewWhileLoading)
            viewWhileLoading.fillSuperview()
        }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self, weak viewWhileLoading, url] result in
            viewWhileLoading?.removeFromSuperview()
            switch result {
            case .success(let image):
                self?.animatedSet(image.image)
            case .failure:
                self?.addFallbackView(url, viewWhileLoading: viewWhileLoading, fallbackView: fallbackView)
            }
        }
    }
    
    private func addFallbackView(_ url: URL, viewWhileLoading: UIView?, fallbackView: View?) {
        guard let fallbackView = fallbackView else { return }
        fallbackView.removeFromSuperview()
        addSubview(fallbackView)
        fallbackView.fillSuperview()
        fallbackView.animations.insert(.shrink)
        fallbackView.onPress = { [weak self] in
            self?.loadImage(url, viewWhileLoading: viewWhileLoading, fallbackView: fallbackView)
        }
    }
    
    private func animatedSet(_ image: UIImage?) {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: { [weak self] in
                self?.image = image
            },
            completion: nil
        )
    }
}
#endif
