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
#if canImport(Combine)
import Combine
#endif
import WrapKit
#if canImport(SwiftUI)
import SwiftUI
#endif
import WrapKit

public final class EntryFlowSpy: EntryFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showSplash
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowSplash: [Void] = []

    // MARK: - EntryFlow methods
    public func showSplash() {
        capturedShowSplash.append(())
        messages.append(.showSplash)
    }

    // MARK: - Properties
}
