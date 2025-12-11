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

extension KeyValueFieldViewOutput {
    public var weakReferenced: any KeyValueFieldViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: KeyValueFieldViewOutput where T: KeyValueFieldViewOutput {

    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        object?.display(model: model)
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        object?.display(keyTitle: keyTitle)
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        object?.display(valueTitle: valueTitle)
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        object?.display(bottomImage: bottomImage)
    }

}
#endif
