//
//  RemoteService.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

public struct RemoteError: Codable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

public class RemoteService<Request, Response: Decodable>: Service {
    private let client: HTTPClient
    private let makeURLRequest: ((Request) -> URLRequest?)
    private let isResponseOk: ((Data, HTTPURLResponse) -> Bool)?
    
    public init(
        client: HTTPClient,
        makeURLRequest: @escaping ((Request) -> URLRequest?),
        isResponseOk: ((Data, HTTPURLResponse) -> Bool)? = nil
    ) {
        self.client = client
        self.makeURLRequest = makeURLRequest
        self.isResponseOk = isResponseOk
    }
    
    public func make(request: Request, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask? {
        guard let urlRequest = makeURLRequest(request) else {
            completion(.failure(.internal))
            return nil
        }
        return client.dispatch(urlRequest) { [weak self] result in
            switch result {
            case let .success((data, response)):
                if self?.isResponseOk?(data, response) ?? true, let model = try? JSONDecoder().decode(Response.self, from: data){
                    completion(.success(model))
                } else if let errorModel = try? JSONDecoder().decode(RemoteError.self, from: data) {
                    completion(.failure(.message(errorModel.message)))
                } else {
                    completion(.failure(.internal))
                }
            case .failure(let error):
                if let _ = error as? AuthenticatedHTTPClientDecorator.NotAuthenticated {
                    completion(.failure(.notAuthorized))
                } else {
                    completion(.failure(ServiceError.connectivity))
                }
            }
        }
    }
}
