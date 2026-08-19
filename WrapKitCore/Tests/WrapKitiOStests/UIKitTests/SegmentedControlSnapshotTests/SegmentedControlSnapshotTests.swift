//
//  SegmentedControlSnapshotTests.swift
//  WrapKitTests
//

import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class SegmentedControlSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedSegmentedControlSnapshotSUT?

    override func tearDown() {
        currentPairedSUT = nil
        super.tearDown()
    }

    func test_SegmentedControl_default_state() {
        let snapshotName = "SEGMENTEDCONTROL_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(segments: makeSegments())

        assertPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_SegmentedControl_default_state() {
        let snapshotName = "SEGMENTEDCONTROL_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(segments: [
            .init(title: "First.", index: 0),
            .init(title: "Second", index: 1),
            .init(title: "Third", index: 2)
        ])

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }

    func test_SegmentedControl_with_appearance() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_APPEARANCE"
        let (sut, container) = makeSUT()

        sut.display(appearence: makeAccentAppearance())
        sut.display(segments: makeSegments())

        assertPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_SegmentedControl_with_appearance() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_APPEARANCE"
        let (sut, container) = makeSUT()

        sut.display(appearence: makeFailAccentAppearance())
        sut.display(segments: makeSegments())

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }

    func test_SegmentedControl_with_long_titles() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_LONG_TITLES"
        let (sut, container) = makeSUT()

        sut.display(segments: [
            .init(title: "Very long first", index: 0),
            .init(title: "Very long second", index: 1),
            .init(title: "Very long third", index: 2)
        ])

        assertPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_SegmentedControl_with_long_titles() {
        let snapshotName = "SEGMENTEDCONTROL_WITH_LONG_TITLES"
        let (sut, container) = makeSUT()

        sut.display(segments: [
            .init(title: "Very long first.", index: 0),
            .init(title: "Very long second", index: 1),
            .init(title: "Very long third", index: 2)
        ])

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }
}

private extension SegmentedControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedSegmentedControlSnapshotSUT, container: UIView) {
        let appearance = makeDefaultAppearance()
        let sut = PairedSegmentedControlSnapshotSUT(appearance: appearance)
        let container = makeContainer()

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )

        container.layoutIfNeeded()
        currentPairedSUT = sut

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        checkForMemoryLeaks(sut.adapter, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 140)
        container.backgroundColor = .clear
        return container
    }

    func assertPairedSnapshot(
        container: UIView,
        named: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let names = snapshotNames(for: named)
        assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: names.light, precision: precision, file: file, line: line)
        assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: names.dark, precision: precision, file: file, line: line)
    }

    func assertPairedSnapshotFail(
        container: UIView,
        named: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let names = snapshotNames(for: named)
        assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: names.light, precision: precision, file: file, line: line)
        assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: names.dark, precision: precision, file: file, line: line)
    }

    func recordPairedSnapshot(
        container: UIView,
        named: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let names = snapshotNames(for: named)
        recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: names.light, file: file, line: line)
        recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: names.dark, file: file, line: line)
    }

    private func snapshotNames(for name: String) -> (light: String, dark: String) {
        let prefix = if #available(iOS 26, *) { "iOS26" } else { "iOS18.5" }
        return ("\(prefix)_\(name)_LIGHT", "\(prefix)_\(name)_DARK")
    }
}

private extension SegmentedControlSnapshotTests {
    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        saveAssertSnapshot(snapshot, named: assertSnapshotName(for: name, context: "UIKit"), context: "UIKit")
        assertStoredSnapshotEquals(snapshot, named: name, precision: precision, context: "UIKit", file: file, line: line)

        if #available(iOS 17, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            saveAssertSnapshot(swiftUISnapshot, named: assertSnapshotName(for: name, context: "SwiftUI"), context: "SwiftUI")
            assertStoredSnapshotEquals(
                swiftUISnapshot,
                named: name,
                precision: swiftUISnapshotPrecision,
                context: "SwiftUI",
                file: file,
                line: line
            )
        }
    }

    func assertPairedSnapshotFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        saveAssertSnapshot(snapshot, named: assertSnapshotName(for: name, context: "UIKit"), context: "UIKit")
        assertStoredSnapshotDifferent(snapshot, named: name, precision: precision, context: "UIKit", file: file, line: line)

        if #available(iOS 17, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            saveAssertSnapshot(swiftUISnapshot, named: assertSnapshotName(for: name, context: "SwiftUI"), context: "SwiftUI")
            assertStoredSnapshotDifferent(
                swiftUISnapshot,
                named: name,
                precision: swiftUIFailSnapshotPrecision,
                context: "SwiftUI",
                file: file,
                line: line
            )
        }
    }

    func recordPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        recordUIKitSnapshot(snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
    }

    private var swiftUISnapshotPrecision: Float {
        0.97
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }

    private func colorScheme(from snapshotName: String) -> ColorScheme {
        normalizedSnapshotName(from: snapshotName).hasSuffix("_DARK") ? .dark : .light
    }

    private func recordedSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(normalizedSnapshotName(from: snapshotName))"
    }

    private func assertSnapshotName(for snapshotName: String, context: String) -> String {
        let prefix = context == "SwiftUI" ? "SiwftUI" : "UIKit"
        return "\(prefix)_\(normalizedSnapshotName(from: snapshotName))"
    }

    private func normalizedSnapshotName(from snapshotName: String) -> String {
        if snapshotName.hasPrefix("UIKit_") {
            return String(snapshotName.dropFirst("UIKit_".count))
        }
        if snapshotName.hasPrefix("SiwftUI_") {
            return String(snapshotName.dropFirst("SiwftUI_".count))
        }
        if snapshotName.hasPrefix("SwiftUI_") {
            return String(snapshotName.dropFirst("SwiftUI_".count))
        }
        return snapshotName
    }
}

