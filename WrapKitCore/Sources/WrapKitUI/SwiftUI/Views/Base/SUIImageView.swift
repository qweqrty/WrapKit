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

#if canImport(UIKit)
import UIKit
#endif

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
                    if let symbolName {
                        systemSymbolView(named: symbolName)
                    } else if let loadedImage = loadedImage ?? cachedRemoteImage(for: colorScheme) {
                        contentView(loadedImage)
                    } else if hasError {
                        fallbackViewOrEmpty
                    }

                    if shouldShowLoadingView {
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

    private var symbolName: String? {
        guard case .symbolName(let name) = model.image else { return nil }
        return name
    }

    private var shouldShowLoadingView: Bool {
        if isLoading { return true }

        // Output updates can be delivered before SwiftUI executes the reload callback. UIKit
        // reveals its loading view synchronously for a valid remote URL, so derive that first
        // frame from the model as well instead of briefly rendering an empty image container.
        guard resolvedRemoteURL(for: colorScheme) != nil,
              loadedImage == nil,
              cachedRemoteImage(for: colorScheme) == nil,
              !hasError
        else { return false }
        return true
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
        #if canImport(UIKit)
        if shouldRasterizeAssetSymbol {
            resizableContentView(SUIVectorImageRasterCache.shared.image(for: image))
        } else if shouldPrepareWrongURLPlaceholder, image.isSymbolImage {
            preparedWrongURLPlaceholder(image)
        } else {
            resizableContentView(image)
        }
        #else
        resizableContentView(image)
        #endif
    }

    private var shouldRasterizeAssetSymbol: Bool {
        guard case .asset = model.image else { return false }
        return true
    }

    private var shouldPrepareWrongURLPlaceholder: Bool {
        guard model.image?.isRemote == true else { return false }
        return resolvedRemoteURL(for: colorScheme) == nil
    }

    #if canImport(UIKit)
    private func preparedWrongURLPlaceholder(_ image: Image) -> some View {
        GeometryReader { geometry in
            let preparedImage = SUIVectorImageRasterCache.shared.preparedImage(
                for: image,
                size: geometry.size,
                contentModeIsFit: model.contentModeIsFit ?? true
            )
            SwiftUIImage(image: preparedImage)
                .renderingMode(.template)
                .resizable()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .foregroundColor(SwiftUI.Color.accentColor)
        }
    }
    #endif

    @ViewBuilder
    private func resizableContentView(_ image: Image) -> some View {
        if shouldRenderTemplate {
            SwiftUIImage(image: image)
                .renderingMode(.template)
                .resizable()
                .modifier(OptionalAspectRatio(contentModeIsFit: model.contentModeIsFit ?? true))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .foregroundColor(SwiftUI.Color.accentColor)
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

        case .symbolName(let name):
            downloadTask?.cancel()
            isLoading = false
            let image = ImageFactory.systemImage(named: name)
            loadedImage = image
            shouldRenderTemplate = true
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
            let url = mode == .dark ? dark : light
            if shouldSkipReload(for: url) {
                completion?(loadedImage)
                return
            }
            loadImageFromURL(url, requestID: requestID, completion: completion)

        case .urlString(let light, let dark):
            let urlString = mode == .dark ? dark : light
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
        guard let resolvedURL = resolvedRemoteURL(for: mode) else { return nil }
        if let storedImage = SUIRemoteImageCache.shared.image(for: resolvedURL) {
            return storedImage
        }

        if let cachedImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: resolvedURL.absoluteString) {
            SUIRemoteImageCache.shared.store(cachedImage, for: resolvedURL)
            return cachedImage
        }

        return nil
    }

    private func resolvedRemoteURL(for mode: ColorScheme) -> URL? {
        switch model.image {
        case .url(let light, let dark):
            return mode == .dark ? dark : light
        case .urlString(let light, let dark):
            let string = mode == .dark ? dark : light
            return string.flatMap(URL.init(string:))
        case .asset, .symbolName, .data, nil:
            return nil
        }
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
            if case .symbolName(let name) = model.image {
                return ImageFactory.systemImage(named: name)?.size ?? self.size
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
            borderColor: model.borderColor?.resolvedForImageLayer ?? borderColor,
            cornerRadius: model.cornerRadius ?? cornerRadius,
            alpha: model.alpha ?? alpha
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
            alpha: alpha
        )
    }

    func replacingImage(_ image: ImageEnum?) -> ImageViewPresentableModel {
        replacing(image: image)
    }

    func replacingBorderColor(_ borderColor: Color?) -> ImageViewPresentableModel {
        replacing(borderColor: borderColor?.resolvedForImageLayer)
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
        return ImageViewPresentableModel(
            accessibilityIdentifier: accessibilityIdentifier,
            accessibility: accessibility,
            size: size,
            image: image ?? self.image,
            onPress: onPress ?? self.onPress,
            onLongPress: onLongPress ?? self.onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor ?? self.borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
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
            alpha: alpha ?? self.alpha
        )
    }
}

