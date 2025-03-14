// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(Combine)
import Combine
#endif

extension PaginationViewOutput {
    public var weakReferenced: any PaginationViewOutput {
        return WeakRefVirtualProxy(self)
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
