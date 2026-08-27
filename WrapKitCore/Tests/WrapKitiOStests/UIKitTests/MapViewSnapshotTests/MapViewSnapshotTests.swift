//
//  MapViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class MapViewSnapshotTests: XCTestCase {

    func test_mapView_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_DEFAULT_STATE"

        sut.setContentBackgroundColor(.systemBlue)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_DEFAULT_STATE"

        sut.setContentBackgroundColor(.blue)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_with_map_background() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_MAP_BACKGROUND"

        sut.setGradientBackground(
            first: UIColor.systemGreen.withAlphaComponent(0.3),
            second: UIColor.systemBlue.withAlphaComponent(0.3)
        )

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_with_map_background() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_MAP_BACKGROUND"

        sut.setGradientBackground(
            first: UIColor.systemGreen.withAlphaComponent(0.4),
            second: UIColor.systemBlue.withAlphaComponent(0.3)
        )

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_location_button_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .systemBlue, borderWidth: 1, borderColor: .black)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_location_button_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .blue, borderWidth: 1, borderColor: .black)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_zoom_buttons_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_BUTTONS_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setPlusButtonBackgroundColor(.systemBlue)
        sut.setMinusButtonBackgroundColor(.systemRed)
        sut.setActionsBackgroundColor(.white)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_zoom_buttons_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_BUTTONS_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setPlusButtonBackgroundColor(.blue)
        sut.setMinusButtonBackgroundColor(.systemRed)
        sut.setActionsBackgroundColor(.white)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_location_button_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(true)
        sut.setActionsBackgroundColor(.white)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_location_button_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_LOCATION_BUTTON_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(false)
        sut.setActionsBackgroundColor(.white)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_zoom_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsHidden(true)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_zoom_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ZOOM_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsHidden(false)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_all_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ALL_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(true)
        sut.setActionsHidden(true)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_all_controls_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_ALL_CONTROLS_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setLocationButtonHidden(false)
        sut.setActionsHidden(false)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_separator_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorColor(.systemRed)

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_separator_visible() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_VISIBLE"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorColor(.red)

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_separator_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorHidden(true)
        container.layoutIfNeeded()

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_separator_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_SEPARATOR_HIDDEN"

        sut.setContentBackgroundColor(.systemGray5)
        sut.setActionsBackgroundColor(.white)
        sut.setSeparatorHidden(false)
        container.layoutIfNeeded()

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_mapView_with_simulated_map_content() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_PINS"

        sut.setPinsBackground(.systemTeal, alpha: 0.2)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsBackgroundColor(.white)
        container.layoutIfNeeded()

        assertUIKitOnlySnapshot(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }

    func test_fail_mapView_with_simulated_map_content() {
        let (sut, container) = makeSUT()
        let snapshotName = "MAPVIEW_WITH_PINS"

        sut.setPinsBackground(.systemTeal, alpha: 0.5)
        sut.setLocationButton(backgroundColor: .white)
        sut.setActionsBackgroundColor(.white)
        container.layoutIfNeeded()

        assertUIKitOnlySnapshotFail(view: container, named: snapshotName, reason: "MapView has no shared Output contract yet.")
    }
}

private extension MapViewSnapshotTests {
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
