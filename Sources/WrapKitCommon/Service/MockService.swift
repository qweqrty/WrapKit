//
//  MockService.swift
//  WrapKit
//
//  Created by Stas Lee on 14/1/24.
//

import Foundation
        
open class MockService<Request, Response: Decodable>: Service {
    public typealias ResponseHandler = ((_ request: Request, _ data: Data, _ response: HTTPURLResponse, _ completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> Void)
     
    public var result: Result<Response, ServiceError>
    private let responseHandler: ResponseHandler?
    
    public init(result: Result<Response, ServiceError>, responseHandler: ResponseHandler?) {
        self.result = result
        self.responseHandler = responseHandler
    }
    
    public func make(request: Request, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask? {
        completion(result)
        return nil
    }
}
