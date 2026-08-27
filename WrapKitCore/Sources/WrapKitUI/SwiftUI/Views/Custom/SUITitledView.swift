//
//  SUITitledView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUITitledView<Content: View>: View {
    @StateObject private var stateModel: SUITitledViewStateModel

    private let spacing: CGFloat
    private let content: Content

    public init(
        adapter: TitledOutputSwiftUIAdapter,
        spacing: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.spacing = spacing
        self.content = content()
    }

    init(
        stateModel: SUITitledViewStateModel,
        spacing: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        _stateModel = .init(wrappedValue: stateModel)
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if !stateModel.isHidden {
            VStack(spacing: spacing) {
                SUIHKeyValueFieldView(
                    adapter: stateModel.titlesAdapter,
                    keyFont: .systemFont(ofSize: 20),
                    keyTextColor: .label,
                    valueFont: .systemFont(ofSize: 20),
                    valueTextColor: .label,
                    keyLineLimit: nil,
                    valueLineLimit: nil,
                    keyMinimumScaleFactor: 1,
                    valueMinimumScaleFactor: 1
                )

                ZStack {
                    SwiftUIColor.clear
                        .frame(height: 0)
                    content
                }

                SUIHKeyValueFieldView(
                    adapter: stateModel.bottomTitlesAdapter,
                    keyFont: .systemFont(ofSize: 18),
                    valueFont: .systemFont(ofSize: 14),
                    valueTextColor: .gray,
                    keyMinimumScaleFactor: 1,
                    isHidden: true
                )
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .top)
            .allowsHitTesting(stateModel.isUserInteractionEnabled)
        }
    }
}

public extension SUITitledView where Content == SwiftUICore.EmptyView {
    init(
        adapter: TitledOutputSwiftUIAdapter,
        spacing: CGFloat = 4
    ) {
        self.init(adapter: adapter, spacing: spacing) {
            SwiftUICore.EmptyView()
        }
    }
}

#endif
