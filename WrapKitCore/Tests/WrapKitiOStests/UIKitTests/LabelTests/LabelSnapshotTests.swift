//
//  LabelSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import SwiftUI

final class LabelSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedLabelSnapshotSUT?

    override func tearDown() {
        currentPairedSUT = nil
        super.tearDown()
    }

    func test_labelOutput_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"
        
        // WHEN
        sut.display(model: .text("default"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_labelOutput_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"
        
        // WHEN
        sut.display(model: .text("nothing"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_long_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))
        
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_labelOutput_long_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines."))
        
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_hidden_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: false)
        
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_labelOutput_hidden_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: true)
        
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_withInsets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_INSETS"
        
        // WHEN
        sut.textInsets = UIEdgeInsets(top: 10, left: 80, bottom: 10, right: 20)
        sut.backgroundColor = .cyan
        sut.display(model: .text("Insetted text"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_labelOutput_withInsets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_INSETS"
        
        // WHEN
        sut.textInsets = UIEdgeInsets(top: 15, left: 80, bottom: 10, right: 25)
        sut.backgroundColor = .cyan
        sut.display(model: .text("Insetted text"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func tests_fail_labelOutput_multiple_display() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_MULTIPLE_DISPLAY"
        // WHEN
        sut.display(text: "First text.")
        
        let secondText = TextAttributes(text: "Second Text.")
        
        sut.display(attributes: [secondText])
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // MARK: - Corener Style tests
    func test_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"
        
        // WHEN
        sut.cornerStyle = .automatic
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"
        
        // WHEN
        sut.cornerStyle = CornerStyle.none
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"
        
        // WHEN
        sut.cornerStyle = .fixed(30)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"
        
        // WHEN
        sut.cornerStyle = .fixed(31)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"
        
        // WHEN
        sut.cornerStyle = CornerStyle.none
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"
        
        // WHEN
        sut.cornerStyle = .fixed(1)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_color() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"
        
        //WHEN
        let blue = TextAttributes(text: "Blue", color: .systemBlue)
        let yellow = TextAttributes(text: "Yellow", color: .systemYellow)
        
        sut.display(model: .attributes([blue, yellow]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_font_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_FONT"
        
        //WHEN
        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 17))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 15))
        
        sut.display(model: .attributes([bold, regular]))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_singleLineText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"
        //WHEN
        let single = TextAttributes(text: "Single", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])
        
        sut.display(model: .attributes([single, line]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_singleLineText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"
        //WHEN
        let single = TextAttributes(text: "Single", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])
        
        sut.display(model: .attributes([single, line]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // TODO: - strange double line layout
    func test_labelOutput_with_doubleLineText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"
        
        //WHEN
        let double = TextAttributes(text: "Double", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])
        
        sut.display(model: .attributes([double, line]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_doubleLineText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"
        
        //WHEN
        let double = TextAttributes(text: "Double", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])
        
        sut.display(model: .attributes([double, line]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // TODO: - byWord doesnt work.
    func test_labelOutput_with_byWordText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_BYWORD"
        
        //WHEN
        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .byWord])
        
        sut.display(model: .attributes([byWord]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_byWordText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_BYWORD"
        
        //WHEN
        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .patternDash])
        
        sut.display(model: .attributes([byWord]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // TODO: - Dash doesnt work.
    func test_labelOutput_with_patternDashText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASH"
        
        //WHEN
        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.patternDash])
        sut.backgroundColor = .cyan
        
        sut.display(model: .attributes([dashed]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_patternDashText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASH"
        
        //WHEN
        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.single])
        sut.backgroundColor = .cyan
        
        sut.display(model: .attributes([dashed]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // TODO: - DashDot doesnt work.
    func test_labelOutput_with_patternDashDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"
        
        //WHEN
        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.patternDashDot])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dashDot]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_patternDashDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"
        
        //WHEN
        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dashDot]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // TODO: - DashDotDot doesnt work.
    func test_labelOutput_with_patternDashDotDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"
        
        //WHEN
        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.patternDashDotDot])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dashDotDot]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_patterntDashDotDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"
        
        //WHEN
        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dashDotDot]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    // TODO: - Dot doesnt work.
    func test_labelOutput_with_patternDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOT"
        
        //WHEN
        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.patternDot])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dot]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_patterntDotText_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOT"
        
        //WHEN
        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([dot]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_thickUnderline_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_THICK"
        
        //WHEN
        let thick = TextAttributes(text: "Thick string", underlineStyle: [.thick])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([thick]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_thickUnderline_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_THICK"
        
        //WHEN
        let thick = TextAttributes(text: "Thick string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([thick]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star.fill"))
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([leadingImage]))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star"))
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([leadingImage]))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"
        
        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star.fill"))
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([trailingImage]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"
        
        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star"))
        sut.backgroundColor = .systemBlue
        
        sut.display(model: .attributes([trailingImage]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_textAttributesOnTap() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP"
        
        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 3
        
        // WHEN
        let first_attr = TextAttributes(text: "First") { [weak sut] in
            sut?.backgroundColor = .systemRed
            exp.fulfill()
        }
        let second_attr = TextAttributes(text: "Second") { [weak sut] in
            sut?.cornerStyle = .fixed(21)
            exp.fulfill()
        }
        
        let third_attr = TextAttributes(text: "Third") { [weak sut] in
            let updatedThird = TextAttributes(text: "Updated Third!.")
            sut?.display(attributes: [first_attr, second_attr, updatedThird])
            exp.fulfill()
        }
        
        sut.display(model: .attributes([first_attr, second_attr, third_attr]))
        
        first_attr.onTap?()
        second_attr.onTap?()
        third_attr.onTap?()
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_ANIMATED_FINAL_STATE"
        
        let exp = expectation(description: "Wait for animation completion")

        let mapToString: (Decimal) -> TextOutputPresentableModel.TextModel = { value in
            return .text(String(format: "%.0f", value.doubleValue))
        }

        // WHEN
        sut.display(
            from: 0,
            to: 100,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.1
        ) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.3)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_ANIMATED_FINAL_STATE"
        
        let exp = expectation(description: "Wait for animation completion")

        let mapToString: (Decimal) -> TextOutputPresentableModel.TextModel = { value in
            return .text(String(format: "%.0f", value.doubleValue))
        }

        // WHEN
        sut.display(
            id: "testAnimation",
            from: 0,
            to: 99,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.1
        ) { [weak sut] in
            sut?.backgroundColor = .cyan
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"
        
        sut.textColor = .red
        sut.font = .systemFont(ofSize: 16)
        sut.textAlignment = .right
        
        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .blue)
        let regular = TextAttributes(text: "Text attribute with default label color")
        
        sut.display(model: .attributes([bold, regular]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"
        
        sut.textColor = .red
        sut.font = .systemFont(ofSize: 16)
        sut.textAlignment = .right
        
        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .systemBlue)
        let regular = TextAttributes(text: "Text attribute with default label color.")
        
        sut.display(model: .attributes([bold, regular]))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"
        
        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(20), insets: .init(top: 20, leading: 50, bottom: 20, trailing: 20)))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_fail_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"
        
        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(29), insets: .init(top: 21, leading: 50, bottom: 20, trailing: 20)))
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }

    func test_label_output_html_Br() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_BR"

        // THEN
        sut.display(htmlString: HtmlTestCases.example1, config: .init(size: 13, color: .red))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_boldItalic() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_boldItalic"

        // THEN
        sut.display(htmlString: HtmlTestCases.boldItalic, config: .init(color: .green))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_inlineStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_inlineStyle"

        // THEN
        sut.display(htmlString: HtmlTestCases.inlineStyle, config: .default)

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_paragraphs() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_paragraphs"

        // THEN
        sut.display(htmlString: HtmlTestCases.paragraphs, config: .init(paragraphSpacing: 12))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_lists() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_lists"

        // THEN
        sut.display(htmlString: HtmlTestCases.lists, config: .init(lineSpacing: 8))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_longText() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_longText"

        // THEN
        sut.display(
            htmlString: HtmlTestCases.longText,
            config: .init(textAlignment: .center, lineBreakMode: .byWordWrapping)
        )

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_other() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_other"

        // THEN
        sut.display(htmlString: HtmlTestCases.other, config: .init(color: .red))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_emoji() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_EMOJI_STATE"

        // WHEN
        sut.display(model: .text("it's fine 🙂"))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_utfLikeText() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_FAKE_EMOJI_STATE"

        // WHEN
        sut.display(model: .text("Saima 500+O!TV- SALE 30%_850"))

        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

