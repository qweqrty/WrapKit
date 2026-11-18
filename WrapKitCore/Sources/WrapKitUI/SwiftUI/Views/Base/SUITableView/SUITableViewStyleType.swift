#if !os(tvOS) && !os(macOS) && !os(watchOS)
import SwiftUI

public enum SUITableViewStyleType {
    /// A native SwiftUI `List`. Supports row taps, swipe actions, deletion, and reordering.
    case list

    /// A native grouped `List` whose section headers scroll with their rows.
    case groupedList

    /// A lightweight layout for sections and row taps. List-only editing and swipe APIs are unavailable.
    case lazyVStack(scrollable: Bool = false)
    
    @ViewBuilder
    func makeBody<Cell: Hashable, Header, Footer, ListHeaderContent: View, ListFooterContent: View>(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View,
        listHeaderContent: ListHeaderContent,
        listFooterContent: ListFooterContent
    ) -> some View {
        switch self {
        case .list, .groupedList:
            SUITableListView(isGrouped: isGroupedList).makeBody(
                stateModel: stateModel,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent,
                listHeaderContent: listHeaderContent,
                listFooterContent: listFooterContent
            )
        case .lazyVStack(let scrollable):
            SUITableViewLazyVStackStyle(scrollable: scrollable).makeBody(
                sections: stateModel.sections,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent,
                listHeaderContent: listHeaderContent,
                listFooterContent: listFooterContent
            )
        }
    }

    private var isGroupedList: Bool {
        if case .groupedList = self { return true }
        return false
    }
}
#endif
