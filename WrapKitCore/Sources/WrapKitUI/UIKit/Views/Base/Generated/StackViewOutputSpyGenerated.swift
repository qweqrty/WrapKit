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

public final class StackViewOutputSpy: StackViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: StackViewPresentableModel)
        case displaySpacing(spacing: CGFloat?)
        case displayAxis(axis: StackViewAxis)
        case displayDistribution(distribution: StackViewDistribution)
        case displayAlignment(alignment: StackViewAlignment)
        case displayLayoutMargins(layoutMargins: EdgeInsets)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [StackViewPresentableModel] = []
    public private(set) var capturedDisplaySpacingSpacing: [CGFloat?] = []
    public private(set) var capturedDisplayAxisAxis: [StackViewAxis] = []
    public private(set) var capturedDisplayDistributionDistribution: [StackViewDistribution] = []
    public private(set) var capturedDisplayAlignmentAlignment: [StackViewAlignment] = []
    public private(set) var capturedDisplayLayoutMarginsLayoutMargins: [EdgeInsets] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - StackViewOutput methods
    public func display(model: StackViewPresentableModel) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(spacing: CGFloat?) {
        capturedDisplaySpacingSpacing.append(spacing)
        messages.append(.displaySpacing(spacing: spacing))
    }
    public func display(axis: StackViewAxis) {
        capturedDisplayAxisAxis.append(axis)
        messages.append(.displayAxis(axis: axis))
    }
    public func display(distribution: StackViewDistribution) {
        capturedDisplayDistributionDistribution.append(distribution)
        messages.append(.displayDistribution(distribution: distribution))
    }
    public func display(alignment: StackViewAlignment) {
        capturedDisplayAlignmentAlignment.append(alignment)
        messages.append(.displayAlignment(alignment: alignment))
    }
    public func display(layoutMargins: EdgeInsets) {
        capturedDisplayLayoutMarginsLayoutMargins.append(layoutMargins)
        messages.append(.displayLayoutMargins(layoutMargins: layoutMargins))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