private enum SnapshotAssertionMode {
    case equal
    case different
}

private extension LabelSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedLabelSnapshotSUT, container: UIView) {
        let sut = PairedLabelSnapshotSUT()
        let container = makeContainer()
        
        container.addSubview(sut.uiKitLabel)
        sut.uiKitLabel.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(150, priority: .required)
        )
        
        currentPairedSUT = sut

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitLabel, file: file, line: line)
        checkForMemoryLeaks(sut.adapter, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        container.backgroundColor = .clear
        return container
    }
    
    func assertCurrentSnapshots(
        in container: UIView,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertCurrentSnapshots(
            in: container,
            named: snapshotName,
            mode: .equal,
            file: file,
            line: line
        )
    }

    func assertCurrentSnapshotsFail(
        in container: UIView,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertCurrentSnapshots(
            in: container,
            named: snapshotName,
            mode: .different,
            file: file,
            line: line
        )
    }

    private func assertCurrentSnapshots(
        in container: UIView,
        named snapshotName: String,
        mode: SnapshotAssertionMode,
        file: StaticString,
        line: UInt
    ) {
        let lightSnapshot = container.snapshot(for: .iPhone(style: .light))
        let darkSnapshot = container.snapshot(for: .iPhone(style: .dark))
        let names = snapshotNames(for: snapshotName)

        switch mode {
        case .equal:
            assertPairedSnapshot(snapshot: lightSnapshot, named: names.light, file: file, line: line)
            assertPairedSnapshot(snapshot: darkSnapshot, named: names.dark, file: file, line: line)
        case .different:
            assertPairedSnapshotFail(snapshot: lightSnapshot, named: names.light, file: file, line: line)
            assertPairedSnapshotFail(snapshot: darkSnapshot, named: names.dark, file: file, line: line)
        }
    }

    private func snapshotNames(for snapshotName: String) -> (light: String, dark: String) {
        let prefix = if #available(iOS 26, *) { "iOS26" } else { "iOS18.5" }
        return ("\(prefix)_\(snapshotName)_LIGHT", "\(prefix)_\(snapshotName)_DARK")
    }
}

