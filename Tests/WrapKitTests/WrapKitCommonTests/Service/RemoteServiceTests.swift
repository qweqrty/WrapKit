//
//  RemoteServiceTests.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import XCTest
import WrapKit

class RemoteServiceTests: XCTestCase {
    func test_makeRequestWithValidURLRequestAndSuccessfulResponse_completesWithParsedResponse() {
        let expectedResponse = "test_response"
        let responseData = Data(expectedResponse.utf8)
        let responseHandler: (String, Data, HTTPURLResponse, @escaping ((Result<String, ServiceError>)) -> Void) -> Void = { _, data, _, completion in
            completion(.success(String(data: data, encoding: .utf8)!))
        }

        let (sut, clientSpy) = makeSUT(
            makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) },
            responseHandler: responseHandler
        )

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(withStatusCode: 200, data: responseData)

        switch receivedResult {
        case .success(let response):
            XCTAssertEqual(response, expectedResponse)
        default:
            XCTFail("Expected '.success', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithInvalidURLRequest_completesWithInternalError() {
        let (sut, _) = makeSUT(makeURLRequest: { _ in nil })

        var receivedResult: Result<String, ServiceError>?
        _ = sut.make(request: "invalid_request") { result in
            receivedResult = result
        }

        switch receivedResult {
        case .failure(let error):
            XCTAssertTrue(error.isInternal)
        default:
            XCTFail("Expected '.failure(.internal)', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithClientFailure_completesWithConnectivityError() {
        let (sut, clientSpy) = makeSUT(makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) })

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(with: URLError(.notConnectedToInternet))

        switch receivedResult {
        case .failure(let error):
            XCTAssertTrue(error.isConnectivity)
        default:
            XCTFail("Expected '.failure(.connectivity)', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithClientCancelledError_completesWithToBeIgnoredError() {
        let (sut, clientSpy) = makeSUT(makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) })

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(with: URLError(.cancelled))

        switch receivedResult {
        case .failure(let error):
            XCTAssertEqual(error, .toBeIgnored)
        default:
            XCTFail("Expected '.failure(.toBeIgnored)', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithUnexpectedError_completesWithInternalError() {
        let (sut, clientSpy) = makeSUT(makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) })

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(with: NSError(domain: "Test", code: 999, userInfo: nil))

        switch receivedResult {
        case .failure(let error):
            XCTAssertTrue(error.isInternal)
        default:
            XCTFail("Expected '.failure(.internal)', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithUnexpectedResponseCode_completesWithInternalError() {
        let (sut, clientSpy) = makeSUT(makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) })

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(withStatusCode: 500, data: Data())

        switch receivedResult {
        case .failure(let error):
            XCTAssertTrue(error.isInternal)
        default:
            XCTFail("Expected '.failure(.internal)', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithoutResponseHandler_completesSuccessfully() {
        let (sut, clientSpy) = makeSUT(makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) })

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(withStatusCode: 200, data: Data("test_response".utf8))

        switch receivedResult {
        case .success(let response):
            XCTAssertEqual(response, "test_response")
        default:
            XCTFail("Expected '.success', got \(String(describing: receivedResult)) instead")
        }
    }

    func test_makeRequestWithResponseHandler_completesSuccessfully() {
        let responseHandler: (String, Data, HTTPURLResponse, @escaping ((Result<String, ServiceError>)) -> Void) -> Void = { _, data, _, completion in
            completion(.success(String(data: data, encoding: .utf8)!))
        }

        let (sut, clientSpy) = makeSUT(
            makeURLRequest: { _ in URLRequest(url: URL(string: "http://test.com")!) },
            responseHandler: responseHandler
        )

        var receivedResult: Result<String, ServiceError>?
        sut.make(request: "test_request") { result in
            receivedResult = result
        }?.resume()

        clientSpy.completes(withStatusCode: 200, data: Data("test_response".utf8))

        switch receivedResult {
        case .success(let response):
            XCTAssertEqual(response, "test_response")
        default:
            XCTFail("Expected '.success', got \(String(describing: receivedResult)) instead")
        }
    }
}

extension RemoteServiceTests {
    private func makeSUT(
        makeURLRequest: @escaping ((String) -> URLRequest?),
        responseHandler: ((String, Data, HTTPURLResponse, @escaping ((Result<String, ServiceError>)) -> Void) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    )
    -> (RemoteService<String, String>, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteService<String, String>(
            client: spy,
            makeURLRequest: makeURLRequest,
            responseHandler: responseHandler
        )
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(spy, file: file, line: line)
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
