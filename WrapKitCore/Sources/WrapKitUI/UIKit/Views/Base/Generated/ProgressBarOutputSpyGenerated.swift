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
#if canImport(SwiftUI)
import SwiftUI
#endif


public final class ProgressBarOutputSpy: ProgressBarOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case display(model: ProgressBarPresentableModel?)
        case display(progress: CGFloat)
        case display(style: ProgressBarStyle?)
        case display(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [ProgressBarPresentableModel?] = []
    public private(set) var capturedDisplayProgress: [CGFloat] = []
    public private(set) var capturedDisplayStyle: [ProgressBarStyle?] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ProgressBarOutput methods
    public func display(model: ProgressBarPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(progress: CGFloat) {
        capturedDisplayProgress.append(progress)
        messages.append(.display(progress: progress))
    }
    public func display(style: ProgressBarStyle?) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
