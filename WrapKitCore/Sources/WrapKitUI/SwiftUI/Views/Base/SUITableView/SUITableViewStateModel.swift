import Combine
import Foundation

enum SUITableSwipeEdge {
    case leading
    case trailing
}

enum SUITableSwipeConfiguration {
    static let allowsFullSwipe = true
    static let minimumProgrammaticActionWidth: CGFloat = 74
}

public final class SUITableViewStateModel<Header, Cell: Hashable, Footer>: ObservableObject {
    @Published private(set) var sections: [TableSection<Header, Cell, Footer>] = []
    @Published private(set) var trailingSwipeActions: ((IndexPath) -> [TableContextualAction<Cell>])?
    @Published private(set) var leadingSwipeActions: ((IndexPath) -> [TableContextualAction<Cell>])?
    @Published private(set) var move: ((IndexPath, IndexPath) -> Void)?
    @Published private(set) var canMove: ((IndexPath) -> Bool)?
    @Published private(set) var canEdit: ((IndexPath) -> Bool)?
    @Published private(set) var commitEditing: ((TableEditingStyle, IndexPath) -> Void)?
    @Published private(set) var expandedTrailingActionsIndexPath: IndexPath?
    @Published private(set) var hidesRefreshControl = false
    @Published private(set) var draggedIndexPath: IndexPath?

    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: TableOutputSwiftUIAdapter<Cell, Footer, Header>) {
        adapter.$displaySectionsState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.sections = state.sections
                self?.expandedTrailingActionsIndexPath = nil
                self?.draggedIndexPath = nil
            }
            .store(in: &cancellables)

        adapter.$displayTrailingSwipeActionsForIndexPathState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.trailingSwipeActions = state.trailingSwipeActionsForIndexPath
                self?.collapseUnavailableTrailingActions()
            }
            .store(in: &cancellables)

        adapter.$displayLeadingSwipeActionsForIndexPathState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.leadingSwipeActions = state.leadingSwipeActionsForIndexPath
            }
            .store(in: &cancellables)

        adapter.$displayMoveState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.move = state.move
            }
            .store(in: &cancellables)

        adapter.$displayCanMoveState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.canMove = state.canMove
            }
            .store(in: &cancellables)

        adapter.$displayCanEditState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.canEdit = state.canEdit
                self?.collapseUnavailableTrailingActions()
            }
            .store(in: &cancellables)

        adapter.$displayCommitEditingState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.commitEditing = state.commitEditing
            }
            .store(in: &cancellables)

        adapter.$displayIndexPathState
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.expandTrailingActions(at: state.indexPath)
            }
            .store(in: &cancellables)

        adapter.$displayHideRefreshControlState
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.hidesRefreshControl = true
            }
            .store(in: &cancellables)
    }

    func isEditable(at indexPath: IndexPath) -> Bool {
        cellModel(at: indexPath) != nil && (canEdit?(indexPath) ?? true)
    }

    func editingStyle(at indexPath: IndexPath) -> TableEditingStyle {
        cellModel(at: indexPath)?.editingStyle ?? .none
    }

    func isDeletable(at indexPath: IndexPath) -> Bool {
        guard isEditable(at: indexPath), commitEditing != nil else { return false }
        if case .delete = editingStyle(at: indexPath) {
            return true
        }
        return false
    }

    func isInsertable(at indexPath: IndexPath) -> Bool {
        guard isEditable(at: indexPath), commitEditing != nil else { return false }
        if case .insert = editingStyle(at: indexPath) {
            return true
        }
        return false
    }

    func isMovable(at indexPath: IndexPath) -> Bool {
        guard cellModel(at: indexPath) != nil else { return false }
        if hasInsertEditingStyle(at: indexPath) {
            return false
        }
        return canMove?(indexPath) ?? false
    }

    var supportsMoving: Bool {
        move != nil
    }

    func areTrailingActionsExpanded(at indexPath: IndexPath) -> Bool {
        expandedTrailingActionsIndexPath == indexPath
    }

    func collapseTrailingActions() {
        expandedTrailingActionsIndexPath = nil
    }

    func collapseTrailingActions(at indexPath: IndexPath) {
        guard expandedTrailingActionsIndexPath == indexPath else { return }
        collapseTrailingActions()
    }

    func swipeActions(
        at indexPath: IndexPath,
        edge: SUITableSwipeEdge
    ) -> [TableContextualAction<Cell>] {
        guard isEditable(at: indexPath) else { return [] }
        if hasInsertEditingStyle(at: indexPath) {
            return []
        }
        switch edge {
        case .leading:
            return leadingSwipeActions?(indexPath) ?? []
        case .trailing:
            return trailingSwipeActions?(indexPath) ?? []
        }
    }

    @discardableResult
    func performSwipeAction(
        _ action: TableContextualAction<Cell>,
        at indexPath: IndexPath
    ) -> Bool {
        guard isEditable(at: indexPath),
              !hasInsertEditingStyle(at: indexPath),
              let cell = cell(at: indexPath) else {
            collapseTrailingActions(at: indexPath)
            return false
        }
        collapseTrailingActions()
        action.onPress?(cell)
        return true
    }

    func deleteAction(in section: Int, isEditing: Bool = true) -> ((IndexSet) -> Void)? {
        guard isEditing, commitEditing != nil else { return nil }
        return { [weak self] offsets in
            self?.commitDeletion(in: section, offsets: offsets)
        }
    }

    @discardableResult
    func performInsertion(at indexPath: IndexPath) -> Bool {
        guard isInsertable(at: indexPath), let commitEditing else { return false }
        commitEditing(.insert, indexPath)
        return true
    }

    func moveAction(in section: Int) -> ((IndexSet, Int) -> Void)? {
        guard move != nil else { return nil }
        return { [weak self] offsets, destination in
            self?.commitMove(in: section, offsets: offsets, destination: destination)
        }
    }

    @discardableResult
    func beginDragging(at indexPath: IndexPath) -> Bool {
        guard supportsMoving, isMovable(at: indexPath) else {
            draggedIndexPath = nil
            return false
        }
        draggedIndexPath = indexPath
        collapseTrailingActions()
        return true
    }

    func canDrop(at indexPath: IndexPath) -> Bool {
        guard supportsMoving,
              draggedIndexPath != nil,
              sections.indices.contains(indexPath.section)
        else { return false }
        return (0 ... sections[indexPath.section].cells.count).contains(indexPath.row)
    }

    func canReceiveRowDrop(at indexPath: IndexPath) -> Bool {
        // UITableView's canMoveRowAt contract restricts only the source row.
        // Any existing row can therefore be a destination, including a row
        // whose own move handle is disabled.
        cellModel(at: indexPath) != nil
    }

    func dropDestination(
        relativeTo target: IndexPath,
        placeAfterTarget: Bool
    ) -> IndexPath? {
        guard let source = draggedIndexPath,
              cellModel(at: target) != nil else { return nil }

        var destinationRow = target.row + (placeAfterTarget ? 1 : 0)

        // The drop target is expressed in the table before the source row is
        // removed. TableOutput.move, just like UITableView, receives the final
        // destination index path, so normalize same-section coordinates first.
        if source.section == target.section, source.row < destinationRow {
            destinationRow -= 1
        }

        let destination = IndexPath(
            row: destinationRow,
            section: target.section
        )
        return canDrop(at: destination) ? destination : nil
    }

    @discardableResult
    func performDrop(at indexPath: IndexPath) -> Bool {
        guard let source = draggedIndexPath else { return false }
        draggedIndexPath = nil
        return performMove(from: source, to: indexPath)
    }

    func cancelDragging() {
        draggedIndexPath = nil
    }

    @discardableResult
    func performMove(from source: IndexPath, to destination: IndexPath) -> Bool {
        guard supportsMoving,
              isMovable(at: source),
              sections.indices.contains(destination.section),
              (0 ... sections[destination.section].cells.count).contains(destination.row)
        else { return false }

        var updatedSections = sections
        let movedCell = updatedSections[source.section].cells.remove(at: source.row)
        let insertionIndex = min(
            max(destination.row, 0),
            updatedSections[destination.section].cells.count
        )
        let resolvedDestination = IndexPath(
            row: insertionIndex,
            section: destination.section
        )

        if source == resolvedDestination {
            updatedSections[source.section].cells.insert(movedCell, at: source.row)
            sections = updatedSections
            return true
        }

        updatedSections[destination.section].cells.insert(movedCell, at: insertionIndex)
        sections = updatedSections
        collapseTrailingActions()
        move?(source, resolvedDestination)
        return true
    }

    private func commitDeletion(in section: Int, offsets: IndexSet) {
        offsets
            .sorted(by: >)
            .map { IndexPath(row: $0, section: section) }
            .filter(isDeletable)
            .forEach { commitEditing?(.delete, $0) }
    }

    private func commitMove(in section: Int, offsets: IndexSet, destination: Int) {
        guard offsets.count == 1, let sourceRow = offsets.first else { return }
        let source = IndexPath(row: sourceRow, section: section)
        guard isMovable(at: source) else { return }

        let destinationRow = destination > sourceRow ? destination - 1 : destination
        let destinationIndexPath = IndexPath(row: destinationRow, section: section)

        _ = performMove(from: source, to: destinationIndexPath)
    }

    private func expandTrailingActions(at indexPath: IndexPath) {
        guard swipeActions(at: indexPath, edge: .trailing).contains(where: \.hasVisibleContent)
        else { return }
        expandedTrailingActionsIndexPath = indexPath
    }

    private func collapseUnavailableTrailingActions() {
        guard let indexPath = expandedTrailingActionsIndexPath else { return }
        guard swipeActions(at: indexPath, edge: .trailing).contains(where: \.hasVisibleContent)
        else {
            collapseTrailingActions()
            return
        }
    }

    private func cell(at indexPath: IndexPath) -> Cell? {
        cellModel(at: indexPath)?.cell
    }

    private func hasInsertEditingStyle(at indexPath: IndexPath) -> Bool {
        if case .insert = editingStyle(at: indexPath) {
            return true
        }
        return false
    }

    private func cellModel(at indexPath: IndexPath) -> CellModel<Cell>? {
        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].cells.indices.contains(indexPath.row) else { return nil }
        return sections[indexPath.section].cells[indexPath.row]
    }
}

extension TableContextualAction {
    var hasVisibleContent: Bool {
        title != nil || image != nil
    }
}
