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
    @State private var activeRequestID = UUID()

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

    init(
        stateModel: SUIImageViewStateModel,
        viewWhileLoadingView: AnyView? = nil,
        fallbackView: AnyView? = nil,
        wrongUrlPlaceholderImage: Image? = nil,
        backgroundColor: SwiftUIColor? = nil
    ) {
        _stateModel = .init(wrappedValue: stateModel)
        self.viewWhileLoadingView = viewWhileLoadingView
        self.fallbackView = fallbackView
        self.wrongUrlPlaceholderImage = wrongUrlPlaceholderImage
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        Group {
            if stateModel.isHidden {
                SwiftUI.EmptyView()
            } else {
                ZStack {
                    if let systemSymbolName = model.systemSymbolName {
                        systemSymbolView(named: systemSymbolName)
                    } else if let loadedImage = loadedImage ?? cachedRemoteImage(for: colorScheme) {
                        contentView(loadedImage)
                    } else if hasError {
                        fallbackViewOrEmpty
                    }

                    if isLoading {
                        loadingView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ifLet(backgroundColor) { $0.background($1) }
                .modifier(ImageViewContainerStyle(model: model))
                .onChange(of: colorScheme) { newMode in
                    guard model.image?.isRemote == true else { return }
                    loadImage(for: newMode, completion: nil)
                }
            }
        }
        .onReceive(stateModel.$reloadToken) { _ in
            loadImage(for: colorScheme, completion: stateModel.pendingCompletion)
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
                .onTapGesture {
                    loadImage(for: colorScheme, completion: nil)
                }
        } else {
            SwiftUI.EmptyView()
        }
    }

    @ViewBuilder
    private func systemSymbolView(named name: String) -> some View {
#if os(macOS)
        if #available(macOS 11.0, *) {
            systemSymbolContent(named: name)
        } else if let loadedImage {
            contentView(loadedImage)
        }
#else
        systemSymbolContent(named: name)
#endif
    }

    @available(macOS 11.0, *)
    private func systemSymbolContent(named name: String) -> some View {
        FittedSystemSymbol(
            name: name,
            contentModeIsFit: model.contentModeIsFit ?? true
        )
            .id(name)
            .foregroundColor(.accentColor)
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
                SwiftUI.EmptyView()
            }
        }
    }

    private func loadImage(for mode: ColorScheme, completion: ((Image?) -> Void)?) {
        let requestID = UUID()
        activeRequestID = requestID
        hasError = false

        switch model.image {
        case .asset(let image):
            downloadTask?.cancel()
            isLoading = false
            loadedImage = image
            shouldRenderTemplate = image?.rendersAsTemplate ?? false
            lastLoadedRemoteURL = nil
            completion?(image)

        case .data(let data):
            downloadTask?.cancel()
            isLoading = false
            shouldRenderTemplate = false
            lastLoadedRemoteURL = nil
            guard let data, let image = Image(data: data) else {
                loadedImage = nil
                // UIKit only clears invalid data; fallback is reserved for a failed remote request.
                hasError = false
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
            loadImageFromURL(url, requestID: requestID, completion: completion)

        case .urlString(let light, let dark):
            let urlString = (mode == .dark ? dark : light) ?? light
            let url = urlString.flatMap(URL.init(string:))
            if shouldSkipReload(for: url) {
                completion?(loadedImage)
                return
            }
            loadImageFromURL(url, requestID: requestID, completion: completion)

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

    private func loadImageFromURL(
        _ url: URL?,
        requestID: UUID,
        completion: ((Image?) -> Void)?
    ) {
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
                // A missing URL behaves like UIKit's nil placeholder and does not show fallback.
                hasError = false
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
            guard self.activeRequestID == requestID else { return }
            switch result {
            case .success(let cacheResult):
                DispatchQueue.main.async {
                    guard self.activeRequestID == requestID else { return }
                    self.loadedImage = cacheResult.image
                    self.shouldRenderTemplate = false
                    self.hasError = false
                    self.isLoading = false
                }
                downloadTask = KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [.callbackQueue(.mainCurrentOrAsync), .fromMemoryCacheOrRefresh],
                    completionHandler: { result in
                        DispatchQueue.main.async {
                            guard self.activeRequestID == requestID else { return }
                            self.downloadTask = nil
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
                        DispatchQueue.main.async {
                            guard self.activeRequestID == requestID else { return }
                            self.downloadTask = nil
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

/// Keeps the native SF Symbol alignment canvas and scales that canvas into the available space.
/// `Image.resizable()` stretches the glyph bounds instead and loses the symbol's native margins.
@available(macOS 11.0, *)
private struct FittedSystemSymbol: View {
    private static let referenceFontSize: CGFloat = 17

    let name: String
    let contentModeIsFit: Bool

    @State private var referenceSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let fontSize = fontSize(for: proxy.size) {
                    symbol(fontSize: fontSize)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            .background(referenceSymbol)
        }
    }

    private func symbol(fontSize: CGFloat) -> some View {
        SwiftUIImage(systemName: name)
            .renderingMode(.template)
            .font(.system(size: fontSize))
            .imageScale(.medium)
            .fixedSize()
    }

    private var referenceSymbol: some View {
        symbol(fontSize: Self.referenceFontSize)
            .hidden()
            .measureSize($referenceSize)
    }

    private func fontSize(for availableSize: CGSize) -> CGFloat? {
        guard referenceSize.width > 0,
              referenceSize.height > 0,
              availableSize.width > 0,
              availableSize.height > 0
        else { return nil }

        let widthScale = availableSize.width / referenceSize.width
        let heightScale = availableSize.height / referenceSize.height
        let scale = contentModeIsFit
            ? min(widthScale, heightScale)
            : max(widthScale, heightScale)
        return Self.referenceFontSize * scale
    }
}

public struct SUIImageViewView: View {
    let model: ImageViewPresentableModel

    @StateObject private var stateModel: SUIImageViewStateModel

    public init(model: ImageViewPresentableModel) {
        self.model = model
        _stateModel = .init(wrappedValue: .init(model: model))
    }

    public var body: some View {
        SUIImageView(stateModel: stateModel)
            .onChange(of: model) { newModel in
                stateModel.apply(model: newModel)
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
    func mergingFullModel(_ model: ImageViewPresentableModel) -> ImageViewPresentableModel {
        let resolvedSize: CGSize? = {
            if let size = model.size {
                return size
            }
            if case .asset(let image) = model.image {
                return image?.size ?? self.size
            }
            return self.size
        }()

        return ImageViewPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            size: resolvedSize,
            image: model.image,
            onPress: model.onPress,
            onLongPress: model.onLongPress,
            contentModeIsFit: model.contentModeIsFit ?? contentModeIsFit,
            borderWidth: model.borderWidth ?? borderWidth,
            borderColor: model.borderColor ?? borderColor,
            cornerRadius: model.cornerRadius ?? cornerRadius,
            alpha: model.alpha ?? alpha,
            systemSymbolName: model.systemSymbolName
        )
    }

    func clearingForNilModel() -> ImageViewPresentableModel {
        return ImageViewPresentableModel(
            accessibilityIdentifier: nil,
            accessibility: nil,
            size: size,
            image: nil,
            onPress: nil,
            onLongPress: nil,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha,
            systemSymbolName: nil
        )
    }

    func replacingImage(_ image: ImageEnum?) -> ImageViewPresentableModel {
        replacing(image: image)
    }

    func replacingBorderColor(_ borderColor: Color?) -> ImageViewPresentableModel {
        replacing(borderColor: borderColor)
    }

    func replacingOnPress(_ onPress: (() -> Void)?) -> ImageViewPresentableModel {
        replacing(onPress: onPress)
    }

    func replacingOnLongPress(_ onLongPress: (() -> Void)?) -> ImageViewPresentableModel {
        replacing(onLongPress: onLongPress)
    }

    private func replacing(
        image: ImageEnum?? = nil,
        onPress: (() -> Void)?? = nil,
        onLongPress: (() -> Void)?? = nil,
        borderColor: Color?? = nil
    ) -> ImageViewPresentableModel {
        let resolvedImage: ImageEnum?
        let resolvedSystemSymbolName: String?
        switch image {
        case .some(let replacement):
            resolvedImage = replacement
            resolvedSystemSymbolName = nil
        case .none:
            resolvedImage = self.image
            resolvedSystemSymbolName = systemSymbolName
        }

        return ImageViewPresentableModel(
            accessibilityIdentifier: accessibilityIdentifier,
            accessibility: accessibility,
            size: size,
            image: resolvedImage,
            onPress: onPress ?? self.onPress,
            onLongPress: onLongPress ?? self.onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor ?? self.borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha,
            systemSymbolName: resolvedSystemSymbolName
        )
    }

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
            alpha: alpha ?? self.alpha,
            systemSymbolName: image == nil ? systemSymbolName : nil
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
    
    private var effectiveOpacity: CGFloat {
        return model?.alpha ?? 1.0
    }

    func body(content: Content) -> some View {
        content
            .modifier(OptionalFrame(size: model?.size))
            .clipped()
            .cornerRadius(model?.cornerRadius ?? 0)
            .ifLet(model?.borderWidth) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: model?.cornerRadius ?? 0)
                        .strokeBorder(
                            SwiftUIColor(model?.borderColor ?? .black),
                            lineWidth: $1
                        )
                )
            }
            .opacity(effectiveOpacity)
            .modifier(ImageViewInteractionModifier(
                onPress: model?.onPress,
                onLongPress: model?.onLongPress
            ))
            .modifier(ImageViewAccessibilityModifier(model: model))
    }

}

private struct ImageViewInteractionModifier: ViewModifier {
    let onPress: (() -> Void)?
    let onLongPress: (() -> Void)?

    @ViewBuilder
    func body(content: Content) -> some View {
        switch (onPress, onLongPress) {
        case let (onPress?, onLongPress?):
            content
                .onTapGesture(perform: onPress)
                .onLongPressGesture(minimumDuration: 1, perform: onLongPress)
        case let (onPress?, nil):
            content.onTapGesture(perform: onPress)
        case let (nil, onLongPress?):
            content.onLongPressGesture(minimumDuration: 1, perform: onLongPress)
        case (nil, nil):
            content
        }
    }
}

private struct ImageViewAccessibilityModifier: ViewModifier {
    let model: ImageViewPresentableModel?

    @ViewBuilder
    func body(content: Content) -> some View {
        if model?.onPress != nil || model?.onLongPress != nil {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityIdentifier(model?.accessibilityIdentifier ?? "")
                .accessibilityLabel(SwiftUI.Text(model?.accessibility?.label ?? ""))
                .accessibilityHint(SwiftUI.Text(model?.accessibility?.hint ?? ""))
                .accessibilityAddTraits([.isImage, .isButton])
                .modifier(ImageViewAccessibilityActionsModifier(
                    onPress: model?.onPress,
                    onLongPress: model?.onLongPress
                ))
        } else {
            content
                .accessibilityIdentifier(model?.accessibilityIdentifier ?? "")
                .accessibilityHidden(true)
        }
    }
}

private struct ImageViewAccessibilityActionsModifier: ViewModifier {
    let onPress: (() -> Void)?
    let onLongPress: (() -> Void)?

    @ViewBuilder
    func body(content: Content) -> some View {
        switch (onPress, onLongPress) {
        case let (onPress?, onLongPress?):
            content
                .accessibilityAction { onPress() }
                .accessibilityAction(named: SwiftUI.Text("Long press")) { onLongPress() }
        case let (onPress?, nil):
            content.accessibilityAction { onPress() }
        case let (nil, onLongPress?):
            content.accessibilityAction(named: SwiftUI.Text("Long press")) { onLongPress() }
        case (nil, nil):
            content
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
