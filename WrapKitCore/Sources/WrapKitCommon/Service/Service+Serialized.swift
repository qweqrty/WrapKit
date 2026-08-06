import Foundation

public extension Service {
    /// Creates an independent wrapper that serializes its own requests.
    /// Store and reuse the returned service when several requests must share
    /// the same serial queue.
    var serialized: any Service<Request, Response> {
        SerialServiceDecorator(decoratee: self)
    }
}
