import Combine
import Foundation
import XCTest
@testable import WrapKit

final class AuthTokenKeychainIntegrationTests: XCTestCase {
    func test_realKeychain_sameInstance_concurrentReadsAndWritesFinishWithValidTokens() {
        assertConcurrentAccess(usesSeparateInstances: false)
    }

    func test_realKeychain_separateInstances_concurrentReadsNeverObserveMissingOrPartialToken() {
        assertConcurrentAccess(usesSeparateInstances: true)
    }

    private func assertConcurrentAccess(usesSeparateInstances: Bool) {
        let prefix = "MYO-7572.\(UUID().uuidString)."
        let keychain = KeychainSwift(keyPrefix: prefix)
        defer { keychain.delete("concurrent-access") }
        guard keychain.set("test-seed", forKey: "concurrent-access") else {
            XCTFail("Cannot seed the isolated test account. OSStatus: \(keychain.lastResultCode)")
            return
        }
        let workerCount = 6
        let iterations = 20
        let validTokens = Set(["test-seed"] + (0..<workerCount).flatMap { worker in
            (0..<iterations).map { "test-\(worker)-\($0)" }
        })
        let observations = ConcurrentKeychainObservations()

        // This synchronous XCTest deliberately uses concurrent GCD callers of
        // the legacy API. Only the counters are locked by the helper; Keychain
        // operations contend on the original instance's own synchronization.
        DispatchQueue.concurrentPerform(iterations: workerCount) { worker in
            let keychain = usesSeparateInstances ? KeychainSwift(keyPrefix: prefix) : keychain
            observations.started()
            defer { observations.finished() }
            for iteration in 0..<iterations {
                let before = keychain.get("concurrent-access")
                observations.read(valid: before.map(validTokens.contains) ?? false)
                let saved = keychain.set("test-\(worker)-\(iteration)", forKey: "concurrent-access")
                observations.write(succeeded: saved)
                let after = keychain.get("concurrent-access")
                observations.read(valid: after.map(validTokens.contains) ?? false)
            }
        }

        XCTAssertEqual(observations.completedWorkers, workerCount)
        XCTAssertGreaterThan(observations.peakWorkers, 1, "The run must actually exercise overlapping callers")
        XCTAssertEqual(observations.successfulWrites, workerCount * iterations)
        XCTAssertEqual(observations.validReads, workerCount * iterations * 2)
        print("KEYCHAIN_CONCURRENCY separate=\(usesSeparateInstances) completed=\(observations.completedWorkers) peak=\(observations.peakWorkers) writes=\(observations.successfulWrites) reads=\(observations.validReads)")
        XCTAssertTrue(keychain.set("test-final", forKey: "concurrent-access"))
        XCTAssertEqual(keychain.get("concurrent-access"), "test-final")
    }

    @MainActor
    func test_realKeychain_recreatedStoresReadTheSavedAccessAndRefreshTokens() async {
        let keychain = KeychainSwift(keyPrefix: "MYO-7572.\(UUID().uuidString).")
        defer {
            // Never use KeychainSwift.clear(): it does not respect keyPrefix.
            keychain.delete("access")
            keychain.delete("refresh")
        }
        let access = KeychainStorage(key: "access", keychain: keychain)
        let refresh = KeychainStorage(key: "refresh", keychain: keychain)
        let accessSaved = await result(access.set(model: "test-access-1"))
        let refreshSaved = await result(refresh.set(model: "test-refresh-1"))

        XCTAssertTrue(accessSaved, "Test runner needs access to its own Keychain. OSStatus: \(keychain.lastResultCode)")
        XCTAssertTrue(refreshSaved)
        XCTAssertEqual(KeychainStorage(key: "access", keychain: keychain).get(), "test-access-1")
        XCTAssertEqual(KeychainStorage(key: "refresh", keychain: keychain).get(), "test-refresh-1")
    }

    @MainActor
    func test_realKeychain_logoutDeletesOnlyTheTwoTestTokenAccounts() async {
        let prefix = "MYO-7572.\(UUID().uuidString)."
        let keychain = KeychainSwift(keyPrefix: prefix)
        defer {
            keychain.delete("access")
            keychain.delete("refresh")
            keychain.delete("sentinel")
        }
        XCTAssertTrue(keychain.set("unrelated-test-value", forKey: "sentinel"))
        let access = KeychainStorage(key: "access", keychain: keychain)
        let refresh = KeychainStorage(key: "refresh", keychain: keychain)
        let accessSaved = await result(access.set(model: "test-access"))
        let refreshSaved = await result(refresh.set(model: "test-refresh"))
        XCTAssertTrue(accessSaved)
        XCTAssertTrue(refreshSaved)

        let accessCleared = await result(access.clear())
        let refreshCleared = await result(refresh.clear())

        XCTAssertTrue(accessCleared)
        XCTAssertTrue(refreshCleared)
        XCTAssertNil(KeychainStorage(key: "access", keychain: keychain).get())
        XCTAssertNil(KeychainStorage(key: "refresh", keychain: keychain).get())
        XCTAssertEqual(keychain.get("sentinel"), "unrelated-test-value")
    }

    @MainActor
    private func result(_ publisher: AnyPublisher<Bool, Never>) async -> Bool {
        let delivered = expectation(description: "Keychain operation finished")
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

private final class ConcurrentKeychainObservations {
    // Writes are protected below; the test reads totals only after
    // concurrentPerform has joined every worker.
    private let lock = NSLock()
    private var activeWorkers = 0
    private(set) var peakWorkers = 0
    private(set) var completedWorkers = 0
    private(set) var successfulWrites = 0
    private(set) var validReads = 0

    func started() {
        lock.lock()
        defer { lock.unlock() }
        activeWorkers += 1
        peakWorkers = max(peakWorkers, activeWorkers)
    }

    func finished() {
        lock.lock()
        defer { lock.unlock() }
        activeWorkers -= 1
        completedWorkers += 1
    }

    func write(succeeded: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if succeeded { successfulWrites += 1 }
    }

    func read(valid: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if valid { validReads += 1 }
    }
}
