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
    public var weakReferenced: any TableOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: TableOutput where T: TableOutput {
    public typealias Cell = T.Cell
    public typealias Footer = T.Footer
    public typealias Header = T.Header

    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        object?.display(sections: sections)
    }
    public func display(trailingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        object?.display(trailingSwipeActionsForIndexPath: trailingSwipeActionsForIndexPath)
    }
    public func display(expandTrailingActionsAt indexPath: IndexPath) {
        object?.display(expandTrailingActionsAt: indexPath)
    }
    public func display(leadingSwipeActionsForIndexPath: ((IndexPath) -> [TableContextualAction<Cell>])?) {
        object?.display(leadingSwipeActionsForIndexPath: leadingSwipeActionsForIndexPath)
    }
    public func display(move: ((IndexPath, IndexPath) -> Void)?) {
        object?.display(move: move)
    }
    public func display(canMove: ((IndexPath) -> Bool)?) {
        object?.display(canMove: canMove)
    }
    public func display(canEdit: ((IndexPath) -> Bool)?) {
        object?.display(canEdit: canEdit)
    }
    public func display(commitEditing: ((TableEditingStyle, IndexPath) -> Void)?) {
        object?.display(commitEditing: commitEditing)
    }

}
#endif
