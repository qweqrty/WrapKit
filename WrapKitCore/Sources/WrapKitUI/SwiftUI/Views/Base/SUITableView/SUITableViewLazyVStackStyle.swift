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
        if scrollable {
            ScrollView {
                content(sections: sections, cellContent: cellContent, headerContent: headerContent, footerContent: footerContent)
            }
        } else {
            content(sections: sections, cellContent: cellContent, headerContent: headerContent, footerContent: footerContent)
        }
    }
    
    @ViewBuilder
    private func content<Cell: Hashable, Header, Footer>(
        sections: [TableSection<Header, Cell, Footer>],
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View
    ) -> some View {
        LazyVStack(spacing: .zero) {
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
        } else {
            content
        }
    }
}
