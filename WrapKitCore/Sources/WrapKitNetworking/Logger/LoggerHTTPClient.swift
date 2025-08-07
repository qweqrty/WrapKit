//
//  LoggerHTTPClient.swift
//  WrapKit
//
//  Created by Stanislav Li on 7/8/25.
//

import Foundation

public extension HTTPClient {
    var logged: HTTPClient {
        LoggerHTTPClient(decoratee: self)
    }
}

public final class LoggerHTTPClient: HTTPClient {
    public typealias Result = HTTPClient.Result
    
    public struct Log: HashableWithReflection {
        public let request: URLRequest
        public let response: String
        
        public init(request: URLRequest, response: String) {
            self.request = request
            self.response = response
        }
    }
    
    private let decoratee: HTTPClient
    public static var requests = InMemoryStorage<[Log]>(model: nil)
    
    public init(decoratee: HTTPClient) {
        self.decoratee = decoratee
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> any HTTPClientTask {
        return decoratee.dispatch(request) { [weak self] result in
            var requests = Self.requests.get()
            switch result {
            case .success((let data, let response)):
                requests?.append(.init(
                    request: request,
                    response: self?.message(from: response, data: data) ?? "Something went wrong"
                ))
            case .failure(let error):
                requests?.append(.init(
                    request: request,
                    response: self?.message(error: error) ?? "Something went wrong"
                ))
            }
            Self.requests.set(model: requests)
        }
    }
    
    private func printRequest(_ request: URLRequest) {
        print(request.cURL())
    }
    
    private func message(from response: HTTPURLResponse? = nil, data: Data? = nil, error: Error? = nil, request: URLRequest? = nil) -> String {
        if (error as? URLError)?.code == .cancelled, let request = request {
            return printCancelled(request)
        }
        let urlString = response?.url?.absoluteString ?? "N/A"
        let statusCode = (response)?.statusCode.description ?? "N/A"
        let headers = (response)?.allHeaderFields as? [String: Any] ?? [:]
        let body = data?.prettyPrintedJSONString ?? "N/A"
        
        var responseLog = "📥 Incoming Response: \(urlString)"
        responseLog += "\nStatus Code: \(statusCode)"
        responseLog += "\nHeaders: \(headers)"
        responseLog += "\nBody: \(body)"
        if let error = error {
            responseLog += "\nError: \(error.localizedDescription)"
        }
        return responseLog
    }
    
    private func printCancelled(_ request: URLRequest) -> String {
        let urlString = request.url?.absoluteString.truncatedForCancelled() ?? "N/A"
        let method = request.httpMethod ?? "N/A"
        let headers = request.allHTTPHeaderFields?.mapValues { $0.truncatedForCancelled() } ?? [:]
        let body = String(data: request.httpBody ?? Data(), encoding: .utf8)?.truncatedForCancelled() ?? "N/A"

        var requestLog = "📤 Cancelled Request: \(urlString)"
        requestLog += "\nMethod: \(method)"
        requestLog += "\nHeaders: \(headers)"
        requestLog += "\nBody: \(body)"
        return requestLog
    }
}

fileprivate extension URLRequest {
    func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key, value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8), !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return "📤: " + cURL
    }
}

// Truncate extension only for cancelled requests
fileprivate extension String {
    func truncatedForCancelled() -> String {
        let maxCharacters = URLSessionHTTPClient.maxCharactersToPrintForCancelled
        return count > maxCharacters ? prefix(maxCharacters) + "..." : self
    }
}

// Pretty print JSON
fileprivate extension Data {
    var prettyPrintedJSONString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyString = String(data: data, encoding: .utf8) else {
            return String(data: self, encoding: .utf8) ?? "N/A"
        }
        return prettyString
    }
}
