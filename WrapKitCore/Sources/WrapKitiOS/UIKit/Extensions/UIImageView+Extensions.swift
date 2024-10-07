#if canImport(UIKit)
import UIKit
import Kingfisher

public extension ImageView {
    func setImage(
        image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve
    ) {
        switch image {
        case .asset(let image):
            animatedSet(image)
        case .url(let url):
            guard let url else { return }
            loadImage(url)
        case .urlString(let string):
            guard let string else { return }
            guard let url = URL(string: string) else { return }
            loadImage(url)
        case .data(let data):
            guard let data else { return }
            animatedSet(UIImage(data: data))
        case .none:
            break
        }
    }
    
    private func loadImage(_ url: URL) {
        subviews.forEach { $0.removeFromSuperview() }
        
        if let viewWhileLoadingView {
            addSubview(viewWhileLoadingView)
            viewWhileLoadingView.fillSuperview()
        }
        KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self, weak viewWhileLoadingView, url] result in
            viewWhileLoadingView?.removeFromSuperview()

            switch result {
            case .success(let image):
                self?.animatedSet(image.image)
            case .failure:
                self?.addFallbackView(url)
            }
        }
    }
    
    private func addFallbackView(_ url: URL) {
        guard let fallbackView else { return }
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(fallbackView)
        fallbackView.fillSuperview()
        fallbackView.animations.insert(.shrink)
        fallbackView.onPress = { [weak self] in
            self?.loadImage(url)
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
