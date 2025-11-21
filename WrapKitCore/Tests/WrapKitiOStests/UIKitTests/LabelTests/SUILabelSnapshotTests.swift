//
//  SUILabelSnapshotTests.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 19/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import SwiftUI

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
final class SUILabelSnapshotTests: XCTestCase {
    private lazy var defaultFont: UIFont = Label().font
    
    func test_labelOutput_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"
        
        // WHEN
        sut.display(model: .text("default"))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
    }
    
    func test_fail_labelOutput_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"
        
        // WHEN
        sut.display(model: .text("nothing"))
        
        // THEN
        assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
    }
    
    func test_labelOutput_long_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))
        
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        }
    }
    
    func test_labelOutput_hidden_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: false)
        
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
    }
    
    func test_labelOutput_withInsets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_INSETS"
        
        // WHEN
        sut.display(model: .textStyled(text: .text("Insetted text"), cornerStyle: nil, insets: EdgeInsets(top: 10, leading: 80, bottom: 10, trailing: 20), height: 150, backgroundColor: .cyan))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else { // cyan color differs
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - attributedText перезаписывает обычный text
    func tests_labelOutput_multiple_display() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_MULTIPLE_DISPLAY"
        // WHEN
        sut.display(text: "First text")
        
        let secondText = TextAttributes(text: "Second Text")
        
        sut.display(attributes: [secondText])
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.3.1_\(snapshotName)_DARK") // UIKit helps anti-aliasing
    }
    
    // MARK: - Corener Style tests
    func test_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"
        
        // WHEN
        sut.display(model: .textStyled(text: .text("Rounded"), cornerStyle: .automatic, insets: .zero, height: 150, backgroundColor: .blue))
        // THEN
        if #available(iOS 26, *) {
            let precision: Float = 0.99942833 // ios 26 draws radius more accurate than 18
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", precision: precision)
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", precision: precision)
        } else {
            let precision: Float = 0.9994094
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT", precision: precision)
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK", precision: precision)
        }
    }
    
    func test_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"
        
        // WHEN
//        sut.cornerStyle = .fixed(30)
//        sut.backgroundColor = .blue
        sut.display(model: .textStyled(text: .text("Rounded"), cornerStyle: .fixed(30), insets: .zero, height: 150, backgroundColor: .blue))
        let precision: Float = 0.99983
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", precision: precision)
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", precision: precision)
        } else { // on 18 passes with lower precision: 0.99981, because of label
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT", precision: precision)
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK", precision: precision)
        }
    }
    
    func test_fail_labelOutput_with_fixedCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"
        
        sut.display(model: .textStyled(text: .text("Rounded"), cornerStyle: .fixed(29), insets: .zero, height: 150, backgroundColor: .blue))
        assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
    }
    
    func test_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"
        
        // WHEN
//        sut.cornerStyle = CornerStyle.none
//        sut.backgroundColor = .blue
        sut.display(model: .textStyled(text: .text("Rounded"), cornerStyle: CornerStyle.none, insets: .zero, height: 150, backgroundColor: .blue))
        
        // THEN
        if #available(iOS 26, *) { // differs anti-aliasing on iOS 18 light
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - Tests for display with TextAttributes
    func test_labelOutput_with_color() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"
        
        //WHEN
        let blue = TextAttributes(text: "Blue", color: .blue)
        let yellow = TextAttributes(text: "Yellow", color: .yellow)
        
        sut.display(model: .attributes([blue, yellow]))
        
        // THEN
        if #available(iOS 26, *) { // need UIKit for anti-aliasing
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_with_font_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_FONT"
        
        //WHEN
        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 16))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 16))
        
        sut.display(model: .attributes([bold, regular]))

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
    }
    
