// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
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
#if canImport(SwiftUI)
import SwiftUI
#endif

extension TextOutput {
    public var mainQueueDispatched: any TextOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TextOutput where T: TextOutput {

    public func display(model: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(text: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(text: text)
        }
    }
    public func display(attributes: [TextAttributes]) {
        dispatch { [weak self] in
            self?.decoratee.display(attributes: attributes)
        }
    }
    public func display(htmlString: String?, font: Font, color: Color) {
        dispatch { [weak self] in
            self?.decoratee.display(htmlString: htmlString, font: font, color: color)
        }
    }
    public func display(id: String?, from startAmount: Decimal, to endAmount: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
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
