import Combine
import Foundation
import XCTest
import WrapKit

@MainActor
final class InMemoryStorageTests: XCTestCase {
    func test_initialValue_isAvailableFromGetAndPublisher() {
        let storage = InMemoryStorage(model: 10)
        var values: [Int?] = []

        let subscription = storage.publisher.sink { values.append($0) }

        XCTAssertEqual(storage.get(), 10)
        XCTAssertEqual(values, [10])
        subscription.cancel()
    }

    func test_emptyStorage_publishesNilImmediately() {
        let storage = InMemoryStorage<Int>()
        var values: [Int?] = []

        let subscription = storage.publisher.sink { values.append($0) }

        XCTAssertNil(storage.get())
        XCTAssertEqual(values, [nil])
        subscription.cancel()
    }

    func test_mainThreadWrites_publishEveryValueSynchronously() {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink {
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(storage.get(), $0)
            values.append($0)
        }

        storage.set(model: 1)
        storage.set(model: 2)
        storage.clear()

        XCTAssertEqual(values, [0, 1, 2, nil])
        XCTAssertNil(storage.get())
        subscription.cancel()
    }

    func test_equalMainThreadWrites_areNotDeduplicated() {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink { values.append($0) }

        storage.set(model: 1)
        storage.set(model: 1)

        XCTAssertEqual(values, [0, 1, 1])
        subscription.cancel()
    }

    func test_set_commitsWithoutSubscribingToItsResult() {
        let storage = InMemoryStorage(model: 0)

        _ = storage.set(model: 1)

        XCTAssertEqual(storage.get(), 1)
    }

    func test_writeResult_reportsSuccessAfterValueIsCommitted() {
        let storage = InMemoryStorage(model: 0)
        var results: [Bool] = []

        let subscription = storage.set(model: 1).sink {
            XCTAssertEqual(storage.get(), 1)
            results.append($0)
        }

        XCTAssertEqual(results, [true])
        subscription.cancel()
    }

    func test_clearResult_reportsSuccessAfterValueIsRemoved() {
        let storage = InMemoryStorage(model: 1)
        var results: [Bool] = []

        let subscription = storage.clear().sink {
            XCTAssertNil(storage.get())
            results.append($0)
        }

        XCTAssertEqual(results, [true])
        subscription.cancel()
    }

    func test_resubscribingToWriteResult_doesNotReplayTheWrite() {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let observer = storage.publisher.sink { values.append($0) }
        let result = storage.set(model: 1)
        storage.set(model: 2)
        var successes: [Bool] = []

        let first = result.sink { successes.append($0) }
        let second = result.sink { successes.append($0) }

        XCTAssertEqual(successes, [true, true])
        XCTAssertEqual(storage.get(), 2)
        XCTAssertEqual(values, [0, 1, 2])
        first.cancel()
        second.cancel()
        observer.cancel()
    }

    func test_resubscribingToClearResult_doesNotClearLaterValue() {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let observer = storage.publisher.sink { values.append($0) }
        let result = storage.clear()
        storage.set(model: 1)
        var successes: [Bool] = []

        let first = result.sink { successes.append($0) }
        let second = result.sink { successes.append($0) }

        XCTAssertEqual(successes, [true, true])
        XCTAssertEqual(storage.get(), 1)
        XCTAssertEqual(values, [0, nil, 1])
        first.cancel()
        second.cancel()
        observer.cancel()
    }

    func test_cachedPublisher_readsCurrentValueWhenSubscribed() {
        let storage = InMemoryStorage(model: 0)
        let publisher = storage.publisher
        storage.set(model: 1)
        var values: [Int?] = []

        let subscription = publisher.sink { values.append($0) }

        XCTAssertEqual(values, [1])
        subscription.cancel()
    }

    func test_backgroundWrite_commitsBeforeReturningSuccess() async {
        let storage = InMemoryStorage(model: 0)

        performOffMain {
            let subscription = storage.set(model: 1).sink {
                XCTAssertTrue($0)
                XCTAssertFalse(Thread.isMainThread)
                XCTAssertEqual(storage.get(), 1)
            }
            subscription.cancel()
        }

        XCTAssertEqual(storage.get(), 1)
        await drainMainQueue()
    }

