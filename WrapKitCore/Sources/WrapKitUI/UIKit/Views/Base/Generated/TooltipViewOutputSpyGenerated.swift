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

public final class TooltipViewOutputSpy: TooltipViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayTooltipModel(tooltipModel: TooltipViewPresentableModel?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayTooltipModel: [TooltipViewPresentableModel?] = []


    // MARK: - TooltipViewOutput methods
    public func display(tooltipModel: TooltipViewPresentableModel?) {
        capturedDisplayTooltipModel.append(tooltipModel)
        messages.append(.displayTooltipModel(tooltipModel: tooltipModel))
    }

    // MARK: - Properties
}
