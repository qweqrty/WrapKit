// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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

}
#endif
