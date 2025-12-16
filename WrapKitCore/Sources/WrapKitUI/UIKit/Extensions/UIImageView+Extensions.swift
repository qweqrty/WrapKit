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
        
        if image == nil {
            kf.cancelDownloadTask()
            cancelCurrentAnimation()
            self.image = nil
            closure?(nil)
            return
        }
        
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
            kf.cancelDownloadTask()
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
        
        kf.cancelDownloadTask()
        
        if let fallbackView {
            fallbackView.isHidden = true
        }
        viewWhileLoadingView?.isHidden = false
        
        let loadingURL = url
        
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions
        ) { [weak self] result in
            guard let self = self else { return }
            
            let isCurrentURL: Bool = {
                switch self.currentImageEnum {
                case .url(let lightUrl, let darkUrl):
                    return loadingURL == lightUrl || loadingURL == darkUrl
                case .urlString(let lightString, let darkString):
                    let lightURL = lightString.flatMap { URL(string: $0) }
                    let darkURL = darkString.flatMap { URL(string: $0) }
                    return loadingURL == lightURL || loadingURL == darkURL
                case .asset, .data, .none:
                    return false
                }
            }()
            
            guard isCurrentURL else {
                return
            }
            
            switch result {
            case .success(let image):
                self.animatedSet(image.image, closure: closure)
            case .failure:
                self.showFallbackView(loadingURL)
                closure?(nil)
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
