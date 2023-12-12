//
//  URLRequest+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/12/23.
//

import Foundation

public extension URLRequest {
    init(url: URL, method: String) throws {
        self.init(url: url)
        self.httpMethod = method
    }
    
    func appendedQueryItem(key: String, value: String?) -> URLRequest {
        guard let url = self.url else { return self }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        let queryItem = URLQueryItem(name: key, value: value)
        
        if urlComponents?.queryItems != nil {
            urlComponents?.queryItems?.append(queryItem)
        } else {
            urlComponents?.queryItems = [queryItem]
        }
        
        var newRequest = self
        newRequest.url = urlComponents?.url
        return newRequest
    }

}

public extension String {
    var asUrl: URL? { URL(string: self) }
    
    func toDate(dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
}
