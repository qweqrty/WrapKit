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

// MARK: - Service abstraction helper
public extension AnyPublisher {
    // MARK: - Zip Two Publishers
    static func zip<T, U>(
        _ first: AnyPublisher<T, Failure>,
        _ second: AnyPublisher<U, Failure>
    ) -> AnyPublisher<(T, U), Failure> {
        first.zip(second)
            .eraseToAnyPublisher()
    }

    // MARK: - Combine Latest Two Publishers
    static func combineLatest<T, U>(
        _ first: AnyPublisher<T, Failure>,
        _ second: AnyPublisher<U, Failure>
    ) -> AnyPublisher<(T, U), Failure> {
        first.combineLatest(second)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sequential Requests
    func chain<T>(
        with nextRequest: @escaping (Output) -> AnyPublisher<T, Failure>
    ) -> AnyPublisher<T, Failure> {
        self.flatMap { response in
            nextRequest(response)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Retry Mechanism
    func retryOnFailure(_ retries: Int) -> AnyPublisher<Output, Failure> {
        self.retry(retries)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fallback to Another Publisher if Fails
    func fallback(to fallbackPublisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Custom Handling Extensions with Optional Actions
    @discardableResult
    func onSuccess(_ action: ((Output) -> Void)?) -> AnyPublisher<Output, Failure> {
        if let action = action {
            return self.handleEvents(receiveOutput: action).eraseToAnyPublisher()
        } else {
            return self.eraseToAnyPublisher()
        }
    }

    @discardableResult
    func onError(_ action: ((Failure) -> Void)?) -> AnyPublisher<Output, Failure> {
        if let action = action {
            return self.handleEvents(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    action(error)
                }
            }).eraseToAnyPublisher()
        } else {
            return self.eraseToAnyPublisher()
        }
    }

    @discardableResult
    func onCancel(_ action: (() -> Void)?) -> AnyPublisher<Output, Failure> {
        if let action = action {
            return self.handleEvents(receiveCancel: action).eraseToAnyPublisher()
        } else {
            return self.eraseToAnyPublisher()
        }
    }

    @discardableResult
    func onCompletion(_ action: (() -> Void)?) -> AnyPublisher<Output, Failure> {
        if let action = action {
            return self.handleEvents(receiveCompletion: { _ in action() }, receiveCancel: action).eraseToAnyPublisher()
        } else {
            return self.eraseToAnyPublisher()
        }
    }
    
    @discardableResult
    func subscribe(storeIn cancellables: inout Set<AnyCancellable>) -> AnyPublisher<Output, Failure> {
        self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        return self
    }
}
