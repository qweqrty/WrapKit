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
        case display(model: RefreshControlPresentableModel?)
        case display(style: RefreshControlPresentableModel.Style)
        case display(onRefresh: (() -> Void)?)
        case display(appendingOnRefresh: (() -> Void)?)
        case display(isLoading: Bool)
        case setOnRefresh([(() -> Void)?]?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [RefreshControlPresentableModel?] = []
    public private(set) var capturedDisplayStyle: [RefreshControlPresentableModel.Style] = []
    public private(set) var capturedDisplayOnRefresh: [(() -> Void)?] = []
    public private(set) var capturedDisplayAppendingOnRefresh: [(() -> Void)?] = []
    public private(set) var capturedDisplayIsLoading: [Bool] = []

    public private(set) var capturedOnRefresh: [[(() -> Void)?]?] = []

    // MARK: - RefreshControlOutput methods
    public func display(model: RefreshControlPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    public func display(onRefresh: (() -> Void)?) {
        capturedDisplayOnRefresh.append(onRefresh)
        messages.append(.display(onRefresh: onRefresh))
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        capturedDisplayAppendingOnRefresh.append(appendingOnRefresh)
        messages.append(.display(appendingOnRefresh: appendingOnRefresh))
    }
    public func display(isLoading: Bool) {
        capturedDisplayIsLoading.append(isLoading)
        messages.append(.display(isLoading: isLoading))
    }

    // MARK: - Properties
    public var onRefresh: [(() -> Void)?]? {
        didSet {
            capturedOnRefresh.append(onRefresh)
            messages.append(.setOnRefresh(onRefresh))
        }
    }
}
