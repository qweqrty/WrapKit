//
//  ServiceSpy.swift
//  WrapKitTestUtils
//
//  Created by Urmatbek Marat Uulu on 26/12/25.
//

import WrapKit
import Combine
import Foundation

public final class ServiceSpy<Request, Response>: Service {
    
    private struct PublisherBox {
        let request: Request
        let subject: PassthroughSubject<Response, ServiceError>
    }
    
    private let lock = NSLock()
    private var publishers: [PublisherBox] = []
    
    // MARK: - Observability
    
    public var requests: [Request] {
        synchronized { publishers.map { $0.request } }
    }
    
    public var makeCallCount: Int {
        synchronized { publishers.count }
    }
    
    public init() { }
    
    // MARK: - Service
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let subject = PassthroughSubject<Response, ServiceError>()
        synchronized { publishers.append(.init(request: request, subject: subject)) }
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Test helpers
    
    public func complete(
        with result: Result<Response, ServiceError>,
        at index: Int = 0
    ) {
        let subject = synchronized {
            publishers.indices.contains(index) ? publishers[index].subject : nil
        }
        guard let subject else {
            assertionFailure("❌ No publisher at index \(index)")
            return
        }
        
        switch result {
        case .success(let response):
            subject.send(response)
            subject.send(completion: .finished)
            
        case .failure(let error):
            subject.send(completion: .failure(error))
        }
    }

    private func synchronized<Value>(_ action: () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }
}
