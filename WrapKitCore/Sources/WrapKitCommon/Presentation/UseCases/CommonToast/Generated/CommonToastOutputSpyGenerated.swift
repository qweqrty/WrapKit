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

public final class CommonToastOutputSpy: CommonToastOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(_ : CommonToast)
        case hide()
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayToast: [CommonToast] = []


    // MARK: - CommonToastOutput methods
    public func display(_ toast: CommonToast) {
        capturedDisplayToast.append(toast)
        messages.append(.display(toast))
    }
    public func hide() {
        messages.append(.hide())
    }

    // MARK: - Properties
}
