//
//  URLSessionHTTPClient.swift
//  WrapKitNetworking
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    public typealias Result = HTTPClient.Result
    public struct UnexpectedValuesRepresentation: Error {}

    private let session: URLSession
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func resume() {
            wrapped.resume()
        }
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        var output = """
        \(urlAsString) \n\n
        \(method) \(path)?\(query) HTTP/1.1 \n
        HOST: \(host)\n
        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
           output += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
           output += "\n \(String(data: body, encoding: .utf8) ?? "")"
        }
        print(output)
        let task = session.dataTask(with: request) { data, response, error in
            print("\n - - - - - - - - - - INCOMMING - - - - - - - - - - \n")
            defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
            let urlString = response?.url?.absoluteString
            let components = NSURLComponents(string: urlString ?? "")
            let path = "\(components?.path ?? "")"
            let query = "\(components?.query ?? "")"
            var output = ""
            if let urlString = urlString {
               output += "\(urlString)"
               output += "\n\n"
            }
            if let statusCode =  (response as? HTTPURLResponse)?.statusCode {
               output += "HTTP \(statusCode) \(path)?\(query)\n"
            }
            if let host = components?.host {
               output += "Host: \(host)\n"
            }
            for (key, value) in (response as? HTTPURLResponse)?.allHeaderFields ?? [:] {
               output += "\(key): \(value)\n"
            }
            if let body = data {
               output += "\n\(String(data: body, encoding: .utf8) ?? "")\n"
            }
            if error != nil {
               output += "\nError: \(error!.localizedDescription)\n"
            }
            print(output)
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        
        return URLSessionTaskWrapper(wrapped: task)
    }
}

