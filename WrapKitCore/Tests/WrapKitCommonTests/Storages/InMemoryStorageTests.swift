import XCTest
import Combine
@testable import WrapKit

final class InMemoryStorageTests: XCTestCase {
    var storage: InMemoryStorage<String>!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        storage = InMemoryStorage<String>()
        cancellables = []
    }

    override func tearDown() {
        storage = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialValueIsNil() {
        XCTAssertNil(storage.get(), "Initial value should be nil")
    }

    func testSetValue() {
        let expectation = self.expectation(description: "Value set successfully")
        let testValue = "Hello, World!"

        storage.set(model: testValue)
            .sink { success in
                XCTAssertTrue(success, "Setting value should return true")
                XCTAssertEqual(self.storage.get(), testValue, "Stored value does not match expected value")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testClearValue() {
        let setExpectation = self.expectation(description: "Value set successfully")
        let clearExpectation = self.expectation(description: "Value cleared successfully")
        let testValue = "Temporary Value"

        // Set a value
        storage.set(model: testValue)
            .sink { success in
                XCTAssertTrue(success, "Setting value should return true")
                XCTAssertEqual(self.storage.get(), testValue, "Stored value does not match expected value")
                setExpectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [setExpectation], timeout: 1.0)

        // Clear the value
        storage.clear()
            .sink { success in
                XCTAssertTrue(success, "Clearing value should return true")
                XCTAssertNil(self.storage.get(), "Value should be nil after clearing")
                clearExpectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [clearExpectation], timeout: 1.0)
    }

    func testPublisherUpdatesOnSet() {
        let expectation = self.expectation(description: "Publisher emits new value")
        let testValue = "Updated Value"

        // Subscribe to the publisher to observe changes
        storage.publisher
            .dropFirst() // Ignore the initial nil value
            .sink { newValue in
                XCTAssertEqual(newValue, testValue, "Publisher emitted value does not match the set value")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Set the value in storage
        storage.set(model: testValue)
            .sink { _ in } // Simply consume the completion to keep the subscription active
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testPublisherUpdatesOnClear() {
        let expectation = self.expectation(description: "Publisher emits nil after clearing")

        // Subscribe to the publisher to observe changes
        storage.publisher
            .dropFirst() // Ignore the initial nil value
            .sink { newValue in
                XCTAssertNil(newValue, "Publisher emitted value should be nil after clearing")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Clear the storage
        storage.clear()
            .sink { _ in } // Simply consume the completion to keep the subscription active
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
