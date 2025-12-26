//
//  ServiceSpy.swift
//  WrapKitTestUtils
//
//  Created by Urmatbek Marat Uulu on 26/12/25.
//

import WrapKit
import Combine

public class ServiceSpy<Request: Equatable, Response>: Service {
    private var publishers: [(request: Request, publisher: PassthroughSubject<Response, ServiceError>)] = []
    
    public var requests: [Request] {
        publishers.map { $0.request }
    }
    
    public init() { }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let publisher = PassthroughSubject<Response, ServiceError>()
        publishers.append((request, publisher))
        return publisher.eraseToAnyPublisher()
    }
    
    public func complete(with result: Result<Response, ServiceError>, at index: Int) {
        guard index < publishers.count else { return }
        
        switch result {
        case .success(let response):
            publishers[index].publisher.send(response)
            publishers[index].publisher.send(completion: .finished)
        case .failure(let error):
            publishers[index].publisher.send(completion: .failure(error))
        }
    }
}
