//
//  ServiceSpy.swift
//  WrapKitTestUtils
//
//  Created by Urmatbek Marat Uulu on 26/12/25.
//

import WrapKit
import Combine

public final class ServiceSpy<Request, Response>: Service {
    
    private struct PublisherBox {
        let request: Request
        let subject: PassthroughSubject<Response, ServiceError>
    }
    
    private var publishers: [PublisherBox] = []
    
    // MARK: - Observability
    
    public var requests: [Request] {
        publishers.map { $0.request }
    }
    
    public var makeCallCount: Int {
        publishers.count
    }
    
    public init() { }
    
    // MARK: - Service
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let subject = PassthroughSubject<Response, ServiceError>()
        publishers.append(.init(request: request, subject: subject))
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Test helpers
    
    public func complete(
        with result: Result<Response, ServiceError>,
        at index: Int = 0
    ) {
        guard publishers.indices.contains(index) else {
            assertionFailure("❌ No publisher at index \(index)")
            return
        }
        
        let subject = publishers[index].subject
        
        switch result {
        case .success(let response):
            subject.send(response)
            subject.send(completion: .finished)
            
        case .failure(let error):
            subject.send(completion: .failure(error))
        }
    }
}
