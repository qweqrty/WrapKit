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
    public var mainQueueDispatched: any TooltipViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TooltipViewOutput where T: TooltipViewOutput {

    public func display(tooltipModel: TooltipViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(tooltipModel: tooltipModel)
        }
    }

}
#endif
