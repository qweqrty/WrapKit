//
//  MainQueueDispatchDecorator.swift
//  WrapKitTests
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public final class MainQueueDispatchDecorator<T> {
    public private(set) var decoratee: T
    
    public init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    public func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

//extension MainQueueDispatchDecorator: SelectionFlow where T == SelectionFlow {
//    public func showSelection(model: SelectionPresenterModel) {
//        dispatch { [weak self] in
//            self?.decoratee.showSelection(model: model)
//        }
//    }
//    
//    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
//        dispatch { [weak self] in
//            self?.decoratee.showSelection(model: model)
//        }
//    }
//    
//    public func close(with result: SelectionType?) {
//        dispatch { [weak self, result] in
//            self?.decoratee.close(with: result)
//        }
//    }
//}
//
//extension SelectionFlow {
//    public var mainQueueDispatched: SelectionFlow {
//        MainQueueDispatchDecorator(decoratee: self)
//    }
//}
//
//extension MainQueueDispatchDecorator: CardViewOutput where T == CardViewOutput {
//    public func display(model: CardViewPresentableModel) {
//        dispatch { [weak self] in
//            self?.decoratee.display(model: model)
//        }
//    }
//}
//
//extension CardViewOutput {
//    public var mainQueueDispatched: CardViewOutput {
//        MainQueueDispatchDecorator(decoratee: self)
//    }
//}
//
//extension MainQueueDispatchDecorator: TimerOutput where T == TimerOutput {
//    public func display(secondsRemaining: Int?) {
//        dispatch { [weak self] in
//            self?.decoratee.display(secondsRemaining: secondsRemaining)
//        }
//    }
//}
//
//extension MainQueueDispatchDecorator: AlertOutput where T == AlertOutput {
//    public func showAlert(title: String?, text: String?, actions: [AlertAction], cancelText: String?) {
//        dispatch { [weak self] in
//            self?.decoratee.showAlert(title: title, text: text, actions: actions, cancelText: cancelText)
//        }
//    }
//    
//    public func showActionSheet(title: String?, text: String?, actions: [AlertAction], cancelText: String?) {
//        dispatch { [weak self] in
//            self?.decoratee.showActionSheet(title: title, text: text, actions: actions, cancelText: cancelText)
//        }
//    }
//}
//
//extension AlertOutput {
//    public var mainQueueDispatched: AlertOutput {
//        MainQueueDispatchDecorator(decoratee: self)
//    }
//    
//    public var weakReferenced: AlertOutput {
//        return WeakRefVirtualProxy(self)
//    }
//}
//
//extension MainQueueDispatchDecorator: SelectionOutput where T == SelectionOutput {
//    public func display(items: [SelectionType.SelectionCellPresentableModel], selectedCountTitle: String) {
//        dispatch { [weak self] in
//            self?.decoratee.display(items: items, selectedCountTitle: selectedCountTitle)
//        }
//    }
//    
//    public func display(title: String?) {
//        dispatch { [weak self] in
//            self?.decoratee.display(title: title)
//        }
//    }
//    
//    public func display(shouldShowSearchBar: Bool) {
//        dispatch { [weak self] in
//            self?.decoratee.display(shouldShowSearchBar: shouldShowSearchBar)
//        }
//    }
//    
//    public func display(canReset: Bool) {
//        dispatch { [weak self] in
//            self?.decoratee.display(canReset: canReset)
//        }
//    }
//}
//
//extension SelectionOutput {
//    public var mainQueueDispatched: SelectionOutput {
//        MainQueueDispatchDecorator(decoratee: self)
//    }
//    
//    public var weakReferenced: SelectionOutput {
//        return WeakRefVirtualProxy(self)
//    }
//}
//
//extension MainQueueDispatchDecorator: CommonToastOutput where T == CommonToastOutput {
//    public func display(_ toast: CommonToast) {
//        dispatch { [weak self] in
//            self?.decoratee.display(toast)
//        }
//    }
//}
//
//extension CommonToastOutput {
//    public var mainQueueDispatched: CommonToastOutput {
//        MainQueueDispatchDecorator(decoratee: self)
//    }
//}
//
//extension MainQueueDispatchDecorator: HTTPClient where T == HTTPClient {
//    public func dispatch(_ request: URLRequest, completion: @escaping (Swift.Result<(data: Data, response: HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
//        decoratee.dispatch(request) { [weak self] response in
//            self?.dispatch { completion(response) }
//        }
//    }
//}
//
//extension MainQueueDispatchDecorator: CommonLoadingOutput where T == CommonLoadingOutput {
//    public func display(isLoading: Bool) {
//        dispatch { [weak self] in
//            self?.decoratee.display(isLoading: isLoading)
//        }
//        
//    }
//    
//    public var isLoading: Bool {
//        get {
//            return decoratee.isLoading
//        }
//    }
//}
//
//extension MainQueueDispatchDecorator: HTTPDownloadClient where T == HTTPDownloadClient {
//    public func download(_ request: URLRequest, progress: @escaping (Double) -> Void, completion: @escaping (DownloadResult) -> Void) -> HTTPClientTask {
//        decoratee.download(request, progress: { [weak self] result in
//            self?.dispatch(completion: { progress(result) })
//        }) { [weak self] response in
//            self?.dispatch { completion(response) }
//        }
//    }
//}
//
//extension MainQueueDispatchDecorator: ExpandableCardViewOutput where T == ExpandableCardViewOutput {
//    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
//        dispatch { [weak self] in
//            self?.decoratee.display(model: model)
//        }
//    }
//}
//
//extension ExpandableCardViewOutput {
//    public var mainQueueDispatched: ExpandableCardViewOutput {
//        MainQueueDispatchDecorator(decoratee: self)
//    }
//}
