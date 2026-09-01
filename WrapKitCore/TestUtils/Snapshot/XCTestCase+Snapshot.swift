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
        alphaTolerance: UInt8 = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL),
              let oldImage = UIImage(data: storedSnapshotData, scale: snapshot.scale) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        let diffing = snapshotDiffing(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance
        )
        guard let diff = diffing.diff(oldImage, snapshot) else { return }
        
        let artifactsUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let artifactsSubUrl = artifactsUrl.appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)
        
        try? storedSnapshotData.write(to: artifactsSubUrl.appendingPathComponent("origin.png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("diff.png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("new.png"))
        attachSnapshotArtifacts(
            reference: oldImage,
            snapshot: diff.artifacts.image,
            difference: diff.artifacts.diff,
            name: name
        )
        XCTFail(diff.message + "\n Diff snapshot URL: \(artifactsSubUrl)", file: file, line: line)
    }
    
    func assertFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        alphaTolerance: UInt8 = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL),
              let oldImage = UIImage(data: storedSnapshotData, scale: snapshot.scale) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        guard snapshotDiffing(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance
        ).diff(oldImage, snapshot) != nil
//              diff.message.starts(with: "Images should be different.")
        else {
            XCTFail("Images should be different.", file: file, line: line)
            return
        }
    }

    func assertSwiftUIParity(
        snapshot swiftUISnapshot: UIImage,
        matchingUIKit uiKitSnapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(
            reference: uiKitSnapshot,
            snapshot: swiftUISnapshot,
            diffing: .swiftUIParity,
            artifactsName: "SwiftUI_\(name)",
            file: file,
            line: line
        )
    }

    /// Use only when the scenario depends on UIKit-specific state that is not part of a shared
    /// Output contract. This keeps the immutable UIKit baseline strict without pretending that
    /// the same scenario was exercised by SwiftUI.
    func assertUIKitOnlySnapshot(
        snapshot: UIImage,
        named name: String,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTContext.runActivity(named: "SwiftUI parity intentionally excluded: \(reason)") { _ in
            assert(snapshot: snapshot, named: name, file: file, line: line)
        }
    }

    func assertUIKitOnlySnapshotFail(
        snapshot: UIImage,
        named name: String,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTContext.runActivity(named: "SwiftUI parity intentionally excluded: \(reason)") { _ in
            assertFail(snapshot: snapshot, named: name, file: file, line: line)
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

    private func snapshotDiffing(
        precision: Float,
        perceptualPrecision: Float,
        alphaTolerance: UInt8
    ) -> Diffing<UIImage> {
        guard precision < 1 || perceptualPrecision < 1 || alphaTolerance > 0 else {
            return .strictImage
        }
        return .image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance
        )
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }

    private func assert(
        reference: UIImage,
        snapshot: UIImage,
        diffing: Diffing<UIImage>,
        artifactsName: String,
        file: StaticString,
        line: UInt
    ) {
        guard let diff = diffing.diff(reference, snapshot) else { return }

        let artifactsURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(artifactsName)
        try? FileManager.default.createDirectory(at: artifactsURL, withIntermediateDirectories: true)
        try? reference.pngData()?.write(to: artifactsURL.appendingPathComponent("origin.png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsURL.appendingPathComponent("diff.png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsURL.appendingPathComponent("new.png"))
        attachSnapshotArtifacts(
            reference: reference,
            snapshot: diff.artifacts.image,
            difference: diff.artifacts.diff,
            name: artifactsName
        )
        XCTFail(diff.message + "\n Diff snapshot URL: \(artifactsURL)", file: file, line: line)
    }

    private func attachSnapshotArtifacts(
        reference: UIImage,
        snapshot: UIImage,
        difference: UIImage,
        name: String
    ) {
        let artifacts: [(label: String, image: UIImage)] = [
            ("Reference", reference),
            ("New", snapshot),
            ("Difference", difference)
        ]

        artifacts.forEach { artifact in
            let attachment = XCTAttachment(image: artifact.image)
            attachment.name = "\(name) · \(artifact.label)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

}

#endif
#endif
