//
//  Image+Ext.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 27/10/25.
//

import SwiftUI

public extension SwiftUIImage {
    init(image: Image) {
#if canImport(AppKit)
        self.init(nsImage: image)
#elseif canImport(UIKit)
        self.init(uiImage: image)
#endif
    }
}
