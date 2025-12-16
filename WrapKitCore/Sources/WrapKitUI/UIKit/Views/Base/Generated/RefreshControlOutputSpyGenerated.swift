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
#if canImport(UIKit)
import UIKit
#endif

public final class RefreshControlOutputSpy: RefreshControlOutput {
    enum Message: HashableWithReflection {
        case display(model: RefreshControlPresentableModel?)
        case display(style: RefreshControlPresentableModel.Style)
        case display(onRefresh: (() -> Void)?)
        case display(appendingOnRefresh: (() -> Void)?)
        case display(isLoading: Bool)
        case setOnRefresh([(() -> Void)?]?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [RefreshControlPresentableModel?] = []
    private(set) var capturedDisplayStyle: [RefreshControlPresentableModel.Style] = []
    private(set) var capturedDisplayOnRefresh: [(() -> Void)?] = []
    private(set) var capturedDisplayAppendingOnRefresh: [(() -> Void)?] = []
    private(set) var capturedDisplayIsLoading: [Bool] = []

    private(set) var capturedOnRefresh: [[(() -> Void)?]?] = []

    // MARK: - RefreshControlOutput methods
    func display(model: RefreshControlPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(style: RefreshControlPresentableModel.Style) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    func display(onRefresh: (() -> Void)?) {
        capturedDisplayOnRefresh.append(onRefresh)
        messages.append(.display(onRefresh: onRefresh))
    }
    func display(appendingOnRefresh: (() -> Void)?) {
        capturedDisplayAppendingOnRefresh.append(appendingOnRefresh)
        messages.append(.display(appendingOnRefresh: appendingOnRefresh))
    }
    func display(isLoading: Bool) {
        capturedDisplayIsLoading.append(isLoading)
        messages.append(.display(isLoading: isLoading))
    }

    // MARK: - Properties
    var onRefresh: [(() -> Void)?]? {
        didSet {
            capturedOnRefresh.append(onRefresh)
            messages.append(.setOnRefresh(onRefresh))
        }
    }
}
