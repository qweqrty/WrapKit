#if canImport(UIKit)
import UIKit
import Kingfisher

public extension ImageView {
    func setImage(
        _ image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve,
        kingfisherOptions: KingfisherOptionsInfo = []
    ) {
        switch image {
        case .asset(let image):
            animatedSet(image)
        case .url(let url):
            guard let url else { return }
            loadImage(url, kingfisherOptions: kingfisherOptions)
        case .urlString(let string):
            guard let string else { return }
            guard let url = URL(string: string) else { return }
            loadImage(url, kingfisherOptions: kingfisherOptions)
        case .data(let data):
            guard let data else { return }
            animatedSet(UIImage(data: data))
        case .none:
            break
        }
    }
    
    private func loadImage(_ url: URL, kingfisherOptions: KingfisherOptionsInfo) {
        if let fallbackView {
            fallbackView.isHidden = true
        }
        viewWhileLoadingView?.isHidden = false
        KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions) { [weak self, weak viewWhileLoadingView, url] result in
            viewWhileLoadingView?.isHidden = true

            switch result {
            case .success(let image):
                self?.animatedSet(image.image)
            case .failure:
                self?.showFallbackView(url)
            }
        }
    }
    
    private func showFallbackView(_ url: URL, kingfisherOptions: KingfisherOptionsInfo = []) {
        guard let fallbackView else { return }
        fallbackView.isHidden = false
        fallbackView.animations.insert(.shrink)
        fallbackView.onPress = { [weak self] in
            self?.loadImage(url, kingfisherOptions: kingfisherOptions)
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
