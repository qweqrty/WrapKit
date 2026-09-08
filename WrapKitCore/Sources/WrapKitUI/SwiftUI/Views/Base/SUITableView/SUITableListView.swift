import SwiftUI

private let suiTableRowMoveTypeIdentifier = "com.wrapkit.table-row-move"

struct SUITableRowIdentity<Cell: Hashable>: Hashable {
    enum Base: Hashable {
        case accessibilityIdentifier(String)
        case cell(Cell)
    }

    let base: Base
    let occurrence: Int
}

struct SUITableIdentifiedCell<Cell: Hashable> {
    let id: SUITableRowIdentity<Cell>
    let rowIndex: Int
    let model: CellModel<Cell>
}

func suiTableIdentifiedCells<Cell: Hashable>(
    _ cells: [CellModel<Cell>]
) -> [SUITableIdentifiedCell<Cell>] {
    var occurrences: [SUITableRowIdentity<Cell>.Base: Int] = [:]

    return cells.enumerated().map { rowIndex, model in
        let base: SUITableRowIdentity<Cell>.Base
        if let accessibilityIdentifier = model.accessibilityIdentifier {
            base = .accessibilityIdentifier(accessibilityIdentifier)
        } else {
            base = .cell(model.cell)
        }
        let occurrence = occurrences[base, default: 0]
        occurrences[base] = occurrence + 1
        return .init(
            id: .init(base: base, occurrence: occurrence),
            rowIndex: rowIndex,
            model: model
        )
    }
}

func suiTableAllowsRowTap(
    editingStyle _: TableEditingStyle,
    isEditing: Bool
) -> Bool {
    // UITableView keeps allowsSelectionDuringEditing disabled by default.
    // The shared TableOutput contract does not expose an override, so every
    // row style must preserve that default while edit mode is active.
    !isEditing
}

struct SUITableIndexedSwipeAction<Cell> {
    let sourceIndex: Int
    let action: TableContextualAction<Cell>
}

func suiTableProgrammaticTrailingActions<Cell>(
    _ actions: [TableContextualAction<Cell>]
) -> [SUITableIndexedSwipeAction<Cell>] {
    actions.enumerated().reversed().compactMap { sourceIndex, action in
        guard action.hasVisibleContent else { return nil }
        return .init(sourceIndex: sourceIndex, action: action)
    }
}

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
                    ForEach(suiTableIdentifiedCells(section.cells), id: \.id) { row in
                        let rowIndex = row.rowIndex
                        let cellModel = row.model
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

    @ViewBuilder
    public func makeBody<Cell: Hashable, Header, Footer>(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        cellContent: @escaping (Cell, IndexPath) -> some View,
        headerContent: @escaping (Header) -> some View,
        footerContent: @escaping (Footer) -> some View
    ) -> some View {
        SUITableInteractiveListContent(
            stateModel: stateModel,
            cellContent: cellContent,
            headerContent: headerContent,
            footerContent: footerContent
        )
    }
}

private struct SUITableInteractiveListContent<
    Header,
    Cell: Hashable,
    Footer,
    CellContent: View,
    HeaderContent: View,
    FooterContent: View
