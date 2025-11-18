//
//  SwitchControlSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class SwitchControlSnapshotTests: XCTestCase {
    func test_switchControl_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_DEFAUlt_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_DEFAUlt_STATE_DARK")
    }
    
    func test_switchControl_isOn_false() {
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for expectation")
        
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .black,
            backgroundColor: .cyan,
            cornerRadius: 0,
            shimmerStyle: nil))
        // WHEN
        
        sut.display(isOn: false)
        
        container.setNeedsLayout()
        container.layoutIfNeeded()
        
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_ISON_FALSE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_ISON_FALSE_DARK")
    }
    
    // MARK: - Style tests
    func test_switchControl_with_tintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_WITH_TINTCOLOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_WITH_TINTCOLOR_DARK")
    }
    
    func test_switchControl_with_thumbTintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        sut.backgroundColor = .blue
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_WITH_THUMBTINTCOLOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_WITH_THUMBTINTCOLOR_DARK")
    }
    
    func test_switchControl_with_backgroundColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .systemBlue,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        sut.backgroundColor = .blue
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_WITH_BACKGROUNDCOLOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_WITH_BACKGROUNDCOLOR_DARK")
    }
    
    func test_switchControl_with_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .systemBlue,
            cornerRadius: 10,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        sut.backgroundColor = .blue
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_WITH_CORNERRADIUS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_WITH_CORNERRADIUS_DARK")
    }
    
    func test_switchControl_with_shimmerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = ShimmerView.Style(
            backgroundColor: .systemYellow,
            gradientColorOne: .systemPurple,
            gradientColorTwo: .white,
            cornerRadius: 10)
        
        sut.display(style: .init(
            tintColor: .systemGreen,
            thumbTintColor: .cyan,
            backgroundColor: .systemBackground,
            cornerRadius: 10,
            shimmerStyle: style))
        
        sut.display(isLoading: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SWITCHCONTROL_WITH_SHIMMERSTYLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SWITCHCONTROL_WITH_SHIMMERSTYLE_DARK")
    }
}

extension SwitchControlSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SwitchControl, container: UIView) {
        
        let sut = SwitchControl()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .width(200, priority: .required),
            .height(50, priority: .required)
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
