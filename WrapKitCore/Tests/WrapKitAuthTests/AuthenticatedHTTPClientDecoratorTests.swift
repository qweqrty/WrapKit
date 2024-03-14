//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    func test_dispatch_withNoAccessToken_completesWithNotAuthorizedError() {
        let (sut, storage, httpClientSpy, _) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model: nil, completion: nil)

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8))
        XCTAssertEqual(httpClientSpy.requestedURLs, [URL(string: "http://test.com")!])
        switch receivedResult {
        case .failure(let error as ServiceError):
            XCTAssertEqual(error, ServiceError.notAuthorized)
        default:
            XCTFail("Expected '.failure(.notAuthorized)', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_withAccessTokenAndAuthenticatedResponse_completesSuccessfully() {
        let (sut, storage, httpClientSpy, _) = makeSUT(isAuthenticated: { _ in true })

        storage.set(model: "valid_token", completion: nil)

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()
        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8))

        XCTAssertEqual(httpClientSpy.requestedURLs, [URL(string: "http://test.com")!])
        switch receivedResult {
        case .success(let (data, response)):
            XCTAssertEqual(data, Data("data".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withAccessTokenAndUnauthenticatedResponseAndTokenRefresherSuccess_retriesRequest() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { (data, response) in
            return response.statusCode == 200
        })

        storage.set(model: "valid_token", completion: nil)
        var receivedResult: HTTPClient.Result?

        let exp = expectation(description: "Wait for completion")
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
            exp.fulfill()
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        tokenRefresherSpy?.complete(with: .success("new_token"))
        httpClientSpy.completes(withStatusCode: 200, data: Data("data".utf8), at: 1)
        
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(httpClientSpy.requestedURLs, [URL(string: "http://test.com")!, URL(string: "http://test.com")!])
        switch receivedResult {
        case .success(let (data, response)):
            XCTAssertEqual(data, Data("data".utf8))
            XCTAssertEqual(response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }
    
    func test_dispatch_withAccessTokenAndUnauthenticatedResponseAndTokenRefresherFailure_completesWithNotAuthorized() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model: "valid_token", completion: nil)

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        tokenRefresherSpy?.complete(with: .failure(ServiceError.notAuthorized))

        switch receivedResult {
        case .failure(let error as ServiceError):
            XCTAssertEqual(error, ServiceError.notAuthorized)
        default:
            XCTFail("Expected '.failure(.notAuthorized)', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_withAccessTokenAndTwoUnauthenticatedResponses_doesNotRetryTwice() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model:"valid_token", completion: nil)

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
        tokenRefresherSpy?.complete(with: .success("new_token"))
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 1)

        switch receivedResult {
        case .success(let result):
            XCTAssertEqual(result.data, Data("data".utf8))
            XCTAssertEqual(result.response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.success', but got \(String(describing: receivedResult))")
        }
    }

    func test_dispatch_withAccessTokenAndUnauthenticatedResponseWithNoTokenRefresher_doesNotRetry() {
        let (sut, storage, httpClientSpy, _) = makeSUT(tokenRefresher: nil, isAuthenticated: { _ in false })

        storage.set(model: "valid_token", completion: nil)

        var receivedResult: HTTPClient.Result?
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
            receivedResult = result
        }.resume()

        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))

        switch receivedResult {
        case .success(let result):
            XCTAssertEqual(result.data, Data("data".utf8))
            XCTAssertEqual(result.response.url, URL(string: "http://test.com")!)
        default:
            XCTFail("Expected '.sucess', but got \(String(describing: receivedResult))")
        }
    }
    
//    func test_concurrentDispatch_withMultipleUnauthenticatedResponses_allRetryOnce() {
//        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })
//        storage.set("valid_token")
//        let exp = expectation(description: "Wait for completion")
//        exp.expectedFulfillmentCount = 2
//
//        var receivedResults: [HTTPClient.Result?] = []
//
//        for _ in 0..<2 {
//            sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { result in
//                receivedResults.append(result)
//                exp.fulfill()
//            }.resume()
//        }
//        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 0)
//        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8), at: 1)
//        tokenRefresherSpy?.complete(with: .success("new_token"))
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertEqual(tokenRefresherSpy?.refreshCalledCount, 1, "Expected one refresh call, but got \(tokenRefresherSpy?.refreshCalledCount ?? 0)")
//        XCTAssertEqual(receivedResults.count, 2)
//    }
    
    func test_dispatch_withTokenRefreshed_storesNewToken() {
        let (sut, storage, httpClientSpy, tokenRefresherSpy) = makeSUT(isAuthenticated: { _ in false })

        storage.set(model: "valid_token", completion: nil)
        
        sut.dispatch(URLRequest(url: URL(string: "http://test.com")!)) { _ in }.resume()
        httpClientSpy.completes(withStatusCode: 401, data: Data("data".utf8))
        tokenRefresherSpy?.complete(with: .success("new_token"))

        XCTAssertEqual(storage.get(), "new_token")
    }

    
    // MARK: - Helpers

    private func makeSUT(tokenRefresher: TokenRefresherSpy? = TokenRefresherSpy(), isAuthenticated: @escaping AuthenticatedHTTPClientDecorator.AuthenticationPolicy = { _ in true }) -> (sut: AuthenticatedHTTPClientDecorator, storage: InMemoryStorage<String>, httpClientSpy: HTTPClientSpy, tokenRefresherSpy: TokenRefresherSpy?) {
        let httpClientSpy = HTTPClientSpy()
        let storage = InMemoryStorage<String>()
        
        let sut = AuthenticatedHTTPClientDecorator(
            decoratee: httpClientSpy,
            accessTokenStorage: storage,
            tokenRefresher: tokenRefresher,
            enrichRequestWithToken: { request, token in
                var req = request
                req.setValue(token, forHTTPHeaderField: "Authorization")
                return req
            },
            isAuthenticated: isAuthenticated
        )

        return (sut, storage, httpClientSpy, tokenRefresher)
    }

    class TokenRefresherSpy: TokenRefresher {
        var completion: ((Result<String, ServiceError>) -> Void)?
        var refreshCalledCount: Int = 0

        func refresh(completion: @escaping (Result<String, ServiceError>) -> Void) {
            self.completion = completion
            refreshCalledCount += 1
        }

        func complete(with result: Result<String, ServiceError>) {
            completion?(result)
        }
    }
}

