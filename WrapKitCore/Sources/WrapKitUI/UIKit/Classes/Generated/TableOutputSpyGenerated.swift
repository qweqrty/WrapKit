// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class TableOutputSpy: TableOutput {
    enum Message: HashableWithReflection {
        case display(sections: [TableSection<Header, Cell, Footer>])
        case display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?)
        case display(expandTrailingActionsAt: IndexPath)
        case display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?)
        case display(move: ((IndexPath, IndexPath) -> Void)?)
        case display(canMove: ((IndexPath) -> Bool)?)
        case display(canEdit: ((IndexPath) -> Bool)?)
        case display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplaySections: [[TableSection<Header, Cell, Footer>]] = []
    private(set) var capturedDisplayTrailingSwipeActionsForIndexPath: [((IndexPath) -> [TableContextualAction<Cell>])?] = []
    private(set) var capturedDisplayIndexPath: [IndexPath] = []
    private(set) var capturedDisplayLeadingSwipeActionsForIndexPath: [((IndexPath) -> [TableContextualAction<Cell>])?] = []
    private(set) var capturedDisplayMove: [((IndexPath, IndexPath) -> Void)?] = []
    private(set) var capturedDisplayCanMove: [((IndexPath) -> Bool)?] = []
    private(set) var capturedDisplayCanEdit: [((IndexPath) -> Bool)?] = []
    private(set) var capturedDisplayCommitEditing: [((TableEditingStyle, IndexPath) -> Void)?] = []


    // MARK: - TableOutput methods
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        capturedDisplaySections.append(sections)
        messages.append(.display(sections: sections))
    }
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        capturedDisplayTrailingSwipeActionsForIndexPath.append(trailingSwipeActionsForIndexPath)
        messages.append(.display(trailingSwipeActionsForIndexPath: trailingSwipeActionsForIndexPath))
    }
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        capturedDisplayIndexPath.append(indexPath)
        messages.append(.display(expandTrailingActionsAt: indexPath))
    }
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        capturedDisplayLeadingSwipeActionsForIndexPath.append(leadingSwipeActionsForIndexPath)
        messages.append(.display(leadingSwipeActionsForIndexPath: leadingSwipeActionsForIndexPath))
    }
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        capturedDisplayMove.append(move)
        messages.append(.display(move: move))
    }
    public func display(canMove: ((IndexPath) -> Bool)?) {
        capturedDisplayCanMove.append(canMove)
        messages.append(.display(canMove: canMove))
    }
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        capturedDisplayCanEdit.append(canEdit)
        messages.append(.display(canEdit: canEdit))
    }
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        capturedDisplayCommitEditing.append(commitEditing)
        messages.append(.display(commitEditing: commitEditing))
    }

    // MARK: - Properties
}
