//
//  SUIScrollableHStackView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIScrollableHStackView<Content: View>: View {
    private let spacing: CGFloat
    private let contentInset: EdgeInsets
    private let showsHorizontalScrollIndicator: Bool
    private let backgroundColor: Color
    private let content: Content

    public init(
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        showsHorizontalScrollIndicator: Bool = false,
        backgroundColor: Color = .clear,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.contentInset = contentInset
        self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: showsHorizontalScrollIndicator) {
                HStack(spacing: spacing) {
                    content
                }
                .frame(minWidth: proxy.size.width)
                .frame(maxHeight: .infinity)
                .padding(contentInset.asSUIEdgeInsets)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SwiftUIColor(backgroundColor))
        }
    }
}

public extension SUIScrollableHStackView where Content == SwiftUICore.EmptyView {
    init(
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        showsHorizontalScrollIndicator: Bool = false,
        backgroundColor: Color = .clear
    ) {
        self.init(
            spacing: spacing,
            contentInset: contentInset,
            showsHorizontalScrollIndicator: showsHorizontalScrollIndicator,
            backgroundColor: backgroundColor
        ) {
            SwiftUICore.EmptyView()
        }
    }
}

#endif
