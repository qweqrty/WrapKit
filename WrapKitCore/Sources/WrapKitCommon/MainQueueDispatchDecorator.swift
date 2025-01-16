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

extension MainQueueDispatchDecorator: SelectionFlow where T == SelectionFlow {
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
        dispatch { [weak self, result] in
            self?.decoratee.close(with: result)
        }
    }
}

extension SelectionFlow {
    public var mainQueueDispatched: SelectionFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: HTTPClient where T == HTTPClient {
    public func dispatch(_ request: URLRequest, completion: @escaping (Swift.Result<(data: Data, response: HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        decoratee.dispatch(request) { [weak self] response in
            self?.dispatch { completion(response) }
        }
    }
}

extension MainQueueDispatchDecorator: HTTPDownloadClient where T == HTTPDownloadClient {
    public func download(_ request: URLRequest, progress: @escaping (Double) -> Void, completion: @escaping (DownloadResult) -> Void) -> HTTPClientTask {
        decoratee.download(request, progress: { [weak self] result in
            self?.dispatch(completion: { progress(result) })
        }) { [weak self] response in
            self?.dispatch { completion(response) }
        }
    }
}
