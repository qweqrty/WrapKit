//
//  Image+Ext.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 27/10/25.
//

#if canImport(SwiftUI)
import SwiftUI

public extension SwiftUIImage {
    init(image: Image) {
#if canImport(UIKit)
        self.init(uiImage: image)
#elseif canImport(AppKit)
        self.init(nsImage: image)
#endif
    }
}

extension Image {
    var rendersAsTemplate: Bool {
#if os(macOS)
        return isTemplate
#else
        return renderingMode != .alwaysOriginal
#endif
    }

    var rendersAsTemplateInImageView: Bool {
#if os(macOS)
        return isTemplate
#else
        switch renderingMode {
        case .alwaysTemplate: return true
        case .alwaysOriginal: return false
        default: return isSymbolImage
        }
#endif
    }

    var swiftUIRenderingMode: SwiftUIImage.TemplateRenderingMode {
        rendersAsTemplate ? .template : .original
    }
}

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension Image {
    /// Picks the light or dark variant of an asset catalog image for a SwiftUI color scheme.
    /// `Image(uiImage:)` keeps the variant resolved when the image was created, while
    /// UIImageView re-resolves it from `imageAsset` on every trait change.
    func resolvedForColorScheme(_ colorScheme: ColorScheme) -> Image {
        guard !isSymbolImage else { return self }
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection.current,
            UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        ])
        // Derived images (withRenderingMode / withTintColor) return nil here, as in UIImageView.
        guard let resolved = imageAsset?.image(with: traits) as Image? else { return self }
        return resolved.renderingMode == renderingMode ? resolved : resolved.withRenderingMode(renderingMode)
    }
}
#endif

#endif
