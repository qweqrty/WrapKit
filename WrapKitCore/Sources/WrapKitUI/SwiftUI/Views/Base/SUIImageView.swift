//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 24/7/25.
//

import SwiftUI

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
               // ImageViewSwiftUI(model: model)

            }
        }
    }

    /// Renders a basic SwiftUIImage when only ImageEnum is provided
    @ViewBuilder
    private func renderPlainImage(from imageEnum: ImageEnum) -> some View {
        switch imageEnum {
        case .asset(let platformImg):
            if let platformImg = platformImg {
                swiftUIImage(from: platformImg)
                    .resizable()
                    .scaledToFit()
            } else {
                EmptyView()
            }
        case .data(let data):
            if let data = data,
               let plat = platformImage(from: data) {
                swiftUIImage(from: plat)
                    .resizable()
                    .scaledToFit()
            } else {
                EmptyView()
            }
        case .url(let url, _):
//            if let u = url {
//                ImageViewSwiftUI(model: ImageViewPresentableModel(image: .url(u)))
//            } else {
//                EmptyView()
//            }
        case .urlString(let str, _):
//            if let s = str, let u = URL(string: s) {
//                ImageViewSwiftUI(model: ImageViewPresentableModel(image: .url(u)))
//            } else {
//                EmptyView()
//            }
        }
    }

    /// Converts platform Image (UIImage/NSImage) to SwiftUIImage
    private func swiftUIImage(from platformImg: Image) -> SwiftUIImage {
    #if os(macOS)
        return SwiftUIImage(nsImage: platformImg)
    #else
        return SwiftUIImage(uiImage: platformImg)
    #endif
    }

    /// Helper to get platform Image from Data
    private func platformImage(from data: Data) -> Image? {
    #if os(macOS)
        return NSImage(data: data)
    #else
        return UIImage(data: data)
    #endif
    }
}
