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

extension TitledOutput {
    public var weakReferenced: any TitledOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: TitledOutput where T: TitledOutput {

    public func display(model: TitledViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        object?.display(titles: titles)
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        object?.display(bottomTitles: bottomTitles)
    }
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        object?.display(leadingBottomTitle: leadingBottomTitle)
    }
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        object?.display(trailingBottomTitle: trailingBottomTitle)
    }
    public func display(isUserInteractionEnabled: Bool) {
        object?.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
