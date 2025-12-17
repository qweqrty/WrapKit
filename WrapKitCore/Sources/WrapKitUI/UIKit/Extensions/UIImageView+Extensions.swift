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
        
        let loadToken = UUID()
        currentLoadToken = loadToken
        
        if image == nil {
            kf.cancelDownloadTask()
            cancelCurrentAnimation()
            self.image = nil
            closure?(nil)
            return
        }
        
        switch image {
        case .asset(let image):
            self.animatedSet(image, loadToken: loadToken, closure: closure)
        case .url(let lightUrl, let darkUrl):
            let url = traitCollection.userInterfaceStyle == .dark ? darkUrl : lightUrl
            self.loadImage(url, loadToken: loadToken, kingfisherOptions: kingfisherOptions, closure: closure)
        case .urlString(let lightString, let darkString):
            let string = traitCollection.userInterfaceStyle == .dark ? darkString : lightString
            self.loadImage(URL(string: string ?? ""), loadToken: loadToken, kingfisherOptions: kingfisherOptions, closure: closure)
        case .data(let data):
            guard let data else {
                closure?(nil)
                return
            }
            self.animatedSet(UIImage(data: data), loadToken: loadToken, closure: closure)
        case .none:
            kf.cancelDownloadTask()
            cancelCurrentAnimation()
            self.image = nil
            closure?(nil)
        }
    }
    
    private func loadImage(_ url: URL?, loadToken: UUID, kingfisherOptions: KingfisherOptionsInfo, closure: ((Image?) -> Void)? = nil) {
        guard let url = url else {
            animatedSet(wrongUrlPlaceholderImage, loadToken: loadToken, closure: nil)
            return
        }
        
        kf.cancelDownloadTask()
        
        if let fallbackView {
            fallbackView.isHidden = true
        }
        viewWhileLoadingView?.isHidden = false
        
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
            guard let self = self else { return }
            guard self.currentLoadToken == loadToken else { return }
            
            switch result {
            case .success(let image):
                self.animatedSet(image.image, loadToken: loadToken, closure: closure)
                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions) { [weak self] result in
                    guard let self = self else { return }
                    guard self.currentLoadToken == loadToken else { return }
                    
                    switch result {
                    case .success(let image):
                        self.animatedSet(image.image, loadToken: loadToken, closure: closure)
                    case .failure:
                        self.showFallbackView(url, loadToken: loadToken)
                        closure?(nil)
                    }
                }
            case .failure:
                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions) { [weak self] result in
                    guard let self = self else { return }
                    guard self.currentLoadToken == loadToken else { return }
                    
                    switch result {
                    case .success(let image):
                        self.animatedSet(image.image, loadToken: loadToken, closure: closure)
                    case .failure:
                        self.showFallbackView(url, loadToken: loadToken)
                        closure?(nil)
                    }
                }
            }
        }
    }
    
    private func showFallbackView(_ url: URL, loadToken: UUID, kingfisherOptions: KingfisherOptionsInfo = []) {
        viewWhileLoadingView?.isHidden = true
        viewWhileLoadingView?.alpha = 0
        guard let fallbackView else { return }
        fallbackView.isHidden = false
        fallbackView.animations.insert(.shrink)
        fallbackView.onPress = { [weak self] in
            self?.viewWhileLoadingView?.alpha = 1
            self?.loadImage(url, loadToken: loadToken, kingfisherOptions: kingfisherOptions)
        }
    }
    
    private func animatedSet(_ image: UIImage?, loadToken: UUID, closure: ((Image?) -> Void)? = nil) {
        guard currentLoadToken == loadToken else { return }
        cancelCurrentAnimation()
        currentAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
            self?.image = image
        }
        currentAnimator?.addCompletion { [weak self] _ in
            self?.currentAnimator = nil
            self?.viewWhileLoadingView?.isHidden = true
            closure?(image)
        }

        // Start the animation
        currentAnimator?.startAnimation()
    }
}
#endif
