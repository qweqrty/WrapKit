// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif

extension HiddableOutput {
    public var weakReferenced: any HiddableOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: HiddableOutput where T: HiddableOutput {

    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
