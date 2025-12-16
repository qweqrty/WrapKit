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
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Lottie)
import Lottie
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class LottieViewOutputSpy: LottieViewOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(model: LottieViewPresentableModel)
        case setCurrentAnimationName(String?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [LottieViewPresentableModel] = []

    private(set) var capturedCurrentAnimationName: [String?] = []

    // MARK: - LottieViewOutput methods
    public func display(model: LottieViewPresentableModel) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }

    // MARK: - Properties
    var currentAnimationName: String? {
        didSet {
            capturedCurrentAnimationName.append(currentAnimationName)
            messages.append(.setCurrentAnimationName(currentAnimationName))
        }
    }
}
