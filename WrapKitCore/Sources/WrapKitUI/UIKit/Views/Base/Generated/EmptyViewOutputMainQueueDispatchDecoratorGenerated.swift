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

extension EmptyViewOutput {
    public var mainQueueDispatched: any EmptyViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: EmptyViewOutput where T: EmptyViewOutput {

    public func display(model: EmptyViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(title: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(title: title)
        }
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(subtitle: subtitle)
        }
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(buttonModel: buttonModel)
        }
    }
    public func display(image: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(image: image)
        }
    }
    public func display(isHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isHidden: isHidden)
        }
    }

}
#endif
