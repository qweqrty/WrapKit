//
//  SUIImageView.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 31/7/25.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Kingfisher
import Combine

public struct SUIImageView: View {
    let viewWhileLoadingView: AnyView?
    let fallbackView: AnyView?
    let wrongUrlPlaceholderImage: Image?
    let backgroundColor: SwiftUIColor?

    @StateObject private var stateModel: SUIImageViewStateModel
    @State private var loadedImage: Image?
    @State private var shouldRenderTemplate = false
    @State private var isLoading = false
    @State private var hasError = false
    @State private var downloadTask: DownloadTask?
    @State private var lastLoadedRemoteURL: URL?

    @Environment(\.colorScheme) private var colorScheme

    public init(
        adapter: ImageViewOutputSwiftUIAdapter,
        viewWhileLoadingView: AnyView? = nil,
        fallbackView: AnyView? = nil,
        wrongUrlPlaceholderImage: Image? = nil,
        backgroundColor: SwiftUIColor? = nil
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.viewWhileLoadingView = viewWhileLoadingView
        self.fallbackView = fallbackView
        self.wrongUrlPlaceholderImage = wrongUrlPlaceholderImage
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        Group {
            if stateModel.isHidden {
                SwiftUICore.EmptyView()
            } else {
                ZStack {
                    if let loadedImage = loadedImage ?? cachedRemoteImage(for: colorScheme) {
                        contentView(loadedImage)
                    } else if hasError {
                        fallbackViewOrEmpty
                    }

                    if isLoading {
                        loadingView
                    }
                }
                .ifLet(backgroundColor) { $0.background($1) }
                .modifier(ImageViewContainerStyle(model: model))
                .onChange(of: colorScheme) { newMode in
                    guard model.image?.isRemote == true else { return }
                    loadImage(for: newMode, completion: nil)
                }
                .onReceive(stateModel.$reloadToken) { _ in
                    if stateModel.isHidden {
                        isLoading = false
                        hasError = false
                        loadedImage = nil
                        return
                    }
                    loadImage(for: colorScheme, completion: stateModel.pendingCompletion)
                }
            }
        }
    }

    private var model: ImageViewPresentableModel {
        stateModel.model
    }

    @ViewBuilder
    private var fallbackViewOrEmpty: some View {
        if let fallbackView {
            fallbackView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            SwiftUICore.EmptyView()
        }
    }

    @ViewBuilder
    private func contentView(_ image: Image) -> some View {
        if shouldRenderTemplate {
            SwiftUIImage(image: image)
                .renderingMode(.template)
                .resizable()
                .modifier(OptionalAspectRatio(contentModeIsFit: model.contentModeIsFit ?? true))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .foregroundColor(.accentColor)
        } else {
            SwiftUIImage(image: image)
                .resizable()
                .modifier(OptionalAspectRatio(contentModeIsFit: model.contentModeIsFit ?? true))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private var loadingView: some View {
        Group {
            if let viewWhileLoadingView {
                viewWhileLoadingView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                CircularSwiftUIProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func loadImage(for mode: ColorScheme, completion: ((Image?) -> Void)?) {
        hasError = false

        switch model.image {
        case .asset(let image):
            downloadTask?.cancel()
            isLoading = false
            loadedImage = image
            shouldRenderTemplate = image?.renderingMode != .alwaysOriginal
            lastLoadedRemoteURL = nil
            completion?(image)

        case .data(let data):
            downloadTask?.cancel()
            isLoading = false
            shouldRenderTemplate = false
            lastLoadedRemoteURL = nil
            guard let data, let image = Image(data: data) else {
                loadedImage = nil
                hasError = true
                completion?(nil)
                return
            }
            loadedImage = image
            completion?(image)

        case .url(let light, let dark):
            let url = (mode == .dark ? dark : light) ?? light
            if shouldSkipReload(for: url) {
                completion?(loadedImage)
                return
            }
            loadImageFromURL(url, completion: completion)

        case .urlString(let light, let dark):
            let urlString = (mode == .dark ? dark : light) ?? light
            let url = urlString.flatMap(URL.init(string:))
            if shouldSkipReload(for: url) {
                completion?(loadedImage)
                return
            }
            loadImageFromURL(url, completion: completion)

        case nil:
            downloadTask?.cancel()
            isLoading = false
            loadedImage = nil
            shouldRenderTemplate = false
            hasError = false
            lastLoadedRemoteURL = nil
            completion?(nil)
        }
    }

    private func shouldSkipReload(for url: URL?) -> Bool {
        guard let url else { return false }
        return lastLoadedRemoteURL == url && loadedImage != nil && !isLoading
    }

    private func cachedRemoteImage(for mode: ColorScheme) -> Image? {
        let resolvedURL: URL?
        switch model.image {
        case .url(let light, let dark):
            resolvedURL = (mode == .dark ? dark : light) ?? light
        case .urlString(let light, let dark):
            let urlString = (mode == .dark ? dark : light) ?? light
            resolvedURL = urlString.flatMap(URL.init(string:))
        default:
            resolvedURL = nil
        }

        guard let resolvedURL else { return nil }
        if let storedImage = SUIRemoteImageCache.shared.image(for: resolvedURL) {
            return storedImage
        }

        if let cachedImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: resolvedURL.absoluteString) {
            SUIRemoteImageCache.shared.store(cachedImage, for: resolvedURL)
            return cachedImage
        }

        return nil
    }

    private func loadImageFromURL(_ url: URL?, completion: ((Image?) -> Void)?) {
        guard let url else {
            downloadTask?.cancel()
            isLoading = false
            lastLoadedRemoteURL = nil
            if let wrongUrlPlaceholderImage {
                loadedImage = wrongUrlPlaceholderImage
                shouldRenderTemplate = true
                hasError = false
                completion?(wrongUrlPlaceholderImage)
            } else {
                loadedImage = nil
                shouldRenderTemplate = false
                hasError = true
                completion?(nil)
            }
            return
        }

        if let storedImage = SUIRemoteImageCache.shared.image(for: url) {
            loadedImage = storedImage
            shouldRenderTemplate = false
            hasError = false
            isLoading = false
            lastLoadedRemoteURL = url
            completion?(storedImage)
            return
        }

        if let cachedImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: url.absoluteString) {
            SUIRemoteImageCache.shared.store(cachedImage, for: url)
            loadedImage = cachedImage
            shouldRenderTemplate = false
            hasError = false
            isLoading = false
            lastLoadedRemoteURL = url
            completion?(cachedImage)
            return
        }

        if url != downloadTask?.sessionTask.originalURL {
            downloadTask?.cancel()
        }

        loadedImage = nil
        shouldRenderTemplate = false
        hasError = false
        isLoading = true

        KingfisherManager.shared.cache.retrieveImage(
            forKey: url.absoluteString,
            options: [.callbackQueue(.mainCurrentOrAsync)]
        ) { result in
            switch result {
            case .success(let cacheResult):
                DispatchQueue.main.async {
                    self.loadedImage = cacheResult.image
                    self.shouldRenderTemplate = false
                    self.hasError = false
                    self.isLoading = false
                }
                downloadTask = KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [.callbackQueue(.mainCurrentOrAsync), .fromMemoryCacheOrRefresh],
                    completionHandler: { result in
                        self.downloadTask = nil
                        DispatchQueue.main.async {
                            self.isLoading = false
                            switch result {
                            case .success(let value):
                                SUIRemoteImageCache.shared.store(value.image, for: url)
                                self.loadedImage = value.image
                                self.shouldRenderTemplate = false
                                self.hasError = false
                                self.lastLoadedRemoteURL = url
                                completion?(value.image)
                            case .failure:
                                self.loadedImage = nil
                                self.shouldRenderTemplate = false
                                self.hasError = true
                                completion?(nil)
                            }
                        }
                    }
                )
            case .failure(let error):
                guard !error.isTaskCancelled else { return }
                downloadTask = KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [.callbackQueue(.mainCurrentOrAsync)],
                    completionHandler: { result in
                        self.downloadTask = nil
                        DispatchQueue.main.async {
                            self.isLoading = false
                            switch result {
                            case .success(let value):
                                SUIRemoteImageCache.shared.store(value.image, for: url)
                                self.loadedImage = value.image
                                self.shouldRenderTemplate = false
                                self.hasError = false
                                self.lastLoadedRemoteURL = url
                                completion?(value.image)
                            case .failure:
                                self.loadedImage = nil
                                self.shouldRenderTemplate = false
                                self.hasError = true
                                completion?(nil)
                            }
                        }
                    }
                )
            }
        }
    }
}

private final class SUIRemoteImageCache {
    static let shared = SUIRemoteImageCache()

