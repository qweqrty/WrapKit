// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
#if canImport(Combine)
import Combine
#endif
public class PaginationViewOutputSwiftUIAdapter<PresentableItem: Any>: ObservableObject, PaginationViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelHasMoreState: DisplayModelHasMoreState? = nil
    public struct DisplayModelHasMoreState {
        public let model: [PresentableItem]
        public let hasMore: Bool
    }
    public func display(model: [PresentableItem], hasMore: Bool) {
        displayModelHasMoreState = .init(
            model: model, 
            hasMore: hasMore
        )
    }
    @Published public var displayIsLoadingFirstPageState: DisplayIsLoadingFirstPageState? = nil
    public struct DisplayIsLoadingFirstPageState {
        public let isLoadingFirstPage: Bool
    }
    public func display(isLoadingFirstPage: Bool) {
        displayIsLoadingFirstPageState = .init(
            isLoadingFirstPage: isLoadingFirstPage
        )
    }
    @Published public var displayIsLoadingSubsequentPageState: DisplayIsLoadingSubsequentPageState? = nil
    public struct DisplayIsLoadingSubsequentPageState {
        public let isLoadingSubsequentPage: Bool
    }
    public func display(isLoadingSubsequentPage: Bool) {
        displayIsLoadingSubsequentPageState = .init(
            isLoadingSubsequentPage: isLoadingSubsequentPage
        )
    }
    @Published public var displayErrorAtFirstPageState: DisplayErrorAtFirstPageState? = nil
    public struct DisplayErrorAtFirstPageState {
        public let errorAtFirstPage: ServiceError
    }
    public func display(errorAtFirstPage: ServiceError) {
        displayErrorAtFirstPageState = .init(
            errorAtFirstPage: errorAtFirstPage
        )
    }
    @Published public var displayErrorAtSubsequentPageState: DisplayErrorAtSubsequentPageState? = nil
    public struct DisplayErrorAtSubsequentPageState {
        public let errorAtSubsequentPage: ServiceError
    }
    public func display(errorAtSubsequentPage: ServiceError) {
        displayErrorAtSubsequentPageState = .init(
            errorAtSubsequentPage: errorAtSubsequentPage
        )
    }
}
