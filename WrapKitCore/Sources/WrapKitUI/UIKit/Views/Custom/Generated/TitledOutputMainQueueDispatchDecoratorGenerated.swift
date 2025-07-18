// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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

extension TitledOutput {
    public var mainQueueDispatched: any TitledOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TitledOutput where T: TitledOutput {

    public func display(model: TitledViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        dispatch { [weak self] in
            self?.decoratee.display(titles: titles)
        }
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        dispatch { [weak self] in
            self?.decoratee.display(bottomTitles: bottomTitles)
        }
    }
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(leadingBottomTitle: leadingBottomTitle)
        }
    }
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(trailingBottomTitle: trailingBottomTitle)
        }
    }
    public func display(isUserInteractionEnabled: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isUserInteractionEnabled: isUserInteractionEnabled)
        }
    }
    public func display(isHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isHidden: isHidden)
        }
    }

}
#endif
