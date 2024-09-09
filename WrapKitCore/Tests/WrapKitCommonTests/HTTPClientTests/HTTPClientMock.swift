import WrapKit
import Foundation

class HTTPClientTaskMock: HTTPClientTask {
    private(set) var isCancelled = false
    func resume() {}
    func cancel() {
        isCancelled = true
    }
}

enum HTTPClientError: Error {
    case connectivity
    case invalidResponse
}
