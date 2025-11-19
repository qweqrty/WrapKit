//
//  ShimmerViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class ShimmerViewSnapshotTests: XCTestCase {
    func test_shimmerView_initial_state() {
        // GIVEN
        let (_, container) = makeSUT()
        let snapshotName = "SHIMMERVIEW_INITIAL_STATE"
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_shimmerView_with_background_color() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SHIMMERVIEW_WITH_BACKGROUND"
        
        // WHEN
        sut.backgroundColor = .systemGray6
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - Gradient Configuration Tests
    func test_shimmerView_custom_gradient_colors() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SHIMMERVIEW_CUSTOM_GRADIENT_COLORS"
        
        // WHEN
        sut.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        sut.gradientColorOne = .clear
        sut.gradientColorTwo = .white.withAlphaComponent(0.8)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_shimmerView_colored_gradient() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SHIMMERVIEW_COLORED_GRADIENT"
        
        // WHEN
        sut.backgroundColor = .systemPurple.withAlphaComponent(0.2)
        sut.gradientColorOne = .clear
        sut.gradientColorTwo = .systemPurple.withAlphaComponent(0.6)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_shimmerView_with_style() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SHIMMERVIEW_WITH_STYLE"
        
        // WHEN
        let style = ShimmerView.Style(
            backgroundColor: .systemPink,
            gradientColorOne: .clear,
            gradientColorTwo: .white.withAlphaComponent(0.9),
            cornerRadius: 12
        )
        
        sut.style = style
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_shimmerView_pill_shape() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "SHIMMERVIEW_PILL_SHAPE"
        
        // WHEN
        sut.backgroundColor = .systemGray6
        sut.layer.cornerRadius = sut.bounds.height / 2
        sut.layer.masksToBounds = true
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    // MARK: - Real-World Use Cases
    func test_shimmerView_skeleton_card() {
        // GIVEN
        let snapshotName = "SHIMMERVIEW_SKELETON_CARD"
        
        let container = makeContainer()
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        
        // Avatar shimmer
        let avatarShimmer = ShimmerView()
        avatarShimmer.backgroundColor = .systemGray6
        avatarShimmer.layer.cornerRadius = 30
        avatarShimmer.layer.masksToBounds = true
        
        // Title shimmer
        let titleShimmer = ShimmerView()
        titleShimmer.backgroundColor = .systemGray6
        titleShimmer.layer.cornerRadius = 4
        
        // Subtitle shimmer
        let subtitleShimmer = ShimmerView()
        subtitleShimmer.backgroundColor = .systemGray6
        subtitleShimmer.layer.cornerRadius = 4
        
        // WHEN
        container.addSubview(cardView)
        cardView.anchor(
            .top(container.topAnchor, constant: 20),
            .leading(container.leadingAnchor, constant: 20),
            .trailing(container.trailingAnchor, constant: -20),
            .height(120)
        )
        
        cardView.addSubview(avatarShimmer)
        avatarShimmer.anchor(
            .leading(cardView.leadingAnchor, constant: 16),
            .centerY(cardView.centerYAnchor),
            .width(60),
            .height(60)
        )
        
        cardView.addSubview(titleShimmer)
        titleShimmer.anchor(
            .top(cardView.topAnchor, constant: 30),
            .leading(avatarShimmer.trailingAnchor, constant: 16),
            .trailing(cardView.trailingAnchor, constant: -16),
            .height(16)
        )
        
        cardView.addSubview(subtitleShimmer)
        subtitleShimmer.anchor(
            .top(titleShimmer.bottomAnchor, constant: 12),
            .leading(avatarShimmer.trailingAnchor, constant: 16),
            .width(150),
            .height(12)
        )
        
        container.layoutIfNeeded()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
}

extension ShimmerViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ShimmerView, container: UIView) {
        let sut = ShimmerView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(100, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .white
        return container
    }
}
