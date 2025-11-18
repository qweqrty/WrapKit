//
//  CardViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 11/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class CardViewSnapshotTests: XCTestCase {
    
    private let image = Image(systemName: "star.fill")
    private let secondImage = Image(systemName: "star")
    
    func test_CardView_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_DEFAULT_STATE_DARK")
    }
    
    func test_CardView_with_backgroundImage() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .init(image: .asset(image)))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_DARK")
    }
    
    func test_CardView_with_backgroundImage_contentModeIsFit_false() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .init(image: .asset(image), contentModeIsFit: false))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODE_ISFIT_FALSELIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODEISFIT_FALSE_DARK")
    }
    
    func test_CardView_with_backgroundImage_borederWidth_and_color() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR_DARK")
    }
    
    func test_CardView_with_backgroundImage_cornderRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image = Image(systemName: "star.fill")
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                          ))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS_DARK")
    }
    
    func test_CardView_with_backgroundImage_alpha() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                           alpha: 0.3
                                          ))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA_DARK")
    }
    
    func test_CardView_with_leadingTitles() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingTitles:
                .init(.text("First"), .text("Second"))
        )
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_LEADINGTITLES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_LEAIDNGTITLES_DARK")
    }
    
    func test_CardView_with_trailingTitles() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingTitles: .init(.text("First"), .text("Second")))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_TRAILINGTITLES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_TRAILINGTITLES_DARK")
    }
    
    func test_CardView_with_leadingImage() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingImage: .init(image: .asset(image)))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_LEADINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_LEADINGIMAGE_DARK")
    }
    
    func test_CardView_with_trailingImage() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingImage: .init(image: .asset(image)))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_TRAILINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_TRAILINGIMAGE_DARK")
    }
    
    func test_CardView_with_secondaryTrailingImage() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(secondaryTrailingImage: .init(image: .asset(secondImage)))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_SECONDARYTRAILINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_SECONDARYTRAILINGIMAGE_DARK")
    }
    
    func test_CardView_with_subTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(subTitle: .text("Subtitle"))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_SUBTITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_SUBTITLE_DARK")
    }
    
    func test_CardView_with_valueTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(valueTitle: .text("Value title"))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_VALUETITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_VALUETITLE_DARK")
    }
    
    func test_CardView_with_title_value_subtitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(title: .text("Title"))
        sut.display(subTitle: .text("Subtitle"))
        sut.display(valueTitle: .text("Value title"))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_SUBVALUETITLES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_SUBVALUETITLES_DARK")
    }
    
    func test_CardView_with_bottomSeparator() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .black,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .green,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 0
        ))
        
        sut.display(title: .text("Title"))
        sut.display(bottomSeparator: .init(color: .lightGray, height: 4))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BOTTOMSEPARATOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BOTTOMSEPARATOR_DARK")
    }
    
    func test_CardView_with_switchControl() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(switchControl: .init(
            isOn: true,
            isEnabled: true,
            style: .init(tintColor: .blue, thumbTintColor: .green, backgroundColor: .white, cornerRadius: 10)
        ))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_SWITCHCONTROL_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_SWITCHCONTROL_DARK")
    }
    
    func test_CardView_with_switchControl_isFalse() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(switchControl: .init(
            isOn: false,
            isEnabled: true,
            style: .init(tintColor: .blue, thumbTintColor: .green, backgroundColor: .white, cornerRadius: 10)
        ))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_SWITCHCONTROL_ISFALSE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_SWITCHCONTROL_ISFALSE_DARK")
    }
    
    // TODO: - need to simulate real tap
    func test_CardView_onPress() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .systemGreen
        })
        
        sut.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_ONPRESS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_ONPRESS_DARK")
    }
    
    // TODO: - need to simulate real tap
    func test_CardView_onLongPress() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .systemGreen
        })
        
        sut.onLongPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_ONLONGPRESS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_ONLONGPRESS_DARK")
    }
    
    func test_CardView_isHidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(isHidden: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_ISHIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_ISHIDDEN_DARK")
    }
}

extension CardViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: CardView, container: UIView) {
        let sut = CardView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(200, priority: .required)
        )
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeDefaultStyle() -> CardViewPresentableModel.Style {
        return .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        )
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
