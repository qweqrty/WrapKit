import Foundation

public extension Service {
    var serialized: any Service<Request, Response> {
        SerialServiceDecorator(decoratee: self)
    }
}