private extension Color {
    var resolvedForImageLayer: Color {
        #if canImport(UIKit)
        // UIImageView stores `layer.borderColor` as a concrete CGColor when Output is called.
        // Resolve at the same boundary so a dynamic UIColor does not change later only in SwiftUI.
        return resolvedColor(with: UITraitCollection.current)
        #else
        return self
        #endif
    }
}

private extension ImageEnum {
    var isRemote: Bool {
        switch self {
        case .url, .urlString:
            return true
        case .asset, .symbolName, .data:
            return false
        }
    }
}

#if canImport(UIKit)
private final class SUIVectorImageRasterCache {
    static let shared = SUIVectorImageRasterCache()

    private let images = NSCache<UIImage, UIImage>()
    private let placeholderImages = NSCache<SUIPlaceholderRasterKey, UIImage>()
    private let maximumPixelDimension: CGFloat = 1_024

    private init() {
        images.countLimit = 16
        images.totalCostLimit = 32 * 1_024 * 1_024
        placeholderImages.countLimit = 16
        placeholderImages.totalCostLimit = 32 * 1_024 * 1_024
    }

    func image(for image: UIImage) -> UIImage {
        guard image.isSymbolImage else { return image }
        if let cachedImage = images.object(forKey: image) {
            return cachedImage
        }

        let longestDimension = max(image.size.width, image.size.height)
        guard longestDimension > 0 else { return image }
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = maximumPixelDimension / longestDimension
        format.preferredRange = .extended
        let sourceImage = image.withRenderingMode(.alwaysOriginal)
        let rasterizedImage = UIGraphicsImageRenderer(
            size: image.size,
            format: format
        ).image { _ in
            sourceImage.draw(at: .zero)
        }.withRenderingMode(image.renderingMode)
        let pixelCount = Int(maximumPixelDimension * maximumPixelDimension)
        images.setObject(rasterizedImage, forKey: image, cost: pixelCount * 4)
        return rasterizedImage
    }

    func preparedImage(
        for image: UIImage,
        size: CGSize,
        contentModeIsFit: Bool
    ) -> UIImage {
        guard image.isSymbolImage, size.width > 0, size.height > 0 else { return image }
        // ImageEnum carries an unnamed UIImage, so preserve UIImageView's public SF Symbol
        // optical sizing in a raster canvas before handing the pixels back to SwiftUI.
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = UITraitCollection.current.displayScale
        format.preferredRange = .extended
        let cacheKey = SUIPlaceholderRasterKey(
            image: image,
            size: size,
            contentModeIsFit: contentModeIsFit,
            displayScale: format.scale
        )
        if let cachedImage = placeholderImages.object(forKey: cacheKey) {
            return cachedImage
        }
        let imageView = UIImageView(image: image)
        imageView.bounds = CGRect(origin: .zero, size: size)
        imageView.contentMode = contentModeIsFit ? .scaleAspectFit : .scaleAspectFill
        imageView.tintColor = .white
        imageView.layer.contentsScale = format.scale
        let rasterizedImage = UIGraphicsImageRenderer(
            size: size,
            format: format
        ).image { context in
            imageView.layer.render(in: context.cgContext)
        }.withRenderingMode(image.renderingMode)
        let pixelCount = Int(size.width * format.scale * size.height * format.scale)
        placeholderImages.setObject(rasterizedImage, forKey: cacheKey, cost: pixelCount * 4)
        return rasterizedImage
    }
}

private final class SUIPlaceholderRasterKey: NSObject {
    private let image: UIImage
    private let size: CGSize
    private let contentModeIsFit: Bool
    private let displayScale: CGFloat

    init(
        image: UIImage,
        size: CGSize,
        contentModeIsFit: Bool,
        displayScale: CGFloat
    ) {
        self.image = image
        self.size = size
        self.contentModeIsFit = contentModeIsFit
        self.displayScale = displayScale
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(image))
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(contentModeIsFit)
        hasher.combine(displayScale)
        return hasher.finalize()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let key = object as? SUIPlaceholderRasterKey else { return false }
        return image === key.image &&
            size == key.size &&
            contentModeIsFit == key.contentModeIsFit &&
            displayScale == key.displayScale
    }
}
#endif

// MARK: - View Modifiers
private struct ImageViewContainerStyle: ViewModifier {
    let model: ImageViewPresentableModel?
    
    private var effectiveOpacity: CGFloat {
        return model?.alpha ?? 1.0
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        let cornerRadius = model?.cornerRadius ?? 0
        if #available(iOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            styled(
                content,
                shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        } else {
            styled(
                content,
                shape: RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
            )
        }
    }

    private func styled<CornerShape: InsettableShape>(
        _ content: Content,
        shape: CornerShape
    ) -> some View {
        content
            .modifier(OptionalFrame(size: model?.size))
            .clipped()
            .clipShape(shape)
            .ifLet(model?.borderWidth) {
                $0.overlay(
                    shape.strokeBorder(
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
