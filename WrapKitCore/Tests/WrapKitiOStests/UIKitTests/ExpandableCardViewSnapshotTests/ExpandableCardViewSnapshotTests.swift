//
//  ExpandableCardViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class ExpandableCardViewSnapshotTests: XCTestCase {
    func test_expandableCardView_default_state() {
        let (sut, container) = makeSUT()
        
        sut.primeCardView.backgroundColor = .systemRed
        sut.secondaryCardView.backgroundColor = .systemBlue
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_DEFAULT_STATE_DARK")
    }
    
    func test_expandableCardView_only_prime_card_visible() {
        let (sut, container) = makeSUT()
        
        sut.primeCardView.backgroundColor = .white
        sut.primeCardView.layer.cornerRadius = 12
        sut.primeCardView.layer.shadowColor = UIColor.black.cgColor
        sut.primeCardView.layer.shadowOpacity = 0.1
        sut.primeCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        sut.primeCardView.layer.shadowRadius = 8
        
        // Secondary card is hidden by default
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_ONLY_PRIME_VISIBLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_ONLY_PRIME_VISIBLE_DARK")
    }
    
    func test_expandableCardView_both_cards_visible() {
        let (sut, container) = makeSUT()
        
        sut.primeCardView.backgroundColor = .white
        sut.primeCardView.layer.cornerRadius = 12
        
        sut.secondaryCardView.isHidden = false
        sut.secondaryCardView.backgroundColor = .systemGray6
        sut.secondaryCardView.layer.cornerRadius = 12
        
        sut.stackView.spacing = 8
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_BOTH_VISIBLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_BOTH_VISIBLE_DARK")
    }
    
    func test_expandableCardView_expanded_with_spacing() {
        let (sut, container) = makeSUT()
        
        sut.primeCardView.backgroundColor = .systemBlue
        sut.secondaryCardView.backgroundColor = .systemGreen
        sut.secondaryCardView.isHidden = false
        
        sut.stackView.spacing = 50
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_WITH_SPACING_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_WITH_SPACING_DARK")
    }
    
    func test_expandableCardView_expanded_no_spacing() {
        let (sut, container) = makeSUT()
        
        sut.primeCardView.backgroundColor = .systemBlue
        sut.secondaryCardView.backgroundColor = .systemGreen
        sut.secondaryCardView.isHidden = false
        
        sut.stackView.spacing = 0
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_NO_SPACING_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_NO_SPACING_DARK")
    }
    
    func test_expandableCardView_display_only_prime_model() {
        let (sut, container) = makeSUT()
        
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
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_DISPLAY_PRIME_ONLY_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_DISPLAY_PRIME_ONLY_DARK")
    }
    
    func test_expandableCardView_display_both_models() {
        let (sut, container) = makeSUT()
        
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
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_DISPLAY_BOTH_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_DISPLAY_BOTH_DARK")
    }
    
    func test_expandableCardView_different_card_heights() {
        let (sut, container) = makeSUT()
        
        sut.primeCardView.backgroundColor = .systemBlue
        sut.primeCardView.constrainHeight(60)
        
        sut.secondaryCardView.isHidden = false
        sut.secondaryCardView.backgroundColor = .systemGreen
        sut.secondaryCardView.constrainHeight(120)
        
        sut.stackView.spacing = 8
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_DIFFERENT_HEIGHTS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_DIFFERENT_HEIGHTS_DARK")
    }
    
    func test_expandableCardView_with_content() {
        let (sut, container) = makeSUT()
        let image = Image(systemName: "star.fill")
        
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
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EXPANDABLECARDVIEW_WITH_CONTENT_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EXPANDABLECARDVIEW_WITH_CONTENT_dARK")
    }
}

extension ExpandableCardViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ExpandableCardView, container: UIView) {
        
        let sut = ExpandableCardView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(390, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        container.backgroundColor = .clear
        return container
    }
}
