// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class RefreshControlOutputSpy: RefreshControlOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: RefreshControlPresentableModel?)
        case displayStyle(style: RefreshControlPresentableModel.Style)
        case displayOnRefresh(onRefresh: (() -> Void)?)
        case displayAppendingOnRefresh(appendingOnRefresh: (() -> Void)?)
        case displayIsLoading(isLoading: Bool)
        case setOnRefresh([(() -> Void)?]?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [RefreshControlPresentableModel?] = []
    public private(set) var capturedDisplayStyleStyle: [RefreshControlPresentableModel.Style] = []
    public private(set) var capturedDisplayOnRefreshOnRefresh: [(() -> Void)?] = []
    public private(set) var capturedDisplayAppendingOnRefreshAppendingOnRefresh: [(() -> Void)?] = []
    public private(set) var capturedDisplayIsLoadingIsLoading: [Bool] = []

    public private(set) var capturedOnRefresh: [[(() -> Void)?]?] = []

    // MARK: - RefreshControlOutput methods
    public func display(model: RefreshControlPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        capturedDisplayStyleStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(onRefresh: (() -> Void)?) {
        capturedDisplayOnRefreshOnRefresh.append(onRefresh)
        messages.append(.displayOnRefresh(onRefresh: onRefresh))
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        capturedDisplayAppendingOnRefreshAppendingOnRefresh.append(appendingOnRefresh)
        messages.append(.displayAppendingOnRefresh(appendingOnRefresh: appendingOnRefresh))
    }
    public func display(isLoading: Bool) {
        capturedDisplayIsLoadingIsLoading.append(isLoading)
        messages.append(.displayIsLoading(isLoading: isLoading))
    }

    // MARK: - Properties
    public var onRefresh: [(() -> Void)?]? {
        didSet {
            capturedOnRefresh.append(onRefresh)
            messages.append(.setOnRefresh(onRefresh))
        }
    }
}
