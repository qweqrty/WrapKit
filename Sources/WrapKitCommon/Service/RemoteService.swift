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

open class RemoteService<Request, Response: Decodable>: Service {
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
            case let .success(response):
                self?.handle(response: response, completion: completion)
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func handle(response: (Data, HTTPURLResponse), completion: @escaping ((Result<Response, ServiceError>)) -> Void) {
        let (data, httpResponse) = response

        if isResponseOk?(data, httpResponse) ?? true {
            do {
                let model = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(model))
            } catch {
                printDecodingError(error, data: data)
                completion(.failure(.internal))
            }
        } else if let errorModel = try? JSONDecoder().decode(RemoteError.self, from: data) {
            completion(.failure(.message(errorModel.message)))
        } else {
            completion(.failure(.internal))
        }
    }

    private func printDecodingError(_ error: Error, data: Data) {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(let key, let context):
                print("\nType Mismatch for key: \(key), \(context.debugDescription)\n")
            case .valueNotFound(let key, let context):
                print("\nValue not found for key: \(key), \(context.debugDescription)\n")
            case .keyNotFound(let key, let context):
                print("\nKey not found: \(key), \(context.debugDescription)\n")
            case .dataCorrupted(let context):
                print("\nData corrupted: \(context.debugDescription)\n")
            @unknown default:
                print("\nUnknown decoding error: \(decodingError)\n")
            }
        } else {
            print("\nOther error: \(error)\n")
        }
    }
}
