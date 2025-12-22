// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

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

    public enum Message: HashableWithReflection {
        case displayModel(model: LottieViewPresentableModel)
        case setCurrentAnimationName(String?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [LottieViewPresentableModel] = []

    public private(set) var capturedCurrentAnimationName: [String?] = []

    // MARK: - LottieViewOutput methods
    public func display(model: LottieViewPresentableModel) {
        capturedDisplayModel.append(model)
        messages.append(.displayModel(model: model))
    }

    // MARK: - Properties
    public var currentAnimationName: String? {
        didSet {
            capturedCurrentAnimationName.append(currentAnimationName)
            messages.append(.setCurrentAnimationName(currentAnimationName))
        }
    }

    // MARK: - Reset
    public func reset() {
        messages.removeAll()
        capturedDisplayModel.removeAll()
        capturedCurrentAnimationName.removeAll()
    }
}
