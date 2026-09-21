//
//  SUICollectionView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public enum SUICollectionViewLayout {
    case lazyVGrid(columns: [GridItem])
    case lazyHGrid(rows: [GridItem])
    case grid(columns: Int)
}

public struct SUICollectionView<Data, ID, CellContent>: View where Data: RandomAccessCollection, ID: Hashable, CellContent: View {
    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let layout: SUICollectionViewLayout
    private let spacing: CGFloat
    private let contentInset: EdgeInsets
    private let showsIndicators: Bool
    private let isScrollEnabled: Bool
    private let backgroundColor: Color
    private let emptyPlaceholderView: AnyView?
    private let cellContent: (Data.Element) -> CellContent

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        layout: SUICollectionViewLayout = .lazyVGrid(columns: [.init(.flexible())]),
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        showsIndicators: Bool = false,
        isScrollEnabled: Bool = true,
        backgroundColor: Color = .clear,
        emptyPlaceholderView: AnyView? = nil,
        @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent
    ) {
        self.data = data
        self.id = id
        self.layout = layout
        self.spacing = spacing
        self.contentInset = contentInset
        self.showsIndicators = showsIndicators
        self.isScrollEnabled = isScrollEnabled
        self.backgroundColor = backgroundColor
        self.emptyPlaceholderView = emptyPlaceholderView
        self.cellContent = cellContent
    }

    public var body: some View {
        ZStack {
            if data.isEmpty {
                emptyPlaceholderView
            }

            collectionContent
        }
        .background(SwiftUIColor(backgroundColor))
        .disabled(!isScrollEnabled)
    }

    @ViewBuilder
    private var collectionContent: some View {
        switch layout {
        case .lazyVGrid(let columns):
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                LazyVGrid(columns: columns, spacing: spacing) {
                    cells
                }
                .padding(contentInset.asSUIEdgeInsets)
            }

        case .lazyHGrid(let rows):
            ScrollView(.horizontal, showsIndicators: showsIndicators) {
                LazyHGrid(rows: rows, spacing: spacing) {
                    cells
                }
                .padding(contentInset.asSUIEdgeInsets)
            }

        case .grid(let columns):
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
                    grid(columns: columns)
                } else {
                    LazyVGrid(columns: fallbackColumns(columns), spacing: spacing) {
                        cells
                    }
                }
            }
            .padding(contentInset.asSUIEdgeInsets)
        }
    }

    @ViewBuilder
    private var cells: some View {
        ForEach(data, id: id) { item in
            cellContent(item)
        }
    }

    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    private func grid(columns: Int) -> some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(gridRows(columns: columns).indices, id: \.self) { rowIndex in
                GridRow {
                    ForEach(gridRows(columns: columns)[rowIndex], id: id) { item in
                        cellContent(item)
                    }
                }
            }
        }
    }

    private func gridRows(columns: Int) -> [[Data.Element]] {
        let items = Array(data)
        let columns = max(columns, 1)
        return stride(from: 0, to: items.count, by: columns).map { startIndex in
            Array(items[startIndex..<min(startIndex + columns, items.count)])
        }
    }

    private func fallbackColumns(_ columns: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(columns, 1))
    }
}

public extension SUICollectionView where Data.Element: Identifiable, ID == Data.Element.ID {
    init(
        _ data: Data,
        layout: SUICollectionViewLayout = .lazyVGrid(columns: [.init(.flexible())]),
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        showsIndicators: Bool = false,
        isScrollEnabled: Bool = true,
        backgroundColor: Color = .clear,
        emptyPlaceholderView: AnyView? = nil,
        @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent
    ) {
        self.init(
            data,
            id: \.id,
            layout: layout,
            spacing: spacing,
            contentInset: contentInset,
            showsIndicators: showsIndicators,
            isScrollEnabled: isScrollEnabled,
            backgroundColor: backgroundColor,
            emptyPlaceholderView: emptyPlaceholderView,
            cellContent: cellContent
        )
    }
}

#endif