private extension LabelSnapshotTests {
    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        saveAssertSnapshot(snapshot, named: assertSnapshotName(for: name, context: "UIKit"), context: "UIKit")
        assertStoredSnapshotEquals(snapshot, named: name, precision: precision, context: "UIKit", file: file, line: line)

        if #available(iOS 17, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            saveAssertSnapshot(swiftUISnapshot, named: assertSnapshotName(for: name, context: "SwiftUI"), context: "SwiftUI")
            assertStoredSnapshotEquals(
                swiftUISnapshot,
                named: name,
                precision: swiftUISnapshotPrecision,
                context: "SwiftUI",
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
        saveAssertSnapshot(snapshot, named: assertSnapshotName(for: name, context: "UIKit"), context: "UIKit")
        assertStoredSnapshotDifferent(snapshot, named: name, precision: precision, context: "UIKit", file: file, line: line)

        if #available(iOS 17, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            saveAssertSnapshot(swiftUISnapshot, named: assertSnapshotName(for: name, context: "SwiftUI"), context: "SwiftUI")
            assertStoredSnapshotDifferent(
                swiftUISnapshot,
                named: name,
                precision: swiftUIFailSnapshotPrecision,
                context: "SwiftUI",
                file: file,
                line: line
            )
        }
    }

    func recordPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        recordUIKitSnapshot(snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
    }

    private var swiftUISnapshotPrecision: Float {
        0.095
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }

    private func colorScheme(from snapshotName: String) -> ColorScheme {
        normalizedSnapshotName(from: snapshotName).hasSuffix("_DARK") ? .dark : .light
    }

    private func recordedSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(normalizedSnapshotName(from: snapshotName))"
    }

    private func assertSnapshotName(for snapshotName: String, context: String) -> String {
        let prefix = context == "SwiftUI" ? "SiwftUI" : "UIKit"
        return "\(prefix)_\(normalizedSnapshotName(from: snapshotName))"
    }

    private func normalizedSnapshotName(from snapshotName: String) -> String {
        if snapshotName.hasPrefix("UIKit_") {
            return String(snapshotName.dropFirst("UIKit_".count))
        }
        if snapshotName.hasPrefix("SiwftUI_") {
            return String(snapshotName.dropFirst("SiwftUI_".count))
        }
        if snapshotName.hasPrefix("SwiftUI_") {
            return String(snapshotName.dropFirst("SwiftUI_".count))
        }
        return snapshotName
    }
}

