//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 25/7/23.
//

import XCTest
import WrapKit

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    func test_dispatch_enrichesURLRequestWithToken() {
        let (sut, httpClientSpy, tokenStorageSpy) = makeSUT(enrichRequestWithToken: { request, token in
            var request = request
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        })
        
        tokenStorageSpy.set(accessToken: "accessToken")
        sut.dispatch(URLRequest(url: makeURL()), completion: { _ in }).resume()
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests.first?.value(forHTTPHeaderField: "Authorization"), "Bearer accessToken")
    }
    
    func test_dispatch_doesNotEnrichURLRequest_whenTokenNil() {
        let (sut, httpClientSpy, _) = makeSUT(enrichRequestWithToken: { request, token in
            var request = request
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        })
        
        sut.dispatch(URLRequest(url: makeURL()), completion: { _ in }).resume()
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests.first?.value(forHTTPHeaderField: "Authorization"), nil)
    }
    
    func test_dispatch_completesWithData_whenAuthenticated() {
        let (sut, httpClientSpy, _) = makeSUT(
            enrichRequestWithToken: { request, _ in return request },
            authenticationPolicy: { _ in return true }
        )
        let expectedResult: (data: Data, response: HTTPURLResponse) = (
            data: makeData(),
            response: HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
        
        expect(sut, toCompleteWith: .success(expectedResult), when: {
            httpClientSpy.completes(withStatusCode: 200, data: expectedResult.data)
        })
    }
    
    func test_dispatch_completesWithDedicatedError_whenAuthenticationPolicyNotPassed() {
        let (sut, httpClientSpy, _) = makeSUT(
            enrichRequestWithToken: { request, _ in return request },
            authenticationPolicy: { _ in return false }
        )

        expect(sut, toCompleteWith: .failure(AuthenticatedHTTPClientDecorator.NotAuthenticated()), when: {
            httpClientSpy.completes(withStatusCode: 200, data: makeData())
        })
    }
    
    func test_dispatch_refreshesToken_makingRequestSecondTimeWithRefreshedToken() {
        let (sut, httpClientSpy, tokenStorageSpy) = makeSUT(
            refresh: { request, completion in completion(.init(accessToken: "accessToken")) },
            enrichRequestWithToken: { request, token in
                var request = request
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return request
            },
            authenticationPolicy: { (data, response) in
                return response.statusCode != 401
            }
        )
        let expectedResult: (data: Data, response: HTTPURLResponse) = (
            data: makeData(),
            response: HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
        tokenStorageSpy.set(refreshToken: "refreshToken")
        
        expect(sut, toCompleteWith: .success(expectedResult), when: {
            httpClientSpy.completes(withStatusCode: 401, data: makeData())
            httpClientSpy.completes(withStatusCode: 200, data: makeData())
            XCTAssertEqual(tokenStorageSpy.getAccessToken(), "accessToken")
        })
        
        XCTAssertEqual(httpClientSpy.requestedURLRequests[1].value(forHTTPHeaderField: "Authorization"), "Bearer accessToken")
        XCTAssertEqual(httpClientSpy.requestedURLRequests.count, 2)
    }


}

extension AuthenticatedHTTPClientDecoratorTests {
    private func makeSUT(
        refresh: TokenService.Refresh? = nil,
        enrichRequestWithToken: @escaping AuthenticatedHTTPClientDecorator.EnrichRequestWithToken,
        authenticationPolicy: @escaping AuthenticatedHTTPClientDecorator.AuthenticationPolicy = { _ in return true },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (AuthenticatedHTTPClientDecorator, HTTPClientSpy, TokenStorage) {
        let tokenStorageSpy = TokenStorageSpy()
        let clientSpy = HTTPClientSpy()
        let tokenService = TokenService(storage: tokenStorageSpy, refresh: refresh)
        let sut = AuthenticatedHTTPClientDecorator(
            decoratee: clientSpy,
            tokenService: tokenService,
            enrichRequestWithToken: enrichRequestWithToken,
            isAuthenticated: authenticationPolicy
        )
        return (sut, clientSpy, tokenStorageSpy)
    }
    
    private func expect(_ sut: AuthenticatedHTTPClientDecorator, toCompleteWith expectedResult: HTTPClient.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.dispatch(URLRequest(url: makeURL())) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse.data, expectedResponse.data, file: file, line: line)
                XCTAssertEqual(receivedResponse.response.statusCode, expectedResponse.response.statusCode, file: file, line: line)
                XCTAssertEqual(receivedResponse.response.url, expectedResponse.response.url, file: file, line: line)
                XCTAssertEqual(receivedResponse.response.mimeType, expectedResponse.response.mimeType, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }.resume()

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
