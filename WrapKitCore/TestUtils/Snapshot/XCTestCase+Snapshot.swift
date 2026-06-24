#if canImport(UIKit)
#if canImport(XCTest)
import UIKit
import XCTest

public extension XCTestCase {
    func assert(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        maxChannelDelta: UInt8 = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL), let oldImage = UIImage(data: storedSnapshotData) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        guard let diff = Diffing.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            maxChannelDelta: maxChannelDelta
        ).diff(oldImage, snapshot) else { return }
        
        let artifactsUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let artifactsSubUrl = artifactsUrl.appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)
        
        try? storedSnapshotData.write(to: artifactsSubUrl.appendingPathComponent("origin.png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("diff.png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("new.png"))
        copyFailedSnapshotArtifacts(
            name: name,
            originData: storedSnapshotData,
            diff: diff.artifacts.diff,
            new: diff.artifacts.image,
            file: file
        )
        XCTFail(diff.message + "\n Diff snapshot URL: \(artifactsSubUrl)", file: file, line: line)
    }
    
    func assertFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        maxChannelDelta: UInt8 = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL), let oldImage = UIImage(data: storedSnapshotData) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        guard Diffing.image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            maxChannelDelta: maxChannelDelta
        ).diff(oldImage, snapshot) != nil
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
            XCTFail("Record succeeded at URL: \(snapshotURL) - use `assert` to compare the snapshot from now on.", file: file, line: line)
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
    
    private func copyFailedSnapshotArtifacts(
        name: String,
        originData: Data,
        diff: UIImage,
        new: UIImage,
        file: StaticString
    ) {
        guard let artifactsURL = makeFailedSnapshotArtifactsURL(file: file) else { return }
        let fileName = sanitizeFailedSnapshotName("\(self.name)_\(name)")
        
        try? FileManager.default.createDirectory(at: artifactsURL, withIntermediateDirectories: true)
        try? originData.write(to: artifactsURL.appendingPathComponent("\(fileName)__01_origin.png"))
        try? new.pngData()?.write(to: artifactsURL.appendingPathComponent("\(fileName)__02_new.png"))
        try? diff.pngData()?.write(to: artifactsURL.appendingPathComponent("\(fileName)__03_diff.png"))
    }
    
    private func makeFailedSnapshotArtifactsURL(file: StaticString) -> URL? {
        var directoryURL = URL(fileURLWithPath: String(describing: file)).deletingLastPathComponent()
        
        while directoryURL.path != "/" {
            let scriptURL = directoryURL
                .appendingPathComponent("Scripts")
                .appendingPathComponent("collect_failed_test_artifacts.sh")
            if FileManager.default.fileExists(atPath: scriptURL.path) {
                return directoryURL
                    .appendingPathComponent("TestArtifacts")
                    .appendingPathComponent("failed-tests")
                    .appendingPathComponent("latest-images")
            }
            directoryURL.deleteLastPathComponent()
        }
        
        return nil
    }
    
    private func sanitizeFailedSnapshotName(_ name: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
        return name.unicodeScalars.map { scalar in
            allowedCharacters.contains(scalar) ? String(scalar) : "_"
        }.joined()
    }
}

#endif
#endif
