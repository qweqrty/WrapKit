//
//  RemoteService.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Combine
import Foundation

open class RemoteService<Request, Response>: Service {
    public typealias ResponseHandler = (_ request: Request, _ data: Data, _ response: HTTPURLResponse, _ completion: @escaping (Result<Response, ServiceError>) -> Void) -> Void
    
    private let client: HTTPClient
    private let makeURLRequest: (Request) -> URLRequest?
    private let responseHandler: ResponseHandler?
    
    public init(
        client: HTTPClient,
        makeURLRequest: @escaping (Request) -> URLRequest?,
        responseHandler: ResponseHandler?
    ) {
        self.client = client
        self.makeURLRequest = makeURLRequest
        self.responseHandler = responseHandler
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        guard let urlRequest = makeURLRequest(request) else {
            return Fail(error: ServiceError.internal).eraseToAnyPublisher()
        }
        
        var task: HTTPClientTask?
        
        return Deferred {
            Future { [weak self] promise in
                task = self?.client.dispatch(urlRequest) { result in
                    switch result {
                    case .success(let response):
                        self?.responseHandler?(request, response.data, response.response) { handlerResult in
                            promise(handlerResult)
                        }
                    case .failure(let error):
                        if (error as? URLError)?.code == .cancelled {
                            promise(.failure(.cancelled))
                        } else if let error = error as NSError?,
                                  error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                            promise(.failure(.connectivity))
                        } else {
                            promise(.failure(.internal))
                        }
                    }
                }
                task?.resume()
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
    
    public func make(request: Request, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask? {
        guard let urlRequest = makeURLRequest(request) else {
            completion(.failure(.internal))
            return nil
        }
        let task = client.dispatch(urlRequest) { [weak self] result in
            switch result {
            case .success(let response):
                self?.responseHandler?(request, response.data, response.response) { handlerResult in
                    completion(handlerResult)
                }
            case .failure(let error):
                if (error as? URLError)?.code == .cancelled {
                    completion(.failure(.cancelled))
                } else if let error = error as NSError?,
                          error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.connectivity))
                } else {
                    completion(.failure(.internal))
                }
            }
        }
        task.resume()
        return task
    }
}
