// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension TableOutput {
    public var mainQueueDispatched: any TableOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TableOutput where T: TableOutput {
    public typealias Cell = T.Cell
    public typealias Footer = T.Footer
    public typealias Header = T.Header

    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        dispatch { [weak self] in
            self?.decoratee.display(sections: sections)
        }
    }
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        dispatch { [weak self] in
            self?.decoratee.display(trailingSwipeActionsForIndexPath: trailingSwipeActionsForIndexPath)
        }
    }
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        dispatch { [weak self] in
            self?.decoratee.display(expandTrailingActionsAt: indexPath)
        }
    }
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        dispatch { [weak self] in
            self?.decoratee.display(leadingSwipeActionsForIndexPath: leadingSwipeActionsForIndexPath)
        }
    }
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(move: move)
        }
    }
    public func display(canMove: ((IndexPath) -> Bool)?) {
        dispatch { [weak self] in
            self?.decoratee.display(canMove: canMove)
        }
    }
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        dispatch { [weak self] in
            self?.decoratee.display(canEdit: canEdit)
        }
    }
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(commitEditing: commitEditing)
        }
    }

}
#endif
