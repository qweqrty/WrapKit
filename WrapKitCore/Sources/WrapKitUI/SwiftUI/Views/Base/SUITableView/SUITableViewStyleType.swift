import SwiftUI

public enum SUITableViewStyleType {
    /// A native SwiftUI `List`. Supports row taps, swipe actions, deletion, and reordering.
    case list

    /// A lightweight layout for sections and row taps. List-only editing and swipe APIs are unavailable.
    case lazyVStack(scrollable: Bool = false)
    
    @ViewBuilder
    func makeBody<Cell: Hashable, Header, Footer>(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View
    ) -> some View {
        switch self {
        case .list:
            SUITableListView().makeBody(
                stateModel: stateModel,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent
            )
        case .lazyVStack(let scrollable):
            SUITableViewLazyVStackStyle(scrollable: scrollable).makeBody(
                sections: stateModel.sections,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent
            )
        }
    }
}
