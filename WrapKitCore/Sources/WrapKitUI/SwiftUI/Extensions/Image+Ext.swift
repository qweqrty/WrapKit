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
        return renderingMode == .alwaysTemplate || (renderingMode == .automatic && isSymbolImage)
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
        guard let imageAsset else { return self }
        guard isAssetCatalogOriginal(in: imageAsset),
              let resolved = imageAsset.image(with: traits) as Image? else {
            // A derived copy (withTintColor / withRenderingMode) keeps its variant, as in UIImageView,
            // but its tint can be a dynamic color. UIImageView resolves that tint with its own traits
            // on every draw, while `Image(uiImage:)` keeps the color resolved at creation.
            return drawn(with: traits)
        }
        return resolved.renderingMode == renderingMode ? resolved : resolved.withRenderingMode(renderingMode)
    }

    /// Asset catalog lookups return nil for derived copies (tinted or re-moded) once the traits differ
    /// from the ones they were created with, so an image that resolves for both styles is an original.
    private func isAssetCatalogOriginal(in imageAsset: UIImageAsset) -> Bool {
        [UIUserInterfaceStyle.light, .dark].allSatisfy { style in
            imageAsset.image(with: UITraitCollection(traitsFrom: [
                UITraitCollection.current,
                UITraitCollection(userInterfaceStyle: style)
            ])) as Image? != nil
        }
    }

    private func drawn(with traits: UITraitCollection) -> Image {
        guard size.width > 0, size.height > 0 else { return self }
        let format = UIGraphicsImageRendererFormat(for: traits)
        format.scale = scale
        format.opaque = false
        var image = self
        traits.performAsCurrent {
            image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        }
        let result = image.withRenderingMode(renderingMode)
        result.accessibilityIdentifier = accessibilityIdentifier
        return result
    }
}
#endif

#endif
