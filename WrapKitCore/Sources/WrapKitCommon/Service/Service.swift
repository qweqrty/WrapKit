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

import Combine

public extension AnyPublisher where Failure == ServiceError {
    
    // MARK: - Zip Two Publishers
    static func zip<T, U>(
        _ first: AnyPublisher<T, ServiceError>,
        _ second: AnyPublisher<U, ServiceError>
    ) -> AnyPublisher<(T, U), ServiceError> {
        first.zip(second)
            .eraseToAnyPublisher()
    }

    // MARK: - Combine Latest Two Publishers
    static func combineLatest<T, U>(
        _ first: AnyPublisher<T, ServiceError>,
        _ second: AnyPublisher<U, ServiceError>
    ) -> AnyPublisher<(T, U), ServiceError> {
        first.combineLatest(second)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sequential Requests
    func chain<T>(
        with nextRequest: @escaping (Output) -> AnyPublisher<T, ServiceError>
    ) -> AnyPublisher<T, ServiceError> {
        self.flatMap { response in
            nextRequest(response)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Retry Mechanism
    func retryOnFailure(_ retries: Int) -> AnyPublisher<Output, ServiceError> {
        self.retry(retries)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fallback to Another Publisher if Fails
    func fallback(to fallbackPublisher: AnyPublisher<Output, ServiceError>) -> AnyPublisher<Output, ServiceError> {
        self.catch { _ in fallbackPublisher }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Custom Handling Extensions
    @discardableResult
    func onSuccess(_ action: @escaping (Output) -> Void) -> AnyPublisher<Output, ServiceError> {
        self.handleEvents(receiveOutput: action).eraseToAnyPublisher()
    }

    @discardableResult
    func onError(_ action: @escaping (ServiceError) -> Void) -> AnyPublisher<Output, ServiceError> {
        self.handleEvents(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                action(error)
            }
        }).eraseToAnyPublisher()
    }

    @discardableResult
    func onCancel(_ action: @escaping () -> Void) -> AnyPublisher<Output, ServiceError> {
        self.handleEvents(receiveCancel: action).eraseToAnyPublisher()
    }

    @discardableResult
    func onCompletion(_ action: @escaping () -> Void) -> AnyPublisher<Output, ServiceError> {
        self.handleEvents(receiveCompletion: { _ in action() }, receiveCancel: action).eraseToAnyPublisher()
    }
    
    @discardableResult
    func subscribe(storeIn cancellables: inout Set<AnyCancellable>?) -> AnyPublisher<Output, ServiceError> {
        if cancellables != nil {
            self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &cancellables!)
        }
        return self
    }
}
