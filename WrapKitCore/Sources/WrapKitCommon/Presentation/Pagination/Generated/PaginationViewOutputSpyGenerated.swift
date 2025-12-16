// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(Combine)
import Combine
#endif


public class PaginationViewOutputSpy<PresentableItem: Any>: PaginationViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case display(model: [PresentableItem], hasMore: Bool)
        case display(isLoadingFirstPage: Bool)
        case display(isLoadingSubsequentPage: Bool)
        case display(errorAtFirstPage: ServiceError)
        case display(errorAtSubsequentPage: ServiceError)
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
        messages.append(.display(model: model, hasMore: hasMore))
    }
    public func display(isLoadingFirstPage: Bool) {
        capturedDisplayIsLoadingFirstPage.append(isLoadingFirstPage)
        messages.append(.display(isLoadingFirstPage: isLoadingFirstPage))
    }
    public func display(isLoadingSubsequentPage: Bool) {
        capturedDisplayIsLoadingSubsequentPage.append(isLoadingSubsequentPage)
        messages.append(.display(isLoadingSubsequentPage: isLoadingSubsequentPage))
    }
    public func display(errorAtFirstPage: ServiceError) {
        capturedDisplayErrorAtFirstPage.append(errorAtFirstPage)
        messages.append(.display(errorAtFirstPage: errorAtFirstPage))
    }
    public func display(errorAtSubsequentPage: ServiceError) {
        capturedDisplayErrorAtSubsequentPage.append(errorAtSubsequentPage)
        messages.append(.display(errorAtSubsequentPage: errorAtSubsequentPage))
    }

    // MARK: - Properties
}
