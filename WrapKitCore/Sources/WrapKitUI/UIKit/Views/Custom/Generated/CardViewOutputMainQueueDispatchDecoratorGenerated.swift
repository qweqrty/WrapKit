// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

extension CardViewOutput {
    public var mainQueueDispatched: any CardViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension CardViewOutput {
    public var weakReferenced: any CardViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: CardViewOutput where T: CardViewOutput {

    public func display(model: CardViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(style: CardViewPresentableModel.Style?) {
        dispatch { [weak self] in
            self?.decoratee.display(style: style)
        }
    }
    public func display(title: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(title: title)
        }
    }
    public func display(leadingImage: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(leadingImage: leadingImage)
        }
    }
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(secondaryLeadingImage: secondaryLeadingImage)
        }
    }
    public func display(trailingImage: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(trailingImage: trailingImage)
        }
    }
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(secondaryTrailingImage: secondaryTrailingImage)
        }
    }
    public func display(subTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(subTitle: subTitle)
        }
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(valueTitle: valueTitle)
        }
    }
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        dispatch { [weak self] in
            self?.decoratee.display(bottomSeparator: bottomSeparator)
        }
    }
    public func display(switchControl: SwitchControlPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(switchControl: switchControl)
        }
    }
    public func display(onPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onPress: onPress)
        }
    }
    public func display(onLongPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onLongPress: onLongPress)
        }
    }

}

extension WeakRefVirtualProxy: CardViewOutput where T: CardViewOutput {

    public func display(model: CardViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(style: CardViewPresentableModel.Style?) {
        object?.display(style: style)
    }
    public func display(title: TextOutputPresentableModel?) {
        object?.display(title: title)
    }
    public func display(leadingImage: ImageViewPresentableModel?) {
        object?.display(leadingImage: leadingImage)
    }
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        object?.display(secondaryLeadingImage: secondaryLeadingImage)
    }
    public func display(trailingImage: ImageViewPresentableModel?) {
        object?.display(trailingImage: trailingImage)
    }
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        object?.display(secondaryTrailingImage: secondaryTrailingImage)
    }
    public func display(subTitle: TextOutputPresentableModel?) {
        object?.display(subTitle: subTitle)
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        object?.display(valueTitle: valueTitle)
    }
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        object?.display(bottomSeparator: bottomSeparator)
    }
    public func display(switchControl: SwitchControlPresentableModel?) {
        object?.display(switchControl: switchControl)
    }
    public func display(onPress: (() -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(onLongPress: (() -> Void)?) {
        object?.display(onLongPress: onLongPress)
    }

}

#endif
