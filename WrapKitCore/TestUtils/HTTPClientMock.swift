import WrapKit
import Foundation

public class HTTPClientTaskMock: HTTPClientTask {
    public private(set) var isCancelled = false
    public func resume() {}
    public func cancel() {
        isCancelled = true
    }
}

public enum HTTPClientError: Error {
    case connectivity
    case invalidResponse
}
