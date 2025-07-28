//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 24/7/25.
//

import SwiftUI
import Kingfisher

public struct SUIImageView: View {
    @ObservedObject var adapter: ImageViewOutputSwiftUIAdapter
    
    public init(adapter: ImageViewOutputSwiftUIAdapter) {
        self.adapter = adapter
    }
    
    public var body: some View {
        Group {
            if let hidden = adapter.displayIsHiddenState?.isHidden, hidden {
                SwiftUICore.EmptyView()
            } else if let model = adapter.displayModelState?.model {
                ModelImageView(model: model)
            } else if let image = adapter.displayImageState?.image {
                ModelImageView(model: .init(image: image))
            }
        }
    }
}

struct ModelImageView: View {
    let model: ImageViewPresentableModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var loadedImage: AnyView?
    @State private var hasError = false
    
    var body: some View {
        Group {
            if hasError {
                showImageError()
            } else if let image = loadedImage {
                image
                    .modifier(ImageViewStyle(model: model))
            } else {
                showImageError() // TODO:
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageEnum = model.image else { return }
        
        switch imageEnum {
        case .asset(let image):
            if let image {
                loadedImage = AnyView(
                    SwiftUIImage(image: image)
                        .resizable()
                        .modifier(ImageViewStyle(model: model))
                )
            } else {
                loadedImage = AnyView(showImageError())
            }
        case .data(let data):
            if let data {
                loadedImage = AnyView(CGImageView(data: data, model: model))
            }
        case .url(let light, let dark):
            let selected = (colorScheme == .dark ? dark ?? light : light ?? dark)
            if let url = selected {
                loadedImage = AnyView(
                    KFImage(url)
                        .onFailure { _ in hasError = true }
                        .fade(duration: 0.3)
                )
            } else {
                loadedImage = AnyView(showImageError())
            }
        case .urlString(let light, let dark):
            let selected = (colorScheme == .dark ? dark ?? light : light ?? dark)
            if let url = URL(string: selected ?? "") {
                loadedImage = AnyView(
                    KFImage(url)
                        .onFailure { _ in hasError = true }
                        .fade(duration: 0.3)
                )
            } else {
                loadedImage = AnyView(showImageError())
            }
        }
    }
    
    private func showImageError() -> some View {
        Text("Invalid image data")
            .foregroundColor(.red)
    }
}

struct ImageViewStyle: ViewModifier {
    let model: ImageViewPresentableModel?
    
    func body(content: Content) -> some View {
        guard let model else {
            return AnyView(content)
        }
        return AnyView(
            content
            .modifier(OptionalFrame(size: model.size))
            .modifier(OptionalAspectRatio(contentModeIsFit: model.contentModeIsFit))
            .clipped()
            .cornerRadius(model.cornerRadius ?? 0)
            .overlay(
                RoundedRectangle(cornerRadius: model.cornerRadius ?? 0)
                    .stroke(model.borderColor.map { SwiftUIColor($0) } ?? .clear,
                            lineWidth: model.borderWidth ?? 0)
            )
            .opacity(model.alpha ?? 1.0)
            .onTapGesture {
                model.onPress?()
            }
            .onLongPressGesture(minimumDuration: 1) {
                model.onLongPress?()
            }
        )
    }
}

struct CGImageView: View {
    let data: Data
    let model: ImageViewPresentableModel?
    
    var body: some View {
        if let cgImage = cgImageFromData(data) {
            SwiftUIImage(decorative: cgImage, scale: 1.0)
                .resizable()
                .modifier(ImageViewStyle(model: model))
        } else {
            Text("Invalid image data")
                .foregroundColor(.red)
        }
    }
    
    func cgImageFromData(_ data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}

struct OptionalFrame: ViewModifier {
    let size: CGSize?
    
    func body(content: Content) -> some View {
        if let size = size {
            content.frame(width: size.width, height: size.height)
        } else {
            content
        }
    }
}

struct OptionalAspectRatio: ViewModifier {
    let contentModeIsFit: Bool?
    
    func body(content: Content) -> some View {
        if let isFit = contentModeIsFit {
            content.aspectRatio(contentMode: isFit ? .fit : .fill)
        } else {
            content
        }
    }
}
