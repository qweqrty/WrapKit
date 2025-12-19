import XCTest
import Foundation
import Combine
import WrapKit
import WrapKitTestUtils

class StoredHTTPClientDecoratorTests: XCTestCase {

    func test_dispatch_forwardsEnrichedRequestToDecoratee() {
        let url = URL(string: "https://example.com")!
        let originalRequest = URLRequest(url: url)
        let enrichedURL = URL(string: "https://modified.com")!
        let enrichedRequest = URLRequest(url: enrichedURL)
        
        let (sut, clientSpy, storage) = makeSUT { request, _ in
            XCTAssertEqual(request.url, originalRequest.url)
            return enrichedRequest
        }
        
        storage.set(model: nil)
        _ = sut.dispatch(originalRequest) { _ in }
        XCTAssertEqual(clientSpy.requestedURLs, [enrichedURL])
    }
    
    func test_dispatch_enrichesRequestWithStorageModel() {
        let url = URL(string: "https://example.com")!
        let originalRequest = URLRequest(url: url)
        let enrichedURL = URL(string: "https://modified.com")!
        let enrichedRequest = URLRequest(url: enrichedURL)
        
        let storedModel = "Stored Model"
        
        let (sut, clientSpy, storage) = makeSUT { request, model in
            XCTAssertEqual(model, storedModel) // Verify model from storage is passed
            return enrichedRequest
        }
        
        storage.set(model: storedModel)
        _ = sut.dispatch(originalRequest) { _ in }
        XCTAssertEqual(clientSpy.requestedURLs, [enrichedURL])
    }

    func test_dispatch_forwardsCompletionToDecoratee() {
        let expectedData = Data("Expected data".utf8)
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let expectedResult: HTTPClient.Result = .success((expectedData, expectedResponse))

        let (sut, clientSpy, _) = makeSUT { request, _ in request }

        let exp = expectation(description: "Wait for completion")
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

extension StoredHTTPClientDecoratorTests {
    private func makeSUT(
        enrichRequest: @escaping ((URLRequest, String?) -> URLRequest) = { request, _ in request },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (StoredHTTPClientDecorator<String>, HTTPClientSpy, InMemoryStorage<String>) {
        let clientSpy = HTTPClientSpy()
        let storage = InMemoryStorage<String>()
        let sut = StoredHTTPClientDecorator(
            decoratee: clientSpy,
            storage: storage,
            enrichRequest: enrichRequest
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(clientSpy, file: file, line: line)
        checkForMemoryLeaks(storage, file: file, line: line)
        return (sut, clientSpy, storage)
    }
}
