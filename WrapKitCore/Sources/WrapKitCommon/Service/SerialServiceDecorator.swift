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
    private var completionRequestRetainer: SerialServiceDecorator?

    public init(decoratee: any Service<Request, Response>) {
        self.decoratee = decoratee
    }

    // Combine-based method
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        let subject = PassthroughSubject<Response, ServiceError>()
        let publisher = subject
            .handleEvents(
                receiveSubscription: { [self] _ in withExtendedLifetime(self) {} },
                receiveOutput: { [self] _ in withExtendedLifetime(self) {} },
                receiveCompletion: { [self] _ in withExtendedLifetime(self) {} },
                receiveCancel: { [self] in withExtendedLifetime(self) {} }
            )
            .eraseToAnyPublisher()

        queue.async { [self] in
            pendingRequests.enqueue((request: request, subject: subject, completion: nil))
            processNextRequest()
        }

        return publisher
    }

    // Completion-based method
    public func make(request: Request, completion: @escaping (Result<Response, ServiceError>) -> Void) -> (any HTTPClientTask)? {
        queue.async { [self] in
            completionRequestRetainer = self
            pendingRequests.enqueue((request: request, subject: nil, completion: completion))
            processNextRequest()
        }
        
        return nil
    }

    private func processNextRequest() {
        guard !isProcessing, let (request, currentSubject, currentCompletion) = pendingRequests.head else { return }

        isProcessing = true

        currentTask = decoratee.make(request: request)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure(let error):
                    currentSubject?.send(completion: .failure(error))
                    currentCompletion?(.failure(error))
                case .finished:
                    currentSubject?.send(completion: .finished)
                }

                queue.async { [self] in
                    self.pendingRequests.dequeue()
                    self.isProcessing = false
                    self.currentTask = nil
                    if self.pendingRequests.elements.contains(where: { $0.completion != nil }) == false {
                        self.completionRequestRetainer = nil
                    }
                    self.processNextRequest()
                }
            }, receiveValue: { response in
                currentSubject?.send(response)
                currentCompletion?(.success(response))
            })
    }
}
