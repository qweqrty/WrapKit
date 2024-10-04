#if canImport(UIKit)
import UIKit
import Kingfisher

public extension UIImageView {
    func setImage(
        image: ImageEnum?,
        animation: UIView.AnimationOptions = .transitionCrossDissolve,
        viewWhileLoading: UIView? = nil,
        fallbackView: View? = nil,
        stopLoading: (() -> Void)? = nil
    ) {
        switch image {
        case .asset(let image):
            animatedSet(image)
        case .url(let url):
            guard let url else { return }
            loadImage(
                url,
                viewWhileLoading: viewWhileLoading,
                fallbackView: fallbackView,
                stopLoading: stopLoading
            )
        case .urlString(let string):
            guard let string else { return }
            guard let url = URL(string: string) else { return }
            loadImage(
                url,
                viewWhileLoading: viewWhileLoading,
                fallbackView: fallbackView,
                stopLoading: stopLoading
            )
        case .data(let data):
            guard let data else { return }
            animatedSet(UIImage(data: data))
        case .none:
            break
        }
    }
    
    private func loadImage(
        _ url: URL,
        viewWhileLoading: UIView?,
        fallbackView: View?,
        stopLoading: (() -> Void)? = nil
    ) {
        fallbackView?.removeFromSuperview()
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        if let viewWhileLoading {
            DispatchQueue.main.async { [weak self] in
                self?.addSubview(viewWhileLoading)
                viewWhileLoading.fillSuperview()
            }
        }
        
        KingfisherManager.shared.retrieveImage(with: url, options: [.callbackQueue(.mainCurrentOrAsync)]) { [weak self, weak viewWhileLoading, url] result in
            guard let self else { return }
            viewWhileLoading?.removeFromSuperview()
            stopLoading?()
            switch result {
            case .success(let image):
                self.animatedSet(image.image)
            case .failure:
                self.addFallbackView(url, viewWhileLoading: viewWhileLoading, fallbackView: fallbackView)
            }
        }
    }
    
    private func addFallbackView(_ url: URL, viewWhileLoading: UIView?, fallbackView: View?) {
        guard let fallbackView = fallbackView else { return }
        subviews.forEach { view in
            view.removeFromSuperview()
        }
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
