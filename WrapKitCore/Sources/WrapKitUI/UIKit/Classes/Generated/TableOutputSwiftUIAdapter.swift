// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
public class TableOutputSwiftUIAdapter<Cell: Hashable,Footer: Any,Header: Any>: ObservableObject, TableOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displaySectionsState: DisplaySectionsState? = nil
    public struct DisplaySectionsState {
        public let sections: [TableSection<Header, Cell, Footer>]
    }
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        displaySectionsState = .init(
            sections: sections
        )
    }
    @Published public var displayTrailingSwipeActionsForIndexPathState: DisplayTrailingSwipeActionsForIndexPathState? = nil
    public struct DisplayTrailingSwipeActionsForIndexPathState {
        public let trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?
    }
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        displayTrailingSwipeActionsForIndexPathState = .init(
            trailingSwipeActionsForIndexPath: trailingSwipeActionsForIndexPath
        )
    }
    @Published public var displayIndexPathState: DisplayIndexPathState? = nil
    public struct DisplayIndexPathState {
        public let indexPath: IndexPath
    }
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        displayIndexPathState = .init(
            indexPath: indexPath
        )
    }
    @Published public var displayLeadingSwipeActionsForIndexPathState: DisplayLeadingSwipeActionsForIndexPathState? = nil
    public struct DisplayLeadingSwipeActionsForIndexPathState {
        public let leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?
    }
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        displayLeadingSwipeActionsForIndexPathState = .init(
            leadingSwipeActionsForIndexPath: leadingSwipeActionsForIndexPath
        )
    }
    @Published public var displayMoveState: DisplayMoveState? = nil
    public struct DisplayMoveState {
        public let move: ((IndexPath, IndexPath) -> Void)?
    }
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        displayMoveState = .init(
            move: move
        )
    }
    @Published public var displayCanMoveState: DisplayCanMoveState? = nil
    public struct DisplayCanMoveState {
        public let canMove: ((IndexPath) -> Bool)?
    }
    public func display(canMove: ((IndexPath) -> Bool)?) {
        displayCanMoveState = .init(
            canMove: canMove
        )
    }
    @Published public var displayCanEditState: DisplayCanEditState? = nil
    public struct DisplayCanEditState {
        public let canEdit: ((IndexPath) -> Bool)?
    }
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        displayCanEditState = .init(
            canEdit: canEdit
        )
    }
    @Published public var displayCommitEditingState: DisplayCommitEditingState? = nil
    public struct DisplayCommitEditingState {
        public let commitEditing: ((TableEditingStyle, IndexPath) -> Void)?
    }
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        displayCommitEditingState = .init(
            commitEditing: commitEditing
        )
    }
}