private extension LabelSnapshotTests {
    private func recordUIKitSnapshot(
        _ snapshot: UIImage,
        named name: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func saveAssertSnapshot(
        _ snapshot: UIImage,
        named name: String,
        context: String
    ) {
        let root = URL(fileURLWithPath: "/Users/ubeishenkulov/Documents/WrapKit/tmp_snapshot_compare/paired_assert", isDirectory: true)
            .appendingPathComponent(context, isDirectory: true)
        let snapshotURL = root.appendingPathComponent("\(name).png")
        guard let snapshotData = snapshot.pngData() else { return }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            // Best-effort helper for local visual comparison.
        }
    }

    private func assertStoredSnapshotEquals(
        _ snapshot: UIImage,
        named name: String,
        precision: Float,
        context: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeReferenceSnapshotURL(named: name, file: file)

        guard
            let storedSnapshotData = try? Data(contentsOf: snapshotURL),
            let oldImage = UIImage(data: storedSnapshotData)
        else {
            if context == "UIKit" {
                recordUIKitSnapshot(snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
                return
            }
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use record mode before asserting.", file: file, line: line)
            return
        }

        guard let diff = Diffing.image(precision: precision).diff(oldImage, snapshot) else { return }

        let normalizedName = normalizedSnapshotName(from: name)
        let uiKitName = recordedSnapshotName(for: normalizedName)
        let currentName = assertSnapshotName(for: normalizedName, context: context)
        let artifactsSubUrl = URL(fileURLWithPath: "/Users/ubeishenkulov/Documents/WrapKit/tmp_snapshot_compare/paired_failures", isDirectory: true)
            .appendingPathComponent(normalizedName)
        try? FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)

        try? storedSnapshotData.write(to: artifactsSubUrl.appendingPathComponent("origin_\(uiKitName).png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("diff_\(currentName).png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("new_\(currentName).png"))

        XCTFail("[\(context)] " + diff.message + "\n Origin: \(uiKitName)\n New: \(currentName)\n Diff snapshot URL: \(artifactsSubUrl)", file: file, line: line)
    }

    private func assertStoredSnapshotDifferent(
        _ snapshot: UIImage,
        named name: String,
        precision: Float,
        context: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeReferenceSnapshotURL(named: name, file: file)

        guard
            let storedSnapshotData = try? Data(contentsOf: snapshotURL),
            let oldImage = UIImage(data: storedSnapshotData)
        else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use record mode before asserting.", file: file, line: line)
            return
        }

        guard Diffing.image(precision: precision).diff(oldImage, snapshot) != nil else {
            XCTFail("[\(context)] Images should be different.", file: file, line: line)
            return
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeReferenceSnapshotURL(named name: String, file: StaticString) -> URL {
        for candidate in referenceSnapshotCandidates(for: name) {
            let url = makeSnapshotURL(named: candidate, file: file)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        return makeSnapshotURL(named: normalizedSnapshotName(from: name), file: file)
    }

    private func referenceSnapshotCandidates(for name: String) -> [String] {
        let normalizedName = normalizedSnapshotName(from: name)
        var candidates = [String]()

        func appendUnique(_ value: String) {
            if !candidates.contains(value) {
                candidates.append(value)
            }
        }

        appendUnique(recordedSnapshotName(for: normalizedName))
        appendUnique(normalizedName)

        // Legacy typo kept for historical snapshots: ...DOUBLELINELIGHT
        if normalizedName.contains("TITLE_WITH_DOUBLELINE_LIGHT") {
            let legacyName = normalizedName.replacingOccurrences(of: "TITLE_WITH_DOUBLELINE_LIGHT", with: "TITLE_WITH_DOUBLELINELIGHT")
            appendUnique("UIKit_\(legacyName)")
            appendUnique(legacyName)
        }

        return candidates
    }
}
