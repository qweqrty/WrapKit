////
////  KeychainStorageTests.swift
////  WrapKitAuthTests
////
////  Created by Stas Lee on 1/7/23.
////
//
//import Combine
//import XCTest
//import WrapKit
//import WrapKitTestUtils
//
//class KeychainStorageTests: XCTestCase {
//    private static let key = "test"
//    
//    func test_get_whenKeyExists_returnsValue() {
//        // Given
//        let (sut, _) = makeSUT()
//        
//        assert(publisher: sut.set(model: "newValue"), emits: true)
//        
//        // When
//        assert(publisher: sut.publisher, emits: "newValue")
//    }
////    
////    func test_set_whenSettingValue_savesValueToKeychain() {
////        // Given
////        let (sut, mockKeychain) = makeSUT()
////        
////        // When
////        assert(publisher: sut.set(model: "newValue"), emits: true)
////        
////        // Then
////        assert(publisher: sut.publisher, emits: "newValue")
////        XCTAssertEqual(mockKeychain.get(Self.key), "newValue")
////    }
////    
////    func test_set_whenDeletingValue_removesValueFromKeychain() {
////        // Given
////        let (sut, mockKeychain) = makeSUT()
////        
////        // First set a value
////        assert(publisher: sut.set(model: "testValue"), emits: true)
////        
////        // When deleting the value
////        assert(publisher: sut.set(model: nil), emits: true)
////        
////        // Then
////        assert(publisher: sut.publisher, emits: nil)
////        XCTAssertNil(mockKeychain.get(Self.key))
////    }
////    
////    func test_publisher_emitsValuesOnChange() {
////        // Given
////        let (sut, _) = makeSUT()
////        
////        // Initial state should be nil
////        assert(publisher: sut.publisher, emits: nil)
////        
////        // When
////        assert(publisher: sut.set(model: "firstValue"), emits: true)
////        
////        // Then
////        assert(publisher: sut.publisher, emits: "firstValue")
////        
////        // When
////        assert(publisher: sut.set(model: "secondValue"), emits: true)
////        
////        // Then
////        assert(publisher: sut.publisher, emits: "secondValue")
////        
////        // When
////        assert(publisher: sut.set(model: nil), emits: true)
////        
////        // Then
////        assert(publisher: sut.publisher, emits: nil)
////    }
////    
////    func test_threadSafety_whenAccessingConcurrently() {
////        // Given
////        let bag = ThreadSafeBag()
////        let fullfillCount = 10
////        let (sut, _) = makeSUT()
////        let exp = expectation(description: "Concurrent access should complete")
////        exp.expectedFulfillmentCount = fullfillCount
////
////        // When
////        DispatchQueue.global().async {
////            for index in 0..<10 {
////                let cancellable = sut.set(model: "value\(index)")
////                    .sink { isSuccess in
////                        XCTAssertTrue(isSuccess, "Setting value should succeed")
////                        exp.fulfill()
////                    }
////                
////                bag.store(cancellable)
////            }
////        }
////
////        wait(for: [exp], timeout: 2.0)
////
////        // Then
////        let finalValue = sut.get()
////        let expectedValue = "value\(fullfillCount - 1)"
////        XCTAssertEqual(finalValue, expectedValue, "Final value should be from the last operation \(expectedValue)")
////    }
//
//    // MARK: - Helpers
//    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: KeychainStorage, mockKeychain: KeychainSwift) {
//        let mockKeychain = KeychainSwift()
//        let sut = KeychainStorage(key: Self.key, keychain: mockKeychain)
//        checkForMemoryLeaks(sut, file: file, line: line)
//        checkForMemoryLeaks(mockKeychain, file: file, line: line)
//        return (sut, mockKeychain)
//    }
//    
//}
