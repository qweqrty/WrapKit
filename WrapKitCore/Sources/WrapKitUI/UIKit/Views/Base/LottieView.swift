//
//  LottieView.swift
//  WrapKit
//

#if canImport(UIKit)
import Foundation
import Lottie
import UIKit

open class LottieView: UIView, LottieViewOutput {
    public var currentAnimationName: String?

    private var animationView: LottieAnimationView?
    private var animationDataTask: URLSessionDataTask?
    private var animationRequestID: UUID?

    deinit {
        animationDataTask?.cancel()
    }

    // MARK: - Display Method
    public func display(model: LottieViewPresentableModel) {
        stopAnimation()

        if let url = model.url {
            displayRemoteAnimation(from: url, model: model)
            return
        }

        guard let animationView = LottieAnimationView(assetName: model.fileName, bundle: model.bundle) else {
            print("Failed to initialize LottieAnimationView with asset name: \(model.fileName), in bundlePath: \(model.bundle.bundlePath)")
            return
        }

        display(animationView: animationView, model: model, animationName: model.fileName)
    }

    private func displayRemoteAnimation(from url: URL, model: LottieViewPresentableModel) {
        let requestID = UUID()
        animationRequestID = requestID
        currentAnimationName = url.absoluteString

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error as? URLError, error.code == .cancelled {
                return
            }

            guard let data else {
                print("Failed to download Lottie animation from url: \(url.absoluteString), error: \(String(describing: error))")
                return
            }

            guard let animation = try? LottieAnimation.from(data: data) else {
                print("Failed to create Lottie animation from url: \(url.absoluteString)")
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self, self.animationRequestID == requestID else { return }
                let animationView = LottieAnimationView(animation: animation)
                self.display(animationView: animationView, model: model, animationName: url.absoluteString)
            }
        }

        animationDataTask = dataTask
        dataTask.resume()
    }

    private func display(
        animationView: LottieAnimationView,
        model: LottieViewPresentableModel,
        animationName: String
    ) {
        animationView.animationSpeed = model.animationSpeed
        animationView.loopMode = model.loopMode
        animationView.play()

        addSubview(animationView)
        animationView.frame = bounds
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.animationView = animationView
        currentAnimationName = animationName
    }

    private func stopAnimation() {
        animationDataTask?.cancel()
        animationDataTask = nil
        animationRequestID = nil

        animationView?.stop()
        animationView?.frame = .zero
        animationView?.removeFromSuperview()
        animationView = nil
    }

    // MARK: - Lifecycle
    open override func layoutSubviews() {
        super.layoutSubviews()
        animationView?.frame = bounds
    }
}

extension LottieView: HiddableOutput {
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

extension LottieAnimationView {
    convenience init?(assetName: String, bundle: Bundle) {
        // Try to fetch the data from XCAssets
        guard let dataAsset = NSDataAsset(name: assetName, bundle: bundle) else {
            print("Failed to load animation data for asset: \(assetName)")
            return nil
        }
        // Try to create an animation from the data
        guard let animation = try? LottieAnimation.from(data: dataAsset.data) else {
            print("Failed to create Lottie animation for asset: \(assetName)")
            return nil
        }
        self.init(animation: animation)
    }
}
#endif
