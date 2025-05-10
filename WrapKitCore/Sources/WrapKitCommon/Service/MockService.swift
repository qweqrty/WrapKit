//
//  MockService.swift
//  WrapKit
//
//  Created by Stas Lee on 14/1/24.
//

import Foundation
import Combine

open class MockService<Request, Response: Decodable>: Service {
    public typealias ResponseHandler = (_ request: Request, _ data: Data, _ response: HTTPURLResponse, _ completion: @escaping (Result<Response, ServiceError>) -> Void) -> Void
    
    public var result: Result<Response, ServiceError>
    private let responseHandler: ResponseHandler?
    
    public init(result: Result<Response, ServiceError>, responseHandler: ResponseHandler? = nil) {
        self.result = result
        self.responseHandler = responseHandler
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        return Future { [result] promise in
            promise(result)
        }
        .eraseToAnyPublisher()
    }
}
