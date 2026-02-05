import Combine
import XCTest
import ObjectiveC

public extension XCTestCase {
    func XCTAssertEventually(
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line,
        _ condition: @escaping () -> Bool
    ) {
        let exp = XCTestExpectation(description: "Eventually")
        let deadline = Date().addingTimeInterval(timeout)
        
        func poll() {
            if condition() {
                exp.fulfill()
            } else if Date() < deadline {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: poll)
            }
        }
        
        DispatchQueue.main.async(execute: poll)
        XCTWaiter().wait(for: [exp], timeout: timeout + 0.1)
        
        if !condition() {
            XCTFail("Condition not met", file: file, line: line)
        }
    }
    
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

// Screenshot
private enum ScreenshotAssoc {
    static var indexKey: UInt8 = 0
}

public extension XCTestCase {

    private var screenshotIndex: Int {
        get { (objc_getAssociatedObject(self, &ScreenshotAssoc.indexKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &ScreenshotAssoc.indexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func takeScreenshot(
        named name: String? = nil,
        after delay: TimeInterval = 0.3,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if delay > 0 {
            RunLoop.main.run(until: Date().addingTimeInterval(delay))
        }

        let screenshot = XCUIScreen.main.screenshot()

        screenshotIndex += 1
        let autoName = String(format: "%03d", screenshotIndex)
        let finalName = name.map { "\(autoName)_\($0)" } ?? autoName

        let testFileURL = URL(fileURLWithPath: String(describing: file))
        let testFolderURL = testFileURL.deletingLastPathComponent()

        let testClass = String(describing: type(of: self))
        let testName = self.name
            .components(separatedBy: " ")
            .last?
            .replacingOccurrences(of: "]", with: "")
            ?? "UnknownTest"

        let screenshotsFolder = testFolderURL
            .appendingPathComponent(testClass, isDirectory: true)
            .appendingPathComponent(testName, isDirectory: true)

        do {
            try FileManager.default.createDirectory(
                at: screenshotsFolder,
                withIntermediateDirectories: true
            )

            let fileURL = screenshotsFolder.appendingPathComponent("\(finalName).png")
            try screenshot.pngRepresentation.write(to: fileURL, options: .atomic)
            print("📸 Screenshot saved: \(fileURL.path)")
        } catch {
            XCTFail("Failed to save screenshot: \(error)", file: file, line: line)
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
