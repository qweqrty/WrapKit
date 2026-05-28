import SwiftUI

public struct SUITableListView {
    public init() {}

    @ViewBuilder
    public func makeBody<Cell: Hashable, Header, Footer>(
        sections: [TableSection<Header, Cell, Footer>],
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View
    ) -> some View {
        List {
            ForEach(sections.indices, id: \.self) { sectionIndex in
                let section = sections[sectionIndex]
                Section {
                    ForEach(section.cells.indices, id: \.self) { rowIndex in
                        let cellModel = section.cells[rowIndex]
                        cellContent(cellModel.cell, IndexPath(row: rowIndex, section: sectionIndex))
                            .onTapGesture {
                                cellModel.onTap?(IndexPath(row: rowIndex, section: sectionIndex), cellModel.cell)
                            }
                            .listRowInsets(SwiftUI.EdgeInsets())
                            .listRowBackground(SwiftUI.Color.clear)
                            .if(true) { view in
                                if #available(iOS 15.0, *) {
                                    view.listRowSeparator(.hidden)
                                } else {
                                    view
                                }
                            }
                    }
                } header: {
                    if let header = section.header {
                        headerContent(header)
                    }
                } footer: {
                    if let footer = section.footer {
                        footerContent(footer)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
