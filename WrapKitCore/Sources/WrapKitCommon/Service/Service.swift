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
    
        /// Handles various events of the publisher.
        ///
        /// - Parameters:
        ///   - onSuccess: Closure called upon successful emission of an output.
        ///   - onError: Closure called upon failure with an error.
        ///   - onCancel: Closure called when the publisher is cancelled.
        ///   - onCompletion: Closure called upon completion, regardless of success or failure.
        /// - Returns: A publisher with the specified event handlers attached.
        @discardableResult
        func handle(
            onSuccess: ((Output) -> Void)? = nil,
            onError: ((Failure) -> Void)? = nil,
            onCancel: (() -> Void)? = nil,
            onCompletion: (() -> Void)? = nil
        ) -> AnyPublisher<Output, Failure> {
            self.handleEvents(
                receiveOutput: { output in
                    onSuccess?(output)
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        onError?(error)
                    }
                    onCompletion?()
                },
                receiveCancel: {
                    onCancel?()
                    onCompletion?()
                }
            )
            .eraseToAnyPublisher()
        }

    
    @discardableResult
    func subscribe(storeIn cancellables: inout Set<AnyCancellable>) -> AnyPublisher<Output, Failure> {
        self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        return self
    }
}
