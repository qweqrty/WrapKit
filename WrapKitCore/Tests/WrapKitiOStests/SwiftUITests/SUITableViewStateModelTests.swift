import SwiftUI
import UIKit
import XCTest
@testable import WrapKit

final class SUITableViewStateModelTests: XCTestCase {
    func test_cellModel_defaultsEditingStyleToDelete() {
        let sut = CellModel(cell: "Inbox")

        guard case .delete = sut.editingStyle else {
            return XCTFail("Expected source-compatible delete editing style")
        }
    }

    func test_cellModel_keepsOnTapAsTrailingClosureWithDefaultEditingStyle() {
        var capturedCell: String?
        let sut = CellModel(cell: "Inbox") { _, cell in
            capturedCell = cell
        }

        sut.onTap?(IndexPath(row: 0, section: 0), sut.cell)

        XCTAssertEqual(capturedCell, "Inbox")
        guard case .delete = sut.editingStyle else {
            return XCTFail("Expected the default delete editing style")
        }
    }

    func test_uikitDataSource_mapsEveryCellEditingStyle() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let sut = DiffableTableViewDataSource<Void, String, Void>(
            tableView: tableView,
            configureCell: nil
        )
        sut.display(sections: makeEditingSections())
        var capturedInsertIndexPath: IndexPath?
        sut.display(commitEditing: { style, indexPath in
            guard case .insert = style else { return }
            capturedInsertIndexPath = indexPath
        })

        XCTAssertEqual(
            sut.tableView(
                tableView,
                editingStyleForRowAt: IndexPath(row: 0, section: 0)
            ),
            .delete
        )
        XCTAssertEqual(
            sut.tableView(
                tableView,
                editingStyleForRowAt: IndexPath(row: 1, section: 0)
            ),
            .insert
        )
        XCTAssertEqual(
            sut.tableView(
                tableView,
                editingStyleForRowAt: IndexPath(row: 2, section: 0)
            ),
            .none
        )
        XCTAssertEqual(
            sut.tableView(
                tableView,
                editingStyleForRowAt: IndexPath(row: 3, section: 0)
            ),
            .none
        )

        sut.tableView(
            tableView,
            commit: .insert,
            forRowAt: IndexPath(row: 1, section: 0)
        )

