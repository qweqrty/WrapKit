//
//  SerialServiceDecorator.swift
//  WrapKit
//
//  Created by Stas Lee on 31/7/23.
//

import Foundation

public class SerialServiceDecorator<Request, Response: Decodable>: Service {
    typealias PendingCompletion = (
        id: String,
        result: Result<Response, ServiceError>?,
        completion: ((Result<Response, ServiceError>) -> Void)
    )
    private let decoratee: any Service<Request, Response>
    private var pendingCompletions = Queue<PendingCompletion>()
    
    public init(decoratee: any Service<Request, Response>) {
        self.decoratee = decoratee
    }
    
    public func make(request: Request, completion: @escaping (Result<Response, ServiceError>) -> Void) -> HTTPClientTask? {
        let completionId = UUID().uuidString
        
        pendingCompletions.enqueue((completionId, nil, completion))
        
        let task = decoratee.make(request: request) { [completionId, weak self] response in
            if (completionId == self?.pendingCompletions.head?.id) {
                self?.pendingCompletions.dequeue()?.completion(response)
                while (self?.pendingCompletions.head?.result != nil) {
                    if let result = self?.pendingCompletions.head?.result {
                        self?.pendingCompletions.dequeue()?.completion(result)
                    }
                }
            } else if let index = self?.pendingCompletions.elements.firstIndex(where: { $0.id == completionId }) {
                self?.pendingCompletions.elements[index].result = response
            } else {
                fatalError()
            }
        }
        
        return task
    }
}
