#if canImport(UIKit)
import UIKit
import Kingfisher

public extension ImageView {
    func setImage(
        _ image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve,
        closure: ((Image?) -> Void)? = nil
    ) {
        if Thread.isMainThread {
            handleImage(image, closure: closure)
         } else {
             DispatchQueue.main.async { [weak self] in
                 self?.handleImage(image, closure: closure)
             }
         }
    }
    
    private func handleImage(_ image: ImageEnum?, kingfisherOptions: KingfisherOptionsInfo = [], closure: ((Image?) -> Void)? = nil) {
        currentImageEnum = image
        switch image {
        case .asset(let image):
            self.animatedSet(image, closure: closure)
        case .url(let lightUrl, let darkUrl):
            let url = traitCollection.userInterfaceStyle == .dark ? (darkUrl ?? lightUrl) : (lightUrl ?? darkUrl)
            self.loadImage(url, kingfisherOptions: kingfisherOptions, closure: closure)
        case .urlString(let lightString, let darkString):
            let string = traitCollection.userInterfaceStyle == .dark ? (darkString ?? lightString) : (lightString ?? darkString)
            guard let url = URL(string: string ?? "") else { return }
            self.loadImage(url, kingfisherOptions: kingfisherOptions, closure: closure)
        case .data(let data):
            guard let data else { return }
            self.animatedSet(UIImage(data: data), closure: closure)
        case .none:
            break
        }
    }
    
    private func loadImage(_ url: URL?, kingfisherOptions: KingfisherOptionsInfo, closure: ((Image?) -> Void)? = nil) {
        guard let url = url else { return }
        if let fallbackView {
            fallbackView.isHidden = true
        }
        viewWhileLoadingView?.isHidden = false
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
            switch result {
            case .success(let image):
                self?.animatedSet(image.image, closure: closure)

                self?.kf.setImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions, completionHandler: { result in
                    switch result {
                    case .success(let result):
                        self?.viewWhileLoadingView?.isHidden = true
                    case .failure:
                        self?.showFallbackView(url)
                    }
                })
            case.failure:
                self?.kf.setImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions, completionHandler: { result in
                    switch result {
                    case .success(let result):
                        self?.viewWhileLoadingView?.isHidden = true
                    case .failure:
                        self?.showFallbackView(url)
                    }
                })
            }
        }
    }
    
    private func showFallbackView(_ url: URL, kingfisherOptions: KingfisherOptionsInfo = []) {
        viewWhileLoadingView?.isHidden = true
        viewWhileLoadingView?.alpha = 0
        guard let fallbackView else { return }
        fallbackView.isHidden = false
        fallbackView.animations.insert(.shrink)
        fallbackView.onPress = { [weak self] in
            self?.viewWhileLoadingView?.alpha = 1
            self?.loadImage(url, kingfisherOptions: kingfisherOptions)
        }
    }
    
    private func animatedSet(_ image: UIImage?, closure: ((Image?) -> Void)? = nil) {
        cancelCurrentAnimation()

        currentAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
            self?.image = image
            closure?(image)
        }
        currentAnimator?.addCompletion { [weak self] _ in
            self?.currentAnimator = nil
            self?.viewWhileLoadingView?.isHidden = true
        }

        // Start the animation
        currentAnimator?.startAnimation()
    }
}
#endif
