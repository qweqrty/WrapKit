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
    @Environment(\.colorScheme) private var colorScheme
    @State private var downloadTask: DownloadTask?
    
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
            if adapter.displayIsHiddenState?.isHidden == true {
                SwiftUICore.EmptyView()
            } else {
                ZStack {
                    if hasError {
                        (fallbackView ?? AnyView(errorView))
                            .frame(width: model.size?.width, height: model.size?.height)
                    } else if let loadedImage {
                        SwiftUIImage(image: loadedImage)
                            .resizable()
                            .modifier(ImageViewStyle(model: model))
                    }
                    
                    if isLoading {
                        viewWhileLoadingView ?? AnyView(
                            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                        )
                    }
                }
                .onAppear {
                    updateModelFromAdapter()
                    loadImage(for: colorScheme)
                }
                .onChange(of: colorScheme) { newMode in
                    loadImage(for: newMode)
                }
                .onReceive(adapter.objectWillChange) { _ in
                    updateModelFromAdapter()
                    loadImage(for: colorScheme)
                }
            }
        }
    }
    
    private func updateModelFromAdapter() {
        var model = adapter.displayModelState?.model ?? ImageViewPresentableModel()
        
        if let image = adapter.displayImageState?.image {
            model = model.withImage(image)
        }
        if let size = adapter.displaySizeState?.size {
            model = model.withSize(size)
        }
        if let onPress = adapter.displayOnPressState?.onPress {
            model = model.withOnPress(onPress)
        }
        if let onLongPress = adapter.displayOnLongPressState?.onLongPress {
            model = model.withOnLongPress(onLongPress)
        }
        if let contentModeIsFit = adapter.displayContentModeIsFitState?.contentModeIsFit {
            model = model.withContentModeIsFit(contentModeIsFit)
        }
        if let borderWidth = adapter.displayBorderWidthState?.borderWidth {
            model = model.withBorderWidth(borderWidth)
        }
        if let borderColor = adapter.displayBorderColorState?.borderColor {
            model = model.withBorderColor(borderColor)
        }
        if let cornerRadius = adapter.displayCornerRadiusState?.cornerRadius {
            model = model.withCornerRadius(cornerRadius)
        }
        if let alpha = adapter.displayAlphaState?.alpha {
            model = model.withAlpha(alpha)
        }
        self.model = model
    }
    
    private func loadImage(for mode: ColorScheme) {
        downloadTask?.cancel()
        hasError = false
        loadedImage = nil
        
        guard let imageEnum = model.image else {
            isLoading = false
            hasError = true
            return
        }
        
        switch imageEnum {
        case .asset(let image):
            self.loadedImage = image
            self.isLoading = false
            
        case .data(let data):
            loadImageFromData(data)
            
        case .url(let light, let dark):
            let url = (mode == .dark ? dark : light) ?? light
            loadImageFromURL(url)
            
        case .urlString(let light, let dark):
            let urlString = (mode == .dark ? dark : light) ?? light
            let url = urlString.flatMap(URL.init(string:))
            loadImageFromURL(url)
        }
    }
    
    private func loadImageFromData(_ data: Data?) {
        guard let data else {
            self.hasError = true
            return
        }
        
        loadedImage = Image(data: data)
    }
    
    private func loadImageFromURL(_ url: URL?) {
        guard let url else {
            self.hasError = true
            self.isLoading = false
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
    
    private var errorView: some View {
        Text("Invalid image data")
            .foregroundColor(.red)
            .padding()
    }
}

// MARK: - Model Extensions
private extension ImageViewPresentableModel {
    func withImage(_ image: ImageEnum?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withSize(_ size: CGSize?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withOnPress(_ onPress: (() -> Void)?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withOnLongPress(_ onLongPress: (() -> Void)?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withContentModeIsFit(_ contentModeIsFit: Bool?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withBorderWidth(_ borderWidth: CGFloat?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withBorderColor(_ borderColor: Color?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withCornerRadius(_ cornerRadius: CGFloat?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
        )
    }
    
    func withAlpha(_ alpha: CGFloat?) -> ImageViewPresentableModel {
        ImageViewPresentableModel(
            size: size,
            image: image,
            onPress: onPress,
            onLongPress: onLongPress,
            contentModeIsFit: contentModeIsFit,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            alpha: alpha
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
