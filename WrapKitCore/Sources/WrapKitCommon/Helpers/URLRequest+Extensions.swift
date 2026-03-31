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
    var asUrl: URL? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        // Reject obvious malformed cases with quotes that should be escaped.
        guard !trimmed.contains("'"), !trimmed.contains("\"") else { return nil }
        
        let sanitized = trimmed
            .replacingOccurrences(of: "\\", with: "/")
            .normalizedHttpSlashes()
            .collapsedPathSlashes()
        let sanitizedQuotes = sanitized.replacingOccurrences(of: "\"", with: "%22")
        
        if sanitized.hasPrefix("http:/") && !sanitized.hasPrefix("http://") { return nil }
        if sanitized.hasPrefix("https:/") && !sanitized.hasPrefix("https://") { return nil }
        
        if let url = URL(string: sanitizedQuotes),
           url.scheme != nil,
           isValid(url: url) {
            return url
        } else {
            if let urlEscapedString = sanitized.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let escapedURL = URL(string: urlEscapedString),
               escapedURL.scheme != nil,
               isValid(url: escapedURL) {
                return escapedURL
            }
        }
        return nil
    }
    
    func toDate(dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
    
    private func isValid(url: URL) -> Bool {
        if let scheme = url.scheme?.lowercased(), (scheme == "http" || scheme == "https") {
            return url.host != nil
        } else {
            return true
        }
    }
    
    private func normalizedHttpSlashes() -> String {
        guard let colonIndex = firstIndex(of: ":") else { return self }
        let scheme = self[..<colonIndex]
        let lowerScheme = scheme.lowercased()
        guard lowerScheme == "http" || lowerScheme == "https" else { return self }
        
        let afterColon = self[index(after: colonIndex)...]
        let slashCount = afterColon.prefix { $0 == "/" }.count
        guard slashCount >= 2 else { return self }
        
        let trimmedSlashes = afterColon.drop(while: { $0 == "/" })
        return scheme + ":" + "//" + trimmedSlashes
    }
    
    private func collapsedPathSlashes() -> String {
        guard let schemeRange = range(of: "://") else { return self }
        let hostAndRest = self[schemeRange.upperBound...]
        guard let firstSlash = hostAndRest.firstIndex(of: "/") else { return self } // no path
        
        let hostPart = self[..<firstSlash]
        let pathPart = self[firstSlash...]
        let collapsedPath = pathPart.replacingOccurrences(of: "/+", with: "/", options: .regularExpression)
        return hostPart + collapsedPath
    }
}
