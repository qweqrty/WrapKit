import XCTest
@testable import WrapKit
import CoreData
import Combine

struct User: Equatable {
    let name: String
    let age: Int
}

// Core Data Entity Model
final class UserCoreDataModel: NSManagedObject, CoreDataConvertible {
    typealias DomainModel = User

    @NSManaged var name: String
    @NSManaged var age: Int32

    func toDomainModel() -> User {
        return User(name: name, age: Int(age))
    }

    static func fromDomainModel(_ model: User, context: NSManagedObjectContext) -> UserCoreDataModel {
        let user = UserCoreDataModel(context: context)
        user.name = model.name
        user.age = Int32(model.age)
        return user
    }
}


// CoreDataStorage Test Setup
class CoreDataStorageTests: XCTestCase {
    var storage: CoreDataStorage<User, UserCoreDataModel>!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        storage = CoreDataStorage<User, UserCoreDataModel>(
            storeURL: URL(string: "dev/null")!,
            entityName: "UserCoreDataModel"
        )
    }

    func testCoreDataStorageSetAndGet() throws {
        // Create a test user
        let testUser = User(name: "John Doe", age: 30)

        // Set the user in CoreDataStorage
        let setExpectation = self.expectation(description: "Set user")
        storage.set(model: testUser)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Failed to set user: \(error.localizedDescription)")
                }
            }, receiveValue: { success in
                XCTAssertTrue(success, "Failed to set user")
                setExpectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [setExpectation], timeout: 5.0)

        // Retrieve the user and validate
        let fetchExpectation = self.expectation(description: "Fetch user")
        
        // 2. Пытаемся извлечь данные через метод `get()`
        let retrievedUser = storage.get()
        
        // 3. Проверяем, что данные извлечены корректно
        XCTAssertNotNil(retrievedUser, "No user retrieved from storage")
        XCTAssertEqual(retrievedUser, testUser, "Retrieved user does not match the expected user")
        wait(for: [fetchExpectation], timeout: 5.0)
    }
}
