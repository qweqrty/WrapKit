import XCTest
import Foundation
import WrapKit

class HTTPClientCompletionDecoratorTests: XCTestCase {
    
    func test_dispatch_forwardsRequestToDecoratee() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let (sut, clientSpy) = makeSUT()
        
        _ = sut.dispatch(request) { _ in }
        
        XCTAssertEqual(clientSpy.requestedURLs, [url])
    }
    
    func test_dispatch_callsCompletionOnDecoratorWithResultFromDecoratee() {
        let expectedData = Data("Expected data".utf8)
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let expectedResult: HTTPClient.Result = .success((expectedData, expectedResponse))
        var completionCallCount = 0
        
        let (sut, clientSpy) = makeSUT { result in
            completionCallCount += 1
            switch (result, expectedResult) {
            case (.success(let (receivedData, receivedResponse)), .success(let (expectedData, expectedResponse))):
                XCTAssertEqual(receivedData, expectedData)
                XCTAssertEqual(receivedResponse.url, expectedResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, expectedResponse.statusCode)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
        }
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.dispatch(URLRequest(url: URL(string: "https://example.com")!)) { _ in
            exp.fulfill()
        }
        
        clientSpy.completes(withStatusCode: 200, data: expectedData)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(completionCallCount, 1)
    }
    
    func test_dispatch_forwardsResultToCompletion() {
        let expectedData = Data("Expected data".utf8)
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let expectedResult: HTTPClient.Result = .success((expectedData, expectedResponse))
        
        let (sut, clientSpy) = makeSUT()
        
        let exp = expectation(description: "Wait for result")
        var receivedResult: HTTPClient.Result?
        
        _ = sut.dispatch(URLRequest(url: URL(string: "https://example.com")!)) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        clientSpy.completes(withStatusCode: 200, data: expectedData)
        
        wait(for: [exp], timeout: 1.0)
        
        switch receivedResult {
        case .success(let (receivedData, receivedResponse)):
            XCTAssertEqual(receivedData, expectedData)
            XCTAssertEqual(receivedResponse.url, expectedResponse.url)
            XCTAssertEqual(receivedResponse.statusCode, expectedResponse.statusCode)
        default:
            XCTFail("Expected \(expectedResult), got \(String(describing: receivedResult)) instead")
        }
    }
}

// MARK: - Helper Methods

extension HTTPClientCompletionDecoratorTests {
    private func makeSUT(completion: @escaping ((HTTPClient.Result) -> Void) = { _ in }) -> (HTTPClientCompletionDecorator, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = HTTPClientCompletionDecorator(decoratee: spy, completion: completion)
        return (sut, spy)
    }
}
