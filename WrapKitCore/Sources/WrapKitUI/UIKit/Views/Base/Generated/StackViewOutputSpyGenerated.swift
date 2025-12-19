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
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

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
    public private(set) var capturedDisplayModel: [(StackViewPresentableModel)] = []
    public private(set) var capturedDisplaySpacing: [(CGFloat?)] = []
    public private(set) var capturedDisplayAxis: [(StackViewAxis)] = []
    public private(set) var capturedDisplayDistribution: [(StackViewDistribution)] = []
    public private(set) var capturedDisplayAlignment: [(StackViewAlignment)] = []
    public private(set) var capturedDisplayLayoutMargins: [(EdgeInsets)] = []
    public private(set) var capturedDisplayIsHidden: [(Bool)] = []

    // MARK: - StackViewOutput methods
    public func display(model: StackViewPresentableModel) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(spacing: CGFloat?) {
        capturedDisplaySpacing.append((spacing))
        messages.append(.displaySpacing(spacing: spacing))
    }
    public func display(axis: StackViewAxis) {
        capturedDisplayAxis.append((axis))
        messages.append(.displayAxis(axis: axis))
    }
    public func display(distribution: StackViewDistribution) {
        capturedDisplayDistribution.append((distribution))
        messages.append(.displayDistribution(distribution: distribution))
    }
    public func display(alignment: StackViewAlignment) {
        capturedDisplayAlignment.append((alignment))
        messages.append(.displayAlignment(alignment: alignment))
    }
    public func display(layoutMargins: EdgeInsets) {
        capturedDisplayLayoutMargins.append((layoutMargins))
        messages.append(.displayLayoutMargins(layoutMargins: layoutMargins))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append((isHidden))
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
