//
//  StoredService.swift
//  WrapKit
//
//  Created by Stanislav Li on 7/4/25.
//

import Combine
import Foundation

public extension Service {
    func composed(primeStorage: any Storage<Response>) -> any Service<Request, Response> {
        return StorageServiceComposition(primary: primeStorage, secondary: self)
    }
    
    func composed(secondaryStorage: any Storage<Response>) -> any Service<Request, Response> {
        return ServiceStorageComposition(primary: self, secondary: secondaryStorage)
    }
}

private class StorageServiceComposition<Request, Response>: Service {
    private let primary: any Storage<Response>
    private let secondary: any Service<Request, Response>
    
    public init(primary: any Storage<Response>, secondary: any Service<Request, Response>) {
        self.primary = primary
        self.secondary = secondary
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let value = primary.get()
        if let value {
            return Just(value)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        } else {
            return secondary.make(request: request)
                .handle(
                    onSuccess: { [weak self] response in
                        self?.primary.set(model: response)
                    }
                )
        }
    }
}

private class ServiceStorageComposition<Request, Response>: Service {
    private let primary: any Service<Request, Response>
    private let secondary: any Storage<Response>
    
    public init(primary: any Service<Request, Response>, secondary: any Storage<Response>) {
        self.primary = primary
        self.secondary = secondary
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        return primary.make(request: request)
            .handle(
                onSuccess: { [weak self] response in
                    self?.secondary.set(model: response)
                }
            )
            .catch { [weak self] error -> AnyPublisher<Response, ServiceError> in
                if let cached = self?.secondary.get() {
                    return Just(cached)
                        .setFailureType(to: ServiceError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
