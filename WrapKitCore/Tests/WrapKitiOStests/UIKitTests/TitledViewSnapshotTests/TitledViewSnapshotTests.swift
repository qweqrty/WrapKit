//
//  TitledViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import enum SwiftUI.ColorScheme
#endif

final class TitledViewSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedTitledViewSnapshotSUT?

    func test_titledView_defaul_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_DEFAULT_STATE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))

        recordPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_titledView_defaul_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_DEFAULT_STATE"

        sut.display(titles: .init(.text("First title."), .text("Second title")))

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }

    func test_titledView_with_bottomTitles() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_BOTTOMTTILES"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom"), .text("Second bottom")))

        recordPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_titledView_with_bottomTitles() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_BOTTOMTTILES"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom."), .text("Second bottom")))

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }

    func test_titledView_with_leadingBottomTitle() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title"))

        recordPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_titledView_with_leadingBottomTitle() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title."))

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }

    func test_titledView_with_trailingBottomTitle() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title"))

        recordPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_titledView_with_trailingBottomTitle() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title."))

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }

    func test_titledView_with_isHidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_HIDDEN"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: true)

        recordPairedSnapshot(container: container, named: snapshotName)
    }

    func test_fail_titledView_with_isHidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_HIDDEN"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: false)

        assertPairedSnapshotFail(container: container, named: snapshotName)
    }
}

private extension TitledViewSnapshotTests {
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: PairedTitledViewSnapshotSUT, container: UIView) {
        let sut = PairedTitledViewSnapshotSUT()
        let container = makeContainer()

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )

        container.layoutIfNeeded()

        currentPairedSUT = sut
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}

private extension TitledViewSnapshotTests {
    func assertPairedSnapshot(
        container: UIView,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func assertPairedSnapshotFail(
        container: UIView,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func recordPairedSnapshot(
        container: UIView,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if #available(iOS 26, *) {
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }
}

private extension TitledViewSnapshotTests {
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
        0.99
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

private extension TitledViewSnapshotTests {
    func recordUIKitSnapshot(
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

    func saveAssertSnapshot(
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

    func assertStoredSnapshotEquals(
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

    func assertStoredSnapshotDifferent(
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

    func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    func makeReferenceSnapshotURL(named name: String, file: StaticString) -> URL {
        for candidate in referenceSnapshotCandidates(for: name) {
            let url = makeSnapshotURL(named: candidate, file: file)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        return makeSnapshotURL(named: normalizedSnapshotName(from: name), file: file)
    }

    func referenceSnapshotCandidates(for name: String) -> [String] {
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
