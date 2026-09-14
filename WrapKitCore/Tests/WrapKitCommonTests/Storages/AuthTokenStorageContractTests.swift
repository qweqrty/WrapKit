import Combine
import Foundation
import XCTest
@testable import WrapKit

final class AuthTokenStorageContractTests: XCTestCase {
    @MainActor
    func test_initialValue_matchesStorageAndPublisher() async {
        let backend = TokenKeychainDouble(value: "access-0")
        let storage = KeychainStorage(key: "access", keychain: backend)

        XCTAssertEqual(storage.get(), "access-0")
        let published = await firstValue(storage)
        XCTAssertEqual(published, "access-0")
    }

    @MainActor
    func test_successfulWrite_updatesStorageAndPublisher() async {
        let backend = TokenKeychainDouble(value: "access-0")
        let storage = KeychainStorage(key: "access", keychain: backend)

        let success = await result(storage.set(model: "access-1"))

        XCTAssertTrue(success)
        XCTAssertEqual(storage.get(), "access-1")
        let published = await firstValue(storage)
        XCTAssertEqual(published, "access-1")
    }

    @MainActor
    func test_failedWrite_keepsPreviousStorageAndPublisher() async {
        let backend = TokenKeychainDouble(value: "access-0", acceptsWrites: false)
        let storage = KeychainStorage(key: "access", keychain: backend)

        let success = await result(storage.set(model: "access-1"))

        XCTAssertFalse(success)
        XCTAssertEqual(storage.get(), "access-0")
        let published = await firstValue(storage)
        XCTAssertEqual(published, "access-0")
    }

    @MainActor
    func test_clear_removesStorageAndPublishedToken() async {
        let storage = KeychainStorage(key: "access", keychain: TokenKeychainDouble(value: "access-0"))

        let success = await result(storage.clear())

        XCTAssertTrue(success)
        XCTAssertNil(storage.get())
        let published = await firstValue(storage)
        XCTAssertNil(published)
    }

    @MainActor
    func test_failedClear_doesNotPublishLogoutThatWasNotPersisted() async {
        let backend = TokenKeychainDouble(value: "access-0", acceptsWrites: false)
        let storage = KeychainStorage(key: "access", keychain: backend)

        let success = await result(storage.clear())

        XCTAssertFalse(success)
        XCTAssertEqual(storage.get(), "access-0")
        let published = await firstValue(storage)
        XCTAssertEqual(published, "access-0")
    }

    @MainActor
    func test_secondStorageInstance_afterWrite_publishesTheSameTokenAsGet() async {
        let backend = TokenKeychainDouble(value: "access-0")
        let writer = KeychainStorage(key: "access", keychain: backend)
        let reader = KeychainStorage(key: "access", keychain: backend)

        let success = await result(writer.set(model: "access-1"))

        XCTAssertTrue(success)
        XCTAssertEqual(reader.get(), "access-1")
        let published = await firstValue(reader)
        XCTAssertEqual(published, reader.get(), "A second wrapper must not retain a stale in-memory token.")
    }

    @MainActor
    func test_secondStorageInstance_afterLogout_doesNotPublishClearedToken() async {
        let backend = TokenKeychainDouble(value: "access-0")
        let writer = KeychainStorage(key: "access", keychain: backend)
        let reader = KeychainStorage(key: "access", keychain: backend)

        let success = await result(writer.clear())

        XCTAssertTrue(success)
        XCTAssertNil(reader.get())
        let published = await firstValue(reader)
        XCTAssertNil(published, "A new subscriber must not receive the token of a logged-out session.")
    }

    @MainActor
    func test_recreatedStorage_readsLastPersistedToken() async {
        let backend = TokenKeychainDouble(value: "access-0")
        let writer = KeychainStorage(key: "access", keychain: backend)
        let success = await result(writer.set(model: "access-1"))
        let recreated = KeychainStorage(key: "access", keychain: backend)

        XCTAssertTrue(success)
        XCTAssertEqual(recreated.get(), "access-1")
        let published = await firstValue(recreated)
        XCTAssertEqual(published, "access-1")
    }

    @MainActor
    func test_existingSubscriber_onSecondInstance_receivesWriteAndLogout() async {
        let backend = TokenKeychainDouble(value: "access-0")
        let writer = KeychainStorage(key: "access", keychain: backend)
        let reader = KeychainStorage(key: "access", keychain: backend)
        let delivered = expectation(description: "Reader receives initial token, replacement and logout")
        delivered.expectedFulfillmentCount = 3
        var values: [String?] = []
        let subscription = reader.publisher.sink {
            values.append($0)
            delivered.fulfill()
        }

        let writeSucceeded = await result(writer.set(model: "access-1"))
        let clearSucceeded = await result(writer.clear())
        XCTAssertTrue(writeSucceeded)
        XCTAssertTrue(clearSucceeded)
        await fulfillment(of: [delivered], timeout: 2)
        subscription.cancel()

        XCTAssertEqual(values, ["access-0", "access-1", nil])
        XCTAssertNil(reader.get())
    }

