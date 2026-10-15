//
//  SUITableView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 13/5/26.
//

#if !os(tvOS) && !os(macOS) && !os(watchOS)
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
    FooterContent: View,
    ListHeaderContent: View,
    ListFooterContent: View
>: View {
    @StateObject private var stateModel: SUITableViewStateModel<Header, Cell, Footer>
    let style: SUITableViewStyleType
    let cellContent: (Cell, IndexPath) -> CellContent
    let headerContent: (Header) -> HeaderContent
    let footerContent: (Footer) -> FooterContent
    let listHeaderContent: ListHeaderContent
    let listFooterContent: ListFooterContent

    public init(
        adapter: TableOutputSwiftUIAdapter<Cell, Footer, Header>,
        style: SUITableViewStyleType = .lazyVStack(),
        @ViewBuilder cellContent: @escaping (Cell, IndexPath) -> CellContent,
        @ViewBuilder headerContent: @escaping (Header) -> HeaderContent,
        @ViewBuilder footerContent: @escaping (Footer) -> FooterContent,
        @ViewBuilder listHeaderContent: () -> ListHeaderContent,
        @ViewBuilder listFooterContent: () -> ListFooterContent
    ) {
        _stateModel = StateObject(wrappedValue: SUITableViewStateModel(adapter: adapter))
        self.style = style
        self.cellContent = cellContent
        self.headerContent = headerContent
        self.footerContent = footerContent
        self.listHeaderContent = listHeaderContent()
        self.listFooterContent = listFooterContent()
    }

    public var body: some View {
        style.makeBody(
            stateModel: stateModel,
            cellContent: cellContent,
            headerContent: headerContent,
            footerContent: footerContent,
            listHeaderContent: listHeaderContent,
            listFooterContent: listFooterContent
        )
        .preference(
            key: SUITableRefreshControlHiddenPreferenceKey.self,
            value: stateModel.hidesRefreshControl
        )
    }
}

public extension SUITableView where ListHeaderContent == SwiftUI.EmptyView, ListFooterContent == SwiftUI.EmptyView {
    init(
        adapter: TableOutputSwiftUIAdapter<Cell, Footer, Header>,
        style: SUITableViewStyleType = .lazyVStack(),
        @ViewBuilder cellContent: @escaping (Cell, IndexPath) -> CellContent,
        @ViewBuilder headerContent: @escaping (Header) -> HeaderContent,
        @ViewBuilder footerContent: @escaping (Footer) -> FooterContent
    ) {
        self.init(
            adapter: adapter,
            style: style,
            cellContent: cellContent,
            headerContent: headerContent,
            footerContent: footerContent,
            listHeaderContent: { SwiftUI.EmptyView() },
            listFooterContent: { SwiftUI.EmptyView() }
        )
    }
}
#endif
