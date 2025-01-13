//
//  WeakRefVirtualProxy.swift
//
//
//  Created by Stanislav Li on 17/10/24.
//

import Foundation

public final class WeakRefVirtualProxy<T: AnyObject> {
    public weak var object: T?
    
    public init(_ object: T) {
        self.object = object
    }
}
//
//extension WeakRefVirtualProxy: CommonLoadingOutput where T: CommonLoadingOutput {
//    public var isLoading: Bool { object?.isLoading == true }
//    
//    public func display(isLoading: Bool) {
//        object?.display(isLoading: isLoading)
//    }
//}
//
//extension WeakRefVirtualProxy: TimerOutput where T: TimerOutput {
//    public func display(secondsRemaining: Int?) {
//        object?.display(secondsRemaining: secondsRemaining)
//    }
//}
//
//
//extension CardViewOutput {
//    public var weakReferenced: CardViewOutput {
//        return WeakRefVirtualProxy(self)
//    }
//}
//
//extension WeakRefVirtualProxy: CardViewOutput where T: CardViewOutput {
//    public func display(model: CardViewPresentableModel) {
//        object?.display(model: model)
//    }
//}
//
//extension WeakRefVirtualProxy: AlertOutput where T: AlertOutput {
//    public func showAlert(title: String?, text: String?, actions: [AlertAction], cancelText: String?) {
//        object?.showAlert(title: title, text: text, actions: actions, cancelText: cancelText)
//    }
//    
//    public func showActionSheet(title: String?, text: String?, actions: [AlertAction], cancelText: String?) {
//        object?.showActionSheet(title: title, text: text, actions: actions, cancelText: cancelText)
//    }
//}
//
//extension WeakRefVirtualProxy: SelectionOutput where T: SelectionOutput {
//    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
//        object?.display(items: items, selectedCountTitle: selectedCountTitle)
//    }
//    
//    public func display(title: String?) {
//        object?.display(title: title)
//    }
//    
//    public func display(shouldShowSearchBar: Bool) {
//        object?.display(shouldShowSearchBar: shouldShowSearchBar)
//    }
//    
//    public func display(canReset: Bool) {
//        object?.display(canReset: canReset)
//    }
//    
//}
//
//extension ExpandableCardViewOutput {
//    public var weakReferenced: ExpandableCardViewOutput {
//        return WeakRefVirtualProxy(self)
//    }
//}
//
//extension WeakRefVirtualProxy: ExpandableCardViewOutput where T: ExpandableCardViewOutput {
//    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
//        object?.display(model: model)
//    }
//}
