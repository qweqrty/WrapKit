//
//  RemoteService.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation
        
open class RemoteService<Request, Response: Decodable>: Service {
    public typealias ResponseHandler = ((_ data: Data, _ response: HTTPURLResponse, _ completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> Void)
     
    private let client: HTTPClient
    private let makeURLRequest: ((Request) -> URLRequest?)
    private let responseHandler: ResponseHandler?
    
    public init(
        client: HTTPClient,
        makeURLRequest: @escaping ((Request) -> URLRequest?),
        responseHandler: ResponseHandler?
    ) {
        self.client = client
        self.makeURLRequest = makeURLRequest
        self.responseHandler = responseHandler
    }
    
    public func make(request: Request, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask? {
        guard let urlRequest = makeURLRequest(request) else {
            completion(.failure(.internal))
            return nil
        }
        return client.dispatch(urlRequest) { [weak self] result in
            switch result {
            case let .success(response):
                self?.responseHandler?(response.data, response.response, completion)
            case .failure(let error):
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.connectivity))
                    } else {
                        completion(.failure(.internal))
                    }
                    return
                }
                
            }
        }
    }
}
