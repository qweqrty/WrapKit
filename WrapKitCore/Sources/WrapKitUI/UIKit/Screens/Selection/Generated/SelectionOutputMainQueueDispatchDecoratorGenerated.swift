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

extension SelectionOutput {
    public var mainQueueDispatched: any SelectionOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: SelectionOutput where T: SelectionOutput {

    public func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String) {
        dispatch { [weak self] in
            self?.decoratee.display(items: items, selectedCountTitle: selectedCountTitle)
        }
    }
    public func display(shouldShowSearchBar: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(shouldShowSearchBar: shouldShowSearchBar)
        }
    }

}
#endif
