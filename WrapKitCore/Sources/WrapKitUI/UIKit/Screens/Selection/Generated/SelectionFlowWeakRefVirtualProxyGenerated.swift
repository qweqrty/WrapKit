// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
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
    public var weakReferenced: any SelectionFlow {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: SelectionFlow where T: SelectionFlow {

    public func showSelection(model: SelectionPresenterModel) {
        object?.showSelection(model: model)
    }
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        object?.showSelection(model: model)
    }
    public func close(with result: SelectionType?) {
        object?.close(with: result)
    }

}
#endif
