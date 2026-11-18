import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUIMapViewSnapshotTests: XCTestCase {

    func test_mapView_default_state() {
        let sut = makeSUT()
        sut.stateModel.content = .color(.systemBlue)

        assertSnapshots(sut, named: "MAPVIEW_DEFAULT_STATE")
    }

    func test_fail_mapView_default_state() {
        let sut = makeSUT()
        sut.stateModel.content = .color(.blue)

        assertSnapshotsFail(sut, named: "MAPVIEW_DEFAULT_STATE")
    }

    func test_mapView_with_map_background() {
        let sut = makeSUT()
        sut.stateModel.content = .gradient([
            .systemGreen.withAlphaComponent(0.3),
            .systemBlue.withAlphaComponent(0.3)
        ])

        assertSnapshots(sut, named: "MAPVIEW_WITH_MAP_BACKGROUND")
    }

    func test_fail_mapView_with_map_background() {
        let sut = makeSUT()
        sut.stateModel.content = .gradient([
            .systemGreen.withAlphaComponent(0.4),
            .systemBlue.withAlphaComponent(0.3)
        ])

        assertSnapshotsFail(sut, named: "MAPVIEW_WITH_MAP_BACKGROUND")
    }

    func test_mapView_location_button_visible() {
        let sut = makeSUT()
        configureLocationButton(sut, backgroundColor: .systemBlue)

        assertSnapshots(sut, named: "MAPVIEW_LOCATION_BUTTON_VISIBLE")
    }

    func test_fail_mapView_location_button_visible() {
        let sut = makeSUT()
        configureLocationButton(sut, backgroundColor: .blue)

        assertSnapshotsFail(sut, named: "MAPVIEW_LOCATION_BUTTON_VISIBLE")
    }

    func test_mapView_zoom_buttons_visible() {
        let sut = makeSUT()
        configureZoomButtons(sut, plusBackgroundColor: .systemBlue)

        assertSnapshots(sut, named: "MAPVIEW_ZOOM_BUTTONS_VISIBLE")
    }

    func test_fail_mapView_zoom_buttons_visible() {
        let sut = makeSUT()
        configureZoomButtons(sut, plusBackgroundColor: .blue)

        assertSnapshotsFail(sut, named: "MAPVIEW_ZOOM_BUTTONS_VISIBLE")
    }

    func test_mapView_location_button_hidden() {
        let sut = makeSUT()
        configureControlsBackground(sut)
        sut.stateModel.locationButton.isHidden = true

        assertSnapshots(sut, named: "MAPVIEW_LOCATION_BUTTON_HIDDEN")
    }

    func test_fail_mapView_location_button_hidden() {
        let sut = makeSUT()
        configureControlsBackground(sut)
        sut.stateModel.locationButton.isHidden = false

        assertSnapshotsFail(sut, named: "MAPVIEW_LOCATION_BUTTON_HIDDEN")
    }

    func test_mapView_zoom_controls_hidden_preserves_actions_layout_slot() {
        let sut = makeSUT()
        configureControlsBackground(sut)
        sut.stateModel.isActionsHidden = true

        assertSnapshots(sut, named: "MAPVIEW_ZOOM_CONTROLS_HIDDEN")
    }

    func test_fail_mapView_zoom_controls_hidden() {
        let sut = makeSUT()
        configureControlsBackground(sut)
        sut.stateModel.isActionsHidden = false

        assertSnapshotsFail(sut, named: "MAPVIEW_ZOOM_CONTROLS_HIDDEN")
    }

    func test_mapView_all_controls_hidden() {
        let sut = makeSUT()
        sut.stateModel.content = .color(.systemGray5)
        sut.stateModel.locationButton.isHidden = true
        sut.stateModel.isActionsHidden = true

        assertSnapshots(sut, named: "MAPVIEW_ALL_CONTROLS_HIDDEN")
    }

    func test_fail_mapView_all_controls_hidden() {
        let sut = makeSUT()
        sut.stateModel.content = .color(.systemGray5)
        sut.stateModel.locationButton.isHidden = false
        sut.stateModel.isActionsHidden = false

        assertSnapshotsFail(sut, named: "MAPVIEW_ALL_CONTROLS_HIDDEN")
    }

    func test_mapView_separator_visible() {
        let sut = makeSUT()
        configureSeparator(sut, color: .systemRed, isHidden: false)

        assertSnapshots(sut, named: "MAPVIEW_SEPARATOR_VISIBLE")
    }

    func test_fail_mapView_separator_visible() {
        let sut = makeSUT()
        configureSeparator(sut, color: .red, isHidden: false)

        assertSnapshotsFail(sut, named: "MAPVIEW_SEPARATOR_VISIBLE")
    }

    func test_mapView_separator_hidden() {
        let sut = makeSUT()
        configureSeparator(sut, color: .lightGray, isHidden: true)

        assertSnapshots(sut, named: "MAPVIEW_SEPARATOR_HIDDEN")
    }

    func test_fail_mapView_separator_hidden() {
        let sut = makeSUT()
        configureSeparator(sut, color: .lightGray, isHidden: false)

        assertSnapshotsFail(sut, named: "MAPVIEW_SEPARATOR_HIDDEN")
    }

    func test_mapView_with_simulated_map_content() {
        let sut = makeSUT()
        configurePins(sut, alpha: 0.2)

        assertSnapshots(sut, named: "MAPVIEW_WITH_PINS")
    }

    func test_fail_mapView_with_simulated_map_content() {
        let sut = makeSUT()
        configurePins(sut, alpha: 0.5)

        assertSnapshotsFail(sut, named: "MAPVIEW_WITH_PINS")
    }
}

