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
    private var pendingRequests = Queue<(request: Request, subject: PassthroughSubject<Response, ServiceError>?, completion: ((Result<Response, ServiceError>) -> Void)?)>()
    private var currentTask: AnyCancellable?
    private var isProcessing = false
    private let queue = DispatchQueue(label: "SerialServiceDecoratorQueue")

    public init(decoratee: any Service<Request, Response>) {
        self.decoratee = decoratee
    }

    // Combine-based method
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let subject = PassthroughSubject<Response, ServiceError>()

        queue.async { [weak self] in
            self?.pendingRequests.enqueue((request: request, subject: subject, completion: nil))
            self?.processNextRequest()
        }

        return subject.eraseToAnyPublisher()
    }

    // Completion-based method
    public func make(request: Request, completion: @escaping (Result<Response, ServiceError>) -> Void) -> (any HTTPClientTask)? {
        queue.async { [weak self] in
            self?.pendingRequests.enqueue((request: request, subject: nil, completion: completion))
            self?.processNextRequest()
        }
        
        return nil
    }

    private func processNextRequest() {
        guard !isProcessing, let (request, currentSubject, currentCompletion) = pendingRequests.head else { return }

        isProcessing = true

        currentTask = decoratee.make(request: request)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    currentSubject?.send(completion: .failure(error))
                    currentCompletion?(.failure(error))
                case .finished:
                    currentSubject?.send(completion: .finished)
                }

                self?.queue.async {
                    self?.pendingRequests.dequeue()
                    self?.isProcessing = false
                    self?.processNextRequest()
                }
            }, receiveValue: { response in
                currentSubject?.send(response)
                currentCompletion?(.success(response))
            })
    }
}
