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
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemBlue
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_DEFAULT_STATE_DARK")
    }
    
    func test_mapView_with_map_background() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGreen.withAlphaComponent(0.3).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.frame = sut.contentView.bounds
        sut.contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_WITH_MAP_BACKGROUND_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_WITH_MAP_BACKGROUND_DARK")
    }
    
    func test_mapView_location_button_visible() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.locationView.backgroundColor = .systemBlue
        sut.locationView.layer.borderWidth = 1
        sut.locationView.layer.borderColor = UIColor.black.cgColor
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_LOCATION_BUTTON_VISIBLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_LOCATION_BUTTON_VISIBLE_DARK")
    }
    
    func test_mapView_zoom_buttons_visible() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.plusView.backgroundColor = .systemBlue
        sut.minusView.backgroundColor = .systemRed
        sut.actionsStackView.backgroundColor = .white
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_ZOOM_BUTTONS_VISIBLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_ZOOM_BUTTONS_VISIBLE_DARK")
    }
    
    func test_mapView_location_button_hidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.locationView.isHidden = true
        sut.actionsStackView.backgroundColor = .white
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_LOCATION_BUTTON_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_LOCATION_BUTTON_HIDDEN_DARK")
    }
    
    func test_mapView_zoom_controls_hidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.locationView.backgroundColor = .white
        sut.actionsStackView.isHidden = true
        
        // THEN
        record(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_ZOOM_CONTROLS_HIDDEN_LIGHT")
        record(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_ZOOM_CONTROLS_HIDDEN_DARK")
    }
    
    func test_mapView_all_controls_hidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.locationView.isHidden = true
        sut.actionsStackView.isHidden = true
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_ALL_CONTROLS_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_ALL_CONTROLS_HIDDEN_DARK")
    }
    
    func test_mapView_separator_visible() {
        // GIven
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.actionsStackView.backgroundColor = .white
        sut.separatorView.backgroundColor = .systemRed
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_SEPARATOR_VISIBLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_SEPARATOR_VISIBLE_DARK")
    }
    
    func test_mapView_separator_hidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemGray5
        sut.actionsStackView.backgroundColor = .white
        sut.separatorView.isHidden = true
        
        container.layoutIfNeeded()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_SEPARATOR_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "MAPVIEW_SEPARATOR_HIDDEN_DARK")
    }
    
    func test_mapView_with_simulated_map_content() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.contentView.backgroundColor = .systemTeal.withAlphaComponent(0.2)
        
        for i in 0..<3 {
            let pin = UIView()
            pin.backgroundColor = .systemRed
            pin.layer.cornerRadius = 10
            sut.contentView.addSubview(pin)
            pin.anchor(
                .top(sut.contentView.topAnchor, constant: CGFloat(30 + i * 40)),
                .leading(sut.contentView.leadingAnchor, constant: CGFloat(50 + i * 60)),
                .width(20),
                .height(20)
            )
        }
        
        sut.locationView.backgroundColor = .white
        sut.actionsStackView.backgroundColor = .white
        
        container.layoutIfNeeded()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_WITH_PINS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "MAPVIEW_WITH_PINS_DARK")
    }
    
}

extension MapViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: MapView<UIView>, container: UIView) {
        
        let sut = MapView<UIView>(mapView: UIView())
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(200, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
