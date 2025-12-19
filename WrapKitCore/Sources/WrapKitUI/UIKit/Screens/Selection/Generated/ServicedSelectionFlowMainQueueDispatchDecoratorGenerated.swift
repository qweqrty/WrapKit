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

extension ServicedSelectionFlow {
    public var mainQueueDispatched: any ServicedSelectionFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: ServicedSelectionFlow where T: ServicedSelectionFlow {
    public typealias Request = T.Request
    public typealias Response = T.Response

    public func showSelection(model: ServicedSelectionModel<Request, Response>) {
        dispatch { [weak self] in
            self?.decoratee.showSelection(model: model)
        }
    }

}
#endif
