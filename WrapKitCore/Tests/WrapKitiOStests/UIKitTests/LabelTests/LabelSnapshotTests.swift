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
<<<<<<< HEAD
        let (sut, container) = makeSUT()
        
=======
        let sut = makeSUT()
>>>>>>> main
        // WHEN
        sut.display(model: .text("default"))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_DEFAULT_STATE_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_DEFAULT_STATE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_DEFAULT_STATE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_DEFAULT_STATE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_DEFAULT_STATE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_fail_labelOutput_default_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(model: .text("nothing"))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_DEFAULT_STATE_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_DEFAULT_STATE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_DEFAULT_STATE_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_DEFAULT_STATE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_long_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))
        
<<<<<<< HEAD
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_LONG_TITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_LONG_TITLE_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_LONG_TITLE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_LONG_TITLE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_LONG_TITLE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_LONG_TITLE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_hidden_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: false)
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_HIDDEN_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_HIDDEN_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_HIDDEN_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_HIDDEN_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_HIDDEN_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_withInsets() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.textInsets = UIEdgeInsets(top: 10, left: 80, bottom: 10, right: 20)
        sut.backgroundColor = .cyan
        sut.display(model: .text("Insetted text"))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_INSETS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_INSETS_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_INSETS_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_INSETS_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_INSETS_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_INSETS_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // MARK: - attributedText перезаписывает обычный text
    func tests_labelOutput_multiple_display() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(text: "First text")
        
        let secondText = TextAttributes(text: "Second Text")
        
        sut.display(attributes: [secondText])
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_MULTIPLE_DISPLAY_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_MULTIPLE_DISPLAY_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_MULTIPLE_DISPLAY_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_MULTIPLE_DISPLAY_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_MULTIPLE_DISPLAY_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_MULTIPLE_DISPLAY_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // MARK: - Corener Style tests
    func test_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.cornerStyle = .automatic
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNER_AUTOMATIC_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNER_AUTOMATIC_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_CORNER_AUTOMATIC_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_CORNER_AUTOMATIC_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_CORNER_AUTOMATIC_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_CORNER_AUTOMATIC_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.cornerStyle = .fixed(100)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNER_FIXED_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNER_FIXED_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_CORNER_FIXED_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_CORNER_FIXED_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_CORNER_FIXED_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_CORNER_FIXED_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.cornerStyle = CornerStyle.none
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNER_NONE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNER_NONE_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_CORNER_NONE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_CORNER_NONE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_CORNER_NONE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_CORNER_NONE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    //MARK: - Tests for display with TextAttributes
    func test_labelOutput_with_color() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let blue = TextAttributes(text: "Blue", color: .blue)
        let yellow = TextAttributes(text: "Yellow", color: .yellow)
        
        sut.display(model: .attributes([blue, yellow]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_COLOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_COLOR_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_COLOR_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_COLOR_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_COLOR_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_COLOR_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_font_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 16))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 16))
        
        sut.display(model: .attributes([bold, regular]))
<<<<<<< HEAD
        
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_FONT_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_FONT_DARK")
=======

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_FONT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_FONT_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_FONT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_FONT_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_singleLineText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let single = TextAttributes(text: "Single", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])
        
        sut.display(model: .attributes([single, line]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_SINGLELINE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_SINGLELINE_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_SINGLELINE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_SINGLELINE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_SINGLELINE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_SINGLELINE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // TODO: - strange double line layout
    func test_labelOutput_with_doubleLineText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let double = TextAttributes(text: "Double", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])
        
        sut.display(model: .attributes([double, line]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DOUBLELINE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DOUBLELINE_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_DOUBLELINE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_DOUBLELINE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_DOUBLELINE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_DOUBLELINE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // TODO: - byWord doesnt work.
    func test_labelOutput_with_byWordText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .byWord])
        
        sut.display(model: .attributes([byWord]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_BYWORD_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_BYWORD_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_BYWORD_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_BYWORD_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_BYWORD_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_BYWORD_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // TODO: - Dash doesnt work.
    func test_labelOutput_with_patternDashText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.patternDash])
        sut.backgroundColor = .cyan
        
        sut.display(model: .attributes([dashed]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DASH_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DASH_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_DASH_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_DASH_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_DASH_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_DASH_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // TODO: - DashDot doesnt work.
    func test_labelOutput_with_patternDashDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.patternDashDot])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dashDot]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DASHDOT_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DASHDOT_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_DASHDOT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_DASHDOT_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_DASHDOT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_DASHDOT_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // TODO: - DashDotDot doesnt work.
    func test_labelOutput_with_patterntDashDotDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.patternDashDotDot])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dashDotDot]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DASHDOTDOT_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DASHDOTDOT_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_DASHDOTDOT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_DASHDOTDOT_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_DASHDOTDOT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_DASHDOTDOT_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // TODO: - Dot doesnt work.
    func test_labelOutput_with_patterntDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.patternDot])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dot]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_DOT_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_DOT_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_DOT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_DOT_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_DOT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_DOT_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_thickUnderline_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let thick = TextAttributes(text: "Thick string", underlineStyle: [.thick])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([thick]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_THICK_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_THICK_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_THICK_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_THICK_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_THICK_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_THICK_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star.fill"))
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([leadingImage]))
<<<<<<< HEAD
        
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_LEADINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_LEADINGIMAGE_DARK")
=======

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_LEADINGIMAGE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_LEADINGIMAGE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_LEADINGIMAGE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_LEADINGIMAGE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        
        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star.fill"))
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([trailingImage]))
        
<<<<<<< HEAD
        //THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_TRAILINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_TRAILINGIMAGE_DARK")
=======
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_TRAILINGIMAGE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_TRAILINGIMAGE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_TRAILINGIMAGE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_TRAILINGIMAGE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    // MARK: - Tests for label taps
    func test_labelOutput_textAttributesOnTap() {
        // GIVEN
        let (sut, container) = makeSUT()
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
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let (sut, container) = makeSUT()
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
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "LABEL_ANIMATED_FINAL_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "LABEL_ANIMATED_FINAL_STATE_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_ANIMATED_FINAL_STATE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_ANIMATED_FINAL_STATE_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_ANIMATED_FINAL_STATE_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_ANIMATED_FINAL_STATE_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let (sut, container) = makeSUT()
    
        sut.textColor = .red
        sut.font = .systemFont(ofSize: 16)
        sut.textAlignment = .right
        
        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .blue)
        let regular = TextAttributes(text: "Text attribute with default label color")
        
        sut.display(model: .attributes([bold, regular]))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
    
    func test_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(20), insets: .init(top: 20, leading: 50, bottom: 20, trailing: 20)))
        
        // THEN
<<<<<<< HEAD
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "LABEL_CORNERSTYLE_INSETS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "LABEL_CORNERSTYLE_INSETS_DARK")
=======
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_LABEL_CORNERSTYLE_INSETS_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_LABEL_CORNERSTYLE_INSETS_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_LABEL_CORNERSTYLE_INSETS_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_LABEL_CORNERSTYLE_INSETS_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
>>>>>>> main
    }
}

extension LabelSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: Label, container: UIView) {
        let sut = Label()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(150, priority: .required)
        )
        
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
