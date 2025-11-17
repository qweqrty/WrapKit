// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
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

extension LottieViewOutput {
    public var weakReferenced: any LottieViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: LottieViewOutput where T: LottieViewOutput {

    public func display(model: LottieViewPresentableModel) {
        object?.display(model: model)
    }

    public var currentAnimationName: String? {
        get { return object?.currentAnimationName }
        set { object?.currentAnimationName = newValue }
    }
}
#endif
