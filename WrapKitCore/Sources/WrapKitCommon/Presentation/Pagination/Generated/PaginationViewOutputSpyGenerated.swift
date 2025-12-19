// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(Combine)
import Combine
#endif

public class PaginationViewOutputSpy<PresentableItem: Any>: PaginationViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: [PresentableItem], hasMore: Bool)
        case displayIsLoadingFirstPage(isLoadingFirstPage: Bool)
        case displayIsLoadingSubsequentPage(isLoadingSubsequentPage: Bool)
        case displayErrorAtFirstPage(errorAtFirstPage: ServiceError)
        case displayErrorAtSubsequentPage(errorAtSubsequentPage: ServiceError)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [[PresentableItem]] = []
    public private(set) var capturedDisplayHasMore: [Bool] = []
    public private(set) var capturedDisplayIsLoadingFirstPage: [Bool] = []
    public private(set) var capturedDisplayIsLoadingSubsequentPage: [Bool] = []
    public private(set) var capturedDisplayErrorAtFirstPage: [ServiceError] = []
    public private(set) var capturedDisplayErrorAtSubsequentPage: [ServiceError] = []


    // MARK: - PaginationViewOutput methods
    public func display(model: [PresentableItem], hasMore: Bool) {
        capturedDisplayModel.append(model)
        capturedDisplayHasMore.append(hasMore)
        messages.append(.displayModel(model: model, hasMore: hasMore))
    }
    public func display(isLoadingFirstPage: Bool) {
        capturedDisplayIsLoadingFirstPage.append(isLoadingFirstPage)
        messages.append(.displayIsLoadingFirstPage(isLoadingFirstPage: isLoadingFirstPage))
    }
    public func display(isLoadingSubsequentPage: Bool) {
        capturedDisplayIsLoadingSubsequentPage.append(isLoadingSubsequentPage)
        messages.append(.displayIsLoadingSubsequentPage(isLoadingSubsequentPage: isLoadingSubsequentPage))
    }
    public func display(errorAtFirstPage: ServiceError) {
        capturedDisplayErrorAtFirstPage.append(errorAtFirstPage)
        messages.append(.displayErrorAtFirstPage(errorAtFirstPage: errorAtFirstPage))
    }
    public func display(errorAtSubsequentPage: ServiceError) {
        capturedDisplayErrorAtSubsequentPage.append(errorAtSubsequentPage)
        messages.append(.displayErrorAtSubsequentPage(errorAtSubsequentPage: errorAtSubsequentPage))
    }

    // MARK: - Properties
}
