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
#if canImport(UIKit)
import UIKit
#endif

extension TextOutput {
    public var mainQueueDispatched: any TextOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TextOutput where T: TextOutput {

    public func display(model: TextOutputPresentableModel?, completion: ((Label?) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model, completion: completion)
        }
    }
    public func display(text: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(text: text)
        }
    }
    public func display(attributes: [TextAttributes], completion: ((Label?) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(attributes: attributes, completion: completion)
        }
    }
    public func display(id: String?, from startAmount: Double, to endAmount: Double, mapToString: ((Double) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        }
    }
    public func display(isHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isHidden: isHidden)
        }
    }

}
#endif