    @MainActor
    func test_failedWriteAndClear_doNotEmitAnyAdditionalValue() async {
        let backend = TokenKeychainDouble(value: "access-0", acceptsWrites: false)
        let storage = KeychainStorage(key: "access", keychain: backend)
        var values: [String?] = []
        let initial = expectation(description: "Initial token")
        let subscription = storage.publisher.sink {
            values.append($0)
            initial.fulfill()
        }
        await fulfillment(of: [initial], timeout: 2)

        let writeSucceeded = await result(storage.set(model: "rejected"))
        let clearSucceeded = await result(storage.clear())
        XCTAssertFalse(writeSucceeded)
        XCTAssertFalse(clearSucceeded)
        let drained = expectation(description: "Pending publisher deliveries drained")
        DispatchQueue.main.async { drained.fulfill() }
        await fulfillment(of: [drained], timeout: 2)
        subscription.cancel()

        XCTAssertEqual(values, ["access-0"])
        XCTAssertEqual(storage.get(), "access-0")
    }

    @MainActor
    func test_equalKeysInDifferentBackends_doNotPublishEachOthersTokens() async {
        let writer = KeychainStorage(key: "access", keychain: TokenKeychainDouble(value: "first"))
        let reader = KeychainStorage(key: "access", keychain: TokenKeychainDouble(value: "second"))
        var values: [String?] = []
        let subscription = reader.publisher.sink { values.append($0) }

        let writeSucceeded = await result(writer.set(model: "new-first"))
        XCTAssertTrue(writeSucceeded)
        let drained = expectation(description: "Pending publisher deliveries drained")
        DispatchQueue.main.async { drained.fulfill() }
        await fulfillment(of: [drained], timeout: 2)
        subscription.cancel()

        XCTAssertEqual(values, ["second"])
        XCTAssertEqual(reader.get(), "second")
    }

    @MainActor
    func test_publisherSubscriber_canReadAndWriteStorageReentrantly() async {
        let storage = KeychainStorage(key: "access", keychain: TokenKeychainDouble(value: "initial"))
        let cleared = expectation(description: "Reentrant writes finish")
        var values: [String?] = []
        let subscription = storage.publisher.sink { value in
            values.append(value)
            XCTAssertEqual(storage.get(), value)
            if value == "initial" {
                storage.set(model: "replacement")
            } else if value == "replacement" {
                storage.clear()
            } else {
                cleared.fulfill()
            }
        }
        await fulfillment(of: [cleared], timeout: 2)
        subscription.cancel()

        XCTAssertEqual(values, ["initial", "replacement", nil])
    }

    func test_backgroundKeychainWrite_isVisibleBeforeReportingSuccess() {
        let storage = KeychainStorage(key: "access", keychain: TokenKeychainDouble(value: "initial"))
        let finished = expectation(description: "Background write committed")
        DispatchQueue.global().async {
            let subscription = storage.set(model: "replacement").sink { success in
                XCTAssertTrue(success)
                XCTAssertEqual(storage.get(), "replacement")
                finished.fulfill()
            }
            subscription.cancel()
        }
        wait(for: [finished], timeout: 2)
        XCTAssertEqual(storage.get(), "replacement")
    }

    func test_backgroundInMemoryWrite_isVisibleBeforeReportingSuccess() {
        let storage = InMemoryStorage(model: "initial")
        let finished = expectation(description: "Background write committed")
        DispatchQueue.global().async {
            let subscription = storage.set(model: "replacement").sink { success in
                XCTAssertTrue(success)
                XCTAssertEqual(storage.get(), "replacement")
                finished.fulfill()
            }
            subscription.cancel()
        }
        wait(for: [finished], timeout: 2)
        XCTAssertEqual(storage.get(), "replacement")
    }

    func test_queuedInMemoryWrite_doesNotReplayTokenAfterMainThreadClear() {
        let storage = InMemoryStorage(model: "initial")
        XCTAssertTrue(Thread.isMainThread)
        let backgroundWrite = DispatchGroup()
        backgroundWrite.enter()
        DispatchQueue.global().async {
            storage.set(model: "background-token")
            backgroundWrite.leave()
        }
        // Join without draining the main queue, so the background publication
        // remains pending when logout clears the model below.
        XCTAssertEqual(backgroundWrite.wait(timeout: .now() + 2), .success)
        storage.clear()
        var values: [String?] = []
        let subscription = storage.publisher.sink { values.append($0) }
        let drained = expectation(description: "Pending in-memory deliveries drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2)
        subscription.cancel()

        XCTAssertNil(storage.get())
        XCTAssertFalse(values.isEmpty)
        XCTAssertTrue(values.allSatisfy { $0 == nil })
    }

    @MainActor
    private func firstValue(_ storage: KeychainStorage) async -> String? {
        let delivered = expectation(description: "Storage publisher emitted its current value")
        var value: String?
        let subscription = storage.publisher.prefix(1).sink {
            value = $0
            delivered.fulfill()
        }
        await fulfillment(of: [delivered], timeout: 2)
        subscription.cancel()
        return value
    }

    @MainActor
    private func result(_ publisher: AnyPublisher<Bool, Never>) async -> Bool {
        let delivered = expectation(description: "Storage write finished")
        var success = false
        let subscription = publisher.prefix(1).sink {
            success = $0
            delivered.fulfill()
        }
        await fulfillment(of: [delivered], timeout: 2)
        subscription.cancel()
        return success
    }
}

private final class TokenKeychainDouble: Keychain {
    private let lock = NSLock()
    private var value: String?
    private let acceptsWrites: Bool

    init(value: String?, acceptsWrites: Bool = true) {
        self.value = value
        self.acceptsWrites = acceptsWrites
    }

    func get(_ key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    func set(_ value: String, forKey key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard acceptsWrites else { return false }
        self.value = value
        return true
    }

    func delete(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard acceptsWrites else { return false }
        value = nil
        return true
    }
}
