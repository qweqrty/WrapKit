#if canImport(UIKit)
#if canImport(XCTest)
import UIKit
import XCTest

public extension XCTestCase {
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL), let oldImage = UIImage(data: storedSnapshotData) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        guard let diff = Diffing.image(precision: 1).diff(oldImage, snapshot) else { return }
        
        let artifactsUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let artifactsSubUrl = artifactsUrl.appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)
        
        try? storedSnapshotData.write(to: artifactsSubUrl.appendingPathComponent("origin.png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("diff.png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("new.png"))
        XCTFail(diff.message + "\n Diff snapshot URL: \(artifactsSubUrl)", file: file, line: line)
    }
    
    func assertFail(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL), let oldImage = UIImage(data: storedSnapshotData) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        guard let diff = Diffing.image(precision: 1).diff(oldImage, snapshot)
//              diff.message.starts(with: "Images should be different.")
        else {
            XCTFail("Images should be different.", file: file, line: line)
            return
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
}

#endif
#endif
