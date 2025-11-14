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

extension LoadingOutput {
    public var weakReferenced: any LoadingOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: LoadingOutput where T: LoadingOutput {

    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
    // Static methods cannot be generated for generic T. Implement this in specific types.

    public var isLoading: Bool? {
        get { return object?.isLoading }
        set { object?.isLoading = newValue }
    }
}
#endif
