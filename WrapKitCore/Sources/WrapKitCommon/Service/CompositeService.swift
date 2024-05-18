//
//  CompositeService.swift
//  WrapKit
//
//  Created by Stanislav Li on 10/12/23.
//

import Foundation

public class ThreeCompositeService<S1: Service, S2: Service, S3: Service>: Service {
    public typealias Request = (S1.Request, S2.Request, S3.Request)
    public typealias Response = (S1.Response, S2.Response, S3.Response)

    private let service1: S1
    private let service2: S2
    private let service3: S3

    public init(_ service1: S1, _ service2: S2, _ service3: S3) {
        self.service1 = service1
        self.service2 = service2
        self.service3 = service3
    }

    public func make(request: (S1.Request, S2.Request, S3.Request), completion: @escaping (Result<(S1.Response, S2.Response, S3.Response), ServiceError>) -> Void) -> HTTPClientTask? {
        var response1: Result<S1.Response, ServiceError>?
        var response2: Result<S2.Response, ServiceError>?
        var response3: Result<S3.Response, ServiceError>?

        let group = DispatchGroup()

        var tasks: [HTTPClientTask] = []

        group.enter()
        if let task1 = service1.make(request: request.0, completion: { result in
            response1 = result
            group.leave()
        }) {
            tasks.append(task1)
        } else {
            group.leave()
        }

        group.enter()
        if let task2 = service2.make(request: request.1, completion: { result in
            response2 = result
            group.leave()
        }) {
            tasks.append(task2)
        } else {
            group.leave()
        }

        group.enter()
        if let task3 = service3.make(request: request.2, completion: { result in
            response3 = result
            group.leave()
        }) {
            tasks.append(task3)
        } else {
            group.leave()
        }

        group.notify(queue: .main) {
            switch (response1, response2, response3) {
            case let (.success(res1), .success(res2), .success(res3)):
                completion(.success((res1, res2, res3)))
            case let (.failure(error), _, _):
                completion(.failure(error))
            case let (_, .failure(error), _):
                completion(.failure(error))
            case let (_, _, .failure(error)):
                completion(.failure(error))
            default:
                completion(.failure(.internal))
            }
        }

        return CompositeHTTPClientTask(tasks: tasks)
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
        let compositeTask = CompositeHTTPClientTask()

        group.enter()
        if let task1 = service1.make(request: request.0, completion: { result in
            response1 = result
            group.leave()
        }) {
            compositeTask.add(task1)
        } else {
            group.leave()
        }

        group.enter()
        if let task2 = service2.make(request: request.1, completion: { result in
            response2 = result
            group.leave()
        }) {
            compositeTask.add(task2)
        } else {
            group.leave()
        }

        group.notify(queue: .main) {
            switch (response1, response2) {
            case let (.success(res1), .success(res2)):
                completion(.success((res1, res2)))
            case let (.failure(error), _):
                completion(.failure(error))
            case let (_, .failure(error)):
                completion(.failure(error))
            default:
                completion(.failure(.internal))
            }
        }

        compositeTask.resume()
        return compositeTask
    }
}
