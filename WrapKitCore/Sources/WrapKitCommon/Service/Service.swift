//
//  Service.swift
//  WrapKit
//
//  Created by Stas Lee on 31/7/23.
//

import Foundation
import Combine

public protocol Service<Request, Response> {
    associatedtype Request
    associatedtype Response
    func make(request: Request) -> AnyPublisher<Response, ServiceError>
}

public enum ServiceError: Encodable, Error, Equatable {
    case message(String)
    case `internal`
    case connectivity
    case notAuthorized
    case cancelled
    
    public var title: String {
        switch self {
        case .cancelled:
            return "Network request has been successfully cancelled"
        case .message(let title):
            return title
        case .internal:
            return "Something went wrong"
        case .connectivity:
            return "No internet connection"
        case .notAuthorized:
            return "Not authorized"
        }
    }
}

public extension AnyPublisher where Failure == ServiceError {
    
    @discardableResult
    func onSuccess(_ action: ((Output) -> Void)?) -> AnyPublisher<Output, ServiceError> {
        return self.handleEvents(receiveOutput: action).eraseToAnyPublisher()
    }
    
    @discardableResult
    func onError(_ action: ((ServiceError) -> Void)?) -> AnyPublisher<Output, ServiceError> {
        return self.handleEvents(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                action?(error)
            }
        }).eraseToAnyPublisher()
    }
    
    @discardableResult
    func onCancel(_ action: (() -> Void)?) -> AnyPublisher<Output, ServiceError> {
        return self.handleEvents(receiveCancel: action).eraseToAnyPublisher()
    }
    
    @discardableResult
    func onCompletion(_ action: (() -> Void)?) -> AnyPublisher<Output, ServiceError> {
        return self.handleEvents(receiveCompletion: { _ in action?() }, receiveCancel: action).eraseToAnyPublisher()
    }
    
    @discardableResult
    func subscribe(storeIn cancellables: inout Set<AnyCancellable>?) -> AnyPublisher<Output, Failure> {
        if cancellables != nil {
            self
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &cancellables!)
        }
        return self
    }
}
public extension AnyPublisher where Failure == ServiceError {
    @discardableResult
    func onSuccess(saveTo storage: any Storage<Output>) -> AnyPublisher<Output, ServiceError> {
        return handleEvents(receiveOutput: { response in
            storage.set(model: response)
        }).eraseToAnyPublisher()
    }
}
