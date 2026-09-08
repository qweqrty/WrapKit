//
//  SUILottieViewStateModel.swift
//  WrapKit
//

#if canImport(SwiftUI)
import Combine
import Foundation
import Lottie
import SwiftUI

final class SUILottieViewStateModel: ObservableObject {
    @Published private(set) var animation: LottieAnimation?
    @Published private(set) var animationSpeed: Double = 1.2
    @Published private(set) var loopMode: LottieLoopMode = .playOnce
    @Published private(set) var reloadToken = UUID()

    private let adapter: LottieViewOutputSwiftUIAdapter
    private var animationDataTask: URLSessionDataTask?
    private var animationRequestID: UUID?
    private var cancellables = Set<AnyCancellable>()

    init(adapter: LottieViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0?.model }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.display(model: model)
            }
            .store(in: &cancellables)
    }

    deinit {
        animationDataTask?.cancel()
    }

    private func display(model: LottieViewPresentableModel) {
        stopAnimation()
        animationSpeed = Double(model.animationSpeed)
        loopMode = model.loopMode

        if let url = model.url {
            displayRemoteAnimation(from: url, model: model)
            return
        }

        guard let dataAsset = NSDataAsset(name: model.fileName, bundle: model.bundle) else {
            print("Failed to load animation data for asset: \(model.fileName)")
            return
        }

        guard let animation = try? LottieAnimation.from(data: dataAsset.data) else {
            print("Failed to create Lottie animation for asset: \(model.fileName)")
            return
        }

        display(animation: animation, model: model, animationName: model.fileName)
    }

    private func displayRemoteAnimation(from url: URL, model: LottieViewPresentableModel) {
        let requestID = UUID()
        animationRequestID = requestID
        adapter.currentAnimationName = url.absoluteString

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error as? URLError, error.code == .cancelled {
                return
            }

            guard let data else {
                print(
                    "Failed to download Lottie animation from url: \(url.absoluteString), "
                        + "error: \(String(describing: error))"
                )
                return
            }

            guard let animation = try? LottieAnimation.from(data: data) else {
                print("Failed to create Lottie animation from url: \(url.absoluteString)")
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self, self.animationRequestID == requestID else { return }
                self.display(animation: animation, model: model, animationName: url.absoluteString)
            }
        }

        animationDataTask = dataTask
        dataTask.resume()
    }

    private func display(
        animation: LottieAnimation,
        model: LottieViewPresentableModel,
        animationName: String
    ) {
        animationSpeed = Double(model.animationSpeed)
        loopMode = model.loopMode
        self.animation = animation
        reloadToken = UUID()
        adapter.currentAnimationName = animationName
    }

    private func stopAnimation() {
        animationDataTask?.cancel()
        animationDataTask = nil
        animationRequestID = nil
        animation = nil
        reloadToken = UUID()
    }
}
#endif
