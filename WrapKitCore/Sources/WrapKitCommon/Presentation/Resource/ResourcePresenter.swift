//
//  ResourcePresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/11/23.
//

import Foundation

public struct Resource<Request, Response> {
    public let storage: any Storage<Response>
    public let service: any WrapKit.Service<Request, Response>
    
    public init(storage: any Storage<Response>, service: any Service<Request, Response>) {
        self.storage = storage
        self.service = service
    }
}
