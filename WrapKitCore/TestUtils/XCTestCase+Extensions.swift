import Combine
import XCTest
import ObjectiveC

// MARK: - Common test helpers

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
        NSError(domain: "TEST_ERROR", code: -1, userInfo: [NSLocalizedDescriptionKey: str])
    }

    func makeData(isEmpty: Bool = false) -> Data {
        isEmpty ? Data() : Data("any data".utf8)
    }

    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

// MARK: - Screenshot counter (per test)

private enum ScreenshotAssoc {
    static var indexKey: UInt8 = 0
}

public extension XCTestCase {

    private var screenshotIndex: Int {
        get { (objc_getAssociatedObject(self, &ScreenshotAssoc.indexKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &ScreenshotAssoc.indexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Keep compatibility with old calls.
    func takeScreenshot(
        named name: String? = nil,
        after delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _takeScreenshotImpl(named: name, after: delay, file: file, line: line)
    }

    /// Collision-proof alias (use in new tests to avoid any external takeScreenshot() collisions).
    func takeFlowScreenshot(
        named name: String? = nil,
        after delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _takeScreenshotImpl(named: name, after: delay, file: file, line: line)
    }

    private func _takeScreenshotImpl(
        named name: String?,
        after delay: TimeInterval,
        file: StaticString,
        line: UInt
    ) {
        if delay > 0 {
            RunLoop.main.run(until: Date().addingTimeInterval(delay))
        }

        let screenshot = XCUIScreen.main.screenshot()

        screenshotIndex += 1
        let seq = String(format: "%03d", screenshotIndex)
        let safe = name?.sanitizedFileComponent()
        let finalName = safe.map { "\(seq)_\($0)" } ?? seq

        let rootURL = artifactsRootURL(file: file)
        let jira = currentJiraKey()
        let scenario = currentScenarioKey()

        let screenshotsFolder = rootURL
            .appendingPathComponent(jira, isDirectory: true)
            .appendingPathComponent(scenario, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: screenshotsFolder, withIntermediateDirectories: true)

            let fileURL = screenshotsFolder.appendingPathComponent("\(finalName).png")
            try screenshot.pngRepresentation.write(to: fileURL, options: .atomic)

            // Also keep in xcresult for easy debugging
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = finalName
            attachment.lifetime = .keepAlways
            add(attachment)

            print("📸 Screenshot saved: \(fileURL.path)")
        } catch {
            XCTFail("Failed to save screenshot: \(error)", file: file, line: line)
        }
    }

    // MARK: - Root selection (NO scheme/env required)

    /// Priority:
    /// 1) UITEST_ARTIFACTS_DIR (CI/local if set somewhere)
    /// 2) CI_PROJECT_DIR/UITestArtifacts (CI)
    /// 3) Auto-detect project root from #file by walking up and finding common markers (.git, *.xcodeproj, *.xcworkspace, Package.swift, Tuist)
    /// 4) Documents/UITestArtifacts (fallback)
    private func artifactsRootURL(file: StaticString) -> URL {
        func nonEmpty(_ key: String) -> String? {
            let v = ProcessInfo.processInfo.environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (v?.isEmpty == false) ? v : nil
        }

        // 1) explicit
        if let dir = nonEmpty("UITEST_ARTIFACTS_DIR"), dir.hasPrefix("/") {
            return URL(fileURLWithPath: dir, isDirectory: true)
        }

        // 2) CI
        if let dir = nonEmpty("CI_PROJECT_DIR"), dir.hasPrefix("/") {
            return URL(fileURLWithPath: dir, isDirectory: true)
                .appendingPathComponent("UITestArtifacts", isDirectory: true)
        }

        // 3) local autodetect
        if let root = autodetectProjectRoot(from: file) {
            return root.appendingPathComponent("UITestArtifacts", isDirectory: true)
        }

        // 4) fallback
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fallback = docs.appendingPathComponent("UITestArtifacts", isDirectory: true)
        print("⚠️ Project root not detected. Falling back to: \(fallback.path)")
        return fallback
    }

    private func autodetectProjectRoot(from file: StaticString) -> URL? {
        let fm = FileManager.default
        var dir = URL(fileURLWithPath: String(describing: file), isDirectory: false)
            .deletingLastPathComponent()

        for _ in 0..<25 {
            if hasProjectMarker(in: dir) { return dir }

            let parent = dir.deletingLastPathComponent()
            if parent.path == dir.path { break }
            dir = parent
        }
        return nil
    }

    private func hasProjectMarker(in dir: URL) -> Bool {
        let fm = FileManager.default

        // fast checks
        let markers: [URL] = [
            dir.appendingPathComponent(".git", isDirectory: true),
            dir.appendingPathComponent("Package.swift", isDirectory: false),
            dir.appendingPathComponent("Tuist", isDirectory: true),
            dir.appendingPathComponent("Project.swift", isDirectory: false),
            dir.appendingPathComponent("Workspace.swift", isDirectory: false)
        ]

        if markers.contains(where: { fm.fileExists(atPath: $0.path) }) { return true }

        // check for *.xcodeproj / *.xcworkspace
        if let items = try? fm.contentsOfDirectory(atPath: dir.path) {
            if items.contains(where: { $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".xcworkspace") }) {
                return true
            }
        }

        return false
    }

    // MARK: - Naming helpers (Jira + Scenario from test name)

    private func currentTestMethodName() -> String {
        self.name
            .components(separatedBy: " ")
            .last?
            .replacingOccurrences(of: "]", with: "")
            ?? "UnknownTest"
    }

    /// "MYO-1452" / "DOM-2344" / "LKAPP-10"
    private func currentJiraKey() -> String {
        let s = currentTestMethodName()
        let pattern = "(MYO|DOM|LKAPP)[-_]\\d+"
        guard let r = s.range(of: pattern, options: .regularExpression) else { return "UNTRACKED" }
        return String(s[r]).replacingOccurrences(of: "_", with: "-")
    }

    /// suffix after Jira ID: test_MYO_1452_Services_balanceTooLow -> Services_balanceTooLow
    private func currentScenarioKey() -> String {
        let s = currentTestMethodName()
        let withoutPrefix = s.hasPrefix("test_") ? String(s.dropFirst(5)) : s

        let pattern = "(MYO|DOM|LKAPP)[-_]\\d+"
        guard let r = withoutPrefix.range(of: pattern, options: .regularExpression) else {
            return withoutPrefix.sanitizedFileComponent()
        }

        let after = withoutPrefix[r.upperBound...]
        let trimmed = after.trimmingCharacters(in: CharacterSet(charactersIn: "_-"))
        return trimmed.isEmpty ? "default" : String(trimmed).sanitizedFileComponent()
    }
}

private extension String {
    func sanitizedFileComponent() -> String {
        self
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Thread-safe container for cancellables

public final class ThreadSafeBag {
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