        XCTAssertEqual(capturedInsertIndexPath, IndexPath(row: 1, section: 0))
    }

    func test_uikitDataSource_hidesEditingControlWithoutCommitHandler() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let sut = DiffableTableViewDataSource<Void, String, Void>(
            tableView: tableView,
            configureCell: nil
        )
        sut.display(sections: makeEditingSections())

        XCTAssertEqual(
            sut.tableView(
                tableView,
                editingStyleForRowAt: IndexPath(row: 1, section: 0)
            ),
            .none
        )
    }

    func test_uikitDataSource_insertRowDisablesMoveAndSwipeOnlyForInsertStyle() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let sut = DiffableTableViewDataSource<Void, String, Void>(
            tableView: tableView,
            configureCell: nil
        )
        sut.display(sections: makeEditingSections())
        sut.display(canMove: { _ in true })
        sut.display(leadingSwipeActionsForIndexPath: { _ in [.init(title: "Favorite")] })
        sut.display(trailingSwipeActionsForIndexPath: { _ in [.init(title: "Info")] })
        let delete = IndexPath(row: 0, section: 0)
        let insert = IndexPath(row: 1, section: 0)
        let none = IndexPath(row: 2, section: 0)
        let stale = IndexPath(row: 3, section: 0)

        XCTAssertTrue(sut.tableView(tableView, canMoveRowAt: delete))
        XCTAssertFalse(sut.tableView(tableView, canMoveRowAt: insert))
        XCTAssertTrue(sut.tableView(tableView, canMoveRowAt: none))
        XCTAssertFalse(sut.tableView(tableView, canMoveRowAt: stale))
        XCTAssertNil(
            sut.tableView(tableView, leadingSwipeActionsConfigurationForRowAt: insert)
        )
        XCTAssertNil(
            sut.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: insert)
        )
        XCTAssertEqual(
            sut.tableView(
                tableView,
                leadingSwipeActionsConfigurationForRowAt: none
            )?.actions.count,
            1
        )
        XCTAssertEqual(
            sut.tableView(
                tableView,
                trailingSwipeActionsConfigurationForRowAt: none
            )?.actions.count,
            1
        )
    }

    func test_rowIdentity_preservesLogicalRowAfterEarlierDeletionAndContentChange() {
        let before = suiTableIdentifiedCells([
            CellModel(accessibilityIdentifier: "row.inbox", cell: "Inbox"),
            CellModel(accessibilityIdentifier: "row.archive", cell: "Archive")
        ])
        let after = suiTableIdentifiedCells([
            CellModel(accessibilityIdentifier: "row.archive", cell: "Archive selected")
        ])

        XCTAssertEqual(before[1].id, after[0].id)
    }

    func test_rowIdentity_keepsDuplicateIdentifierlessCellsDistinct() {
        let rows = suiTableIdentifiedCells([
            CellModel(cell: "Duplicate"),
            CellModel(cell: "Duplicate")
        ])

        XCTAssertNotEqual(rows[0].id, rows[1].id)
    }

    func test_init_replaysStateButDropsPremountExpandCommandLikeUIKit() {
        let adapter = makeAdapter()
        let sections = makeSections(["Inbox", "Archive"])

        adapter.display(sections: sections)
        adapter.display(leadingSwipeActionsForIndexPath: { _ in [] })
        adapter.display(trailingSwipeActionsForIndexPath: { _ in [.init(title: "Info")] })
        adapter.display(canEdit: { _ in true })
        adapter.display(commitEditing: { _, _ in })
        adapter.display(canMove: { _ in true })
        adapter.display(move: { _, _ in })
        adapter.display(expandTrailingActionsAt: IndexPath(row: 1, section: 0))
        adapter.displayHideRefreshControl()

        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertEqual(sut.sections.first?.cells.map(\.cell), ["Inbox", "Archive"])
        XCTAssertNotNil(sut.leadingSwipeActions)
        XCTAssertNotNil(sut.trailingSwipeActions)
        XCTAssertNotNil(sut.canEdit)
        XCTAssertNotNil(sut.commitEditing)
        XCTAssertNotNil(sut.canMove)
        XCTAssertNotNil(sut.move)
        XCTAssertNil(sut.expandedTrailingActionsIndexPath)
        XCTAssertTrue(sut.hidesRefreshControl)
    }

    func test_deleteAction_forwardsOnlyEditableRowsToCommitEditing() {
        let adapter = makeAdapter()
        var capturedIndexPaths: [IndexPath] = []
        adapter.display(sections: makeSections(["Inbox", "Archive"]))
        adapter.display(canEdit: { $0.row == 1 })
        adapter.display(commitEditing: { style, indexPath in
            guard case .delete = style else {
                return XCTFail("Expected the delete editing style")
            }
            capturedIndexPaths.append(indexPath)
        })
        let sut = SUITableViewStateModel(adapter: adapter)

        sut.deleteAction(in: 0)?(IndexSet([0, 1]))

        XCTAssertEqual(capturedIndexPaths, [IndexPath(row: 1, section: 0)])
    }

    func test_editingActions_respectPerRowStyleAndRejectStaleRows() {
        let adapter = makeAdapter()
        adapter.display(sections: makeEditingSections())
        adapter.display(canEdit: { _ in true })
        adapter.display(canMove: { _ in true })
        adapter.display(move: { _, _ in })
        adapter.display(leadingSwipeActionsForIndexPath: { _ in [.init(title: "Favorite")] })
        adapter.display(trailingSwipeActionsForIndexPath: { _ in [.init(title: "Info")] })
        var capturedEdits: [(style: TableEditingStyle, indexPath: IndexPath)] = []
        adapter.display(commitEditing: { style, indexPath in
            capturedEdits.append((style, indexPath))
        })
        let sut = SUITableViewStateModel(adapter: adapter)
        let delete = IndexPath(row: 0, section: 0)
        let insert = IndexPath(row: 1, section: 0)
        let none = IndexPath(row: 2, section: 0)
        let stale = IndexPath(row: 3, section: 0)

        XCTAssertTrue(sut.isDeletable(at: delete))
        XCTAssertFalse(sut.isDeletable(at: insert))
        XCTAssertTrue(sut.isInsertable(at: insert))
        XCTAssertFalse(sut.isInsertable(at: delete))
        XCTAssertFalse(sut.isInsertable(at: stale))
        XCTAssertTrue(sut.isMovable(at: delete))
        XCTAssertFalse(sut.isMovable(at: insert))
        XCTAssertTrue(sut.isMovable(at: none))
        XCTAssertTrue(sut.swipeActions(at: insert, edge: .leading).isEmpty)
        XCTAssertTrue(sut.swipeActions(at: insert, edge: .trailing).isEmpty)
        XCTAssertFalse(sut.swipeActions(at: delete, edge: .leading).isEmpty)
        XCTAssertFalse(sut.swipeActions(at: none, edge: .trailing).isEmpty)
        var swipeActionWasPerformed = false
        let swipeAction = TableContextualAction<String>(title: "Info") { _ in
            swipeActionWasPerformed = true
        }
        XCTAssertFalse(sut.performSwipeAction(swipeAction, at: insert))
        XCTAssertFalse(swipeActionWasPerformed)

        sut.deleteAction(in: 0)?(IndexSet([0, 1, 2, 3]))
        XCTAssertTrue(sut.performInsertion(at: insert))
        XCTAssertFalse(sut.performInsertion(at: delete))
        XCTAssertFalse(sut.performInsertion(at: none))
        XCTAssertFalse(sut.performInsertion(at: stale))

        XCTAssertEqual(capturedEdits.count, 2)
        guard capturedEdits.count == 2 else { return }
        guard case .delete = capturedEdits[0].style else {
            return XCTFail("Expected only the delete row to be deleted")
        }
        XCTAssertEqual(capturedEdits[0].indexPath, delete)
        guard case .insert = capturedEdits[1].style else {
            return XCTFail("Expected the insert row to request insertion")
        }
        XCTAssertEqual(capturedEdits[1].indexPath, insert)
    }

    func test_insertAction_requiresCanEditAndCommitHandler() {
        let adapter = makeAdapter()
        adapter.display(sections: makeEditingSections())
        let sut = SUITableViewStateModel(adapter: adapter)
        let insert = IndexPath(row: 1, section: 0)

        XCTAssertFalse(sut.isInsertable(at: insert))
        XCTAssertFalse(sut.performInsertion(at: insert))

        adapter.display(commitEditing: { _, _ in })
        adapter.display(canEdit: { _ in false })

        XCTAssertFalse(sut.isInsertable(at: insert))
        XCTAssertFalse(sut.performInsertion(at: insert))
    }

    func test_rowTap_matchesUIKitSelectionDuringEditingDefault() {
        XCTAssertFalse(suiTableAllowsRowTap(editingStyle: .delete, isEditing: true))
        XCTAssertTrue(suiTableAllowsRowTap(editingStyle: .insert, isEditing: false))
        XCTAssertFalse(suiTableAllowsRowTap(editingStyle: .insert, isEditing: true))
        XCTAssertFalse(suiTableAllowsRowTap(editingStyle: .none, isEditing: true))
    }

    @available(iOS 17.0, *)
    func test_rowTap_isReachableThroughRenderedSwiftUIList() throws {
        let adapter = makeAdapter()
        var capturedIndexPath: IndexPath?
        var capturedCell: String?
        adapter.display(sections: [
            .init(cells: [
                .init(cell: "Selectable row") { indexPath, cell in
                    capturedIndexPath = indexPath
                    capturedCell = cell
                }
            ])
        ])

        let host = SwiftUIAccessibilityTestHost(
            rootView: makeTable(adapter: adapter, editMode: .inactive),
            size: CGSize(width: 390, height: 240)
        )
        let row = try XCTUnwrap(host.element(withLabel: "Selectable row"))

        XCTAssertTrue(row.accessibilityActivate())
        XCTAssertEqual(capturedIndexPath, IndexPath(row: 0, section: 0))
        XCTAssertEqual(capturedCell, "Selectable row")
    }

    @available(iOS 17.0, *)
    func test_rowTap_isReachableThroughRenderedLazyVStackUsedBySelectionFlow() throws {
        let adapter = makeAdapter()
        var capturedIndexPath: IndexPath?
        var capturedCell: String?
        adapter.display(sections: [
            .init(cells: [
                .init(cell: "Multiple selection row") { indexPath, cell in
                    capturedIndexPath = indexPath
                    capturedCell = cell
                }
            ])
        ])

        let host = SwiftUIAccessibilityTestHost(
            rootView: makeLazyTable(adapter: adapter),
            size: CGSize(width: 390, height: 240)
        )
        let row = try XCTUnwrap(host.element(withLabel: "Multiple selection row"))

        XCTAssertTrue(row.accessibilityActivate())
        XCTAssertEqual(capturedIndexPath, IndexPath(row: 0, section: 0))
        XCTAssertEqual(capturedCell, "Multiple selection row")
    }

    @available(iOS 17.0, *)
    func test_insertControl_isVisibleAndInteractiveOnlyInActiveEditMode() throws {
        let adapter = makeAdapter()
        var capturedIndexPath: IndexPath?
        var capturedInsert = false
        var rowTapCount = 0
        adapter.display(sections: [
            .init(cells: [
                .init(
                    accessibilityIdentifier: "cell.insert",
                    cell: "Add row",
                    editingStyle: .insert,
                    onTap: { _, _ in rowTapCount += 1 }
                )
            ])
        ])
        adapter.display(commitEditing: { style, indexPath in
            capturedIndexPath = indexPath
            if case .insert = style {
                capturedInsert = true
            }
        })

        let inactiveHost = SwiftUIAccessibilityTestHost(
            rootView: makeTable(adapter: adapter, editMode: .inactive),
            size: CGSize(width: 390, height: 240)
        )
        XCTAssertNil(inactiveHost.element(withLabel: "Insert row"))

        let activeHost = SwiftUIAccessibilityTestHost(
            rootView: makeTable(adapter: adapter, editMode: .active),
            size: CGSize(width: 390, height: 240)
        )
        let insertControl = try XCTUnwrap(activeHost.element(withLabel: "Insert row"))

        XCTAssertTrue(insertControl.accessibilityActivate())
        XCTAssertTrue(capturedInsert)
        XCTAssertEqual(capturedIndexPath, IndexPath(row: 0, section: 0))
        XCTAssertEqual(rowTapCount, 0)
    }

    func test_commitEditing_isEditModeOnlyAndDoesNotSynthesizeTrailingSwipeAction() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        adapter.display(commitEditing: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)
        let indexPath = IndexPath(row: 0, section: 0)

        XCTAssertNil(sut.deleteAction(in: 0, isEditing: false))
        XCTAssertNotNil(sut.deleteAction(in: 0, isEditing: true))
        XCTAssertTrue(sut.swipeActions(at: indexPath, edge: .trailing).isEmpty)

        adapter.display(trailingSwipeActionsForIndexPath: { _ in [] })

        XCTAssertTrue(sut.swipeActions(at: indexPath, edge: .trailing).isEmpty)
    }

    func test_moveAction_updatesLocalSectionsAndForwardsUIKitDestinationIndexPath() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox", "Favorites", "Archive"]))
        adapter.display(canMove: { _ in true })
        var capturedMove: (source: IndexPath, destination: IndexPath)?
        adapter.display(move: { source, destination in
            capturedMove = (source, destination)
        })
        let sut = SUITableViewStateModel(adapter: adapter)

        sut.moveAction(in: 0)?(IndexSet(integer: 0), 3)

        XCTAssertEqual(sut.sections.first?.cells.map(\.cell), ["Favorites", "Archive", "Inbox"])
        XCTAssertEqual(capturedMove?.source, IndexPath(row: 0, section: 0))
        XCTAssertEqual(capturedMove?.destination, IndexPath(row: 2, section: 0))
    }

    func test_dragDrop_movesAcrossSectionsAndForwardsUIKitIndexPaths() {
        let adapter = makeAdapter()
        adapter.display(sections: [
            .init(cells: [
                .init(accessibilityIdentifier: "cell.inbox", cell: "Inbox"),
                .init(accessibilityIdentifier: "cell.archive", cell: "Archive")
            ]),
            .init(cells: [
                .init(accessibilityIdentifier: "cell.favorite", cell: "Favorite")
            ])
        ])
        adapter.display(canMove: { $0 != IndexPath(row: 1, section: 0) })
        var capturedMove: (source: IndexPath, destination: IndexPath)?
        adapter.display(move: { source, destination in
            capturedMove = (source, destination)
        })
        let sut = SUITableViewStateModel(adapter: adapter)
        let source = IndexPath(row: 0, section: 0)
        let destination = IndexPath(row: 1, section: 1)

        XCTAssertTrue(sut.beginDragging(at: source))
        XCTAssertEqual(sut.draggedIndexPath, source)
        XCTAssertTrue(sut.canDrop(at: destination))
        XCTAssertTrue(sut.performDrop(at: destination))

        XCTAssertEqual(sut.sections[0].cells.map(\.cell), ["Archive"])
        XCTAssertEqual(sut.sections[1].cells.map(\.cell), ["Favorite", "Inbox"])
        XCTAssertEqual(capturedMove?.source, source)
        XCTAssertEqual(capturedMove?.destination, destination)
        XCTAssertNil(sut.draggedIndexPath)
    }

    func test_dropDestination_normalizesSameSectionCoordinatesAroundSourceRow() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["A", "B", "C", "D"]))
        adapter.display(canMove: { _ in true })
        adapter.display(move: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertTrue(sut.beginDragging(at: IndexPath(row: 1, section: 0)))

        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 1, section: 0),
                placeAfterTarget: false
            ),
            IndexPath(row: 1, section: 0)
        )
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 1, section: 0),
                placeAfterTarget: true
            ),
            IndexPath(row: 1, section: 0)
        )
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 2, section: 0),
                placeAfterTarget: false
            ),
            IndexPath(row: 1, section: 0)
        )
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 2, section: 0),
                placeAfterTarget: true
            ),
            IndexPath(row: 2, section: 0)
        )
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 3, section: 0),
                placeAfterTarget: true
            ),
            IndexPath(row: 3, section: 0)
        )
    }

    func test_dropDestination_resolvesBeforeAfterAndEndInAnotherSection() {
        let adapter = makeAdapter()
        adapter.display(sections: [
            .init(cells: [.init(cell: "Source")]),
            .init(cells: [.init(cell: "First"), .init(cell: "Last")])
        ])
        adapter.display(canMove: { _ in true })
        adapter.display(move: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertTrue(sut.beginDragging(at: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 0, section: 1),
                placeAfterTarget: false
            ),
            IndexPath(row: 0, section: 1)
        )
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 0, section: 1),
                placeAfterTarget: true
            ),
            IndexPath(row: 1, section: 1)
        )
        XCTAssertEqual(
            sut.dropDestination(
                relativeTo: IndexPath(row: 1, section: 1),
                placeAfterTarget: true
            ),
            IndexPath(row: 2, section: 1)
        )
    }

    func test_dragDrop_movesIntoEmptySectionAtItsOnlyValidDestination() {
        let adapter = makeAdapter()
        adapter.display(sections: [
            .init(cells: [.init(cell: "Source")]),
            .init(cells: [])
        ])
        adapter.display(canMove: { _ in true })
        var capturedDestination: IndexPath?
        adapter.display(move: { _, destination in
            capturedDestination = destination
        })
        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertTrue(sut.beginDragging(at: IndexPath(row: 0, section: 0)))
        XCTAssertTrue(sut.canDrop(at: IndexPath(row: 0, section: 1)))
        XCTAssertTrue(sut.performDrop(at: IndexPath(row: 0, section: 1)))

        XCTAssertTrue(sut.sections[0].cells.isEmpty)
        XCTAssertEqual(sut.sections[1].cells.map(\.cell), ["Source"])
        XCTAssertEqual(capturedDestination, IndexPath(row: 0, section: 1))
    }

    func test_crossSectionDropTargets_includeEveryExistingRowLikeUIKit() {
        let adapter = makeAdapter()
        adapter.display(sections: makeEditingSections())
        adapter.display(canMove: { $0.row == 0 })
        adapter.display(move: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertTrue(sut.canReceiveRowDrop(at: IndexPath(row: 0, section: 0)))
        XCTAssertTrue(sut.canReceiveRowDrop(at: IndexPath(row: 1, section: 0)))
        XCTAssertTrue(sut.canReceiveRowDrop(at: IndexPath(row: 2, section: 0)))
        XCTAssertFalse(sut.canReceiveRowDrop(at: IndexPath(row: 3, section: 0)))
    }

    func test_dragDrop_allowsNonMovableRowAsDestination() {
        let adapter = makeAdapter()
        adapter.display(sections: [
            .init(cells: [.init(cell: "Movable")]),
            .init(cells: [.init(cell: "Fixed destination")])
        ])
        adapter.display(canMove: { $0.section == 0 })
        var capturedMove: (source: IndexPath, destination: IndexPath)?
        adapter.display(move: { source, destination in
            capturedMove = (source, destination)
        })
        let sut = SUITableViewStateModel(adapter: adapter)
        let source = IndexPath(row: 0, section: 0)
        let fixedTarget = IndexPath(row: 0, section: 1)

        XCTAssertTrue(sut.beginDragging(at: source))
        XCTAssertFalse(sut.isMovable(at: fixedTarget))
        XCTAssertTrue(sut.canReceiveRowDrop(at: fixedTarget))
        let destination = sut.dropDestination(
            relativeTo: fixedTarget,
            placeAfterTarget: false
        )
        XCTAssertEqual(destination, fixedTarget)
        XCTAssertTrue(sut.performDrop(at: fixedTarget))

        XCTAssertEqual(sut.sections[1].cells.map(\.cell), ["Movable", "Fixed destination"])
        XCTAssertEqual(capturedMove?.source, source)
        XCTAssertEqual(capturedMove?.destination, fixedTarget)
    }

    func test_displaySections_cancelsAnInFlightRowDrag() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        adapter.display(canMove: { _ in true })
        adapter.display(move: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)
        XCTAssertTrue(sut.beginDragging(at: IndexPath(row: 0, section: 0)))

        adapter.display(sections: makeSections(["Archive"]))

        XCTAssertNil(sut.draggedIndexPath)
    }

    func test_dragDrop_rejectsNonMovableAndStaleDestinations() {
        let adapter = makeAdapter()
        adapter.display(sections: [
            .init(cells: [
                .init(accessibilityIdentifier: "cell.inbox", cell: "Inbox")
            ]),
            .init(cells: [])
        ])
        adapter.display(canMove: { _ in false })
        adapter.display(move: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertFalse(sut.beginDragging(at: IndexPath(row: 0, section: 0)))
        XCTAssertFalse(sut.canDrop(at: IndexPath(row: 0, section: 1)))
        XCTAssertFalse(sut.performDrop(at: IndexPath(row: 0, section: 1)))

        adapter.display(canMove: { _ in true })
        XCTAssertTrue(sut.beginDragging(at: IndexPath(row: 0, section: 0)))
        XCTAssertFalse(sut.canDrop(at: IndexPath(row: 1, section: 1)))
        XCTAssertFalse(sut.performDrop(at: IndexPath(row: 1, section: 1)))
        XCTAssertNil(sut.draggedIndexPath)
    }

    func test_actions_areUnavailableWhenHandlersAreMissing() {
        let sut = SUITableViewStateModel(adapter: makeAdapter())

        XCTAssertNil(sut.deleteAction(in: 0))
        XCTAssertNil(sut.moveAction(in: 0))
    }

    func test_expandTrailingActions_replacesOpenRowAndCollapsesOnlyMatchingRow() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox", "Archive"]))
        adapter.display(trailingSwipeActionsForIndexPath: { _ in
            [.init(title: "Info")]
        })
        let sut = SUITableViewStateModel(adapter: adapter)
        let first = IndexPath(row: 0, section: 0)
        let second = IndexPath(row: 1, section: 0)

        adapter.display(expandTrailingActionsAt: first)

        XCTAssertTrue(sut.areTrailingActionsExpanded(at: first))

        adapter.display(expandTrailingActionsAt: second)
        sut.collapseTrailingActions(at: first)

        XCTAssertFalse(sut.areTrailingActionsExpanded(at: first))
        XCTAssertTrue(sut.areTrailingActionsExpanded(at: second))

        sut.collapseTrailingActions(at: second)

        XCTAssertNil(sut.expandedTrailingActionsIndexPath)
    }

    func test_expandTrailingActions_ignoresMissingUneditableAndActionlessRows() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        adapter.display(trailingSwipeActionsForIndexPath: { _ in [] })
        let sut = SUITableViewStateModel(adapter: adapter)

        adapter.display(expandTrailingActionsAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(sut.expandedTrailingActionsIndexPath)

        adapter.display(trailingSwipeActionsForIndexPath: { _ in [.init(title: "Info")] })
        adapter.display(canEdit: { _ in false })
        adapter.display(expandTrailingActionsAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(sut.expandedTrailingActionsIndexPath)

        adapter.display(canEdit: { _ in true })
        adapter.display(expandTrailingActionsAt: IndexPath(row: 1, section: 0))
        XCTAssertNil(sut.expandedTrailingActionsIndexPath)

        adapter.display(trailingSwipeActionsForIndexPath: { _ in [.init()] })
        adapter.display(expandTrailingActionsAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(sut.expandedTrailingActionsIndexPath)
    }

    func test_displaySections_collapsesProgrammaticallyRevealedActions() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        adapter.display(trailingSwipeActionsForIndexPath: { _ in [.init(title: "Info")] })
        let sut = SUITableViewStateModel(adapter: adapter)
        let indexPath = IndexPath(row: 0, section: 0)
        adapter.display(expandTrailingActionsAt: indexPath)

        adapter.display(sections: makeSections(["Archive"]))

        XCTAssertNil(sut.expandedTrailingActionsIndexPath)
    }

    func test_swipeActions_resolveLeadingAndTrailingContractsIndependently() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        adapter.display(leadingSwipeActionsForIndexPath: { _ in
            [.init(style: .normal, title: "Favorite")]
        })
        adapter.display(trailingSwipeActionsForIndexPath: { _ in
            [.init(style: .destructive, title: "Delete")]
        })
        let sut = SUITableViewStateModel(adapter: adapter)
        let indexPath = IndexPath(row: 0, section: 0)

        let leading = sut.swipeActions(at: indexPath, edge: .leading)
        let trailing = sut.swipeActions(at: indexPath, edge: .trailing)

        XCTAssertEqual(leading.first?.title, "Favorite")
        XCTAssertEqual(trailing.first?.title, "Delete")
        guard let leadingStyle = leading.first?.style,
              let trailingStyle = trailing.first?.style else {
            return XCTFail("Expected both swipe action styles")
        }
        if case .destructive = leadingStyle {
            XCTFail("Expected a normal leading action")
        }
        if case .normal = trailingStyle {
            XCTFail("Expected a destructive trailing action")
        }
        XCTAssertTrue(SUITableSwipeConfiguration.allowsFullSwipe)
    }

    func test_programmaticTrailingActions_matchUIKitVisualOrderAndSkipInvisibleActions() {
        let actions: [TableContextualAction<String>] = [
            .init(title: "Delete"),
            .init(),
            .init(title: "More")
        ]

        let resolved = suiTableProgrammaticTrailingActions(actions)

        XCTAssertEqual(resolved.map(\.sourceIndex), [2, 0])
        XCTAssertEqual(resolved.map(\.action.title), ["More", "Delete"])
        XCTAssertEqual(SUITableSwipeConfiguration.minimumProgrammaticActionWidth, 74)
    }

    @available(iOS 17.0, *)
    func test_programmaticTrailingActions_renderInUIKitOrderAndForwardOnlyButtonTap() throws {
        let adapter = makeAdapter()
        var capturedActions: [String] = []
        var rowTapCount = 0
        adapter.display(sections: [
            .init(cells: [
                .init(cell: "Inbox") { _, _ in rowTapCount += 1 }
            ])
        ])
        adapter.display(trailingSwipeActionsForIndexPath: { _ in
            [
                .init(
                    style: .destructive,
                    backgroundColor: .systemRed,
                    title: "Delete",
                    onPress: { capturedActions.append("Delete \($0)") }
                ),
                .init(
                    backgroundColor: .systemBlue,
                    title: "More",
                    onPress: { capturedActions.append("More \($0)") }
                )
            ]
        })
        let stateModel = SUITableViewStateModel(adapter: adapter)
        let host = SwiftUIAccessibilityTestHost(
            rootView: makeTable(stateModel: stateModel, editMode: .inactive),
            size: CGSize(width: 390, height: 240)
        )

        adapter.display(expandTrailingActionsAt: IndexPath(row: 0, section: 0))
        host.settle()
        host.settle()

        let more = try XCTUnwrap(host.element(withLabel: "More"))
        let delete = try XCTUnwrap(host.element(withLabel: "Delete"))
        XCTAssertEqual(more.accessibilityLabel, "More")
        XCTAssertEqual(delete.accessibilityLabel, "Delete")
        XCTAssertLessThan(more.accessibilityFrame.minX, delete.accessibilityFrame.minX)
        XCTAssertGreaterThanOrEqual(
            more.accessibilityFrame.width,
            SUITableSwipeConfiguration.minimumProgrammaticActionWidth - 1
        )
        XCTAssertGreaterThanOrEqual(
            delete.accessibilityFrame.width,
            SUITableSwipeConfiguration.minimumProgrammaticActionWidth - 1
        )

        XCTAssertTrue(delete.accessibilityActivate())
        host.settle()

        XCTAssertEqual(capturedActions, ["Delete Inbox"])
        XCTAssertEqual(rowTapCount, 0)
        XCTAssertNil(stateModel.expandedTrailingActionsIndexPath)
    }

    func test_trailingSwipeActions_useOnlyExplicitCustomActions() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        adapter.display(commitEditing: { _, _ in })
        let sut = SUITableViewStateModel(adapter: adapter)
        let indexPath = IndexPath(row: 0, section: 0)

        XCTAssertTrue(sut.swipeActions(at: indexPath, edge: .trailing).isEmpty)

        adapter.display(trailingSwipeActionsForIndexPath: { _ in
            [.init(title: "Info")]
        })
        XCTAssertEqual(
            sut.swipeActions(at: indexPath, edge: .trailing).map(\.title),
            ["Info"]
        )

        adapter.display(trailingSwipeActionsForIndexPath: { _ in [] })
        XCTAssertTrue(sut.swipeActions(at: indexPath, edge: .trailing).isEmpty)
    }

    func test_performSwipeAction_resolvesCurrentCellAndRejectsStaleIndexPath() {
        let adapter = makeAdapter()
        adapter.display(sections: makeSections(["Inbox"]))
        var capturedCells: [String] = []
        let action = TableContextualAction<String>(title: "Info") { cell in
            capturedCells.append(cell)
        }
        let sut = SUITableViewStateModel(adapter: adapter)
        let indexPath = IndexPath(row: 0, section: 0)

        adapter.display(sections: makeSections(["Archive"]))

        XCTAssertTrue(sut.performSwipeAction(action, at: indexPath))
        XCTAssertFalse(sut.performSwipeAction(action, at: IndexPath(row: 1, section: 0)))
        XCTAssertEqual(capturedCells, ["Archive"])
    }

    func test_hideRefreshControl_changesOnlyAfterOutputRequest() {
        let adapter = makeAdapter()
        let sut = SUITableViewStateModel(adapter: adapter)

        XCTAssertFalse(sut.hidesRefreshControl)

        adapter.displayHideRefreshControl()

        XCTAssertTrue(sut.hidesRefreshControl)
    }

    func test_refreshControlHiddenPreference_reducesMultipleTablesWithOrSemantics() {
        var value = false

        SUITableRefreshControlHiddenPreferenceKey.reduce(value: &value) { false }
        SUITableRefreshControlHiddenPreferenceKey.reduce(value: &value) { true }
        SUITableRefreshControlHiddenPreferenceKey.reduce(value: &value) { false }

        XCTAssertTrue(value)
    }

    private func makeAdapter() -> TableOutputSwiftUIAdapter<String, Void, Void> {
        TableOutputSwiftUIAdapter<String, Void, Void>()
    }

    private func makeSections(_ cells: [String]) -> [TableSection<Void, String, Void>] {
        [
            .init(cells: cells.enumerated().map { index, cell in
                .init(accessibilityIdentifier: "cell.\(index)", cell: cell)
            })
        ]
    }

    private func makeEditingSections() -> [TableSection<Void, String, Void>] {
        [
            .init(cells: [
                .init(accessibilityIdentifier: "cell.delete", cell: "Delete"),
                .init(
                    accessibilityIdentifier: "cell.insert",
                    cell: "Insert",
                    editingStyle: .insert
                ),
                .init(
                    accessibilityIdentifier: "cell.none",
                    cell: "None",
                    editingStyle: .none
                )
            ])
        ]
    }

    private func makeTable(
        adapter: TableOutputSwiftUIAdapter<String, Void, Void>,
        editMode: EditMode
    ) -> some View {
        SUITableView(
            adapter: adapter,
            style: .list,
            cellContent: { cell, _ in SwiftUI.Text(cell) },
            headerContent: { _ in EmptyView() },
            footerContent: { _ in EmptyView() }
        )
        .environment(\.editMode, .constant(editMode))
    }

    private func makeLazyTable(
        adapter: TableOutputSwiftUIAdapter<String, Void, Void>
    ) -> some View {
        SUITableView(
            adapter: adapter,
            style: .lazyVStack(scrollable: true),
            cellContent: { cell, _ in
                SwiftUI.Text(cell)
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            },
            headerContent: { _ in EmptyView() },
            footerContent: { _ in EmptyView() }
        )
    }

    private func makeTable(
        stateModel: SUITableViewStateModel<Void, String, Void>,
        editMode: EditMode
    ) -> some View {
        SUITableListView().makeBody(
            stateModel: stateModel,
            cellContent: { cell, _ in
                HStack {
                    SwiftUI.Text(cell)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 56)
                .background(SwiftUI.Color.white)
            },
            headerContent: { _ in EmptyView() },
            footerContent: { _ in EmptyView() }
        )
        .environment(\.editMode, .constant(editMode))
    }
}
