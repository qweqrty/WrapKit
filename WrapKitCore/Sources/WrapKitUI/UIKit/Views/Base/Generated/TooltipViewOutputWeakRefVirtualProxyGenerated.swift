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

extension TooltipViewOutput {
    public var weakReferenced: any TooltipViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: TooltipViewOutput where T: TooltipViewOutput {

    public func display(tooltipModel: TooltipViewPresentableModel?) {
        object?.display(tooltipModel: tooltipModel)
    }

}
#endif
