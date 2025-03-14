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

extension SelectionOutput {
    public var weakReferenced: any SelectionOutput {
        return WeakRefVirtualProxy(self)
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
