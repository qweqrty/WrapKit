#if canImport(UIKit)
#if canImport(XCTest)
import UIKit
import XCTest

public extension XCTestCase {
#if os(iOS)
    /// Verifies UIKit renders against UIKit-owned origins for every requested appearance.
    /// SwiftUI origins are deliberately never considered as a fallback.
    func assertUIKitSnapshots(
        _ view: UIView,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard validateSnapshotRuntime(file: file, line: line) else { return }
        appearances.forEach { appearance in
            XCTContext.runActivity(named: appearance.snapshotActivityName) { _ in
                assert(
                    snapshot: view.snapshot(for: appearance.uiKitConfiguration),
                    named: uiKitSnapshotName(name, appearance: appearance),
                    file: file,
                    line: line
                )
            }
        }
    }
#endif

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
        guard validateSnapshotRuntime(named: name, file: file, line: line) else { return }

        guard let storedSnapshot = loadStoredSnapshot(
            at: snapshotURL,
            file: file,
            line: line
        ), validateSnapshotPair(
            reference: storedSnapshot.image,
            snapshot: snapshot,
            snapshotURL: snapshotURL,
            file: file,
            line: line
        ) else { return }
        let storedSnapshotData = storedSnapshot.data
        let oldImage = storedSnapshot.image
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
        guard validateSnapshotRuntime(named: name, file: file, line: line) else { return }

        guard let storedSnapshot = loadStoredSnapshot(
            at: snapshotURL,
            file: file,
            line: line
        ), validateSnapshotPair(
            reference: storedSnapshot.image,
            snapshot: snapshot,
            snapshotURL: snapshotURL,
            file: file,
            line: line
        ) else { return }
        let oldImage = storedSnapshot.image
        guard snapshotDiffing(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            alphaTolerance: alphaTolerance
        ).diff(oldImage, snapshot) != nil
        else {
            XCTFail(
                "The sensitivity mutation did not produce a visible snapshot difference.",
                file: file,
                line: line
            )
            return
        }
    }

    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard validateSnapshotRuntime(named: name, file: file, line: line) else { return }
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        guard let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line) else {
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            try snapshotData.write(to: snapshotURL)
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

#if os(iOS)
    private func uiKitSnapshotName(
        _ name: String,
        appearance: SnapshotAppearance
    ) -> String {
        let osPrefix = SnapshotRuntime.currentBaselinePrefix ?? "UNSUPPORTED_RUNTIME"
        return "\(osPrefix)_\(name)_\(appearance.snapshotNameSuffix)"
    }
#endif

    private func validateSnapshotRuntime(
        named name: String? = nil,
        file: StaticString,
        line: UInt
    ) -> Bool {
#if os(iOS)
        let canonicalPrefixes = ["iOS18.5_", "iOS26_", "SwiftUI_iOS18.5_", "SwiftUI_iOS26_"]
        if let name, !canonicalPrefixes.contains(where: name.hasPrefix) {
            return true
        }

        let version = ProcessInfo.processInfo.operatingSystemVersion
        guard let expectedPrefix = SnapshotRuntime.baselinePrefix(for: version) else {
            XCTFail(
                "Unsupported snapshot runtime iOS \(version.majorVersion).\(version.minorVersion). "
                    + "Use iOS 18.5 or iOS 26.2.",
                file: file,
                line: line
            )
            return false
        }
        guard let name else { return true }
        let validPrefixes = ["\(expectedPrefix)_", "SwiftUI_\(expectedPrefix)_"]
        guard validPrefixes.contains(where: name.hasPrefix) else {
            XCTFail(
                "Snapshot name '\(name)' does not match the current \(expectedPrefix) runtime.",
                file: file,
                line: line
            )
            return false
        }
        return true
#else
        return true
#endif
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

    private func loadStoredSnapshot(
        at snapshotURL: URL,
        file: StaticString,
        line: UInt
    ) -> (data: Data, image: UIImage)? {
        let data = try? Data(contentsOf: snapshotURL)
        if let validationError = SnapshotBaselineValidator.validateBaselineData(data) {
            XCTFail(
                validationError.failureMessage(snapshotURL: snapshotURL),
                file: file,
                line: line
            )
            return nil
        }
        guard let data else { return nil }
        guard let image = UIImage(data: data, scale: SnapshotRenderDefaults.scale),
              image.cgImage != nil else {
            XCTFail(
                SnapshotBaselineValidationError.corruptPNG.failureMessage(snapshotURL: snapshotURL),
                file: file,
                line: line
            )
            return nil
        }
        return (data, image)
    }

    private func validateSnapshotPair(
        reference: UIImage,
        snapshot: UIImage,
        snapshotURL: URL,
        file: StaticString,
        line: UInt
    ) -> Bool {
        guard let validationError = SnapshotBaselineValidator.validateSnapshotPair(
            reference: reference,
            snapshot: snapshot
        ) else { return true }
        XCTFail(
            validationError.failureMessage(snapshotURL: snapshotURL),
            file: file,
            line: line
        )
        return false
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

private extension SnapshotBaselineValidationError {
    func failureMessage(snapshotURL: URL) -> String {
        switch self {
        case .missing:
            "Missing snapshot baseline at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting."
        case .empty:
            "Empty snapshot baseline at URL: \(snapshotURL). Record a valid PNG before asserting."
        case .notPNG:
            "Snapshot baseline at URL is not a PNG despite its .png path: \(snapshotURL)."
        case .corruptPNG:
            "Snapshot baseline at URL is a corrupt or incomplete PNG image: \(snapshotURL)."
        case .invalidReferenceBitmap:
            "Snapshot baseline at URL is not a valid non-empty bitmap: \(snapshotURL)."
        case .invalidSnapshotBitmap:
            "New snapshot is not a valid non-empty bitmap for baseline: \(snapshotURL)."
        case let .incompatiblePixelDimensions(expectedWidth, expectedHeight, actualWidth, actualHeight):
            "New snapshot is incompatible with baseline at URL: \(snapshotURL). Expected \(expectedWidth)x\(expectedHeight) px, got \(actualWidth)x\(actualHeight) px."
        case let .incompatibleScale(expected, actual):
            "New snapshot is incompatible with baseline at URL: \(snapshotURL). Expected \(expected)x scale, got \(actual)x."
        case let .incompatibleOrientation(expected, actual):
            "New snapshot is incompatible with baseline at URL: \(snapshotURL). Expected orientation \(expected), got \(actual)."
        }
    }
}

#if os(iOS)
private extension SnapshotAppearance {
    var snapshotNameSuffix: String {
        switch self {
        case .light: "LIGHT"
        case .dark: "DARK"
        }
    }

    var snapshotActivityName: String {
        switch self {
        case .light: "Light appearance"
        case .dark: "Dark appearance"
        }
    }
}
#endif

#endif
#endif