    func test_backgroundClear_commitsBeforeReturningSuccess() async {
        let storage = InMemoryStorage(model: 1)

        performOffMain {
            let subscription = storage.clear().sink {
                XCTAssertTrue($0)
                XCTAssertNil(storage.get())
            }
            subscription.cancel()
        }

        XCTAssertNil(storage.get())
        await drainMainQueue()
    }

    func test_backgroundWrites_notifyExistingSubscriberOnMain() async {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink {
            XCTAssertTrue(Thread.isMainThread)
            values.append($0)
        }

        performOffMain { storage.set(model: 1) }
        XCTAssertEqual(values, [0])
        await drainMainQueue()

        XCTAssertEqual(values, [0, 1])
        subscription.cancel()
    }

    func test_initialPublication_usesSubscriptionThread() {
        let storage = InMemoryStorage(model: 1)

        performOffMain {
            var values: [Int?] = []
            let subscription = storage.publisher.sink {
                XCTAssertFalse(Thread.isMainThread)
                values.append($0)
            }
            XCTAssertEqual(values, [1])
            subscription.cancel()
        }
    }

    func test_queuedBackgroundNotifications_publishCurrentStateNotWriteHistory() async {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink { values.append($0) }

        performOffMain {
            storage.set(model: 1)
            storage.set(model: 2)
        }
        XCTAssertEqual(storage.get(), 2)
        XCTAssertEqual(values, [0])
        await drainMainQueue()

        // Each queued notification reads the latest state, not its original value.
        XCTAssertEqual(values, [0, 2, 2])
        subscription.cancel()
    }

    func test_pendingBackgroundNotification_doesNotOverwriteLaterMainWrite() async {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink { values.append($0) }

        performOffMain { storage.set(model: 1) }
        storage.set(model: 2)
        await drainMainQueue()

        XCTAssertEqual(storage.get(), 2)
        XCTAssertEqual(values, [0, 2, 2])
        subscription.cancel()
    }

    func test_pendingBackgroundNotification_doesNotRestoreClearedValue() async {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink { values.append($0) }

        performOffMain { storage.set(model: 1) }
        storage.clear()
        await drainMainQueue()

        XCTAssertNil(storage.get())
        XCTAssertEqual(values, [0, nil, nil])
        subscription.cancel()
    }

    func test_newSubscriber_readsBackgroundWriteBeforeItsQueuedNotification() async {
        let storage = InMemoryStorage(model: 0)
        performOffMain { storage.set(model: 1) }
        var values: [Int?] = []

        let subscription = storage.publisher.sink { values.append($0) }

        XCTAssertEqual(values, [1])
        await drainMainQueue()
        XCTAssertEqual(values, [1, 1])
        subscription.cancel()
    }

    func test_subscriber_canReadWriteAndClearReentrantly() {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink {
            XCTAssertEqual(storage.get(), $0)
            values.append($0)
            if $0 == 1 {
                storage.set(model: 2)
            } else if $0 == 2 {
                storage.clear()
            }
        }

        storage.set(model: 1)

        XCTAssertEqual(values, [0, 1, 2, nil])
        XCTAssertNil(storage.get())
        subscription.cancel()
    }

    func test_cancellingSubscriber_doesNotCancelOtherSubscribers() {
        let storage = InMemoryStorage(model: 0)
        var firstValues: [Int?] = []
        var secondValues: [Int?] = []
        let first = storage.publisher.sink { firstValues.append($0) }
        let second = storage.publisher.sink { secondValues.append($0) }

        first.cancel()
        storage.set(model: 1)

        XCTAssertEqual(firstValues, [0])
        XCTAssertEqual(secondValues, [0, 1])
        second.cancel()
    }

    func test_cancelledSubscriber_doesNotReceiveQueuedNotification() async {
        let storage = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = storage.publisher.sink { values.append($0) }

        performOffMain { storage.set(model: 1) }
        subscription.cancel()
        await drainMainQueue()

        XCTAssertEqual(values, [0])
    }

