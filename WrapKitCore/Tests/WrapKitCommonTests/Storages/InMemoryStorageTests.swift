////
////  InMemoryStorageTests.swift
////  WrapKit
////
////  Created by Stanislav Li on 17/9/23.
////
//
//import XCTest
//import WrapKit
//
//class InMemoryStorageTests: XCTestCase {
//    
//    func test_get_returnsInitialModelValue() {
//        let initialModel = "InitialValue"
//        let sut = makeSUT(model: initialModel)
//        
//        XCTAssertEqual(sut.get(), initialModel)
//    }
//    
//    func test_set_updatesModelValue() {
//        let sut = makeSUT()
//        
//        let newValue = "NewValue"
//        sut.set(model: newValue, completion: nil)
//        
//        XCTAssertEqual(sut.get(), newValue)
//    }
//    
//    func test_clear_resetsModelValue() {
//        let sut = makeSUT(model: "InitialValue")
//        
//        sut.clear(completion: nil)
//        
//        XCTAssertNil(sut.get())
//    }
//    
//    // MARK: - Tests for Observer functionality
//    
//    func test_modelUpdatesInvokeObserver() {
//        let sut = makeSUT()
//        var receivedValue: String? = nil
//        
//        sut.addObserver(for: self) { model in
//            receivedValue = model
//        }
//        
//        let newValue = "NewValue"
//        sut.set(model: newValue, completion: nil)
//        
//        XCTAssertEqual(receivedValue, newValue)
//    }
//    
//    func test_observerIsRemovedWhenClientIsDeallocated() {
//        let sut = makeSUT()
//        var receivedValue: String? = "InitialValue"
//        
//        autoreleasepool {
//            let temporaryClient = NSObject()
//            sut.addObserver(for: temporaryClient) { model in
//                receivedValue = model
//            }
//            sut.set(model: "FirstChange", completion: nil)
//        }
//        
//        XCTAssertEqual(receivedValue, "FirstChange")
//        
//        sut.set(model: "SecondChange", completion: nil)
//        XCTAssertEqual(receivedValue, "FirstChange") // It shouldn't change since the observer was removed.
//    }
//    
//    // MARK: - Helper methods
//    
//    private func makeSUT(model: String? = nil) -> InMemoryStorage<String> {
//        return InMemoryStorage<String>(model: model)
//    }
//}
//
//extension InMemoryStorageTests {
//    private func makeSUT() -> InMemoryStorage<String> {
//        return InMemoryStorage<String>(model: nil)
//    }
//}
