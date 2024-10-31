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
    private var isProcessing = false
    private let queue = DispatchQueue(label: "SerialServiceDecoratorQueue")
    
    public init(decoratee: any Service<Request, Response>) {
        self.decoratee = decoratee
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let subject = PassthroughSubject<Response, ServiceError>()
        
        queue.async { [weak self] in
            self?.pendingRequests.enqueue((request: request, subject: subject))
            self?.processNextRequest()
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    private func processNextRequest() {
        guard !isProcessing, let (request, currentSubject) = pendingRequests.head else { return }
        
        isProcessing = true
        
        currentTask = decoratee.make(request: request)
            .handle(
                onSuccess: { response in
                    currentSubject.send(response)
                },
                onError: { error in
                    currentSubject.send(completion: .failure(error))
                },
                onCompletion: { [weak self] in
                    currentSubject.send(completion: .finished)
                    self?.queue.async {
                        self?.pendingRequests.dequeue()
                        self?.isProcessing = false
                        self?.processNextRequest()
                    }
                }
            )
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
