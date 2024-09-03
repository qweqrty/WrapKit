//
//  RemoteServiceTests.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import XCTest
import WrapKit

class RemoteServiceTests: XCTestCase {
    func test_makeRequest_dispatchesURLRequest() {
        let url = URL(string: "https://example.com")!
        let expectedRequest = URLRequest(url: url)
        let (sut, clientSpy) = makeSUT { _ in expectedRequest }
        
        _ = sut.make(request: "dummy request") { _ in }
        
        XCTAssertEqual(clientSpy.requestedURLs, [url])
    }
    
    func test_makeRequest_completesWithErrorWhenURLRequestIsNil() {
        let (sut, _) = makeSUT { _ in nil }
        
        var receivedError: ServiceError?
        _ = sut.make(request: "dummy request") { result in
            if case let .failure(error) = result {
                receivedError = error
            }
        }
        
        XCTAssertNotNil(receivedError)
    }
    
//    func test_makeRequest_completesWithSuccess() {
//        let url = URL(string: "https://example.com")!
//        let (sut, clientSpy) = makeSUT { _ in URLRequest(url: url) }
//        let expectedResponse = ServiceError(message: "Success")
//        let jsonData = try! JSONEncoder().encode(expectedResponse)
//        
//        var receivedResponse: RemoteError?
//        _ = sut.make(request: "dummy request") { result in
//            if case let .success(response) = result {
//                receivedResponse = response
//            }
//        }
//        clientSpy.completes(withStatusCode: 200, data: jsonData)
//        
//        XCTAssertEqual(receivedResponse?.message, expectedResponse.message)
//    }

//    func test_makeRequest_completesWithConnectivityErrorWhenClientFails() {
//        let url = URL(string: "https://example.com")!
//        let (sut, clientSpy) = makeSUT { _ in URLRequest(url: url) }
//
//        var receivedError: ServiceError?
//        _ = sut.make(request: "dummy request") { result in
//            if case let .failure(error) = result {
//                receivedError = error
//            }
//        }
//        clientSpy.completes(with: NSError(domain: "connectivity", code: 0, userInfo: nil))
//
//        XCTAssertTrue(receivedError?.isConnectivity ?? false)
//    }
    
//    func test_makeRequest_completesWithInternalErrorWhenDecodingFails() {
//        let url = URL(string: "https://example.com")!
//        let (sut, clientSpy) = makeSUT { _ in URLRequest(url: url) }
//
//        var receivedError: ServiceError?
//        _ = sut.make(request: "dummy request") { result in
//            if case let .failure(error) = result {
//                receivedError = error
//            }
//        }
//        clientSpy.completes(withStatusCode: 200, data: Data()) // Data not decodable
//
//        XCTAssertTrue(receivedError?.isInternal ?? false)
//    }
    
//    func test_makeRequest_completesWithInternalErrorWhenResponseIsNotOK() {
//        let url = URL(string: "https://example.com")!
//        let (sut, clientSpy) = makeSUT { _ in URLRequest(url: url) } isResponseOk: { _, response in
//            return response.statusCode == 200
//        }
//
//        var receivedError: ServiceError?
//        _ = sut.make(request: "dummy request") { result in
//            if case let .failure(error) = result {
//                receivedError = error
//            }
//        }
//        clientSpy.completes(withStatusCode: 400, data: Data())
//
//        XCTAssertTrue(receivedError?.isInternal ?? false)
//    }
    
//    func test_makeRequest_callsCompletionBlockOnlyOnce() {
//        let url = URL(string: "https://example.com")!
//        let (sut, clientSpy) = makeSUT { _ in URLRequest(url: url) }
//
//        var completionCallCount = 0
//        _ = sut.make(request: "dummy request") { _ in
//            completionCallCount += 1
//        }
//        clientSpy.completes(withStatusCode: 200, data: Data())
//        XCTAssertEqual(completionCallCount, 1)
//    }
}

extension RemoteServiceTests {
    private func makeSUT(
        makeURLRequest: @escaping ((String) -> URLRequest?),
        responseHandler: ((String, Data, HTTPURLResponse, @escaping ((Result<String, ServiceError>)) -> Void) -> Void)? = nil)
    -> (RemoteService<String, String>, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteService<String, String>(
            client: spy,
            makeURLRequest: makeURLRequest,
            responseHandler: responseHandler
        )
        return (sut, spy)
    }
}

fileprivate extension ServiceError {
    var isConnectivity: Bool {
        if case .connectivity = self { return true }
        return false
    }
    
    var isInternal: Bool {
        if case .internal = self { return true }
        return false
    }
}
