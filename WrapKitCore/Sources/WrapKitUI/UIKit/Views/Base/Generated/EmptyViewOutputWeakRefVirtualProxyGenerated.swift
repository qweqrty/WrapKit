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
    public var weakReferenced: any EmptyViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: EmptyViewOutput where T: EmptyViewOutput {

    public func display(model: EmptyViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(title: TextOutputPresentableModel?) {
        object?.display(title: title)
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        object?.display(subtitle: subtitle)
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        object?.display(buttonModel: buttonModel)
    }
    public func display(image: ImageViewPresentableModel?) {
        object?.display(image: image)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
