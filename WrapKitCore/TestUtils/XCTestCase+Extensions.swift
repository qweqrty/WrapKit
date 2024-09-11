import Combine
import XCTest

public extension XCTestCase {
    func makeURL(_ string: String = "https://some-given-url.com", file: StaticString = #file, line: UInt = #line) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Could not create URL for \(string)", file: file, line: line)
        }
        return url
    }
    
    func makeError(_ str: String = "uh oh, something went wrong") -> NSError {
        return NSError(domain: "TEST_ERROR", code: -1, userInfo: [NSLocalizedDescriptionKey: str])
    }
    
    func makeData(isEmpty: Bool = false) -> Data {
        return isEmpty ? Data() : Data("any data".utf8)
    }
    
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

// Thread-safe container for cancellables
public class ThreadSafeBag {
    private var lock: NSLock
    private var cancellables: Set<AnyCancellable>
    
    public init(lock: NSLock = NSLock(), cancellables: Set<AnyCancellable> = Set<AnyCancellable>()) {
        self.lock = lock
        self.cancellables = cancellables
    }
    
    public func store(_ cancellable: AnyCancellable) {
        lock.lock()
        defer { lock.unlock() }
        cancellables.insert(cancellable)
    }
}

public extension XCTestCase {
    func assert<Output: Equatable>(
        publisher: AnyPublisher<Output, Never>,
        emits expectedValue: Output,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Value should be set")
        var bag = Set<AnyCancellable>()
        publisher.sink { value in
            XCTAssertEqual(value, expectedValue, file: file, line: line)
            exp.fulfill()
        }
        .store(in: &bag)
        wait(for: [exp], timeout: 0.5)
    }
}
