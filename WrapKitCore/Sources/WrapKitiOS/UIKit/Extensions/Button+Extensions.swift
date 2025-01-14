#if canImport(UIKit)
import UIKit
import Kingfisher

public extension Button {
    func cancelCurrentAnimation() {
        currentAnimator?.stopAnimation(true) // Stop the animation and leave the view in its current state
        currentAnimator = nil
    }
    
    func setImage(
        _ image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve
    ) {
        if Thread.isMainThread {
             handleImage(image)
         } else {
             DispatchQueue.main.async { [weak self] in
                 self?.handleImage(image)
             }
         }
    }
    
    private func handleImage(_ image: ImageEnum?, kingfisherOptions: KingfisherOptionsInfo = []) {
        switch image {
        case .asset(let image):
            self.animatedSet(image)
        case .url(let url):
            guard let url else { return }
            self.loadImage(url, kingfisherOptions: kingfisherOptions)
        case .urlString(let string):
            guard let string else { return }
            guard let url = URL(string: string) else { return }
            self.loadImage(url, kingfisherOptions: kingfisherOptions)
        case .data(let data):
            guard let data else { return }
            self.animatedSet(UIImage(data: data))
        case .none:
            break
        }
    }
    
    private func loadImage(_ url: URL, kingfisherOptions: KingfisherOptionsInfo) {
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
            switch result {
            case .success(let image):
                self?.animatedSet(image.image)

                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions) { [weak self] result in
                    switch result {
                    case .success(let image):
                        self?.animatedSet(image.image)
                    case .failure:
                        return
                    }
                }
            case.failure(_):
                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions) { [weak self] result in
                    switch result {
                    case .success(let image):
                        self?.animatedSet(image.image)
                    case .failure:
                        return
                    }
                }
            }
        }
    }
    
    private func animatedSet(_ image: UIImage?) {
        cancelCurrentAnimation()

        currentAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
            self?.setImage(image, for: .normal)
        }
        currentAnimator?.addCompletion { [weak self] _ in
            self?.currentAnimator = nil
        }

        // Start the animation
        currentAnimator?.startAnimation()
    }
}
#endif
