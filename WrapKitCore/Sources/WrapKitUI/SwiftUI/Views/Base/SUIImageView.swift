//
//  SUIImageView.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 31/7/25.
//
//
import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Kingfisher

public struct SUIImageView: View {
    let adapter: ImageViewOutputSwiftUIAdapter
    let viewWhileLoadingView: AnyView?
    let fallbackView: AnyView?
    
    @State private var model: ImageViewPresentableModel = .init()
    @State private var loadedImage: Image?
    @State private var isLoading = false
    @State private var hasError = false
    @State private var isHidden = false
    @State private var downloadTask: DownloadTask?
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        adapter: ImageViewOutputSwiftUIAdapter,
        viewWhileLoadingView: AnyView? = nil,
        fallbackView: AnyView? = nil
    ) {
        self.adapter = adapter
        self.viewWhileLoadingView = viewWhileLoadingView
        self.fallbackView = fallbackView
    }
    
    public var body: some View {
        Group {
            if isHidden {
                SwiftUICore.EmptyView()
            } else {
                ZStack {
                    if hasError {
                        fallbackViewOrError
                    } else if let loadedImage {
                        contentView(loadedImage)
                    }
                    
                    if isLoading {
                        loadingView
                    }
                }
                .onChange(of: colorScheme) { newMode in
                    loadImage(for: newMode)
                }
                .onReceive(adapter.$displayImageState) { newState in
                    if let image = newState?.image {
                        model = model.updated(image: image)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayAlphaState) { newState in
                    if let alpha = newState?.alpha {
                        model = model.updated(alpha: alpha)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displaySizeState) { newState in
                    if let size = newState?.size {
                        model = model.updated(size: size)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayModelState) { newState in
                    if let adapterModel = newState?.model {
                        model = model.updated(
                            size: adapterModel.size,
                            image: adapterModel.image,
                            onPress: adapterModel.onPress,
                            onLongPress: adapterModel.onLongPress,
                            contentModeIsFit: adapterModel.contentModeIsFit,
                            borderWidth: adapterModel.borderWidth,
                            borderColor: adapterModel.borderColor,
                            cornerRadius: adapterModel.cornerRadius,
                            alpha: adapterModel.alpha
                        )
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayBorderColorState) { newState in
                    if let borderColor = newState?.borderColor {
                        model = model.updated(borderColor: borderColor)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayBorderWidthState) { newState in
                    if let borderWidth = newState?.borderWidth {
                        model = model.updated(borderWidth: borderWidth)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayCornerRadiusState) { newState in
                    if let cornerRadius = newState?.cornerRadius {
                        model = model.updated(cornerRadius: cornerRadius)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayOnPressState) { newState in
                    if let onPress = newState?.onPress {
                        model = model.updated(onPress: onPress)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayOnLongPressState) { newState in
                    if let onLongPress = newState?.onLongPress {
                        model = model.updated(onLongPress: onLongPress)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayContentModeIsFitState) { newState in
                    if let isFit = newState?.contentModeIsFit {
                        model = model.updated(contentModeIsFit: isFit)
                        loadImage(for: colorScheme)
                    }
                }
                .onReceive(adapter.$displayIsHiddenState) { newState in
                    if let isHide = newState?.isHidden {
                        isHidden = isHide
                    }
                }
            }
        }
    }
    
    /// views
    private var fallbackViewOrError: some View {
        (fallbackView ?? AnyView(errorView))
            .frame(width: model.size?.width, height: model.size?.height)
    }

    private func contentView(_ image: Image) -> some View {
        SwiftUIImage(image: image)
            .resizable()
            .modifier(ImageViewStyle(model: model))
    }

    private var loadingView: some View {
        viewWhileLoadingView ?? AnyView(
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private var errorView: some View {
        Text("Invalid image data")
            .foregroundColor(.red)
            .padding()
    }
    
    ///
    private func loadImage(for mode: ColorScheme) {
        downloadTask?.cancel()
        hasError = false
        loadedImage = nil
        
        guard let imageEnum = model.image else {
            hasError = true
            return
        }
        
        switch imageEnum {
        case .asset(let image):
            self.loadedImage = image
        case .data(let data):
            guard let data else {
                self.hasError = true
                return
            }
            loadedImage = Image(data: data)
            
        case .url(let light, let dark):
            let url = (mode == .dark ? dark : light) ?? light
            loadImageFromURL(url)
            
        case .urlString(let light, let dark):
            let urlString = (mode == .dark ? dark : light) ?? light
            let url = urlString.flatMap(URL.init(string:))
            loadImageFromURL(url)
        }
    }
    
    private func loadImageFromURL(_ url: URL?) {
        guard let url else {
            self.hasError = true
            return
        }
        
        isLoading = true
        downloadTask = KingfisherManager.shared.retrieveImage(with: url) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let value):
                    self.loadedImage = value.image
                case .failure:
                    self.hasError = true
                }
            }
        }
    }
}

// MARK: - Model Extensions
private extension ImageViewPresentableModel {
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

// MARK: - View Modifiers
private struct ImageViewStyle: ViewModifier {
    let model: ImageViewPresentableModel?
    
    func body(content: Content) -> some View {
        content
            .modifier(OptionalFrame(size: model?.size))
            .modifier(OptionalAspectRatio(contentModeIsFit: model?.contentModeIsFit))
            .clipped()
            .cornerRadius(model?.cornerRadius ?? 0)
            .overlay(
                RoundedRectangle(cornerRadius: model?.cornerRadius ?? 0)
                    .stroke(borderColor, lineWidth: model?.borderWidth ?? 0)
            )
            .opacity(model?.alpha ?? 1.0)
            .onTapGesture {
                model?.onPress?()
            }
            .onLongPressGesture(minimumDuration: 1) {
                model?.onLongPress?()
            }
    }
    
    private var borderColor: SwiftUIColor {
        guard let borderColor = model?.borderColor else { return .clear }
        return SwiftUIColor(borderColor)
    }
}

private struct OptionalFrame: ViewModifier {
    let size: CGSize?
    
    func body(content: Content) -> some View {
        if let size = size {
            content.frame(width: size.width, height: size.height)
        } else {
            content
        }
    }
}

private struct OptionalAspectRatio: ViewModifier {
    let contentModeIsFit: Bool?
    
    func body(content: Content) -> some View {
        if let isFit = contentModeIsFit {
            content.aspectRatio(contentMode: isFit ? .fit : .fill)
        } else {
            content
        }
    }
}
#endif
