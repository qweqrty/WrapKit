// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
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
    public func display(isUserInteractionEnabled: Bool) {
        object?.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

}
#endif
