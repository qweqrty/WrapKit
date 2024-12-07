import XCTest
import Combine
@testable import WrapKit

final class UserDefaultsStorageTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    struct TestModel: Codable, Hashable {
        let id: Int
        let name: String
    }
    
    func testInitializationAndGet() {
        // Arrange
        let userDefaults = UserDefaults(suiteName: "testInitializationAndGet")!
        defer { userDefaults.removePersistentDomain(forName: "testInitializationAndGet") }
        
        let storage = UserDefaultsStorage<TestModel>(
            key: "testKey",
            userDefaults: userDefaults,
            getLogic: { defaults in
                guard let data = defaults.data(forKey: "testKey"),
                      let model = try? JSONDecoder().decode(TestModel.self, from: data) else {
                    return nil
                }
                return model
            },
            setLogic: { defaults, model in
                if let model = model {
                    let data = try? JSONEncoder().encode(model)
                    defaults.set(data, forKey: "testKey")
                } else {
                    defaults.removeObject(forKey: "testKey")
                }
            }
        )
        
        // Act
        let retrievedModel = storage.get()
        
        // Assert
        XCTAssertNil(retrievedModel, "Expected initial value to be nil")
    }
    
    func testSetAndGet() {
        // Arrange
        let userDefaults = UserDefaults(suiteName: "testSetAndGet")!
        defer { userDefaults.removePersistentDomain(forName: "testSetAndGet") }
        
        let storage = UserDefaultsStorage<TestModel>(
            key: "testKey",
            userDefaults: userDefaults,
            getLogic: { defaults in
                guard let data = defaults.data(forKey: "testKey"),
                      let model = try? JSONDecoder().decode(TestModel.self, from: data) else {
                    return nil
                }
                return model
            },
            setLogic: { defaults, model in
                if let model = model {
                    let data = try? JSONEncoder().encode(model)
                    defaults.set(data, forKey: "testKey")
                } else {
                    defaults.removeObject(forKey: "testKey")
                }
            }
        )
        
        let testModel = TestModel(id: 1, name: "Test")
        
        // Act
        let expectation = self.expectation(description: "Set value")
        storage.set(model: testModel)
            .sink { success in
                XCTAssertTrue(success, "Expected set to succeed")
                let retrievedModel = storage.get()
                XCTAssertEqual(retrievedModel, testModel, "Expected retrieved model to match the set model")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testClear() {
        // Arrange
        let userDefaults = UserDefaults(suiteName: "testClear")!
        defer { userDefaults.removePersistentDomain(forName: "testClear") }
        
        let storage = UserDefaultsStorage<TestModel>(
            key: "testKey",
            userDefaults: userDefaults,
            getLogic: { defaults in
                guard let data = defaults.data(forKey: "testKey"),
                      let model = try? JSONDecoder().decode(TestModel.self, from: data) else {
                    return nil
                }
                return model
            },
            setLogic: { defaults, model in
                if let model = model {
                    let data = try? JSONEncoder().encode(model)
                    defaults.set(data, forKey: "testKey")
                } else {
                    defaults.removeObject(forKey: "testKey")
                }
            }
        )
        
        let testModel = TestModel(id: 1, name: "Test")
        storage.set(model: testModel)
            .sink { _ in }
            .store(in: &cancellables)
        
        // Act
        let expectation = self.expectation(description: "Clear value")
        storage.clear()
            .sink { success in
                XCTAssertTrue(success, "Expected clear to succeed")
                let retrievedModel = storage.get()
                XCTAssertNil(retrievedModel, "Expected value to be nil after clearing")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPublisher() {
        // Arrange
        let userDefaults = UserDefaults(suiteName: "testPublisher")!
        defer { userDefaults.removePersistentDomain(forName: "testPublisher") }
        
        let storage = UserDefaultsStorage<TestModel>(
            key: "testKey",
            userDefaults: userDefaults,
            getLogic: { defaults in
                guard let data = defaults.data(forKey: "testKey"),
                      let model = try? JSONDecoder().decode(TestModel.self, from: data) else {
                    return nil
                }
                return model
            },
            setLogic: { defaults, model in
                if let model = model {
                    let data = try? JSONEncoder().encode(model)
                    defaults.set(data, forKey: "testKey")
                } else {
                    defaults.removeObject(forKey: "testKey")
                }
            }
        )
        
        let testModel = TestModel(id: 1, name: "Test")
        let expectation = self.expectation(description: "Publisher emits new value")
        
        // Act
        storage.publisher
            .sink { value in
                if value == testModel {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        storage.set(model: testModel)
            .sink { _ in }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
