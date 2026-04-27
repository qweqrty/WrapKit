//
//  ExpandableCardViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import SwiftUI
#endif

final class ExpandableCardViewSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedExpandableCardViewSnapshotSUT?

    private var swiftUISnapshotPrecision: Float {
        0.98
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }
    
    func test_expandableCardView_display_only_prime_model() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "EXPANABLE_CARD_VIEW_DISPLAY_ONLY_PRIME_MODEL"
        
        // WHEN
        let primeModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .red,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 0,
                titleValueNumberOfLines: 0),
            title: .text("Title")
        )
        
        sut.display(model: .init(primeModel, nil))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_expandableCardView_display_only_prime_model() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "EXPANABLE_CARD_VIEW_DISPLAY_ONLY_PRIME_MODEL"
        
        // WHEN
        let primeModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .systemRed,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 0,
                titleValueNumberOfLines: 0),
            title: .text("Title")
        )
        
        sut.display(model: .init(primeModel, nil))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_expandableCardView_display_both_models() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "EXPANDABLECARDVIEW_DISPLAY_BOTH"
        
        // WHEN
        let primeModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .systemRed,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 0,
                titleValueNumberOfLines: 0),
            title: .text("Prime title")
        )
        
        let secondaryModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .cyan,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 0,
                titleValueNumberOfLines: 0),
            title: .text("Secondary title")
        )
        
        sut.stackView.spacing = 10
        sut.display(model: .init(primeModel, secondaryModel))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_expandableCardView_display_both_models() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "EXPANDABLECARDVIEW_DISPLAY_BOTH"
        
        // WHEN
        let primeModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .red,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 0,
                titleValueNumberOfLines: 0),
            title: .text("Prime title")
        )
        
        let secondaryModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .blue,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 0,
                titleValueNumberOfLines: 0),
            title: .text("Secondary title")
        )
        
        sut.stackView.spacing = 10
        sut.display(model: .init(primeModel, secondaryModel))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_expandableCardView_with_content() {
        // GIVEN
        let (sut, container) = makeSUT()
        let image = WrapKit.Image(systemName: "star.fill")
        let snapshotName = "EXPANDABLECARDVIEW_WITH_CONTENT"
        
        // WHEN
        let primeModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .systemRed,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 1,
                titleValueNumberOfLines: 1),
            backgroundImage: .init(image: .asset(image)),
            title: .text("Prime title"),
            leadingTitles: .init(.text("First title"), .text("Second title")),
            trailingImage: .init(image: .asset(image)),
            valueTitle: .text("Value title")
        )
        
        let secondaryModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .cyan,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 1,
                titleValueNumberOfLines: 1),
            backgroundImage: .init(image: .asset(image)),
            title: .text("Secondary title"),
            trailingTitles: .init(.text("First title"), .text("Second title")),
            leadingImage: .init(image: .asset(image)),
        )
        
        sut.stackView.spacing = 10
        sut.primeCardView.constrainHeight(120)
        sut.secondaryCardView.constrainHeight(120)
        
        sut.display(model: .init(primeModel, secondaryModel))
        
        sut.layoutIfNeeded()
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(
                snapshot: container.snapshot(for: .iPhone(style: .light)),
                named: "iOS26_\(snapshotName)_LIGHT",
                swiftUIPrecision: 0.972
            )
            assertPairedSnapshot(
                snapshot: container.snapshot(for: .iPhone(style: .dark)),
                named: "iOS26_\(snapshotName)_DARK",
                swiftUIPrecision: 0.972
            )
        } else {
            assertPairedSnapshot(
                snapshot: container.snapshot(for: .iPhone(style: .light)),
                named: "iOS18.5_\(snapshotName)_LIGHT",
                swiftUIPrecision: 0.972
            )
            assertPairedSnapshot(
                snapshot: container.snapshot(for: .iPhone(style: .dark)),
                named: "iOS18.5_\(snapshotName)_DARK",
                swiftUIPrecision: 0.972
            )
        } 
    }
    
    func test_fail_expandableCardView_with_content() {
        // GIVEN
        let (sut, container) = makeSUT()
        let image = WrapKit.Image(systemName: "star")
        let snapshotName = "EXPANDABLECARDVIEW_WITH_CONTENT"
        
        // WHEN
        let primeModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .systemRed,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 1,
                titleValueNumberOfLines: 1),
            backgroundImage: .init(image: .asset(image)),
            title: .text("Prime title"),
            leadingTitles: .init(.text("First title"), .text("Second title")),
            trailingImage: .init(image: .asset(image)),
            valueTitle: .text("Value title")
        )
        
        let secondaryModel = CardViewPresentableModel(
            id: "prime",
            style: .init(
                backgroundColor: .cyan,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .black,
                titleKeyTextColor: .blue,
                trailingTitleKeyTextColor: .black,
                titleValueTextColor: .blue,
                subTitleTextColor: .black,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleKeyLabelFont: .systemFont(ofSize: 32),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 32),
                titleValueLabelFont: .systemFont(ofSize: 32),
                subTitleLabelFont: .systemFont(ofSize: 32),
                cornerRadius: 10,
                stackSpace: 2,
                hStackViewSpacing: 2,
                titleKeyNumberOfLines: 1,
                titleValueNumberOfLines: 1),
            backgroundImage: .init(image: .asset(image)),
            title: .text("Secondary title"),
            trailingTitles: .init(.text("First title"), .text("Second title")),
            leadingImage: .init(image: .asset(image)),
        )
        
        sut.stackView.spacing = 10
        sut.primeCardView.constrainHeight(120)
        sut.secondaryCardView.constrainHeight(120)
        
        sut.display(model: .init(primeModel, secondaryModel))
        
        sut.layoutIfNeeded()
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension ExpandableCardViewSnapshotTests {
    func recordPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        record(
            snapshot: snapshot,
            named: uiKitSnapshotName(for: name),
            file: file,
            line: line
        )
    }

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        swiftUIPrecision: Float? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uiKitName = resolvedUIKitSnapshotName(for: name, file: file)
        assert(snapshot: snapshot, named: uiKitName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assert(
                snapshot: swiftUISnapshot,
                named: uiKitName,
                precision: swiftUIPrecision ?? swiftUISnapshotPrecision,
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
        let uiKitName = resolvedUIKitSnapshotName(for: name, file: file)
        assertFail(snapshot: snapshot, named: uiKitName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertFail(
                snapshot: swiftUISnapshot,
                named: uiKitName,
                precision: swiftUIFailSnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func uiKitSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(snapshotName)"
    }

    func resolvedUIKitSnapshotName(for snapshotName: String, file: StaticString) -> String {
        let prefixed = uiKitSnapshotName(for: snapshotName)
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
        snapshotName.hasSuffix("_DARK") ? .dark : .light
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedExpandableCardViewSnapshotSUT, container: UIView) {
        
        let sut = PairedExpandableCardViewSnapshotSUT()
        let container = makeContainer()
        
        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(390, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        currentPairedSUT = sut
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        container.backgroundColor = .clear
        return container
    }
}

