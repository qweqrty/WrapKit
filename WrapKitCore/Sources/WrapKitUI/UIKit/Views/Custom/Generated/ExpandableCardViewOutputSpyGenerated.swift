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
#if canImport(Combine)
import Combine
#endif

public final class ExpandableCardViewOutputSpy: ExpandableCardViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [Pair<CardViewPresentableModel, CardViewPresentableModel?>] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ExpandableCardViewOutput methods
    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        capturedDisplayModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