    func test_cancellingSubscription_releasesStorage() {
        weak var weakStorage: InMemoryStorage<Int>?
        var subscription: AnyCancellable?
        autoreleasepool {
            let storage = InMemoryStorage(model: 0)
            weakStorage = storage
            subscription = storage.publisher.sink { _ in }
        }

        subscription?.cancel()

        XCTAssertNil(weakStorage)
    }

    func test_zip_receivesEveryMainThreadPair() {
        let start = InMemoryStorage(model: 0)
        let end = InMemoryStorage(model: 0)
        var ranges: [ClosedRange<Int>] = []
        let subscription = start.publisher.zip(end.publisher).sink { first, last in
            guard let first, let last else { return }
            ranges.append(first...last)
        }

        start.set(model: 1)
        end.set(model: 2)
        start.set(model: 3)
        end.set(model: 4)

        XCTAssertEqual(ranges, [0...0, 1...2, 3...4])
        subscription.cancel()
    }

    func test_mainThreadInput_triggersActionOnceWhenValueBecomesValid() {
        let input = InMemoryStorage(model: "")
        var submissions: [String] = []
        let subscription = input.publisher
            .dropFirst()
            .compactMap { $0 }
            .filter { $0.count == 4 }
            .sink { submissions.append($0) }

        ["1", "12", "123", "1234"].forEach { input.set(model: $0) }

        XCTAssertEqual(submissions, ["1234"])
        subscription.cancel()
    }

    func test_equalValues_haveEqualHashesAfterWritesAndClear() {
        let first = InMemoryStorage(model: 0)
        let second = InMemoryStorage(model: 0)
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.hashValue, second.hashValue)

        first.set(model: 1)
        XCTAssertNotEqual(first, second)
        second.set(model: 1)
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.hashValue, second.hashValue)

        first.clear()
        second.clear()
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.hashValue, second.hashValue)
    }

    func test_separateInstances_doNotPublishEachOthersWrites() {
        let first = InMemoryStorage(model: 0)
        let second = InMemoryStorage(model: 0)
        var values: [Int?] = []
        let subscription = second.publisher.sink { values.append($0) }

        first.set(model: 1)

        XCTAssertEqual(values, [0])
        XCTAssertEqual(second.get(), 0)
        subscription.cancel()
    }

    func test_concurrentReadsWritesAndClears_keepWholeSnapshots() async {
        let storage = InMemoryStorage<Snapshot>()
        var values: [Snapshot?] = []
        let subscription = storage.publisher.sink {
            XCTAssertTrue(Thread.isMainThread)
            values.append($0)
        }

        performOffMain {
            let workers = DispatchGroup()
            for index in 0..<200 {
                workers.enter()
                let operation = DispatchWorkItem {
                    defer { workers.leave() }
                    if index.isMultiple(of: 3) {
                        storage.clear()
                    } else {
                        storage.set(model: Snapshot(first: index, second: index))
                    }
                    if let snapshot = storage.get() {
                        XCTAssertEqual(snapshot.first, snapshot.second)
                    }
                }
                DispatchQueue.global().async(execute: operation)
            }
            XCTAssertEqual(workers.wait(timeout: .now() + 5), .success)
        }
        storage.clear()
        await drainMainQueue()

        XCTAssertNil(storage.get())
        XCTAssertEqual(values.count, 202)
        XCTAssertTrue(values.allSatisfy { $0 == nil })
        subscription.cancel()
    }

    // Hold main while background writes commit, keeping their notifications queued.
    private func performOffMain(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ action: @escaping () -> Void
    ) {
        XCTAssertTrue(Thread.isMainThread, file: file, line: line)
        let finished = DispatchGroup()
        finished.enter()
        DispatchQueue.global().async {
            action()
            finished.leave()
        }
        XCTAssertEqual(finished.wait(timeout: .now() + 5), .success, file: file, line: line)
    }

    private func drainMainQueue() async {
        let drained = expectation(description: "Queued storage notifications delivered")
        DispatchQueue.main.async { drained.fulfill() }
        await fulfillment(of: [drained], timeout: 5)
    }

    private struct Snapshot: Hashable {
        let first: Int
        let second: Int
    }
}
