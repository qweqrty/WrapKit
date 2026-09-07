import Combine
import XCTest
import WrapKit

final class SerialServiceDecoratorTests: XCTestCase {
    func test_temporarySerializedService_forwardsValueAndCompletion() {
        let valueExpectation = expectation(description: "Wait for value")
        let completionExpectation = expectation(description: "Wait for completion")
        var receivedValues: [Int] = []

        let cancellable = ImmediateService().serialized.make(request: 42)
            .sink(
                receiveCompletion: { completion in
                    guard case .finished = completion else {
                        return XCTFail("Expected successful completion")
                    }
                    completionExpectation.fulfill()
                },
                receiveValue: { value in
                    receivedValues.append(value)
                    valueExpectation.fulfill()
                }
            )

        withExtendedLifetime(cancellable) {
            wait(for: [valueExpectation, completionExpectation], timeout: 1.0)
        }
        XCTAssertEqual(receivedValues, [42])
    }

    func test_retainedSerializedService_processesRequestsSequentially() {
        let firstRequestStarted = expectation(description: "Wait for first request")
        let secondRequestStarted = expectation(description: "Wait for second request")
        let requestsCompleted = expectation(description: "Wait for both completions")
        requestsCompleted.expectedFulfillmentCount = 2

        let service = ControlledService { request in
            switch request {
            case 1:
                firstRequestStarted.fulfill()
            case 2:
                secondRequestStarted.fulfill()
            default:
                XCTFail("Unexpected request: \(request)")
            }
        }
        let serializedService = service.serialized
        var receivedValues: [Int] = []
        var cancellables = Set<AnyCancellable>()

        serializedService.make(request: 1)
            .sink(
                receiveCompletion: { _ in requestsCompleted.fulfill() },
                receiveValue: { receivedValues.append($0) }
            )
            .store(in: &cancellables)

        serializedService.make(request: 2)
            .sink(
                receiveCompletion: { _ in requestsCompleted.fulfill() },
                receiveValue: { receivedValues.append($0) }
            )
            .store(in: &cancellables)

        wait(for: [firstRequestStarted], timeout: 1.0)
        XCTAssertEqual(service.requests, [1])

        service.complete(with: .success(10), at: 0)

        wait(for: [secondRequestStarted], timeout: 1.0)
        XCTAssertEqual(service.requests, [1, 2])

        service.complete(with: .success(20), at: 1)

        wait(for: [requestsCompleted], timeout: 1.0)
        XCTAssertEqual(receivedValues, [10, 20])
        withExtendedLifetime(cancellables) {}
    }

    func test_serializedService_releasesDecoratorAfterCompletion() {
        let requestStarted = expectation(description: "Wait for request")
        let requestCompleted = expectation(description: "Wait for completion")
        let service = ControlledService { _ in requestStarted.fulfill() }
        weak var weakDecorator: SerialServiceDecorator<Int, Int>?
        var cancellable: AnyCancellable?
        var decorator: SerialServiceDecorator<Int, Int>? = .init(decoratee: service)

        weakDecorator = decorator
        cancellable = decorator?.make(request: 1)
            .sink(
                receiveCompletion: { _ in requestCompleted.fulfill() },
                receiveValue: { _ in }
            )
        decorator = nil

        wait(for: [requestStarted], timeout: 1.0)
        XCTAssertNotNil(weakDecorator)

        service.complete(with: .success(10), at: 0)
        wait(for: [requestCompleted], timeout: 1.0)

        let decoratorReleased = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in weakDecorator == nil },
            object: nil
        )
        wait(for: [decoratorReleased], timeout: 2.0)
        withExtendedLifetime(cancellable) {}
    }

    func test_cancelledNonTerminatingPublisher_releasesDecorator() {
        let requestStarted = expectation(description: "Wait for request")
        let service = ControlledService { _ in requestStarted.fulfill() }
        weak var weakDecorator: SerialServiceDecorator<Int, Int>?
        var decorator: SerialServiceDecorator<Int, Int>? = .init(decoratee: service)
        var cancellable = decorator?.make(request: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

        weakDecorator = decorator
        decorator = nil

        wait(for: [requestStarted], timeout: 1.0)
        XCTAssertNotNil(weakDecorator)

        cancellable?.cancel()
        cancellable = nil

        let decoratorReleased = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in weakDecorator == nil },
            object: nil
        )
        wait(for: [decoratorReleased], timeout: 2.0)
    }

    func test_completionRequest_retainsTemporaryDecoratorUntilCompletionThenReleases() {
        let requestStarted = expectation(description: "Wait for request")
        let requestCompleted = expectation(description: "Wait for completion")
        let service = ControlledService { _ in requestStarted.fulfill() }
        weak var weakDecorator: SerialServiceDecorator<Int, Int>?
        var decorator: SerialServiceDecorator<Int, Int>? = .init(decoratee: service)

        weakDecorator = decorator
        _ = decorator?.make(request: 1) { result in
            XCTAssertEqual(try? result.get(), 10)
            requestCompleted.fulfill()
        }
        decorator = nil

        wait(for: [requestStarted], timeout: 1.0)
        XCTAssertNotNil(weakDecorator)

        service.complete(with: .success(10), at: 0)
        wait(for: [requestCompleted], timeout: 1.0)

        let decoratorReleased = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in weakDecorator == nil },
            object: nil
        )
        wait(for: [decoratorReleased], timeout: 2.0)
    }
}

private struct ImmediateService: Service {
    func make(request: Int) -> AnyPublisher<Int, ServiceError> {
        Just(request)
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
}

private final class ControlledService: Service {
    private struct RequestPublisher {
        let request: Int
        let subject: PassthroughSubject<Int, ServiceError>
    }

    private let lock = NSLock()
    private let onRequest: (Int) -> Void
    private var requestPublishers: [RequestPublisher] = []

    var requests: [Int] {
        lock.lock()
        defer { lock.unlock() }
        return requestPublishers.map(\.request)
    }

    init(onRequest: @escaping (Int) -> Void) {
        self.onRequest = onRequest
    }

    func make(request: Int) -> AnyPublisher<Int, ServiceError> {
        let subject = PassthroughSubject<Int, ServiceError>()

        lock.lock()
        requestPublishers.append(.init(request: request, subject: subject))
        lock.unlock()

        onRequest(request)
        return subject.eraseToAnyPublisher()
    }

    func complete(with result: Result<Int, ServiceError>, at index: Int) {
        lock.lock()
        let subject = requestPublishers[index].subject
        lock.unlock()

        switch result {
        case .success(let value):
            subject.send(value)
            subject.send(completion: .finished)
        case .failure(let error):
            subject.send(completion: .failure(error))
        }
    }
}
