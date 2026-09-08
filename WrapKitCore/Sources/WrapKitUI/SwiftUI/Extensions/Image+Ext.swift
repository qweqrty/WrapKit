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

    var swiftUIRenderingMode: SwiftUIImage.TemplateRenderingMode {
        rendersAsTemplate ? .template : .original
    }
}

#endif
