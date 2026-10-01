//
//  SUITagFlowLayout.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUITagFlowLayout<Data, ID, Content>: View where Data: RandomAccessCollection, ID: Hashable, Content: View {
    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let minimumItemWidth: CGFloat
    private let spacing: CGFloat
    private let content: (Data.Element) -> Content

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        minimumItemWidth: CGFloat = 44,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.minimumItemWidth = minimumItemWidth
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: minimumItemWidth),
                    spacing: spacing,
                    alignment: .leading
                )
            ],
            alignment: .leading,
            spacing: spacing
        ) {
            ForEach(data, id: id) { item in
                content(item)
            }
        }
    }
}

public extension SUITagFlowLayout where Data.Element: Identifiable, ID == Data.Element.ID {
    init(
        _ data: Data,
        minimumItemWidth: CGFloat = 44,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            id: \.id,
            minimumItemWidth: minimumItemWidth,
            spacing: spacing,
            content: content
        )
    }
}

#endif
