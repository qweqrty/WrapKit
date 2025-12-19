// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(SwiftUI)
import SwiftUI
#endif
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

public final class HiddableOutputSpy: HiddableOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayIsHidden: [(Bool)] = []

    // MARK: - HiddableOutput methods
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append((isHidden))
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
