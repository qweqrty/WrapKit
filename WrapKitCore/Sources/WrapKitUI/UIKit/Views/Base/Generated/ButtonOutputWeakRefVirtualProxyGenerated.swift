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

extension ButtonOutput {
    public var weakReferenced: any ButtonOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: ButtonOutput where T: ButtonOutput {

    public func display(model: ButtonPresentableModel?) {
        object?.display(model: model)
    }
    public func display(enabled: Bool) {
        object?.display(enabled: enabled)
    }
    public func display(image: Image?) {
        object?.display(image: image)
    }
    public func display(style: ButtonStyle?) {
        object?.display(style: style)
    }
    public func display(title: String?) {
        object?.display(title: title)
    }
    public func display(spacing: CGFloat) {
        object?.display(spacing: spacing)
    }
    public func display(onPress: (() -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(height: CGFloat) {
        object?.display(height: height)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }
    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }

}
#endif
