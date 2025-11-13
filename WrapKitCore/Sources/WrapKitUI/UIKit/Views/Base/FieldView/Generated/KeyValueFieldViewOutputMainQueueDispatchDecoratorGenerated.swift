// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

extension KeyValueFieldViewOutput {
    public var mainQueueDispatched: any KeyValueFieldViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: KeyValueFieldViewOutput where T: KeyValueFieldViewOutput {

    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(keyTitle: keyTitle)
        }
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(valueTitle: valueTitle)
        }
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(bottomImage: bottomImage)
        }
    }

}
#endif
