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
    case toBeIgnored
    
    public var title: String? {
        switch self {
        case .toBeIgnored:
            return nil
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
