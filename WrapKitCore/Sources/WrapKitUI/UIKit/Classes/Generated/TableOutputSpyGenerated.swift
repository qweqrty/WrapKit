// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public class TableOutputSpy<Cell: Hashable,Footer: Any,Header: Any>: TableOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displaySections(sections: [TableSection<Header, Cell, Footer>])
        case displayTrailingSwipeActionsForIndexPath(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?)
        case displayIndexPath(expandTrailingActionsAt: IndexPath)
        case displayLeadingSwipeActionsForIndexPath(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?)
        case displayMove(move: ((IndexPath, IndexPath) -> Void)?)
        case displayCanMove(canMove: ((IndexPath) -> Bool)?)
        case displayCanEdit(canEdit: ((IndexPath) -> Bool)?)
        case displayCommitEditing(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplaySectionsSections: [[TableSection<Header, Cell, Footer>]] = []
    public private(set) var capturedDisplayTrailingSwipeActionsForIndexPathTrailingSwipeActionsForIndexPath: [((IndexPath) -> [TableContextualAction<Cell>])?] = []
    public private(set) var capturedDisplayIndexPathIndexPath: [IndexPath] = []
    public private(set) var capturedDisplayLeadingSwipeActionsForIndexPathLeadingSwipeActionsForIndexPath: [((IndexPath) -> [TableContextualAction<Cell>])?] = []
    public private(set) var capturedDisplayMoveMove: [((IndexPath, IndexPath) -> Void)?] = []
    public private(set) var capturedDisplayCanMoveCanMove: [((IndexPath) -> Bool)?] = []
    public private(set) var capturedDisplayCanEditCanEdit: [((IndexPath) -> Bool)?] = []
    public private(set) var capturedDisplayCommitEditingCommitEditing: [((TableEditingStyle, IndexPath) -> Void)?] = []


    // MARK: - TableOutput methods
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        capturedDisplaySectionsSections.append(sections)
        messages.append(.displaySections(sections: sections))
    }
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        capturedDisplayTrailingSwipeActionsForIndexPathTrailingSwipeActionsForIndexPath.append(trailingSwipeActionsForIndexPath)
        messages.append(.displayTrailingSwipeActionsForIndexPath(trailingSwipeActionsForIndexPath: trailingSwipeActionsForIndexPath))
    }
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        capturedDisplayIndexPathIndexPath.append(indexPath)
        messages.append(.displayIndexPath(expandTrailingActionsAt: indexPath))
    }
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        capturedDisplayLeadingSwipeActionsForIndexPathLeadingSwipeActionsForIndexPath.append(leadingSwipeActionsForIndexPath)
        messages.append(.displayLeadingSwipeActionsForIndexPath(leadingSwipeActionsForIndexPath: leadingSwipeActionsForIndexPath))
    }
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        capturedDisplayMoveMove.append(move)
        messages.append(.displayMove(move: move))
    }
    public func display(canMove: ((IndexPath) -> Bool)?) {
        capturedDisplayCanMoveCanMove.append(canMove)
        messages.append(.displayCanMove(canMove: canMove))
    }
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        capturedDisplayCanEditCanEdit.append(canEdit)
        messages.append(.displayCanEdit(canEdit: canEdit))
    }
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        capturedDisplayCommitEditingCommitEditing.append(commitEditing)
        messages.append(.displayCommitEditing(commitEditing: commitEditing))
    }

    // MARK: - Properties
}
