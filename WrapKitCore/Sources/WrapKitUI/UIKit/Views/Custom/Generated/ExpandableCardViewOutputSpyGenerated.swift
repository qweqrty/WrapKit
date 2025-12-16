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
#if canImport(Combine)
import Combine
#endif

public final class ExpandableCardViewOutputSpy: ExpandableCardViewOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [Pair<CardViewPresentableModel, CardViewPresentableModel?>] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ExpandableCardViewOutput methods
    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
