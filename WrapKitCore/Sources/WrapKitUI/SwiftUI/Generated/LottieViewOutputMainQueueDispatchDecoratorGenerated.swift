// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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
    public var mainQueueDispatched: any LottieViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension LottieViewOutput {
    public var weakReferenced: any LottieViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: LottieViewOutput where T: LottieViewOutput {

    public func display(model: LottieViewPresentableModel) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }

    public var currentAnimationName: String? {
        get {
            return decoratee.currentAnimationName          
        }
        set {
            decoratee.currentAnimationName = newValue
        }
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
