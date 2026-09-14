import Foundation
import XCTest
@testable import WrapKit

final class CompositeHTTPClientTaskTests: XCTestCase {
    func test_init_doesNotStartOrCancelChildren() {
        let first = TaskSpy()
        let second = TaskSpy()
        let sut = CompositeHTTPClientTask(tasks: [first, second])

        XCTAssertFalse(sut.isCancelled)
        XCTAssertEqual(first.events, [])
        XCTAssertEqual(second.events, [])
    }

    func test_addBeforeResume_waitsForResume() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask()

        sut.add(child)

        XCTAssertEqual(child.events, [])

        sut.resume()

        XCTAssertEqual(child.events, [.resume])
    }

    func test_resume_startsInitialAndAddedChildrenOnce() {
        let first = TaskSpy()
        let second = TaskSpy()
        let sut = CompositeHTTPClientTask(tasks: [first])
        sut.add(second)

        sut.resume()
        sut.resume()

        XCTAssertEqual(first.events, [.resume])
        XCTAssertEqual(second.events, [.resume])
        XCTAssertFalse(sut.isCancelled)
    }

    func test_resumeBeforeAddingChildren_startsLateChildrenOnce() {
        let first = TaskSpy()
        let second = TaskSpy()
        let sut = CompositeHTTPClientTask()

        sut.resume()
        sut.add(first)
        sut.add(second)
        sut.resume()

        XCTAssertEqual(first.events, [.resume])
        XCTAssertEqual(second.events, [.resume])
    }

    func test_cancelBeforeResume_cancelsChildrenWithoutStartingThem() {
        let first = TaskSpy()
        let second = TaskSpy()
        let sut = CompositeHTTPClientTask(tasks: [first, second])

        sut.cancel()
        sut.resume()
        sut.cancel()

        XCTAssertTrue(sut.isCancelled)
        XCTAssertEqual(first.events, [.cancel])
        XCTAssertEqual(second.events, [.cancel])
    }

    func test_cancelAfterResume_cancelsStartedChildrenOnce() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask(tasks: [child])

        sut.resume()
        sut.cancel()
        sut.resume()
        sut.cancel()

        XCTAssertEqual(child.events, [.resume, .cancel])
        XCTAssertTrue(sut.isCancelled)
    }

    func test_addAfterCancel_cancelsLateChildWithoutStartingIt() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask()

        sut.cancel()
        sut.add(child)
        sut.resume()
        sut.cancel()

        XCTAssertEqual(child.events, [.cancel])
    }

    func test_addAfterResumeAndCancel_cancelsLateChildWithoutStartingIt() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask()

        sut.resume()
        sut.cancel()
        sut.add(child)
        sut.resume()

        XCTAssertEqual(child.events, [.cancel])
    }

    func test_cancel_releasesRetainedChildren() {
        let sut = CompositeHTTPClientTask()
        weak var retainedChild: TaskSpy?
        do {
            let child = TaskSpy()
            retainedChild = child
            sut.add(child)
        }
        XCTAssertNotNil(retainedChild)

        sut.cancel()

        XCTAssertNil(retainedChild)
    }

    func test_finish_releasesRetainedChildren() {
        let sut = CompositeHTTPClientTask()
        weak var retainedChild: TaskSpy?
        do {
            let child = TaskSpy()
            retainedChild = child
            sut.add(child)
        }
        XCTAssertNotNil(retainedChild)

        sut.finish()

        XCTAssertNil(retainedChild)
        XCTAssertFalse(sut.isCancelled)
    }

    func test_finishBeforeResume_doesNotStartOrCancelCompletedChildren() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask(tasks: [child])

        sut.finish()
        sut.finish()
        sut.resume()
        sut.cancel()

        XCTAssertEqual(child.events, [])
    }

    func test_finishAfterResume_doesNotCancelCompletedChildren() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask(tasks: [child])

        sut.resume()
        sut.finish()
        sut.cancel()

        XCTAssertEqual(child.events, [.resume])
    }

    func test_addAfterFinish_cancelsLateChildWithoutStartingIt() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask()

        sut.finish()
        sut.resume()
        sut.add(child)
        sut.cancel()

        XCTAssertEqual(child.events, [.cancel])
    }

    func test_addAfterResumedTaskFinishes_cancelsLateChildWithoutStartingIt() {
        let child = TaskSpy()
        let sut = CompositeHTTPClientTask()

        sut.resume()
        sut.finish()
        sut.add(child)

        XCTAssertEqual(child.events, [.cancel])
    }

    func test_resumeCallback_canAddAChildAndResumeAgainWithoutDeadlock() {
        let sut = CompositeHTTPClientTask()
        let lateChild = TaskSpy()
        let child = TaskSpy(onResume: { [weak sut] in
            XCTAssertFalse(sut?.isCancelled ?? true)
            sut?.add(lateChild)
            sut?.resume()
        })
        sut.add(child)

        performOffMain { sut.resume() }

        XCTAssertEqual(child.events, [.resume])
        XCTAssertEqual(lateChild.events, [.resume])
    }

    func test_cancelCallback_canReadCancellationAddChildAndCancelAgainWithoutDeadlock() {
        let sut = CompositeHTTPClientTask()
        let lateChild = TaskSpy()
        let child = TaskSpy(onCancel: { [weak sut] in
            XCTAssertTrue(sut?.isCancelled ?? false)
            sut?.add(lateChild)
            sut?.resume()
            sut?.cancel()
        })
        sut.add(child)

        performOffMain { sut.cancel() }

        XCTAssertEqual(child.events, [.cancel])
        XCTAssertEqual(lateChild.events, [.cancel])
    }

    func test_resumeCallback_canFinishAndRejectLateChildWithoutDeadlock() {
        let sut = CompositeHTTPClientTask()
        let lateChild = TaskSpy()
        let child = TaskSpy(onResume: { [weak sut] in
            sut?.finish()
            sut?.add(lateChild)
        })
        sut.add(child)

        performOffMain { sut.resume() }

        XCTAssertEqual(child.events, [.resume])
        XCTAssertEqual(lateChild.events, [.cancel])
    }

    func test_addWhileResumeCallbackIsHeld_startsLateChildOnce() {
        let sut = CompositeHTTPClientTask()
        let gate = CallbackGate()
        let first = TaskSpy(onResume: { gate.hold() })
        let lateChild = TaskSpy()
        let completed = expectation(description: "Resume returns")
        sut.add(first)
        defer { gate.release() }
        DispatchQueue.global().async {
            sut.resume()
            completed.fulfill()
        }
        XCTAssertTrue(gate.waitUntilEntered())

        sut.add(lateChild)
        sut.resume()
        gate.release()
        wait(for: [completed], timeout: 3)

        XCTAssertEqual(first.events, [.resume])
        XCTAssertEqual(lateChild.events, [.resume])
    }

    func test_addWhileCancelCallbackIsHeld_cancelsLateChildWithoutStartingIt() {
        let sut = CompositeHTTPClientTask()
        let gate = CallbackGate()
        let first = TaskSpy(onCancel: { gate.hold() })
        let lateChild = TaskSpy()
        let completed = expectation(description: "Cancel returns")
        sut.add(first)
        defer { gate.release() }
        DispatchQueue.global().async {
            sut.cancel()
            completed.fulfill()
        }
        XCTAssertTrue(gate.waitUntilEntered())

        sut.add(lateChild)
        sut.resume()
        gate.release()
        wait(for: [completed], timeout: 3)

        XCTAssertEqual(first.events, [.cancel])
        XCTAssertEqual(lateChild.events, [.cancel])
    }

    func test_cancelWhileResumeCallbackIsHeld_cancelsChildOnce() {
        let sut = CompositeHTTPClientTask()
        let gate = CallbackGate()
        let child = TaskSpy(onResume: { gate.hold() })
        let completed = expectation(description: "Resume returns after cancellation")
        sut.add(child)
        defer { gate.release() }
        DispatchQueue.global().async {
            sut.resume()
            completed.fulfill()
        }
        XCTAssertTrue(gate.waitUntilEntered())

        sut.cancel()
        sut.cancel()
        gate.release()
        wait(for: [completed], timeout: 3)

        XCTAssertEqual(child.events, [.resume, .cancel])
        XCTAssertTrue(sut.isCancelled)
    }

    func test_concurrentAddResumeAndCancel_doesNotLoseOrDuplicateChildCancellation() {
        for iteration in 0..<20 {
            let sut = CompositeHTTPClientTask()
            let children = (0..<60).map { _ in TaskSpy() }
            let ready = DispatchGroup()
            let completed = DispatchGroup()
            let start = DispatchSemaphore(value: 0)
            let addFirstHalf = { children.prefix(30).forEach { sut.add($0) } }
            let addSecondHalf = { children.suffix(30).forEach { sut.add($0) } }
            let resumeRepeatedly = { (0..<30).forEach { _ in sut.resume() } }
            let cancelRepeatedly = { (0..<30).forEach { _ in sut.cancel() } }
            let actions = [addFirstHalf, addSecondHalf, resumeRepeatedly, cancelRepeatedly]
            for action in actions {
                ready.enter()
                completed.enter()
                DispatchQueue.global().async {
                    ready.leave()
                    start.wait()
                    action()
                    completed.leave()
                }
            }
            XCTAssertEqual(ready.wait(timeout: .now() + 3), .success)
            actions.forEach { _ in start.signal() }
            XCTAssertEqual(completed.wait(timeout: .now() + 3), .success)

            XCTAssertTrue(sut.isCancelled)
            for (index, child) in children.enumerated() {
                let events = child.events
                XCTAssertEqual(events.filter { $0 == .cancel }.count, 1, "Iteration \(iteration), child \(index)")
                XCTAssertLessThanOrEqual(events.filter { $0 == .resume }.count, 1, "Iteration \(iteration), child \(index)")
            }
        }
    }

    func test_cancelledComposite_doesNotStartLateURLSessionRequest() throws {
        let session = makeSessionThatRejectsNetworkStarts()
        defer { session.invalidateAndCancel() }
        let client = URLSessionHTTPClient(session: session)
        let completed = expectation(description: "Late URLSession task remains cancelled")
        let child = client.dispatch(try makeRequest()) { result in
            Self.assertCancelled(result)
            completed.fulfill()
        }
        let sut = CompositeHTTPClientTask()

        sut.cancel()
        sut.add(child)
        sut.resume()

        wait(for: [completed], timeout: 3)
    }

    func test_cancellationDuringResume_doesNotRevivePendingURLSessionRequest() throws {
        let session = makeSessionThatRejectsNetworkStarts()
        defer { session.invalidateAndCancel() }
        let client = URLSessionHTTPClient(session: session)
        let completed = expectation(description: "Pending URLSession task remains cancelled")
        let networkTask = client.dispatch(try makeRequest()) { result in
            Self.assertCancelled(result)
            completed.fulfill()
        }
        let sut = CompositeHTTPClientTask()
        let first = TaskSpy(onResume: { [weak sut] in sut?.cancel() })
        sut.add(first)
        sut.add(networkTask)

        sut.resume()

        wait(for: [completed], timeout: 3)
        XCTAssertEqual(first.events, [.resume, .cancel])
        XCTAssertTrue(sut.isCancelled)
    }
}

