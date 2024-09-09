import XCTest
import Foundation
import WrapKit

class EncrichHTTPClientDecoratorTests: XCTestCase {
    
    func test_dispatch_enrichesURLRequest() {
        let url = URL(string: "https://example.com")!
        let originalRequest = URLRequest(url: url)
        let enrichedURL = URL(string: "https://modified.com")!
        let enrichedRequest = URLRequest(url: enrichedURL)
        let (sut, clientSpy) = makeSUT { _ in enrichedRequest }
        
        _ = sut.dispatch(originalRequest) { _ in }
        
        XCTAssertEqual(clientSpy.requestedURLs, [enrichedURL])
    }
    
    func test_dispatch_completesWithErrorOnEnrichmentFailure() {
        let unreachableURL = URL(string: "https://nonexistent-url.com")!
        let (sut, clientSpy) = makeSUT { _ in
            return URLRequest(url: unreachableURL)
        }
        
        var receivedError: HTTPClientError?
        let exp = expectation(description: "Wait for completion")

        _ = sut.dispatch(URLRequest(url: URL(string: "https://example.com")!)) { result in
            if case let .failure(error as HTTPClientError) = result {
                receivedError = error
            }
            exp.fulfill()
        }

        clientSpy.completes(with: HTTPClientError.connectivity)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError, .connectivity)
    }

    
    func test_dispatch_forwardsCompletionToClient() {
        let expectedData = Data("Expected data".utf8)
        let (sut, clientSpy) = makeSUT { $0 }
        
        var receivedResult: HTTPClient.Result?
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.dispatch(URLRequest(url: URL(string: "https://example.com")!)) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        clientSpy.completes(withStatusCode: 200, data: expectedData)
        
        wait(for: [exp], timeout: 1.0)
        
        switch receivedResult {
        case .success((let receivedData, _)):
            XCTAssertEqual(receivedData, expectedData)
        default:
            XCTFail("Expected successful result with data, got \(String(describing: receivedResult)) instead")
        }
    }
}

extension EncrichHTTPClientDecoratorTests {
    private func makeSUT(
        enrichRequest: @escaping ((URLRequest) -> URLRequest),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (EncrichHTTPClientDecorator, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = EncrichHTTPClientDecorator(
            decoratee: spy,
            enrichRequest: enrichRequest
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
}
