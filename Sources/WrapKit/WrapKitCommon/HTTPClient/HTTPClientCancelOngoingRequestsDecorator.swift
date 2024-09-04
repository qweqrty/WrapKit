import Combine
import Foundation

public final class HTTPClientCancelOngoingRequestsDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let shouldCancelRequestsOn: ((HTTPClient.Result) -> Bool)
    private var cancellables = Set<AnyCancellable>()
    private let cancelOngoingRequestsSubject = PassthroughSubject<Void, Never>()

    public init(
        decoratee: HTTPClient,
        shouldCancelRequestsOn: @escaping ((HTTPClient.Result) -> Bool)
    ) {
        self.decoratee = decoratee
        self.shouldCancelRequestsOn = shouldCancelRequestsOn
    }

    @discardableResult
    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = decoratee.dispatch(request) { [weak self] result in
            if self?.shouldCancelRequestsOn(result) ?? true {
                self?.cancelOngoingRequests()
            }
            completion(result)
        }
        
        cancelOngoingRequestsSubject
            .sink { _ in
                task.cancel()
            }
            .store(in: &cancellables)
        
        return task
    }

    private func cancelOngoingRequests() {
        cancelOngoingRequestsSubject.send(())
    }
}
