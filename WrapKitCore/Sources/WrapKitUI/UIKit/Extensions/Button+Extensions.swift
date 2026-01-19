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
            self.animatedSet(image)
            completion?(image)
        case .url(let lightUrl, let darkUrl):
            let url = UserInterfaceStyle.current == .light ? lightUrl : darkUrl
            self.loadImage(url, kingfisherOptions: kingfisherOptions, completion: completion)
        case .urlString(let lightString, let darkString):
            let string = UserInterfaceStyle.current == .light ? lightString : darkString
            let url = URL(string: string ?? "")
            self.loadImage(url, kingfisherOptions: kingfisherOptions, completion: completion)
        case .data(let data):
            guard let data else {
                completion?(nil)
                return
            }
            let image = UIImage(data: data)
            self.animatedSet(image)
            completion?(image)
        case .none:
            completion?(nil)
        }
    }
    
    private func loadImage(
        _ url: URL?,
        kingfisherOptions: KingfisherOptionsInfo,
        completion: ((Image?) -> Void)?
    ) {
        guard let url else {
            self.animatedSet(wrongUrlPlaceholderImage)
            completion?(wrongUrlPlaceholderImage)
            return
        }
        KingfisherManager.shared.cache.retrieveImage(
            forKey: url.absoluteString,
            options: [.callbackQueue(.mainCurrentOrAsync)]
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                self.animatedSet(image.image)
                retrieveImage(
                    url: url,
                    kingfisherOptions: [.callbackQueue(.mainCurrentOrAsync), .forceRefresh] + kingfisherOptions,
                    completion: completion
                )
            case.failure(let error):
                guard !error.isTaskCancelled else { return }
                retrieveImage(
                    url: url,
                    kingfisherOptions: [.callbackQueue(.mainCurrentOrAsync)] + kingfisherOptions,
                    completion: completion
                )
            }
        }
    }
    
    @discardableResult
    private func retrieveImage(
        url: URL,
        kingfisherOptions: KingfisherOptionsInfo,
        completion: ((Image?) -> Void)? = nil
    ) -> DownloadTask? {
        return KingfisherManager.shared.retrieveImage(
            with: url,
            options: [.callbackQueue(.mainCurrentOrAsync), .fromMemoryCacheOrRefresh] + kingfisherOptions
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.animatedSet(image.image)
                completion?(image.image)
            case .failure(let error):
                guard !error.isTaskCancelled else { return }
                self.animatedSet(nil)
                completion?(nil)
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
