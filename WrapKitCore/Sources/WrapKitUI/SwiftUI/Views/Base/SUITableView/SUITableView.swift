//
//  SUITableView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 13/5/26.
//

import SwiftUI

struct SUITableRefreshControlHiddenPreferenceKey: PreferenceKey {
    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

public struct SUITableView<
    Header,
    Cell: Hashable,
    Footer,
    CellContent: View,
    HeaderContent: View,
    FooterContent: View
>: View {
    @StateObject private var stateModel: SUITableViewStateModel<Header, Cell, Footer>
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
        _stateModel = StateObject(wrappedValue: SUITableViewStateModel(adapter: adapter))
        self.style = style
        self.cellContent = cellContent
        self.headerContent = headerContent
        self.footerContent = footerContent
    }

    public var body: some View {
        style.makeBody(
            stateModel: stateModel,
            cellContent: cellContent,
            headerContent: headerContent,
            footerContent: footerContent
        )
        .preference(
            key: SUITableRefreshControlHiddenPreferenceKey.self,
            value: stateModel.hidesRefreshControl
        )
    }
}
