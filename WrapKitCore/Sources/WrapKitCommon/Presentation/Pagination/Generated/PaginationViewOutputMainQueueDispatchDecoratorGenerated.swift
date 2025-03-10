// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(Combine)
import Combine
#endif

extension PaginationViewOutput {
    public var mainQueueDispatched: any PaginationViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension PaginationViewOutput {
    public var weakReferenced: any PaginationViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: PaginationViewOutput where T: PaginationViewOutput {
    public typealias PresentableItem = T.PresentableItem

    public func display(model: [PresentableItem], hasMore: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model, hasMore: hasMore)
        }
    }
    public func display(isLoadingFirstPage: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isLoadingFirstPage: isLoadingFirstPage)
        }
    }
    public func display(isLoadingSubsequentPage: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isLoadingSubsequentPage: isLoadingSubsequentPage)
        }
    }
    public func display(errorAtFirstPage: ServiceError) {
        dispatch { [weak self] in
            self?.decoratee.display(errorAtFirstPage: errorAtFirstPage)
        }
    }
    public func display(errorAtSubsequentPage: ServiceError) {
        dispatch { [weak self] in
            self?.decoratee.display(errorAtSubsequentPage: errorAtSubsequentPage)
        }
    }

}

extension WeakRefVirtualProxy: PaginationViewOutput where T: PaginationViewOutput {
    public typealias PresentableItem = T.PresentableItem

    public func display(model: [PresentableItem], hasMore: Bool) {
        object?.display(model: model, hasMore: hasMore)
    }
    public func display(isLoadingFirstPage: Bool) {
        object?.display(isLoadingFirstPage: isLoadingFirstPage)
    }
    public func display(isLoadingSubsequentPage: Bool) {
        object?.display(isLoadingSubsequentPage: isLoadingSubsequentPage)
    }
    public func display(errorAtFirstPage: ServiceError) {
        object?.display(errorAtFirstPage: errorAtFirstPage)
    }
    public func display(errorAtSubsequentPage: ServiceError) {
        object?.display(errorAtSubsequentPage: errorAtSubsequentPage)
    }

}

#endif
