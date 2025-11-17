//
//  LabelSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

class LabelSnapshotTests: XCTestCase {
    func test_labelOutput_default_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(model: .text("default"))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_DEFAULT_STATE_DARK")
    }
    
    func test_fail_labelOutput_default_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(model: .text("nothing"))
        
        // THEN
        assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_DEFAULT_STATE_LIGHT")
        assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_DEFAULT_STATE_DARK")
    }
    
    func test_labelOutput_long_text() {
        //GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_LONG_TITLE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_LONG_TITLE_DARK")
    }
    
    func test_labelOutput_hidden_text() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: false)
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_HIDDEN_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_HIDDEN_DARK")
    }
    
    func test_labelOutput_withInsets() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.textInsets = UIEdgeInsets(top: 10, left: 80, bottom: 10, right: 20)
        sut.backgroundColor = .cyan
        sut.display(model: .text("Insetted text"))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_INSETS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_INSETS_DARK")
    }
    
    // MARK: - attributedText перезаписывает обычный text
    func tests_labelOutput_multiple_display() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(text: "First text")
        
        let secondText = TextAttributes(text: "Second Text")
        
        sut.display(attributes: [secondText])
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_MULTIPLE_DISPLAY_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_MULTIPLE_DISPLAY_DARK")
    }
    
    // MARK: - Corener Style tests
    func test_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.cornerStyle = .automatic
        sut.backgroundColor = .systemBlue
        sut.display(model: .text("Rounded"))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNER_AUTOMATIC_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNER_AUTOMATIC_DARK")
    }
    
    func test_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.cornerStyle = .fixed(100)
        sut.backgroundColor = .systemBlue
        sut.display(model: .text("Rounded"))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNER_FIXED_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNER_FIXED_DARK")
    }
    
    func test_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.cornerStyle = .none
        sut.backgroundColor = .systemBlue
        sut.display(model: .text("Rounded"))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNER_NONE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNER_NONE_DARK")
    }
    
    //MARK: - Tests for display with TextAttributes
    func test_labelOutput_with_color() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let blue = TextAttributes(text: "Blue", color: .systemBlue)
        let yellow = TextAttributes(text: "Yellow", color: .systemYellow)
        
        sut.display(model: .attributes([blue, yellow]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_COLOR_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_COLOR_DARK")
    }
    
    func test_labelOutput_with_font_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 16))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 16))
        
        sut.display(model: .attributes([bold, regular]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_FONT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_FONT_DARK")
    }
    
    func test_labelOutput_with_singleLineText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let single = TextAttributes(text: "Single", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])
        
        sut.display(model: .attributes([single, line]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_SINGLELINE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_SINGLELINE_DARK")
    }
    
    // TODO: - strange double line layout
    func test_labelOutput_with_doubleLineText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let double = TextAttributes(text: "Double", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])
        
        sut.display(model: .attributes([double, line]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DOUBLELINE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DOUBLELINE_DARK")
    }
    
    // TODO: - byWord doesnt work.
    func test_labelOutput_with_byWordText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .byWord])
        
        sut.display(model: .attributes([byWord]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_BYWORD_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_BYWORD_DARK")
    }
    
    // TODO: - Dash doesnt work.
    func test_labelOutput_with_patternDashText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.patternDash])
        
        sut.display(model: .attributes([dashed]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DASH_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DASH_DARK")
    }
    
    // TODO: - DashDot doesnt work.
    func test_labelOutput_with_patternDashDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.patternDashDot])
        
        sut.display(model: .attributes([dashDot]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DASHDOT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DASHDOT_DARK")
    }
    
    // TODO: - DashDotDot doesnt work.
    func test_labelOutput_with_patterntDashDotDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.patternDashDotDot])
        
        sut.display(model: .attributes([dashDotDot]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DASHDOTDOT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DASHDOTDOT_DARK")
    }
    
    // TODO: - Dot doesnt work.
    func test_labelOutput_with_patterntDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.patternDot])
        
        sut.display(model: .attributes([dot]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DOT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DOT_DARK")
    }
    
    func test_labelOutput_with_thickUnderline_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let thick = TextAttributes(text: "Thick string", underlineStyle: [.thick])
        
        sut.display(model: .attributes([thick]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_THICK_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_THICK_DARK")
    }
    
    // TODO: - leading image doesnt work.
    func test_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(named: "mini"))
        
        sut.display(model: .attributes([leadingImage]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_LEADINGIMAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_LEADINGIMAGE_DARK")
    }
    
    // TODO: - trailing image doesnt work.
    func test_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let sut = makeSUT()
        
        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(named: "mini"))
        
        sut.display(model: .attributes([trailingImage]))
        
        //THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_TRAILINGIMAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_TRAILINGIMAGE_DARK")
    }
    
    // MARK: - Tests for label taps
    func test_labelOutput_textAttributesOnTap() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 3
    
        // WHEN
        let first_attr = TextAttributes(text: "First") { [weak sut] in
            sut?.backgroundColor = .red
            exp.fulfill()
        }
        let second_attr = TextAttributes(text: "Second") { [weak sut] in
            sut?.cornerStyle = .fixed(20)
            exp.fulfill()
        }
        
        let third_attr = TextAttributes(text: "Third") { [weak sut] in
            let updatedThird = TextAttributes(text: "Updated Third!")
            sut?.display(attributes: [first_attr, second_attr, updatedThird])
            exp.fulfill()
        }
        
        sut.display(model: .attributes([first_attr, second_attr, third_attr]))
        
        first_attr.onTap?()
        second_attr.onTap?()
        third_attr.onTap?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_DARK")
    }
    
    func test_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for animation completion")

        let mapToString: (Double) -> TextOutputPresentableModel = { value in
            return .text(String(format: "%.0f", value))
        }

        // WHEN
        sut.display(
            id: "testAnimation",
            from: 0,
            to: 100,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.1
        ) { [weak sut] in
            sut?.backgroundColor = .cyan
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_ANIMATED_FINAL_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)),
               named: "LABEL_ANIMATED_FINAL_STATE_DARK")
    }
    
    func test_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let sut = makeSUT()
    
        sut.textColor = .red
        sut.font = .systemFont(ofSize: 16)
        sut.textAlignment = .right
        
        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .blue)
        let regular = TextAttributes(text: "Text attribute with default label color")
        
        sut.display(model: .attributes([bold, regular]))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_DARK")
    }
    
    func test_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let sut = makeSUT()
        
        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(20), insets: .init(top: 20, leading: 50, bottom: 20, trailing: 20)))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNERSTYLE_INSETS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNERSTYLE_INSETS_DARK")
    }
}
extension LabelSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Label {
        let sut = Label()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        return sut
    }
}