@available(iOS 17.0, *)
private extension SUIMapViewSnapshotTests {
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIMapViewSnapshotSUT {
        let sut = SwiftUIMapViewSnapshotSUT()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func configureLocationButton(
        _ sut: SwiftUIMapViewSnapshotSUT,
        backgroundColor: Color
    ) {
        sut.stateModel.content = .color(.systemGray5)
        sut.stateModel.locationButton.backgroundColor = backgroundColor
        sut.stateModel.locationButton.borderColor = .black
        sut.stateModel.locationButton.borderWidth = 1
    }

    func configureZoomButtons(
        _ sut: SwiftUIMapViewSnapshotSUT,
        plusBackgroundColor: Color
    ) {
        sut.stateModel.content = .color(.systemGray5)
        sut.stateModel.plusButton.backgroundColor = plusBackgroundColor
        sut.stateModel.minusButton.backgroundColor = .systemRed
        sut.stateModel.actionsBackgroundColor = .white
    }

    func configureControlsBackground(_ sut: SwiftUIMapViewSnapshotSUT) {
        sut.stateModel.content = .color(.systemGray5)
        sut.stateModel.locationButton.backgroundColor = .white
        sut.stateModel.actionsBackgroundColor = .white
    }

    func configureSeparator(
        _ sut: SwiftUIMapViewSnapshotSUT,
        color: Color,
        isHidden: Bool
    ) {
        sut.stateModel.content = .color(.systemGray5)
        sut.stateModel.actionsBackgroundColor = .white
        sut.stateModel.separatorColor = color
        sut.stateModel.isSeparatorHidden = isHidden
    }

    func configurePins(_ sut: SwiftUIMapViewSnapshotSUT, alpha: CGFloat) {
        sut.stateModel.content = .pins(backgroundColor: .systemTeal, alpha: alpha)
        sut.stateModel.locationButton.backgroundColor = .white
        sut.stateModel.actionsBackgroundColor = .white
    }

    func assertSnapshots(
        _ sut: SwiftUIMapViewSnapshotSUT,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertSnapshots(sut, named: snapshotName, mustMatch: true, file: file, line: line)
    }

    func assertSnapshotsFail(
        _ sut: SwiftUIMapViewSnapshotSUT,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertSnapshots(sut, named: snapshotName, mustMatch: false, file: file, line: line)
    }

    func assertSnapshots(
        _ sut: SwiftUIMapViewSnapshotSUT,
        named snapshotName: String,
        mustMatch: Bool,
        file: StaticString,
        line: UInt
    ) {
        guard let runtime = SnapshotRuntime.currentBaselinePrefix else {
            XCTFail("Unsupported snapshot runtime.", file: file, line: line)
            return
        }

        SnapshotAppearance.allCases.forEach { appearance in
            let suffix = appearance == .light ? "LIGHT" : "DARK"
            let name = "SwiftUI_\(runtime)_\(snapshotName)_\(suffix)"
            let snapshot = sut.swiftUISnapshot(for: appearance)
            if mustMatch {
                assert(
                    snapshot: snapshot,
                    named: name,
                    precision: SwiftUISnapshotPrecision.standard,
                    file: file,
                    line: line
                )
            } else {
                assertFail(
                    snapshot: snapshot,
                    named: name,
                    precision: SwiftUISnapshotPrecision.fail,
                    file: file,
                    line: line
                )
            }
        }
    }
}
