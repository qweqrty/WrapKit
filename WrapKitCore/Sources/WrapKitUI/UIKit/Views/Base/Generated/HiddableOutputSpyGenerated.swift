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
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif

final class HiddableOutputSpy: HiddableOutput {
    enum Message: HashableWithReflection {
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - HiddableOutput methods
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
