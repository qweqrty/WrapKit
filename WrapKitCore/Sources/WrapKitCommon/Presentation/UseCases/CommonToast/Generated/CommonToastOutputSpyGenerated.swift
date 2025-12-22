// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif

public final class CommonToastOutputSpy: CommonToastOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayToast(toast: CommonToast)
        case hide
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayToast: [CommonToast] = []


    // MARK: - CommonToastOutput methods
    public func display(_ toast: CommonToast) {
        capturedDisplayToast.append(toast)
        messages.append(.displayToast(toast: toast))
    }
    public func hide() {
        messages.append(.hide)
    }

    // MARK: - Properties

    // MARK: - Reset
    public func reset() {
        messages.removeAll()
        capturedDisplayToast.removeAll()
    }
}
