//
//  MapViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import SwiftUI
import WrapKit
import WrapKitTestUtils
import XCTest

final class MapViewSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedMapViewSnapshotSUT?

    private var swiftUISnapshotPrecision: Float {
        0.98
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }

    func test_mapView_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_DEFAULT_STATE"

        sut.setContentBackgroundColor(.systemBlue)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_DEFAULT_STATE"

        sut.setContentBackgroundColor(.blue)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_with_map_background() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_MAP_BACKGROUND"

        sut.setGradientBackground(
            first: UIColor.systemGreen.withAlphaComponent(0.3),
            second: UIColor.systemBlue.withAlphaComponent(0.3)
        )

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_with_map_background() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_MAP_BACKGROUND"

        sut.setGradientBackground(
            first: UIColor.systemGreen.withAlphaComponent(0.4),
            second: UIColor.systemBlue.withAlphaComponent(0.3)
        )

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_location_button_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .systemBlue, borderWidth: 1, borderColor: .black)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_location_button_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .blue, borderWidth: 1, borderColor: .black)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_zoom_buttons_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_BUTTONS_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setPlusButtonBackgroundColor(.systemBlue)
        sut.setMinusButtonBackgroundColor(.systemRed)
        sut.setActionsBackgroundColor(.white)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_zoom_buttons_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_BUTTONS_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setPlusButtonBackgroundColor(.blue)
        sut.setMinusButtonBackgroundColor(.systemRed)
        sut.setActionsBackgroundColor(.white)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_location_button_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(true)
        sut.setActionsBackgroundColor(.white)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_location_button_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(false)
        sut.setActionsBackgroundColor(.white)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_zoom_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsHidden(true)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_zoom_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsHidden(false)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_all_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ALL_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(true)
        sut.setActionsHidden(true)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_all_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ALL_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(false)
        sut.setActionsHidden(false)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_separator_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorColor(.systemRed)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_separator_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorColor(.red)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_separator_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorHidden(true)
        container.layoutIfNeeded()

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_separator_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorHidden(false)
        container.layoutIfNeeded()

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_mapView_with_simulated_map_content() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_PINS"

        sut.setPinsBackground(.systemTeal, alpha: 0.2)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsBackgroundColor(.white)
        container.layoutIfNeeded()

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_mapView_with_simulated_map_content() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_PINS"

        sut.setPinsBackground(.systemTeal, alpha: 0.5)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsBackgroundColor(.white)
        container.layoutIfNeeded()

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }
}

private extension MapViewSnapshotTests {
    func assertPairedSnapshots(container: UIView, snapshotName: String, file: StaticString = #filePath, line: UInt = #line) {
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func recordPairedSnapshots(container: UIView, snapshotName: String, file: StaticString = #filePath, line: UInt = #line) {
        if #available(iOS 26, *) {
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func assertPairedSnapshotsFail(container: UIView, snapshotName: String, file: StaticString = #filePath, line: UInt = #line) {
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uiKitSnapshotName = resolvedUIKitSnapshotName(for: name, file: file)
        assert(snapshot: snapshot, named: uiKitSnapshotName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assert(
                snapshot: swiftUISnapshot,
                named: uiKitSnapshotName,
                precision: swiftUISnapshotPrecision,
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
        let uiKitSnapshotName = resolvedUIKitSnapshotName(for: name, file: file)
        assertFail(snapshot: snapshot, named: uiKitSnapshotName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertFail(
                snapshot: swiftUISnapshot,
                named: uiKitSnapshotName,
                precision: swiftUIFailSnapshotPrecision,
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
        record(snapshot: snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
    }

    func resolvedUIKitSnapshotName(for snapshotName: String, file: StaticString) -> String {
        let prefixed = recordedSnapshotName(for: snapshotName)
        if snapshotExists(named: prefixed, file: file) {
            return prefixed
        }
        return snapshotName
    }

    func snapshotExists(named name: String, file: StaticString) -> Bool {
        let url = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        return FileManager.default.fileExists(atPath: url.path)
    }

    func colorScheme(from snapshotName: String) -> ColorScheme {
        normalizedSnapshotName(from: snapshotName).hasSuffix("_DARK") ? .dark : .light
    }

    func recordedSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(normalizedSnapshotName(from: snapshotName))"
    }

    func normalizedSnapshotName(from snapshotName: String) -> String {
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

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: PairedMapViewSnapshotSUT, container: UIView) {
        let sut = PairedMapViewSnapshotSUT()
        let container = makeContainer()

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(200, priority: .required)
        )

        container.layoutIfNeeded()
        currentPairedSUT = sut

        checkForMemoryLeaks(sut, file: file, line: line)
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