private extension CompositeHTTPClientTaskTests {
    func performOffMain(_ action: @escaping () -> Void) {
        let completed = expectation(description: "Reentrant callback returns")
        DispatchQueue.global().async {
            action()
            completed.fulfill()
        }
        wait(for: [completed], timeout: 3)
    }

    func makeSessionThatRejectsNetworkStarts() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UnexpectedNetworkStartURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    func makeRequest() throws -> URLRequest {
        URLRequest(url: try XCTUnwrap(URL(string: "https://composite-task.test/resource")))
    }

    static func assertCancelled(_ result: HTTPClient.Result, file: StaticString = #filePath, line: UInt = #line) {
        switch result {
        case .failure(let error):
            XCTAssertEqual((error as NSError).domain, NSURLErrorDomain, file: file, line: line)
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, file: file, line: line)
        case .success:
            XCTFail("A cancelled task must not succeed", file: file, line: line)
        }
    }

    final class TaskSpy: HTTPClientTask {
        enum Event: Equatable {
            case resume
            case cancel
        }

        private let lock = NSLock()
        private var recordedEvents: [Event] = []
        private let onResume: () -> Void
        private let onCancel: () -> Void

        var events: [Event] {
            lock.lock()
            defer { lock.unlock() }
            return recordedEvents
        }

        init(onResume: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
            self.onResume = onResume
            self.onCancel = onCancel
        }

        func resume() {
            // Record every call, including resume after cancel; the spy must not
            // hide lifecycle errors by implementing its own cancellation guard.
            record(.resume)
            onResume()
        }

        func cancel() {
            record(.cancel)
            onCancel()
        }

        private func record(_ event: Event) {
            lock.lock()
            recordedEvents.append(event)
            lock.unlock()
        }
    }

    final class CallbackGate {
        private let entered = DispatchSemaphore(value: 0)
        private let released = DispatchSemaphore(value: 0)

        func hold() {
            entered.signal()
            XCTAssertEqual(released.wait(timeout: .now() + 3), .success, "Callback must be released")
        }

        func waitUntilEntered() -> Bool {
            entered.wait(timeout: .now() + 3) == .success
        }

        func release() {
            released.signal()
        }
    }

    final class UnexpectedNetworkStartURLProtocol: URLProtocol {
        override class func canInit(with request: URLRequest) -> Bool { true }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            XCTFail("A cancelled URLSession task must not start loading")
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
        }

        override func stopLoading() {}
    }
}
