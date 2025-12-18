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
        cancelCurrentDownload()
        currentImageEnum = image
        
        switch image {
        case .asset(let image):
            self.animatedSet(image, closure: closure)
        case .url(let lightUrl, let darkUrl):
            let url = traitCollection.userInterfaceStyle == .dark ? darkUrl : lightUrl
            self.loadImage(url, kingfisherOptions: kingfisherOptions, closure: closure)
        case .urlString(let lightString, let darkString):
            let string = traitCollection.userInterfaceStyle == .dark ? darkString : lightString
            self.loadImage(URL(string: string ?? ""), kingfisherOptions: kingfisherOptions, closure: closure)
        case .data(let data):
            guard let data else {
                closure?(nil)
                return
            }
            self.animatedSet(UIImage(data: data), closure: closure)
        case .none:
            cancelCurrentAnimation()
            self.image = nil
            closure?(nil)
        }
    }
    
    private func loadImage(_ url: URL?, kingfisherOptions: KingfisherOptionsInfo, closure: ((Image?) -> Void)? = nil) {
        guard let url = url else {
            animatedSet(wrongUrlPlaceholderImage, closure: nil)
            return
        }
        KingfisherManager.shared.downloader.cancel(url: url)
        
        if let fallbackView {
            fallbackView.isHidden = true
        }
        viewWhileLoadingView?.isHidden = false
        
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                self.animatedSet(image.image, closure: closure)
                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let image):
                        self.animatedSet(image.image, closure: closure)
                    case .failure:
                        self.showFallbackView(url)
                        closure?(nil)
                    }
                }
            case .failure:
                KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let image):
                        self.animatedSet(image.image, closure: closure)
                    case .failure:
                        self.showFallbackView(url)
                        closure?(nil)
                    }
                }
            }
        }
    }
    
    private func cancelCurrentDownload() {
        guard let currentImageEnum = currentImageEnum else { return }
        
        switch currentImageEnum {
        case .url(let lightUrl, let darkUrl):
            if let url = lightUrl {
                KingfisherManager.shared.downloader.cancel(url: url)
            }
            if let url = darkUrl {
                KingfisherManager.shared.downloader.cancel(url: url)
            }
        case .urlString(let lightString, let darkString):
            if let urlString = lightString, let url = URL(string: urlString) {
                KingfisherManager.shared.downloader.cancel(url: url)
            }
            if let urlString = darkString, let url = URL(string: urlString) {
                KingfisherManager.shared.downloader.cancel(url: url)
            }
        default:
            break
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
