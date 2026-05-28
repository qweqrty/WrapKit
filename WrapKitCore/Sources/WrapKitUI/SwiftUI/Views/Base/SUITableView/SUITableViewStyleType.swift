import SwiftUI

public enum SUITableViewStyleType {
    case list
    case lazyVStack(scrollable: Bool = false)
    
    @ViewBuilder
    func makeBody<Cell: Hashable, Header, Footer>(
        sections: [TableSection<Header, Cell, Footer>],
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View
    ) -> some View {
        switch self {
        case .list:
            SUITableListView().makeBody(
                sections: sections,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent
            )
        case .lazyVStack(let scrollable):
            SUITableViewLazyVStackStyle(scrollable: scrollable).makeBody(
                sections: sections,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent
            )
        }
    }
}
