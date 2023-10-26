//
//  Service.swift
//  WrapKit
//
//  Created by Stas Lee on 31/7/23.
//

import Foundation

public protocol Service<Request, Response> {
    associatedtype Request
    associatedtype Response
    func make(request: Request, completion: @escaping ((Result<Response, ServiceError>)) -> Void) -> HTTPClientTask?
}

public enum ServiceError: Error {
    case message(String)
    case `internal`
    case connectivity
    case notAuthorized
    
    public var title: String {
        switch self {
        case .message(let title):
            return title
        case .internal:
            return "Something went wrong"
        case .connectivity:
            return "No internet connection"
        case .notAuthorized:
            return "Not authorized"
        }
    }
}

extension ServiceError: Equatable {
    public static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.message(let lhsMessage), .message(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.internal, .internal):
            return true
        case (.connectivity, .connectivity):
            return true
        case (.notAuthorized, .notAuthorized):
            return true
        default:
            return false
        }
    }
}
