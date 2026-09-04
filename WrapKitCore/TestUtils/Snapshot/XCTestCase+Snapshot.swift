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

        assert(
            snapshot: snapshot,
            named: name,
            snapshotURL: snapshotURL,
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance,
            file: file,
            line: line
        )
    }

    func assert(
        snapshot: UIImage,
        named name: String,
        baselineDirectory: URL,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        alphaTolerance: UInt8 = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(
            snapshot: snapshot,
            named: name,
            snapshotURL: baselineDirectory.appendingPathComponent("\(name).png"),
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance,
            file: file,
            line: line
        )
    }

    private func assert(
        snapshot: UIImage,
        named name: String,
        snapshotURL: URL,
        precision: Float,
        perceptualPrecision: Float,
        alphaTolerance: UInt8,
        file: StaticString,
        line: UInt
    ) {

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

        assertFail(
            snapshot: snapshot,
            named: name,
            snapshotURL: snapshotURL,
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance,
            file: file,
            line: line
        )
    }

    func assertFail(
        snapshot: UIImage,
        named name: String,
        baselineDirectory: URL,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        alphaTolerance: UInt8 = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertFail(
            snapshot: snapshot,
            named: name,
            snapshotURL: baselineDirectory.appendingPathComponent("\(name).png"),
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance,
            file: file,
            line: line
        )
    }

    private func assertFail(
        snapshot: UIImage,
        named name: String,
        snapshotURL: URL,
        precision: Float,
        perceptualPrecision: Float,
        alphaTolerance: UInt8,
        file: StaticString,
        line: UInt
    ) {

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
