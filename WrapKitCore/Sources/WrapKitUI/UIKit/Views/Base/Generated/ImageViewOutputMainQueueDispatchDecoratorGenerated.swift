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
#if canImport(SwiftUI)
import SwiftUI
#endif

extension ImageViewOutput {
    public var mainQueueDispatched: any ImageViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: ImageViewOutput where T: ImageViewOutput {

    public func display(model: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(image: ImageEnum?) {
        dispatch { [weak self] in
            self?.decoratee.display(image: image)
        }
    }
    public func display(size: CGSize?) {
        dispatch { [weak self] in
            self?.decoratee.display(size: size)
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
    public func display(contentModeIsFit: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(contentModeIsFit: contentModeIsFit)
        }
    }
    public func display(borderWidth: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(borderWidth: borderWidth)
        }
    }
    public func display(borderColor: Color?) {
        dispatch { [weak self] in
            self?.decoratee.display(borderColor: borderColor)
        }
    }
    public func display(cornerRadius: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(cornerRadius: cornerRadius)
        }
    }
    public func display(alpha: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(alpha: alpha)
        }
    }
    public func display(isHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isHidden: isHidden)
        }
    }

}
#endif
