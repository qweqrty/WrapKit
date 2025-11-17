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

extension SelectionFlow {
    public var mainQueueDispatched: any SelectionFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: SelectionFlow where T: SelectionFlow {

    public func showSelection(model: SelectionPresenterModel) {
        dispatch { [weak self] in
            self?.decoratee.showSelection(model: model)
        }
    }
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        dispatch { [weak self] in
            self?.decoratee.showSelection(model: model)
        }
    }
    public func close(with result: SelectionType?) {
        dispatch { [weak self] in
            self?.decoratee.close(with: result)
        }
    }

}
#endif
