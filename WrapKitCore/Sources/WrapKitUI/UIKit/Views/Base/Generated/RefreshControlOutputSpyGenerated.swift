// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

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
    public private(set) var capturedDisplayModel: [(RefreshControlPresentableModel?)] = []
    public private(set) var capturedDisplayStyle: [(RefreshControlPresentableModel.Style)] = []
    public private(set) var capturedDisplayOnRefresh: [((() -> Void)?)] = []
    public private(set) var capturedDisplayAppendingOnRefresh: [((() -> Void)?)] = []
    public private(set) var capturedDisplayIsLoading: [(Bool)] = []
    public private(set) var capturedSetOnRefresh: [[(() -> Void)?]?] = []

    // MARK: - RefreshControlOutput methods
    public func display(model: RefreshControlPresentableModel?) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        capturedDisplayStyle.append((style))
        messages.append(.displayStyle(style: style))
    }
    public func display(onRefresh: (() -> Void)?) {
        capturedDisplayOnRefresh.append((onRefresh))
        messages.append(.displayOnRefresh(onRefresh: onRefresh))
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        capturedDisplayAppendingOnRefresh.append((appendingOnRefresh))
        messages.append(.displayAppendingOnRefresh(appendingOnRefresh: appendingOnRefresh))
    }
    public func display(isLoading: Bool) {
        capturedDisplayIsLoading.append((isLoading))
        messages.append(.displayIsLoading(isLoading: isLoading))
    }

    // MARK: - Properties
    public var onRefresh: [(() -> Void)?]? {
        didSet {
            capturedSetOnRefresh.append(onRefresh)
            messages.append(.setOnRefresh(onRefresh))
        }
    }
}
