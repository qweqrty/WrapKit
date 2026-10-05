//
//  SUIScrollableContentView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIScrollableContentView<Content: View>: View {
    private let contentInset: EdgeInsets
    private let showsVerticalScrollIndicator: Bool
    private let backgroundColor: Color
    private let content: Content

    public init(
        contentInset: EdgeInsets = .zero,
        showsVerticalScrollIndicator: Bool = false,
        backgroundColor: Color = .clear,
        @ViewBuilder content: () -> Content
    ) {
        self.contentInset = contentInset
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: showsVerticalScrollIndicator) {
                content
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                    .padding(contentInset.asSUIEdgeInsets)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SwiftUIColor(backgroundColor))
        }
    }
}

public extension SUIScrollableContentView where Content == SwiftUICore.EmptyView {
    init(
        contentInset: EdgeInsets = .zero,
        showsVerticalScrollIndicator: Bool = false,
        backgroundColor: Color = .clear
    ) {
        self.init(
            contentInset: contentInset,
            showsVerticalScrollIndicator: showsVerticalScrollIndicator,
            backgroundColor: backgroundColor
        ) {
            SwiftUICore.EmptyView()
        }
    }
}

#endif