>: View {
    @ObservedObject private var stateModel: SUITableViewStateModel<Header, Cell, Footer>
#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif
    private let cellContent: (Cell, IndexPath) -> CellContent
    private let headerContent: (Header) -> HeaderContent
    private let footerContent: (Footer) -> FooterContent

    init(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        @ViewBuilder cellContent: @escaping (Cell, IndexPath) -> CellContent,
        @ViewBuilder headerContent: @escaping (Header) -> HeaderContent,
        @ViewBuilder footerContent: @escaping (Footer) -> FooterContent
    ) {
        self.stateModel = stateModel
        self.cellContent = cellContent
        self.headerContent = headerContent
        self.footerContent = footerContent
    }

    @ViewBuilder
    var body: some View {
        let sections = stateModel.sections
        List {
            ForEach(sections.indices, id: \.self) { sectionIndex in
                let section = sections[sectionIndex]
                Section {
                    ForEach(suiTableIdentifiedCells(section.cells), id: \.id) { row in
                        let rowIndex = row.rowIndex
                        let cellModel = row.model
                        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                        tableRow(
                            cellModel: cellModel,
                            indexPath: indexPath,
                            isEditing: isEditing
                        )
                            .deleteDisabled(!stateModel.isDeletable(at: indexPath))
                            .moveDisabled(!stateModel.isMovable(at: indexPath))
                            .suiTableRowDragSource(
                                stateModel: stateModel,
                                indexPath: indexPath,
                                isEnabled: isEditing && stateModel.isMovable(at: indexPath)
                            )
                            .suiTableRowDropTarget(
                                stateModel: stateModel,
                                indexPath: indexPath,
                                isEnabled: isEditing && stateModel.canReceiveRowDrop(at: indexPath)
                            )
                            .onTapGesture {
                                stateModel.collapseTrailingActions()
                                guard suiTableAllowsRowTap(
                                    editingStyle: cellModel.editingStyle,
                                    isEditing: isEditing
                                ) else { return }
                                cellModel.onTap?(indexPath, cellModel.cell)
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
                    .onDelete(perform: stateModel.deleteAction(
                        in: sectionIndex,
                        isEditing: isEditing
                    ))
                    .onMove(perform: stateModel.moveAction(in: sectionIndex))

                    if section.cells.isEmpty, isEditing, stateModel.supportsMoving {
                        SUITableEmptySectionDropTarget(
                            stateModel: stateModel,
                            destination: IndexPath(row: 0, section: sectionIndex)
                        )
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

    @ViewBuilder
    private func tableRow(
        cellModel: CellModel<Cell>,
        indexPath: IndexPath,
        isEditing: Bool
    ) -> some View {
        SUITableInteractiveRow(
            stateModel: stateModel,
            indexPath: indexPath,
            isEditing: isEditing,
            cellContent: cellContent(cellModel.cell, indexPath),
            onAccessibilityActivate: suiTableAllowsRowTap(
                editingStyle: cellModel.editingStyle,
                isEditing: isEditing
            ) ? {
                stateModel.collapseTrailingActions()
                cellModel.onTap?(indexPath, cellModel.cell)
            } : nil
        )
    }

    private var isEditing: Bool {
#if os(iOS)
        editMode?.wrappedValue.isEditing == true
#else
        true
#endif
    }
}

private extension View {
    @ViewBuilder
    func suiTableActionAccessibility(title: String?) -> some View {
        if let title {
            accessibilityLabel(SwiftUI.Text(title))
        } else {
            self
        }
    }

    @ViewBuilder
    func suiTableRowDragSource<Header, Cell: Hashable, Footer>(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        indexPath: IndexPath,
        isEnabled: Bool
    ) -> some View {
#if os(iOS)
        if isEnabled {
            onDrag {
                guard stateModel.beginDragging(at: indexPath) else {
                    return NSItemProvider()
                }
                let provider = NSItemProvider()
                provider.registerDataRepresentation(
                    forTypeIdentifier: suiTableRowMoveTypeIdentifier,
                    visibility: .ownProcess
                ) { completion in
                    completion(Data(), nil)
                    return nil
                }
                return provider
            }
        } else {
            self
        }
#else
        self
#endif
    }

    @ViewBuilder
    func suiTableRowDropTarget<Header, Cell: Hashable, Footer>(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        indexPath: IndexPath,
        isEnabled: Bool
    ) -> some View {
#if os(iOS)
        modifier(SUITableRowDropTargetModifier(
            stateModel: stateModel,
            indexPath: indexPath,
            isEnabled: isEnabled
        ))
#else
        self
#endif
    }
}

#if os(iOS)
private struct SUITableRowDropTargetModifier<
    Header,
    Cell: Hashable,
    Footer
>: ViewModifier {
    @ObservedObject var stateModel: SUITableViewStateModel<Header, Cell, Footer>
    let indexPath: IndexPath
    let isEnabled: Bool

    @State private var targetHeight: CGFloat = 0

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .background {
                    GeometryReader { geometry in
                        SwiftUI.Color.clear
                            .onAppear { targetHeight = geometry.size.height }
                            .onChange(of: geometry.size.height) { targetHeight = $0 }
                            .allowsHitTesting(false)
                    }
                }
                .onDrop(
                    of: [suiTableRowMoveTypeIdentifier],
                    delegate: SUITableRowDropDelegate(
                        stateModel: stateModel,
                        target: indexPath,
                        targetHeight: targetHeight
                    )
                )
        } else {
            content
        }
    }
}

private struct SUITableRowDropDelegate<Header, Cell: Hashable, Footer>: DropDelegate {
    let stateModel: SUITableViewStateModel<Header, Cell, Footer>
    let target: IndexPath
    let targetHeight: CGFloat

    func validateDrop(info: DropInfo) -> Bool {
        destination(for: info) != nil
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: destination(for: info) == nil ? .forbidden : .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let destination = destination(for: info) else { return false }
        return stateModel.performDrop(at: destination)
    }

    private func destination(for info: DropInfo) -> IndexPath? {
        let isInsertControl: Bool
        if case .insert = stateModel.editingStyle(at: target) {
            isInsertControl = true
        } else {
            isInsertControl = false
        }

        return stateModel.dropDestination(
            relativeTo: target,
            placeAfterTarget: !isInsertControl && info.location.y >= targetHeight / 2
        )
    }
}

private struct SUITableEmptySectionDropTarget<Header, Cell: Hashable, Footer>: View {
    @ObservedObject var stateModel: SUITableViewStateModel<Header, Cell, Footer>
    let destination: IndexPath

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(SwiftUI.Color.accentColor.opacity(0.08))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        SwiftUI.Color.accentColor.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                    )
            }
            .frame(height: 44)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onDrop(
                of: [suiTableRowMoveTypeIdentifier],
                delegate: SUITableEmptySectionDropDelegate(
                    stateModel: stateModel,
                    destination: destination
                )
            )
    }
}

private struct SUITableEmptySectionDropDelegate<Header, Cell: Hashable, Footer>: DropDelegate {
    let stateModel: SUITableViewStateModel<Header, Cell, Footer>
    let destination: IndexPath

    func validateDrop(info _: DropInfo) -> Bool {
        stateModel.canDrop(at: destination)
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(
            operation: stateModel.canDrop(at: destination) ? .move : .forbidden
        )
    }

    func performDrop(info _: DropInfo) -> Bool {
        stateModel.performDrop(at: destination)
    }
}
#endif

private struct SUITableTrailingActionsWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct SUITableInteractiveRow<
    Header,
    Cell: Hashable,
    Footer,
    CellContent: View
>: View {
    @ObservedObject private var stateModel: SUITableViewStateModel<Header, Cell, Footer>
    @State private var trailingActionsWidth: CGFloat = 0
    private let indexPath: IndexPath
    private let isEditing: Bool
    private let cellContent: CellContent
    private let onAccessibilityActivate: (() -> Void)?

    init(
        stateModel: SUITableViewStateModel<Header, Cell, Footer>,
        indexPath: IndexPath,
        isEditing: Bool,
        cellContent: CellContent,
        onAccessibilityActivate: (() -> Void)?
    ) {
        self.stateModel = stateModel
        self.indexPath = indexPath
        self.isEditing = isEditing
        self.cellContent = cellContent
        self.onAccessibilityActivate = onAccessibilityActivate
    }

    @ViewBuilder
    var body: some View {
#if os(iOS)
        switch stateModel.editingStyle(at: indexPath) {
        case .insert:
            insertionRowContent
        case .delete, .none:
            if stateModel.isEditable(at: indexPath) {
                programmaticRevealContent
                    .swipeActions(
                        edge: .leading,
                        allowsFullSwipe: SUITableSwipeConfiguration.allowsFullSwipe
                    ) {
                        nativeContextualActions(
                            stateModel.swipeActions(at: indexPath, edge: .leading)
                        )
                    }
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: SUITableSwipeConfiguration.allowsFullSwipe
                    ) {
                        nativeContextualActions(trailingActions)
                    }
            } else {
                accessibleCellContent
            }
        }
#else
        accessibleCellContent
#endif
    }

    @ViewBuilder
    private var accessibleCellContent: some View {
        if let onAccessibilityActivate {
            cellContent.accessibilityAction {
                onAccessibilityActivate()
            }
        } else {
            cellContent
        }
    }

#if os(iOS)
    @ViewBuilder
    private var insertionRowContent: some View {
        if isEditing, stateModel.isInsertable(at: indexPath) {
            HStack(spacing: 0) {
                SwiftUI.Button {
                    stateModel.performInsertion(at: indexPath)
                } label: {
                    SwiftUI.Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(SwiftUIColor(.systemGreen))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(SwiftUI.Text("Insert row"))
                .accessibilityIdentifier(
                    "wrapkit.table.insert.\(indexPath.section).\(indexPath.row)"
                )

                accessibleCellContent
            }
        } else {
            accessibleCellContent
        }
    }

    @ViewBuilder
    private var programmaticRevealContent: some View {
        ZStack(alignment: .trailing) {
            if showsProgrammaticTrailingActions {
                programmaticTrailingActions
            }

            accessibleCellContent
                .offset(x: showsProgrammaticTrailingActions ? -trailingActionsWidth : 0)
        }
        .clipped()
        .simultaneousGesture(
            DragGesture(minimumDistance: 4)
                .onChanged { _ in
                    stateModel.collapseTrailingActions(at: indexPath)
                },
            including: showsProgrammaticTrailingActions ? .all : .none
        )
        .animation(.easeInOut(duration: 0.2), value: showsProgrammaticTrailingActions)
        .animation(.easeInOut(duration: 0.2), value: trailingActionsWidth)
    }

    private var programmaticTrailingActions: some View {
        HStack(spacing: 0) {
            ForEach(
                suiTableProgrammaticTrailingActions(trailingActions),
                id: \.sourceIndex
            ) { indexedAction in
                let action = indexedAction.action
                SwiftUI.Button(role: buttonRole(for: action.style)) {
                    stateModel.performSwipeAction(action, at: indexPath)
                } label: {
                    contextualActionLabel(action)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(
                            minWidth: SUITableSwipeConfiguration.minimumProgrammaticActionWidth,
                            maxHeight: .infinity
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(programmaticBackgroundColor(for: action))
                .suiTableActionAccessibility(title: action.title)
                .accessibilityIdentifier(
                    "wrapkit.table.trailing.\(indexPath.section).\(indexPath.row).\(indexedAction.sourceIndex)"
                )
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .background {
            GeometryReader { geometry in
                SwiftUI.Color.clear.preference(
                    key: SUITableTrailingActionsWidthPreferenceKey.self,
                    value: geometry.size.width
                )
            }
        }
        .onPreferenceChange(SUITableTrailingActionsWidthPreferenceKey.self) { width in
            trailingActionsWidth = width
        }
    }

    @ViewBuilder
    private func nativeContextualActions(
        _ actions: [TableContextualAction<Cell>]
    ) -> some View {
        ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
            if action.title != nil || action.image != nil {
                SwiftUI.Button(role: buttonRole(for: action.style)) {
                    stateModel.performSwipeAction(action, at: indexPath)
                } label: {
                    contextualActionLabel(action)
                }
                .tint(contextualActionColor(for: action))
            }
        }
    }

    private var trailingActions: [TableContextualAction<Cell>] {
        stateModel.swipeActions(at: indexPath, edge: .trailing)
    }

    private var showsProgrammaticTrailingActions: Bool {
        stateModel.areTrailingActionsExpanded(at: indexPath) &&
            trailingActions.contains(where: \.hasVisibleContent)
    }

    private func programmaticBackgroundColor(
        for action: TableContextualAction<Cell>
    ) -> SwiftUI.Color {
        contextualActionColor(for: action)
    }

    private func contextualActionColor(
        for action: TableContextualAction<Cell>
    ) -> SwiftUI.Color {
        if let backgroundColor = action.backgroundColor {
            return SwiftUIColor(backgroundColor)
        }
        switch action.style {
        case .destructive:
            return .red
        case .normal:
            return .gray
        }
    }

    @ViewBuilder
    private func contextualActionLabel(_ action: TableContextualAction<Cell>) -> some View {
        if let title = action.title, let image = action.image {
            SwiftUI.Label {
                SwiftUI.Text(title)
            } icon: {
                SwiftUIImage(image: image)
            }
        } else if let image = action.image {
            SwiftUIImage(image: image)
        } else if let title = action.title {
            SwiftUI.Text(title)
        }
    }

    private func buttonRole(for style: TableContextualAction<Cell>.Style) -> SwiftUI.ButtonRole? {
        switch style {
        case .destructive:
            return .destructive
        case .normal:
            return nil
        }
    }
#endif
}
