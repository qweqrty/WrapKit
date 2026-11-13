//
//  SUICollectionViewCell.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUICollectionViewCell<Content: View>: View {
    private let backgroundColor: Color
    private let content: Content

    public init(
        backgroundColor: Color = .clear,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public var body: some View {
        content
            .background(SwiftUIColor(backgroundColor))
    }
}

public extension SUICollectionViewCell where Content == SwiftUI.EmptyView {
    init(backgroundColor: Color = .clear) {
        self.init(backgroundColor: backgroundColor) {
            SwiftUI.EmptyView()
        }
    }
}

#endif
