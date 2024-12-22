import XCTest
import Combine
import WrapKit

class InMemoryStorageTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    func test_get_returnsInitialModel() {
        let initialModel = "TestModel"
        let (sut, _) = makeSUT(model: initialModel)
        
        XCTAssertEqual(sut.get(), initialModel)
    }
    
    func test_set_updatesModel() {
        let (sut, _) = makeSUT(model: "Initial")
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
        let (sut, _) = makeSUT(model: "ToBeCleared")
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
        let (sut, _) = makeSUT(model: "Initial")
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

extension InMemoryStorageTests {
    // MARK: - Helpers
    func makeSUT<Model: Hashable>(model: Model? = nil, file: StaticString = #file, line: UInt = #line) -> (sut: InMemoryStorage<Model>, mockStorage: MockInMemoryStorage<Model>) {
        let mockStorage = MockInMemoryStorage<Model>(model: model)
        let sut = InMemoryStorage<Model>(model: model)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(mockStorage, file: file, line: line)
        return (sut, mockStorage)
    }

    // MARK: - MockInMemoryStorage
    class MockInMemoryStorage<Model: Hashable>: Storage, Hashable {
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
            store = model
            subject.send(model)
            return Just(true).eraseToAnyPublisher()
        }

        @discardableResult
        func clear() -> AnyPublisher<Bool, Never> {
            set(model: nil)
        }

        static func == (lhs: MockInMemoryStorage<Model>, rhs: MockInMemoryStorage<Model>) -> Bool {
            return lhs.store == rhs.store
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(store)
        }
    }
}
