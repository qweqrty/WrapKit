import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    public typealias Result = HTTPClient.Result
    public struct UnexpectedValuesRepresentation: Error {}

    private let session: URLSession
    static let maxCharactersToPrintForCancelled: Int = 40  // Only for cancelled requests
    
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
        printRequest(request)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.printResponse(response, data: data, error: error)

            completion(Result {
                if let error = error {
                    if (error as? URLError)?.code == .cancelled {
                        self?.printCancelled(request)
                    }
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
    
    private func printCancelled(_ request: URLRequest) {
        let urlString = request.url?.absoluteString.truncatedForCancelled() ?? "N/A"
        let method = request.httpMethod ?? "N/A"
        let headers = request.allHTTPHeaderFields?.mapValues { $0.truncatedForCancelled() } ?? [:]
        let body = String(data: request.httpBody ?? Data(), encoding: .utf8)?.truncatedForCancelled() ?? "N/A"

        var requestLog = "📤 Cancelled Request: \(urlString)"
        requestLog += "\nMethod: \(method)"
        requestLog += "\nHeaders: \(headers)"
        requestLog += "\nBody: \(body)"
        print(requestLog)
    }

    private func printRequest(_ request: URLRequest) {
        let urlString = request.url?.absoluteString ?? "N/A"
        let method = request.httpMethod ?? "N/A"
        let headers = request.allHTTPHeaderFields ?? [:]
        let body = request.httpBody?.prettyPrintedJSONString ?? "N/A"

        print(request.cURL(pretty: true))
    }

    private func printResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        let urlString = response?.url?.absoluteString ?? "N/A"
        let statusCode = (response as? HTTPURLResponse)?.statusCode.description ?? "N/A"
        let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any] ?? [:]
        let body = data?.prettyPrintedJSONString ?? "N/A"
        
        var responseLog = "📥 Incoming Response: \(urlString)"
        responseLog += "\nStatus Code: \(statusCode)"
        responseLog += "\nHeaders: \(headers)"
        responseLog += "\nBody: \(body)"
        if let error = error {
            responseLog += "\nError: \(error.localizedDescription)"
        }
        print(responseLog)
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
