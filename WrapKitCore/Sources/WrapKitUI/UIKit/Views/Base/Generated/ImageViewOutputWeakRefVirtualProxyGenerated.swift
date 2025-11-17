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

extension ImageViewOutput {
    public var weakReferenced: any ImageViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: ImageViewOutput where T: ImageViewOutput {

    public func display(model: ImageViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(image: ImageEnum?) {
        object?.display(image: image)
    }
    public func display(size: CGSize?) {
        object?.display(size: size)
    }
    public func display(onPress: (() -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(onLongPress: (() -> Void)?) {
        object?.display(onLongPress: onLongPress)
    }
    public func display(contentModeIsFit: Bool) {
        object?.display(contentModeIsFit: contentModeIsFit)
    }
    public func display(borderWidth: CGFloat?) {
        object?.display(borderWidth: borderWidth)
    }
    public func display(borderColor: Color?) {
        object?.display(borderColor: borderColor)
    }
    public func display(cornerRadius: CGFloat?) {
        object?.display(cornerRadius: cornerRadius)
    }
    public func display(alpha: CGFloat?) {
        object?.display(alpha: alpha)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
