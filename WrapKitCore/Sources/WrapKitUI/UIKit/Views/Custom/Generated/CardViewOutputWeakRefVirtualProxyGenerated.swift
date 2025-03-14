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

extension CardViewOutput {
    public var weakReferenced: any CardViewOutput {
        return WeakRefVirtualProxy(self)
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
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
