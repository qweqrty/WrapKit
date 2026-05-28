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
                ForEach(section.cells.indices, id: \.self) { rowIndex in
                    let cellModel = section.cells[rowIndex]
                    cellContent(cellModel.cell, IndexPath(row: rowIndex, section: sectionIndex))
                        .id("\(sectionIndex)_\(rowIndex)")
                        .onTapGesture {
                            cellModel.onTap?(IndexPath(row: rowIndex, section: sectionIndex), cellModel.cell)
                        }
                }
                if let footer = section.footer {
                    footerContent(footer)
                }
            }
        }
    }
}
