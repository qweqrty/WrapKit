#if !os(tvOS) && !os(macOS) && !os(watchOS)
import SwiftUI

public struct SUITableViewLazyVStackStyle {
    let scrollable: Bool
    
    public init(scrollable: Bool = false) {
        self.scrollable = scrollable
    }

    @ViewBuilder
    public func makeBody<Cell: Hashable, Header, Footer>(
        sections: [TableSection<Header, Cell, Footer>],
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View
    ) -> some View {
        makeBody(
            sections: sections,
            cellContent: cellContent,
            headerContent: headerContent,
            footerContent: footerContent,
            listHeaderContent: SwiftUI.EmptyView(),
            listFooterContent: SwiftUI.EmptyView()
        )
    }

    @ViewBuilder
    public func makeBody<Cell: Hashable, Header, Footer, ListHeaderContent: View, ListFooterContent: View>(
        sections: [TableSection<Header, Cell, Footer>],
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View,
        listHeaderContent: ListHeaderContent,
        listFooterContent: ListFooterContent
    ) -> some View {
        if scrollable {
            ScrollView {
                content(
                    sections: sections,
                    cellContent: cellContent,
                    headerContent: headerContent,
                    footerContent: footerContent,
                    listHeaderContent: listHeaderContent,
                    listFooterContent: listFooterContent
                )
            }
        } else {
            content(
                sections: sections,
                cellContent: cellContent,
                headerContent: headerContent,
                footerContent: footerContent,
                listHeaderContent: listHeaderContent,
                listFooterContent: listFooterContent
            )
        }
    }

    @ViewBuilder
    private func content<Cell: Hashable, Header, Footer, ListHeaderContent: View, ListFooterContent: View>(
        sections: [TableSection<Header, Cell, Footer>],
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View,
        listHeaderContent: ListHeaderContent,
        listFooterContent: ListFooterContent
    ) -> some View {
        LazyVStack(spacing: .zero) {
            listHeaderContent
            ForEach(sections.indices, id: \.self) { sectionIndex in
                let section = sections[sectionIndex]
                if let header = section.header {
                    headerContent(header)
                }
                ForEach(suiTableIdentifiedCells(section.cells), id: \.id) { identifiedCell in
                    let rowIndex = identifiedCell.rowIndex
                    let cellModel = identifiedCell.model
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    row(
                        cellModel: cellModel,
                        indexPath: indexPath,
                        content: cellContent(cellModel.cell, indexPath)
                    )
                }
                if let footer = section.footer {
                    footerContent(footer)
                }
            }
            listFooterContent
        }
    }

    @ViewBuilder
    private func row<Cell: Hashable, Content: View>(
        cellModel: CellModel<Cell>,
        indexPath: IndexPath,
        content: Content
    ) -> some View {
        if let onTap = cellModel.onTap {
            SwiftUI.Button {
                onTap(indexPath, cellModel.cell)
            } label: {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .rowAccessibilityIdentifier(cellModel.accessibilityIdentifier)
        } else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func rowAccessibilityIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}
#endif
