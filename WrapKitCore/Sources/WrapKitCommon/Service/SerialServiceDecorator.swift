//
//  SerialServiceDecorator.swift
//  WrapKit
//
//  Created by Stas Lee on 31/7/23.
//

import Foundation
import Combine

// SerialServiceDecorator ensures requests are processed sequentially
public class SerialServiceDecorator<Request, Response>: Service {
    private let decoratee: any Service<Request, Response>
    private var pendingRequests = Queue<(request: Request, subject: PassthroughSubject<Response, ServiceError>)>()
    private var currentTask: AnyCancellable?
    
    public init(decoratee: any Service<Request, Response>) {
        self.decoratee = decoratee
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        // Create a subject for the request and enqueue it
        let subject = PassthroughSubject<Response, ServiceError>()
        pendingRequests.enqueue((request: request, subject: subject))
        
        // Start processing if it's the only request in the queue
        if pendingRequests.elements.count == 1 {
            processNextRequest()
        }
        
        // Return the subject as a publisher
        return subject.eraseToAnyPublisher()
    }
    
    private func processNextRequest() {
        // Ensure there's a request to process
        guard let (request, currentSubject) = pendingRequests.head else { return }
        
        // Make the request on the decoratee
        currentTask = decoratee.make(request: request)
            .handle(
                onSuccess: { [weak self] response in
                    self?.pendingRequests.dequeue()
                    
                    // Process the next request in the queue, if available
                    if !(self?.pendingRequests.elements.isEmpty == true) {
                        self?.processNextRequest()
                    }
                },
                onError: { error in
                    currentSubject.send(completion: .failure(error))
                },
                onCompletion: { [weak self] in
                    currentSubject.send(completion: .finished)
                    self?.pendingRequests.dequeue()
                    
                    // Process the next request in the queue, if available
                    if !(self?.pendingRequests.elements.isEmpty == true) {
                        self?.processNextRequest()
                    }
                }
            )
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