private extension SegmentedControlSnapshotTests {
    private func recordUIKitSnapshot(
        _ snapshot: UIImage,
        named name: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func saveAssertSnapshot(
        _ snapshot: UIImage,
        named name: String,
        context: String
    ) {
        let root = URL(fileURLWithPath: "/Users/ubeishenkulov/Documents/WrapKit/tmp_snapshot_compare/paired_assert", isDirectory: true)
            .appendingPathComponent(context, isDirectory: true)
        let snapshotURL = root.appendingPathComponent("\(name).png")
        guard let snapshotData = snapshot.pngData() else { return }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            // Best-effort helper for local visual comparison.
        }
    }

    private func assertStoredSnapshotEquals(
        _ snapshot: UIImage,
        named name: String,
        precision: Float,
        context: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeReferenceSnapshotURL(named: name, file: file)

        guard
            let storedSnapshotData = try? Data(contentsOf: snapshotURL),
            let oldImage = UIImage(data: storedSnapshotData)
        else {
            if context == "UIKit" {
                recordUIKitSnapshot(snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
                return
            }
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use record mode before asserting.", file: file, line: line)
            return
        }

        guard let diff = Diffing.image(precision: precision).diff(oldImage, snapshot) else { return }

        let normalizedName = normalizedSnapshotName(from: name)
        let uiKitName = recordedSnapshotName(for: normalizedName)
        let currentName = assertSnapshotName(for: normalizedName, context: context)
        let artifactsSubUrl = URL(fileURLWithPath: "/Users/ubeishenkulov/Documents/WrapKit/tmp_snapshot_compare/paired_failures", isDirectory: true)
            .appendingPathComponent(normalizedName)
        try? FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)

        try? storedSnapshotData.write(to: artifactsSubUrl.appendingPathComponent("origin_\(uiKitName).png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("diff_\(currentName).png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("new_\(currentName).png"))

        XCTFail("[\(context)] " + diff.message + "\n Origin: \(uiKitName)\n New: \(currentName)\n Diff snapshot URL: \(artifactsSubUrl)", file: file, line: line)
    }

    private func assertStoredSnapshotDifferent(
        _ snapshot: UIImage,
        named name: String,
        precision: Float,
        context: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeReferenceSnapshotURL(named: name, file: file)

        guard
            let storedSnapshotData = try? Data(contentsOf: snapshotURL),
            let oldImage = UIImage(data: storedSnapshotData)
        else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use record mode before asserting.", file: file, line: line)
            return
        }

        guard Diffing.image(precision: precision).diff(oldImage, snapshot) != nil else {
            XCTFail("[\(context)] Images should be different.", file: file, line: line)
            return
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeReferenceSnapshotURL(named name: String, file: StaticString) -> URL {
        for candidate in referenceSnapshotCandidates(for: name) {
            let url = makeSnapshotURL(named: candidate, file: file)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        return makeSnapshotURL(named: normalizedSnapshotName(from: name), file: file)
    }

    private func referenceSnapshotCandidates(for name: String) -> [String] {
        let normalizedName = normalizedSnapshotName(from: name)
        var candidates = [String]()

        func appendUnique(_ value: String) {
            if !candidates.contains(value) {
                candidates.append(value)
            }
        }

        appendUnique(recordedSnapshotName(for: normalizedName))
        appendUnique(normalizedName)

        return candidates
    }
}

private extension SegmentedControlSnapshotTests {
    func makeSegments() -> [SegmentControlModel] {
        [
            .init(title: "First", index: 0),
            .init(title: "Second", index: 1),
            .init(title: "Third", index: 2)
        ]
    }

    func makeDefaultAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .black,
                backgroundColor: .systemGray5,
                selectedBackgroundColor: .white
            ),
            font: .systemFont(ofSize: 18, weight: .semibold),
            cornerRadius: 10
        )
    }

    func makeAccentAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .white,
                backgroundColor: .systemBlue,
                selectedBackgroundColor: .systemRed
            ),
            font: .systemFont(ofSize: 20, weight: .bold),
            cornerRadius: 14
        )
    }

    func makeFailAccentAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .white,
                backgroundColor: .systemPurple,
                selectedBackgroundColor: .systemRed
            ),
            font: .systemFont(ofSize: 20, weight: .bold),
            cornerRadius: 14
        )
    }
}
