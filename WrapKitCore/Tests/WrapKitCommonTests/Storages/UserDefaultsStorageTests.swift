import XCTest
import WrapKit
import Combine

class UserDefaultsStorageTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    func test_get_returnsInitialModel() {
        let initialModel = "TestModel"
        let (sut, _) = makeUserDefaultsSUT(model: initialModel)

        XCTAssertEqual(sut.get(), initialModel)
    }

    func test_set_updatesModel() {
        let (sut, _) = makeUserDefaultsSUT(model: "Initial")
        let expectation = XCTestExpectation(description: "Set model")

        sut.set(model: "Updated")
            .sink { success in
                XCTAssertTrue(success)
                XCTAssertEqual(sut.get(), "Updated")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_clear_removesModel() {
        let (sut, _) = makeUserDefaultsSUT(model: "ToBeCleared")
        let expectation = XCTestExpectation(description: "Clear model")

        sut.clear()
            .sink { success in
                XCTAssertTrue(success)
                XCTAssertNil(sut.get())
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_publisher_emitsChanges() {
        let (sut, _) = makeUserDefaultsSUT(model: "Initial")
        let expectation = XCTestExpectation(description: "Publisher emits changes")
        var receivedValues: [String] = []

        sut.publisher
            .compactMap { $0 }
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.set(model: "FirstUpdate")
        sut.set(model: "SecondUpdate")

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, ["Initial", "FirstUpdate", "SecondUpdate"])
    }
}

extension UserDefaultsStorageTests {
    // MARK: - Helpers
    func makeUserDefaultsSUT<Model: Codable & Hashable>(
        model: Model? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: UserDefaultsStorage<Model>, mockStorage: MockUserDefaultsStorage<Model>) {
        let mockStorage = MockUserDefaultsStorage<Model>(model: model)
        let sut = UserDefaultsStorage<Model>(
            key: "testKey",
            getLogic: { _ in mockStorage.get() },
            setLogic: { _, model in mockStorage.set(model: model) }
        )
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(mockStorage, file: file, line: line)
        return (sut, mockStorage)
    }

    // MARK: - MockUserDefaultsStorage
    class MockUserDefaultsStorage<Model: Codable & Hashable>: Storage, Hashable {
        private var store: Model?
        private let subject: CurrentValueSubject<Model?, Never>

        init(model: Model? = nil) {
            self.store = model
            self.subject = CurrentValueSubject(model)
        }

        var publisher: AnyPublisher<Model?, Never> {
            subject
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        func get() -> Model? {
            return store
        }

        @discardableResult
        func set(model: Model?) -> AnyPublisher<Bool, Never> {
            return Future<Bool, Never> { [weak self] promise in
                guard let self = self else {
                    promise(.success(false))
                    return
                }
                self.store = model
                self.subject.send(model)
                promise(.success(true))
            }
            .eraseToAnyPublisher()
        }


        @discardableResult
        func clear() -> AnyPublisher<Bool, Never> {
            return set(model: nil)
        }

        static func == (lhs: MockUserDefaultsStorage<Model>, rhs: MockUserDefaultsStorage<Model>) -> Bool {
            return lhs.store == rhs.store
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(store)
        }
    }

}
