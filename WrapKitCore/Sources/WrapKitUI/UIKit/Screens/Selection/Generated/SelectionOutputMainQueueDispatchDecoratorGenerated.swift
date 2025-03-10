// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

extension SelectionOutput {
    public var weakReferenced: any SelectionOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: SelectionOutput where T: SelectionOutput {

    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
        dispatch { [weak self] in
            self?.decoratee.display(items: items, selectedCountTitle: selectedCountTitle)
        }
    }
    public func display(title: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(title: title)
        }
    }
    public func display(shouldShowSearchBar: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(shouldShowSearchBar: shouldShowSearchBar)
        }
    }
    public func display(canReset: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(canReset: canReset)
        }
    }
    public func display(model: EmptyViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }

}

extension WeakRefVirtualProxy: SelectionOutput where T: SelectionOutput {

    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
        object?.display(items: items, selectedCountTitle: selectedCountTitle)
    }
    public func display(title: String?) {
        object?.display(title: title)
    }
    public func display(shouldShowSearchBar: Bool) {
        object?.display(shouldShowSearchBar: shouldShowSearchBar)
    }
    public func display(canReset: Bool) {
        object?.display(canReset: canReset)
    }
    public func display(model: EmptyViewPresentableModel?) {
        object?.display(model: model)
    }

}

#endif
