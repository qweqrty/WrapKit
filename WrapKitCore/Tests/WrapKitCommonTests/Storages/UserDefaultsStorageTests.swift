//
//  UserDefaultsStorageTests.swift
//  WrapKitTests
//
//  Created by Stanislav Li on 4/4/24.
//

import XCTest
import WrapKit

class UserDefaultsStorageTests: XCTestCase {
    
    var storage: UserDefaultsStorage<[String]>!
    let testKey = "test"
    var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Use a volatile domain to prevent polluting the actual user defaults.
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        storage = UserDefaultsStorage<[String]>(
            userDefaults: userDefaults,
            key: testKey,
            getLogic: { [testKey] userDefaults in
                userDefaults.stringArray(forKey: testKey)
            },
            setLogic: { [testKey] userDefaults, object in
                userDefaults.set(object, forKey: testKey)
            }
        )
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        storage = nil
        try super.tearDownWithError()
    }

    func testSaveAndRetrieveModel() {
        let testModel = ["test"]
        let expectation = self.expectation(description: "Save and retrieve the model")
        
        storage.set(model: testModel) { success in
            XCTAssertTrue(success)
            if let retrievedModel: [String] = self.storage.get() {
                XCTAssertEqual(retrievedModel, testModel)
            } else {
                XCTFail("Model could not be retrieved")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(testModel, storage.get())
    }
    
    func testSaveAndRetrieveNilModel() {
        let expectation = self.expectation(description: "Save and retrieve nil for the model")
        
        storage.set(model: nil) { success in
            XCTAssertTrue(success)
            XCTAssertNil(self.storage.get())
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testObserverNotificationOnSave() {
        let testModel = ["test"]
        let expectation = self.expectation(description: "Observer is notified when model is saved")
        
        storage.addObserver(for: self) { model in
            if let model = model {
                XCTAssertEqual(model, testModel)
                expectation.fulfill()
            }
        }
        
        storage.set(model: testModel, completion: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testClearModel() {
        let testModel = ["test"]
        storage.set(model: testModel, completion: nil)
        
        let expectation = self.expectation(description: "Model is cleared")
        
        storage.clear { success in
            XCTAssertTrue(success)
            XCTAssertNil(self.storage.get())
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
//    func testEncodingFailure() {
//        let expectation = self.expectation(description: "Handle encoding failure")
//        
//        // Inject a failing JSONEncoder by subclassing or using dependency injection
//        // ...
//
//        storage.set(model: FailingTestModel()) { success in
//            XCTAssertFalse(success)
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
    
    // Add additional tests for other edge cases such as decoding failure, observer removal, etc.
    
    // Mock models for testing
    struct TestModel: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    struct FailingTestModel: Codable {
        func encode(to encoder: Encoder) throws {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Test encoding failure"))
        }
    }
}
