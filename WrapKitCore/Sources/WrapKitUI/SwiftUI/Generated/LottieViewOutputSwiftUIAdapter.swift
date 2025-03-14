// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Lottie)
import Lottie
#endif
#if canImport(UIKit)
import UIKit
#endif
public class LottieViewOutputSwiftUIAdapter: ObservableObject, LottieViewOutput {
        @Published public var currentAnimationName: String? = nil

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: LottieViewPresentableModel
    }
    public func display(model: LottieViewPresentableModel) {
        displayModelState = .init(
            model: model
        )
    }
}
