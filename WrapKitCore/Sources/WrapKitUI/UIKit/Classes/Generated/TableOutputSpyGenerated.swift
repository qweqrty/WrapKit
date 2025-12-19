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
    public private(set) var capturedDisplaySections: [[TableSection<Header, Cell, Footer>]] = []
    public private(set) var capturedDisplayTrailingSwipeActionsForIndexPath: [((IndexPath) -> [TableContextualAction<Cell>])?] = []
    public private(set) var capturedDisplayIndexPath: [IndexPath] = []
    public private(set) var capturedDisplayLeadingSwipeActionsForIndexPath: [((IndexPath) -> [TableContextualAction<Cell>])?] = []
    public private(set) var capturedDisplayMove: [((IndexPath, IndexPath) -> Void)?] = []
    public private(set) var capturedDisplayCanMove: [((IndexPath) -> Bool)?] = []
    public private(set) var capturedDisplayCanEdit: [((IndexPath) -> Bool)?] = []
    public private(set) var capturedDisplayCommitEditing: [((TableEditingStyle, IndexPath) -> Void)?] = []


    // MARK: - TableOutput methods
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        capturedDisplaySections.append(sections)
        messages.append(.displaySections(sections: sections))
    }
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        capturedDisplayTrailingSwipeActionsForIndexPath.append(trailingSwipeActionsForIndexPath)
        messages.append(.displayTrailingSwipeActionsForIndexPath(trailingSwipeActionsForIndexPath: trailingSwipeActionsForIndexPath))
    }
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        capturedDisplayIndexPath.append(indexPath)
        messages.append(.displayIndexPath(expandTrailingActionsAt: indexPath))
    }
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        capturedDisplayLeadingSwipeActionsForIndexPath.append(leadingSwipeActionsForIndexPath)
        messages.append(.displayLeadingSwipeActionsForIndexPath(leadingSwipeActionsForIndexPath: leadingSwipeActionsForIndexPath))
    }
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        capturedDisplayMove.append(move)
        messages.append(.displayMove(move: move))
    }
    public func display(canMove: ((IndexPath) -> Bool)?) {
        capturedDisplayCanMove.append(canMove)
        messages.append(.displayCanMove(canMove: canMove))
    }
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        capturedDisplayCanEdit.append(canEdit)
        messages.append(.displayCanEdit(canEdit: canEdit))
    }
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        capturedDisplayCommitEditing.append(commitEditing)
        messages.append(.displayCommitEditing(commitEditing: commitEditing))
    }

    // MARK: - Properties
}
