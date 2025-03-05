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

extension FooterDiffableDataSourceOutput {
    public var mainQueueDispatched: any FooterDiffableDataSourceOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension FooterDiffableDataSourceOutput {
    public var weakReferenced: any FooterDiffableDataSourceOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: FooterDiffableDataSourceOutput where T: FooterDiffableDataSourceOutput {
    public typealias FooterItem = T.FooterItem
    public typealias FooterSectionItem = T.FooterSectionItem

    public func display(footer: FooterItem?, section: FooterSectionItem?) {
        dispatch { [weak self] in
            self?.decoratee.display(footer: footer, section: section)
        }
    }

}

extension WeakRefVirtualProxy: FooterDiffableDataSourceOutput where T: FooterDiffableDataSourceOutput {
    public typealias FooterItem = T.FooterItem
    public typealias FooterSectionItem = T.FooterSectionItem

    public func display(footer: FooterItem?, section: FooterSectionItem?) {
        object?.display(footer: footer, section: section)
    }

}

#endif
