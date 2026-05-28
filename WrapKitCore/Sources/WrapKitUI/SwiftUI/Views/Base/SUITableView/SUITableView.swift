//
//  SUITableView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 13/5/26.
//

import SwiftUI

public struct SUITableView<
    Header,
    Cell: Hashable,
    Footer,
    CellContent: View,
    HeaderContent: View,
    FooterContent: View
>: View {
    @ObservedObject var adapter: TableOutputSwiftUIAdapter<Cell, Footer, Header>
    let style: SUITableViewStyleType
    let cellContent: (Cell, IndexPath) -> CellContent
    let headerContent: (Header) -> HeaderContent
    let footerContent: (Footer) -> FooterContent

    public init(
        adapter: TableOutputSwiftUIAdapter<Cell, Footer, Header>,
        style: SUITableViewStyleType = .lazyVStack(),
        @ViewBuilder cellContent: @escaping (Cell, IndexPath) -> CellContent,
        @ViewBuilder headerContent: @escaping (Header) -> HeaderContent,
        @ViewBuilder footerContent: @escaping (Footer) -> FooterContent
    ) {
        self.adapter = adapter
        self.style = style
        self.cellContent = cellContent
        self.headerContent = headerContent
        self.footerContent = footerContent
    }

    public var body: some View {
        let sections = adapter.displaySectionsState?.sections ?? []
        style.makeBody(
            sections: sections,
            cellContent: cellContent,
            headerContent: headerContent,
            footerContent: footerContent
        )
    }
}
