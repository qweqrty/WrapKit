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
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class ProgressBarOutputSpy: ProgressBarOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: ProgressBarPresentableModel?)
        case displayProgress(progress: CGFloat)
        case displayStyle(style: ProgressBarStyle?)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [ProgressBarPresentableModel?] = []
    public private(set) var capturedDisplayProgressProgress: [CGFloat] = []
    public private(set) var capturedDisplayStyleStyle: [ProgressBarStyle?] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - ProgressBarOutput methods
    public func display(model: ProgressBarPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(progress: CGFloat) {
        capturedDisplayProgressProgress.append(progress)
        messages.append(.displayProgress(progress: progress))
    }
    public func display(style: ProgressBarStyle?) {
        capturedDisplayStyleStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
