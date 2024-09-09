import XCTest
import Combine
import Foundation
import WrapKit

class HTTPClientCancelOngoingRequestsDecoratorTests: XCTestCase {

    func test_dispatch_forwardsRequestToDecoratee() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let (sut, clientSpy) = makeSUT(shouldCancel: { _ in false })

        _ = sut.dispatch(request) { _ in }
        XCTAssertEqual(clientSpy.requestedURLs, [url])
    }

    func test_dispatch_completesWithResultFromDecoratee() {
        let expectedData = Data("Expected data".utf8)
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let expectedResult: HTTPClient.Result = .success((expectedData, expectedResponse))
        let (sut, clientSpy) = makeSUT(shouldCancel: { _ in false })
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

    func test_dispatch_cancelsOngoingRequestsWhenShouldCancelConditionIsTrue() {
        let (sut, clientSpy) = makeSUT(shouldCancel: { _ in true })

        let url = URL(string: "https://example.com")!
        let exp = expectation(description: "Wait for completion")

        _ = sut.dispatch(URLRequest(url: url)) { _ in
            exp.fulfill()
        }

        clientSpy.completes(withStatusCode: 200, data: Data())
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(clientSpy.cancelledURLs, [url]) // Verify that the task was cancelled
    }

    func test_dispatch_doesNotCancelOngoingRequestsWhenShouldCancelConditionIsFalse() {
        let (sut, clientSpy) = makeSUT(shouldCancel: { _ in false })

        let url = URL(string: "https://example.com")!
        let exp = expectation(description: "Wait for completion")

        _ = sut.dispatch(URLRequest(url: url)) { _ in
            exp.fulfill()
        }

        clientSpy.completes(withStatusCode: 200, data: Data())
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(clientSpy.cancelledURLs.isEmpty) // Verify that no task was cancelled
    }
}

extension HTTPClientCancelOngoingRequestsDecoratorTests {
    private func makeSUT(
        shouldCancel: @escaping ((HTTPClient.Result) -> Bool),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (HTTPClientCancelOngoingRequestsDecorator, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = HTTPClientCancelOngoingRequestsDecorator(
            decoratee: spy,
            shouldCancelRequestsOn: shouldCancel
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
}
