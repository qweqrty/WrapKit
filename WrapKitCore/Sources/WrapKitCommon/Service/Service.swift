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
    case toBeIgnored
    
    public var title: String? {
        switch self {
        case .toBeIgnored:
            return nil
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
    func onSuccess(_ completion: ((Output) -> Void)?) -> AnyPublisher<Output, ServiceError> {
        return handleEvents(receiveOutput: completion).eraseToAnyPublisher()
    }
    
    @discardableResult
    func onError(_ completion: ((ServiceError) -> Void)?) -> AnyPublisher<Output, ServiceError> {
        return handleEvents(receiveCompletion: { receiveCompletion in
            if case .failure(let error) = receiveCompletion {
                completion?(error)
            }
        }).eraseToAnyPublisher()
    }
}
