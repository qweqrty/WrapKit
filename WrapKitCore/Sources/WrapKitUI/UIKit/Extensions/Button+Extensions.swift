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
        animation: UIView.AnimationOptions = .transitionCrossDissolve,
        completion: ((Image?) -> Void)?
    ) {
        if Thread.isMainThread {
            handleImage(image, completion: completion)
         } else {
             DispatchQueue.main.async { [weak self] in
                 self?.handleImage(image, completion: completion)
             }
         }
    }
    
    private func handleImage(_ image: ImageEnum?, kingfisherOptions: KingfisherOptionsInfo = [], completion: ((Image?) -> Void)?) {
        switch image {
        case .asset(let image):
            self.animatedSet(image, completion: completion)
        case .url(let lightUrl, let darkUrl):
            self.loadImage(UserInterfaceStyle.current == .light ? lightUrl : darkUrl, kingfisherOptions: kingfisherOptions, completion: completion)
        case .urlString(let lightString, let darkString):
            let string = UserInterfaceStyle.current == .light ? lightString : darkString
            self.loadImage(URL(string: string ?? ""), kingfisherOptions: kingfisherOptions, completion: completion)
        case .data(let data):
            guard let data else {
                completion?(nil)
                return
            }
            self.animatedSet(UIImage(data: data), completion: completion)
        case .none:
            completion?(nil)
        }
    }
    
    private func loadImage(_ url: URL?, kingfisherOptions: KingfisherOptionsInfo, completion: ((Image?) -> Void)?) {
        guard let url else {
            self.animatedSet(wrongUrlPlaceholderImage, completion: completion)
            return
        }
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
            switch result {
            case .success(let image):
                self?.animatedSet(image.image, completion: nil)

                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions) { [weak self] result in
                    switch result {
                    case .success(let image):
                        self?.animatedSet(image.image, completion: completion)
                    case .failure:
                        completion?(nil)
                        return
                    }
                }
            case.failure(_):
                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions) { [weak self] result in
                    switch result {
                    case .success(let image):
                        self?.animatedSet(image.image, completion: completion)
                    case .failure:
                        completion?(nil)
                        return
                    }
                }
            }
        }
    }
    
    private func animatedSet(_ image: UIImage?, completion: ((Image?) -> Void)?) {
        cancelCurrentAnimation()

        currentAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
            self?.setImage(image, for: .normal)
        }
        currentAnimator?.addCompletion { [weak self] _ in
            self?.currentAnimator = nil
            completion?(image)
        }

        // Start the animation
        currentAnimator?.startAnimation()
    }
}
#endif