    private let cache = NSCache<NSString, Image>()

    private init() {}

    func image(for url: URL) -> Image? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: Image, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
}

// MARK: - Model Extensions
extension ImageViewPresentableModel {
    func updated(
        size: CGSize? = nil,
        image: ImageEnum? = nil,
        onPress: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        contentModeIsFit: Bool? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        alpha: CGFloat? = nil
    ) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            accessibilityIdentifier: accessibilityIdentifier,
            accessibility: accessibility,
            size: size ?? self.size,
            image: image ?? self.image,
            onPress: onPress ?? self.onPress,
            onLongPress: onLongPress ?? self.onLongPress,
            contentModeIsFit: contentModeIsFit ?? self.contentModeIsFit,
            borderWidth: borderWidth ?? self.borderWidth,
            borderColor: borderColor ?? self.borderColor,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            alpha: alpha ?? self.alpha
        )
    }
}

private extension ImageEnum {
    var isRemote: Bool {
        switch self {
        case .url, .urlString:
            return true
        case .asset, .data:
            return false
        }
    }
}

// MARK: - View Modifiers
private struct ImageViewContainerStyle: ViewModifier {
    let model: ImageViewPresentableModel?

    func body(content: Content) -> some View {
        content
            .modifier(OptionalFrame(size: model?.size))
            .clipped()
            .cornerRadius(model?.cornerRadius ?? 0)
            .ifLet(model?.borderColor) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: model?.cornerRadius ?? 0)
                        .stroke(SwiftUIColor($1), lineWidth: model?.borderWidth ?? 0)
                )
            }
            .opacity(model?.alpha ?? 1.0)
            .onTapGesture {
                model?.onPress?()
            }
            .onLongPressGesture(minimumDuration: 1) {
                model?.onLongPress?()
            }
    }

}

private struct OptionalFrame: ViewModifier {
    let size: CGSize?

    func body(content: Content) -> some View {
        if let size = size {
            content.frame(width: size.width, height: size.height)
        } else {
            content.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

private struct OptionalAspectRatio: ViewModifier {
    let contentModeIsFit: Bool

    func body(content: Content) -> some View {
        content.aspectRatio(contentMode: contentModeIsFit ? .fit : .fill)
    }
}

private struct CircularSwiftUIProgressView: View {
    @State private var isAnimating = false

    private let lineWidth: CGFloat = 2
    private let size: CGFloat = 18

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.28)
            .stroke(
                SwiftUIColor.secondary,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

#endif
