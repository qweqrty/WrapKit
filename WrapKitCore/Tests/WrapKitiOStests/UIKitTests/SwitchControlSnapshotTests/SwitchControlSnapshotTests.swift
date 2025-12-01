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
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"
        // WHEN
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_DEFAUlT_STATE"
        // WHEN
        sut.display(isOn: false)
        sut.display(isEnabled: true)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - wrong appearance on ios26
    func test_switchControl_isOn_false() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_isOn_false() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_ISON_FALSE"
        
        let exp = expectation(description: "Wait for expectation")
        
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .black,
            backgroundColor: .cyan,
            cornerRadius: 0,
            shimmerStyle: nil))
        // WHEN
        
        sut.display(isOn: true)
        
        container.setNeedsLayout()
        container.layoutIfNeeded()
        
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - Style tests
    func test_switchControl_with_tintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_with_tintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_TINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .systemRed,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_switchControl_with_thumbTintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_with_thumbTintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_THUMBTINTCOLOR"
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .green,
            backgroundColor: .clear,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        sut.backgroundColor = .systemBlue
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_switchControl_with_backgroundColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_with_backgroundColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_BACKGROUNDCOLOR"
        
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .blue,
            cornerRadius: 0,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        sut.backgroundColor = .systemBlue
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_switchControl_with_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_with_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_CORNERRADIUS"
        
        // WHEN
        sut.display(style: .init(
            tintColor: .red,
            thumbTintColor: .systemGreen,
            backgroundColor: .systemBlue,
            cornerRadius: 11,
            shimmerStyle: nil))
        sut.display(isOn: true)
        sut.display(isEnabled: true)
        
        sut.backgroundColor = .blue
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_switchControl_with_shimmerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"
        
        // WHEN
        let style = ShimmerView.Style(
            backgroundColor: .systemYellow,
            gradientColorOne: .systemPurple,
            gradientColorTwo: .red,
            cornerRadius: 10)
        
        sut.display(style: .init(
            tintColor: .systemGreen,
            thumbTintColor: .cyan,
            backgroundColor: .clear,
            cornerRadius: 10,
            shimmerStyle: style))
        
        sut.display(isLoading: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_switchControl_with_shimmerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SWITCHCONTROL_WITH_SHIMMERSTYLE"
        
        // WHEN
        let style = ShimmerView.Style(
            backgroundColor: .red,
            gradientColorOne: .yellow,
            gradientColorTwo: .black,
            cornerRadius: 11)
        
        sut.display(style: .init(
            tintColor: .clear,
            thumbTintColor: .clear,
            backgroundColor: .clear,
            cornerRadius: 11,
            shimmerStyle: style))
        
        sut.display(isLoading: true)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)),
                   named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
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
