//
//  StoredServiceDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 1/10/23.
//

import Foundation

public class StoredServiceDecorator<Request, Response>: Service {
    private let decoratee: any Service<Request, Response>
    private let storage: any Storage<Response>
    
    public init(decoratee: any Service<Request, Response>, storage: any Storage<Response>) {
        self.decoratee = decoratee
        self.storage = storage
    }
    
    public func make(request: Request, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask? {
        decoratee.make(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.storage.set(model: response, completion: nil)
            default: break
            }
            completion(result)
        }
    }
}
