//
//  KeychainStorageTests.swift
//  WrapKitAuthTests
//
//  Created by Stas Lee on 1/7/23.
//

import XCTest
import WrapKit

class KeychainStorageTests: XCTestCase {
    
    func test_get_retrievesStoredValue() {
        let (sut, mockKeychain) = makeSUT()
        
        mockKeychain.store["test-key"] = "stored-value"
        
        XCTAssertEqual(sut.get(), "stored-value")
    }
    
    func test_set_storesValue() {
        let (sut, mockKeychain) = makeSUT()
        
        sut.set("new-value")
        
        XCTAssertEqual(mockKeychain.store["test-key"], "new-value")
    }

    func test_clear_removesValue() {
        let (sut, mockKeychain) = makeSUT()
        mockKeychain.store["test-key"] = "value-to-be-cleared"
        
        sut.clear()
        
        XCTAssertNil(mockKeychain.store["test-key"])
    }

    func test_addObserver_notifiesWithCurrentValue() {
        let (sut, mockKeychain) = makeSUT()
        mockKeychain.store["test-key"] = "current-value"
        
        var receivedValue: String?
        sut.addObserver(for: self) { value in
            receivedValue = value
        }
        
        XCTAssertEqual(receivedValue, "current-value")
    }

    // MARK: - Helpers
    
    func makeSUT() -> (sut: KeychainStorage, mockKeychain: MockKeychain) {
        let mockKeychain = MockKeychain()
        let sut = KeychainStorage(key: "test-key", keychain: mockKeychain)
        return (sut, mockKeychain)
    }
    
    class MockKeychain: Keychain {
        var store = [String: String]()
        
        func get(_ key: String) -> String? {
            return store[key]
        }
        
        func set(_ value: String, forKey key: String) -> Bool {
            store[key] = value
            return true
        }
        
        func delete(_ key: String) -> Bool {
            store.removeValue(forKey: key)
            return true
        }
    }
}
