// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension HeaderDiffableDataSourceOutput {
    public var mainQueueDispatched: any HeaderDiffableDataSourceOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension HeaderDiffableDataSourceOutput {
    public var weakReferenced: any HeaderDiffableDataSourceOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: HeaderDiffableDataSourceOutput where T: HeaderDiffableDataSourceOutput {
    public typealias HeaderItem = T.HeaderItem
    public typealias SectionItem = T.SectionItem

    public func display(header: HeaderItem?, section: SectionItem?) {
        dispatch { [weak self] in
            self?.decoratee.display(header: header, section: section)
        }
    }

}

extension WeakRefVirtualProxy: HeaderDiffableDataSourceOutput where T: HeaderDiffableDataSourceOutput {
    public typealias HeaderItem = T.HeaderItem
    public typealias SectionItem = T.SectionItem

    public func display(header: HeaderItem?, section: SectionItem?) {
        object?.display(header: header, section: section)
    }

}

#endif
