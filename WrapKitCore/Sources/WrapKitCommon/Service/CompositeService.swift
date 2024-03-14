//
//  CompositeService.swift
//  WrapKit
//
//  Created by Stanislav Li on 10/12/23.
//

import Foundation

public class ThreeCompositeService<S1: Service, S2: Service, S3: Service>: Service {
    public typealias Request = (S1.Request, S2.Request, S3.Request)
    public typealias Response = (S1.Response?, S2.Response?, S3.Response?)

    private let service1: S1
    private let service2: S2
    private let service3: S3

    public init(_ service1: S1, _ service2: S2, _ service3: S3) {
        self.service1 = service1
        self.service2 = service2
        self.service3 = service3
    }

    public func make(request: (S1.Request, S2.Request, S3.Request), completion: @escaping (Result<(S1.Response?, S2.Response?, S3.Response?), ServiceError>) -> Void) -> HTTPClientTask? {
        var response1: S1.Response?
        var response2: S2.Response?
        var response3: S3.Response?

        let group = DispatchGroup()

        group.enter()
        service1.make(request: request.0) { result in
            response1 = try? result.get()
            group.leave()
        }?.resume()

        group.enter()
        service2.make(request: request.1) { result in
            response2 = try? result.get()
            group.leave()
        }?.resume()

        group.enter()
        service3.make(request: request.2) { result in
            response3 = try? result.get()
            group.leave()
        }?.resume()

        group.notify(queue: .main) {
            completion(.success((response1, response2, response3)))
        }

        return nil
    }
}

public class TwoCompositeService<S1: Service, S2: Service>: Service {
    public typealias Request = (S1.Request, S2.Request)
    public typealias Response = (S1.Response, S2.Response)

    private let service1: S1
    private let service2: S2

    public init(_ service1: S1, _ service2: S2) {
        self.service1 = service1
        self.service2 = service2
    }

    public func make(request: (S1.Request, S2.Request), completion: @escaping (Result<(S1.Response, S2.Response), ServiceError>) -> Void) -> HTTPClientTask? {
        var response1: Result<S1.Response, ServiceError>?
        var response2: Result<S2.Response, ServiceError>?

        let group = DispatchGroup()

        group.enter()
        service1.make(request: request.0) { result in
            response1 = result
            group.leave()
        }?.resume()

        group.enter()
        service2.make(request: request.1) { result in
            response2 = result
            group.leave()
        }?.resume()

        group.notify(queue: .main) {
            switch (response1, response2) {
            case let (.success(res1), .success(res2)):
                completion(.success((res1, res2)))
            case let (.failure(error), _),
                 let (_, .failure(error)):
                completion(.failure(error))
            default:
                completion(.failure(.internal))
            }
        }

        return nil // Or return an actual task if your services support cancellation
    }
}