//    func test_labelOutput_with_singleLineText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"
//        //WHEN
//        let single = TextAttributes(text: "Single", underlineStyle: [.single])
//        let line = TextAttributes(text: "Line", underlineStyle: [.single])
//        
//        sut.display(model: .attributes([single, line]))
//        
////        if #available(iOS 26, *) {
////            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
////            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
////        } else {
//        // lineSpacing is not working in SwiftUI for Tests
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
////        }
//    }
//    
//    // TODO: - strange double line layout
//    func test_labelOutput_with_doubleLineText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"
//        
//        //WHEN
//        let double = TextAttributes(text: "Double", underlineStyle: [.double])
//        let line = TextAttributes(text: "Line", underlineStyle: [.double])
//        
//        sut.display(model: .attributes([double, line]))
//        
//        // THEN
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        } else {
//            XCTFail("Please download given os in Xcode Manage Run Destinations...")
//        }
//    }
//    
//    // TODO: - byWord doesnt work.
//    func test_labelOutput_with_byWordText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_BYWORD"
//        
//        //WHEN
//        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .byWord])
//        
//        sut.display(model: .attributes([byWord]))
//        
//        // THEN
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        } else {
//            XCTFail("Please download given os in Xcode Manage Run Destinations...")
//        }
//    }
//    
//    // TODO: - Dash doesnt work.
//    func test_labelOutput_with_patternDashText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_DASH"
//        
//        //WHEN
//        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.patternDash])
////        sut.backgroundColor = .cyan
//        
//        sut.display(model: .textStyled(text: .attributes([dashed]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .cyan))
//        
//        // THEN
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        } else {
//            XCTFail("Please download given os in Xcode Manage Run Destinations...")
//        }
//    }
//    
//    // TODO: - DashDot doesnt work.
//    func test_labelOutput_with_patternDashDotText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"
//        
//        //WHEN
//        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.patternDashDot])
////        sut.backgroundColor = .systemBlue
//        
//        sut.display(model: .textStyled(text: .attributes([dashDot]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue))
//        
//        // THEN
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        } else {
//            XCTFail("Please download given os in Xcode Manage Run Destinations...")
//        }
//    }
//    
//    // TODO: - DashDotDot doesnt work.
//    func test_labelOutput_with_patterntDashDotDotText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"
//        
//        //WHEN
//        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.patternDashDotDot])
////        sut.backgroundColor = .systemBlue
//        
//        sut.display(model: .textStyled(text: .attributes([dashDotDot]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue))
//        
//        // THEN
////        if #available(iOS 26, *) {
////            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
////            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
////        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
////        } else {
////            XCTFail("Please download given os in Xcode Manage Run Destinations...")
////        }
//    }
//    
//    // TODO: - Dot doesnt work.
//    func test_labelOutput_with_patterntDotText_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_DOT"
//        
//        //WHEN
//        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.patternDot])
////        sut.backgroundColor = .systemBlue
//        
//        sut.display(model: .textStyled(text: .attributes([dot]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue))
//        
//        // THEN
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        } else {
//            XCTFail("Please download given os in Xcode Manage Run Destinations...")
//        }
//    }
//    
//    func test_labelOutput_with_thickUnderline_attributes() {
//        //GIVEN
//        let (sut, container) = makeSUT()
//        let snapshotName = "LABEL_TITLE_WITH_THICK"
//        
//        //WHEN
//        let thick = TextAttributes(text: "Thick string", underlineStyle: [.thick])
////        sut.backgroundColor = .systemBlue
//        
//        sut.display(model: .textStyled(text: .attributes([thick]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue))
//        
//        // THEN
//        if #available(iOS 26, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
//        } else if #available(iOS 18.3.1, *) {
//            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
//            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
//        } else {
//            XCTFail("Please download given os in Xcode Manage Run Destinations...")
//        }
//    }
    
    func test_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star.fill"))
//        sut.backgroundColor = .systemBlue
        
        sut.display(model: .textStyled(text: .attributes([leadingImage]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"
        
        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star.fill"))
//        sut.backgroundColor = .systemBlue
        
        sut.display(model: .textStyled(text: .attributes([trailingImage]), cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - Tests for label taps
    func test_labelOutput_textAttributesOnTap() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP"
        
        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 3
        
        // WHEN
        let first_attr = TextAttributes(text: "First") { [weak sut] in
//            sut?.backgroundColor = .red
            exp.fulfill()
        }
        let second_attr = TextAttributes(text: "Second") { [weak sut] in
//            sut?.cornerStyle = .fixed(20)
            exp.fulfill()
        }
        
        let third_attr = TextAttributes(text: "Third") { [weak sut] in
            let updatedThird = TextAttributes(text: "Updated Third!")
//            sut?.display(attributes: [first_attr, second_attr, updatedThird])
            sut?.display(model: .textStyled(text: .attributes([first_attr, second_attr, updatedThird]), cornerStyle: .fixed(20), insets: .zero, height: 150, backgroundColor: .red))
            exp.fulfill()
        }
        
        sut.display(model: .textStyled(text: .attributes([first_attr, second_attr, third_attr]), cornerStyle: .fixed(20), insets: .zero, height: 150, backgroundColor: .red))
        
        first_attr.onTap?()
        second_attr.onTap?()
        third_attr.onTap?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_ANIMATED_FINAL_STATE"
        
        let exp = expectation(description: "Wait for animation completion")

        let mapToString: (Double) -> TextOutputPresentableModel = { value in
            return .text(String(format: "%.0f", value))
        }

        // WHEN
        sut.display(
            from: 0,
            to: 100,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.1
        ) { [weak sut] in
//            sut?.backgroundColor = .cyan
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"
        
        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .blue, font: .systemFont(ofSize: 16))
        let regular = TextAttributes(text: "Text attribute with default label color", color: .red, font: .systemFont(ofSize: 16), textAlignment: .right)
        
        sut.display(model: .attributes([bold, regular]))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"
        
        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(20), insets: .init(top: 20, leading: 50, bottom: 20, trailing: 20)))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
    }
}

@available(iOS 17, *)
extension SUILabelSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: TextOutput, container: any SwiftUI.View) {
        let adapter = TextOutputSwiftUIAdapter()
        
        let view = VStack(spacing: .zero) {
            SUILabel(adapter: adapter)
                .font(.system(size: 20).leading(.loose))
//                .lineSpacing(5)
//                .baselineOffset(5)
                .frame(height: 150, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            Spacer()
        }
        
        checkForMemoryLeaks(adapter, file: file, line: line)
        return (adapter.weakReferenced, view)
    }
}
