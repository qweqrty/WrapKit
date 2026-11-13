//
//  SUIFillStackView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIFillStackView<Content: View>: View {
    private let axis: StackViewAxis
    private let spacing: CGFloat
    private let backgroundColor: Color
    private let content: Content

    public init(
        axis: StackViewAxis = .vertical,
        spacing: CGFloat = 0,
        backgroundColor: Color = .clear,
        @ViewBuilder content: () -> Content
    ) {
        self.axis = axis
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(
            SUIFillStackViewLayout(axis: axis, spacing: spacing)
        ) {
            content
        }
        .background(SwiftUIColor(backgroundColor))
    }
}

public extension SUIFillStackView where Content == SwiftUICore.EmptyView {
    init(
        axis: StackViewAxis = .vertical,
        spacing: CGFloat = 0,
        backgroundColor: Color = .clear
    ) {
        self.init(
            axis: axis,
            spacing: spacing,
            backgroundColor: backgroundColor
        ) {
            SwiftUICore.EmptyView()
        }
    }
}

private struct SUIFillStackViewLayout: _VariadicView_MultiViewRoot {
    let axis: StackViewAxis
    let spacing: CGFloat

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        switch axis {
        case .horizontal:
            HStack(spacing: spacing) {
                ForEach(children) { child in
                    child.frame(maxHeight: .infinity)
                }
            }
        case .vertical:
            VStack(spacing: spacing) {
                ForEach(children) { child in
                    child.frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#endif
