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
        public struct Response: HashableWithReflection {
            public let data: Data?
            public let response: HTTPURLResponse?
            public let error: Error?
            
            public init(data: Data?, response: HTTPURLResponse?, error: Error?) {
                self.data = data
                self.response = response
                self.error = error
            }
        }
        public let uuid: UUID
        public let date = Date()
        public let request: URLRequest
        public let response = InMemoryStorage<Response>(model: nil)
        
        public init(uuid: UUID = UUID(), request: URLRequest, response: Response?) {
            self.uuid = uuid
            self.request = request
            self.response.set(model: response)
        }
    }
    
    private let decoratee: HTTPClient
    public static var requests = InMemoryStorage<[Log]>(model: nil)
    
    public init(decoratee: HTTPClient) {
        self.decoratee = decoratee
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> any HTTPClientTask {
        let log = Log(request: request, response: nil)
        if !Bundle.isAppStoreBuild {
            var requests = Self.requests.get() ?? []
            requests.append(log)
            Self.requests.set(model: requests)
            print(request.cURL())
        }
        return decoratee.dispatch(request) { result in
            switch result {
            case .success((let data, let response)):
                if !Bundle.isAppStoreBuild {
                    Self.message(from: response, data: data) { message in
                        print(message)
                    }
                    log.response.set(model: .init(data: data, response: response, error: nil))
                }
                completion(.success((data, response)))
            case .failure(let error):
                if !Bundle.isAppStoreBuild {
                    Self.message(error: error) { message in
                        print(message)
                    }
                    log.response.set(model: .init(data: nil, response: nil, error: error))
                }
                completion(.failure(error))
            }
        }
    }
    
    public static func message(from response: HTTPURLResponse? = nil, data: Data? = nil, error: Error? = nil, request: URLRequest? = nil, completion: ((String) -> Void)?) {
        if (error as? URLError)?.code == .cancelled, let request = request {
            completion?(printCancelled(request))
            return
        }
        let urlString = response?.url?.absoluteString ?? "N/A"
        let statusCode = (response)?.statusCode.description ?? "N/A"
        let headers = (response)?.allHeaderFields as? [String: Any] ?? [:]
        var responseLog = "📥 Incoming Response: \(urlString)"
        responseLog += "\nStatus Code: \(statusCode)"
        responseLog += "\nHeaders: \(headers)"
        if let error = error {
            responseLog += "\nError: \(error.localizedDescription)"
        }
        if let data {
            data.prettyPrintedJSONString(completion: { string in
                var responseLog = "📥 Incoming Response: \(urlString)"
                responseLog += "\nStatus Code: \(statusCode)"
                responseLog += "\nHeaders: \(headers)"
                responseLog += "\nBody: \(string)"
                completion?(responseLog)
            })
        } else {
            completion?(responseLog)
        }
    }
    
    static func printCancelled(_ request: URLRequest) -> String {
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

public extension URLRequest {
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

public extension Data {
    func prettyPrintedJSONString(maxDisplayLength: Int = 1000, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var result: String
            
            if let object = try? JSONSerialization.jsonObject(with: self, options: []),
               let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
               let prettyString = String(data: data, encoding: .utf8) {
                result = prettyString
            } else {
                result = String(data: self, encoding: .utf8) ?? ""
            }
            
            let displayString = result.prefix(maxDisplayLength) + (result.count > maxDisplayLength ? "..." : "")
            
            DispatchQueue.main.async {
                completion(String(displayString))
            }
        }
    }
}
