// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class EntryFlowSpy: EntryFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showCatalog
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowCatalogCallCount = 0


    // MARK: - EntryFlow methods
    public func showCatalog() {
        capturedShowCatalogCallCount += 1
        messages.append(.showCatalog)
    }

    // MARK: - Properties
}
