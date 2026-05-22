//
//  SUIStackView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIStackView<Content: View>: View {
    @StateObject private var stateModel: SUIStackViewStateModel

    private let backgroundColor: Color
    private let clipsToBounds: Bool
    private let content: Content

    public init(
        adapter: StackViewOutputSwiftUIAdapter = StackViewOutputSwiftUIAdapter(),
        backgroundColor: Color = .clear,
        distribution: StackViewDistribution = .fill,
        alignment: StackViewAlignment = .fill,
        axis: StackViewAxis = .horizontal,
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        clipsToBounds: Bool = false,
        isHidden: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        _stateModel = .init(
            wrappedValue: .init(
                adapter: adapter,
                axis: axis,
                distribution: distribution,
                alignment: alignment,
                spacing: spacing,
                layoutMargins: contentInset,
                isHidden: isHidden
            )
        )
        self.backgroundColor = backgroundColor
        self.clipsToBounds = clipsToBounds
        self.content = content()
    }

    public var body: some View {
        if !stateModel.isHidden {
            _VariadicView.Tree(
                SUIStackViewLayout(
                    axis: stateModel.axis,
                    distribution: stateModel.distribution,
                    alignment: stateModel.alignment,
                    spacing: stateModel.spacing
                )
            ) {
                content
            }
            .padding(stateModel.layoutMargins.asSUIEdgeInsets)
            .background(SwiftUIColor(backgroundColor))
            .if(clipsToBounds) { $0.clipped() }
        }
    }
}

public extension SUIStackView where Content == SwiftUICore.EmptyView {
    init(
        adapter: StackViewOutputSwiftUIAdapter = StackViewOutputSwiftUIAdapter(),
        backgroundColor: Color = .clear,
        distribution: StackViewDistribution = .fill,
        alignment: StackViewAlignment = .fill,
        axis: StackViewAxis = .horizontal,
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        clipsToBounds: Bool = false,
        isHidden: Bool = false
    ) {
        self.init(
            adapter: adapter,
            backgroundColor: backgroundColor,
            distribution: distribution,
            alignment: alignment,
            axis: axis,
            spacing: spacing,
            contentInset: contentInset,
            clipsToBounds: clipsToBounds,
            isHidden: isHidden
        ) {
            SwiftUICore.EmptyView()
        }
    }
}

private struct SUIStackViewLayout: _VariadicView_MultiViewRoot {
    let axis: StackViewAxis
    let distribution: StackViewDistribution
    let alignment: StackViewAlignment
    let spacing: CGFloat

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        switch axis {
        case .horizontal:
            horizontalStack(children: children)
        case .vertical:
            verticalStack(children: children)
        }
    }

    private func horizontalStack(children: _VariadicView.Children) -> some View {
        HStack(alignment: verticalAlignment, spacing: stackSpacing) {
            ForEach(children) { child in
                horizontalChild(child)
            }
        }
    }

    private func verticalStack(children: _VariadicView.Children) -> some View {
        VStack(alignment: horizontalAlignment, spacing: stackSpacing) {
            ForEach(children) { child in
                verticalChild(child)
            }
        }
    }

    @ViewBuilder
    private func horizontalChild(_ child: _VariadicView.Children.Element) -> some View {
        switch distribution {
        case .fillEqually:
            child.frame(maxWidth: .infinity)
        default:
            child
        }
    }

    @ViewBuilder
    private func verticalChild(_ child: _VariadicView.Children.Element) -> some View {
        switch distribution {
        case .fillEqually:
            child.frame(maxHeight: .infinity)
        default:
            child
        }
    }

    private var stackSpacing: CGFloat? {
        switch distribution {
        case .equalSpacing, .equalCentering:
            return nil
        default:
            return spacing
        }
    }

    private var verticalAlignment: VerticalAlignment {
        switch alignment {
        case .top, .leading:
            return .top
        case .center:
            return .center
        case .bottom, .trailing:
            return .bottom
        case .firstBaseline:
            return .firstTextBaseline
        case .lastBaseline:
            return .lastTextBaseline
        case .fill:
            return .center
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
        switch alignment {
        case .leading, .top:
            return .leading
        case .center:
            return .center
        case .trailing, .bottom:
            return .trailing
        case .fill, .firstBaseline, .lastBaseline:
            return .center
        }
    }
}

#endif
