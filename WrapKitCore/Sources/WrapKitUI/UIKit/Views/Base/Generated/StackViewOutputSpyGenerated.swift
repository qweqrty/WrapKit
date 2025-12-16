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

public final class StackViewOutputSpy: StackViewOutput {
    enum Message: HashableWithReflection {
        case display(model: StackViewPresentableModel)
        case display(spacing: CGFloat?)
        case display(axis: StackViewAxis)
        case display(distribution: StackViewDistribution)
        case display(alignment: StackViewAlignment)
        case display(layoutMargins: EdgeInsets)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [StackViewPresentableModel] = []
    private(set) var capturedDisplaySpacing: [CGFloat?] = []
    private(set) var capturedDisplayAxis: [StackViewAxis] = []
    private(set) var capturedDisplayDistribution: [StackViewDistribution] = []
    private(set) var capturedDisplayAlignment: [StackViewAlignment] = []
    private(set) var capturedDisplayLayoutMargins: [EdgeInsets] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - StackViewOutput methods
    func display(model: StackViewPresentableModel) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(spacing: CGFloat?) {
        capturedDisplaySpacing.append(spacing)
        messages.append(.display(spacing: spacing))
    }
    func display(axis: StackViewAxis) {
        capturedDisplayAxis.append(axis)
        messages.append(.display(axis: axis))
    }
    func display(distribution: StackViewDistribution) {
        capturedDisplayDistribution.append(distribution)
        messages.append(.display(distribution: distribution))
    }
    func display(alignment: StackViewAlignment) {
        capturedDisplayAlignment.append(alignment)
        messages.append(.display(alignment: alignment))
    }
    func display(layoutMargins: EdgeInsets) {
        capturedDisplayLayoutMargins.append(layoutMargins)
        messages.append(.display(layoutMargins: layoutMargins))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
