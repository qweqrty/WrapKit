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

extension TextOutput {
    public var weakReferenced: any TextOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: TextOutput where T: TextOutput {

    public func display(model: TextOutputPresentableModel?) {
        object?.display(model: model)
    }
    public func display(text: String?) {
        object?.display(text: text)
    }
    public func display(attributes: [TextAttributes]) {
        object?.display(attributes: attributes)
    }

}
#endif
