//
//  SUILabelSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class SUILabelSnapshotTests: XCTestCase {
    func test_labelOutput_default_state() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"

        // WHEN
        sut.display(model: .text("default"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_default_state() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"

        // WHEN
        sut.display(model: .text("nothing"))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_long_text() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"

        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_long_text() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"

        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines."))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_hidden_text() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_hidden_text() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"
        //WHEN
        sut.display(text: "Hidden")
        sut.display(isHidden: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_withInsets() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_INSETS"

        // WHEN
        sut.textInsets = UIEdgeInsets(top: 10, left: 80, bottom: 10, right: 20)
        sut.backgroundColor = .cyan
        sut.display(model: .text("Insetted text"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_withInsets() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_INSETS"

        // WHEN
        sut.textInsets = UIEdgeInsets(top: 15, left: 80, bottom: 10, right: 25)
        sut.backgroundColor = .cyan
        sut.display(model: .text("Insetted text"))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - attributedText перезаписывает обычный text
    func tests_labelOutput_multiple_display() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_MULTIPLE_DISPLAY"
        // WHEN
        sut.display(text: "First text")

        let secondText = TextAttributes(text: "Second Text")

        sut.display(attributes: [secondText])

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func tests_fail_labelOutput_multiple_display() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_MULTIPLE_DISPLAY"
        // WHEN
        sut.display(text: "First text.")

        let secondText = TextAttributes(text: "Second Text.")

        sut.display(attributes: [secondText])

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - Corener Style tests
    func test_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"

        // WHEN
        sut.cornerStyle = .automatic
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_automaticCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"

        // WHEN
        sut.cornerStyle = CornerStyle.none
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"

        // WHEN
        sut.cornerStyle = .fixed(30)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_fixedCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"

        // WHEN
        sut.cornerStyle = .fixed(31)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"

        // WHEN
        sut.cornerStyle = CornerStyle.none
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_noneCornerStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"

        // WHEN
        sut.cornerStyle = .fixed(12)
        sut.backgroundColor = .blue
        sut.display(model: .text("Rounded"))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - Tests for display with TextAttributes
    func test_labelOutput_with_color() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"

        //WHEN
        let blue = TextAttributes(text: "Blue", color: .blue)
        let yellow = TextAttributes(text: "Yellow", color: .yellow)

        sut.display(model: .attributes([blue, yellow]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_color() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"

        //WHEN
        let blue = TextAttributes(text: "Blue", color: .systemBlue)
        let yellow = TextAttributes(text: "Yellow", color: .systemYellow)

        sut.display(model: .attributes([blue, yellow]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_colorRangeMutation() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"

        // WHEN
        let expandedBlueRange = TextAttributes(text: "BlueY", color: .blue)
        let shortenedYellowRange = TextAttributes(text: "ellow", color: .yellow)
        sut.display(model: .attributes([expandedBlueRange, shortenedYellowRange]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_font_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_FONT"

        //WHEN
        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 16))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 16))

        sut.display(model: .attributes([bold, regular]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_font_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_FONT"

        //WHEN
        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 17))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 15))

        sut.display(model: .attributes([bold, regular]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_singleLineText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"
        //WHEN
        let single = TextAttributes(text: "Single", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])

        sut.display(model: .attributes([single, line]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_singleLineText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"
        //WHEN
        let single = TextAttributes(text: "Single", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])

        sut.display(model: .attributes([single, line]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // Known UIKit behavior: double underline layout is platform-specific.
    func test_labelOutput_with_doubleLineText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"

        //WHEN
        let double = TextAttributes(text: "Double", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])

        sut.display(model: .attributes([double, line]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_doubleLineText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"

        //WHEN
        let double = TextAttributes(text: "Double", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])

        sut.display(model: .attributes([double, line]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // Known UIKit behavior: by-word underlining does not split at every separator.
    func test_labelOutput_with_byWordText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_BYWORD"

        //WHEN
        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .byWord])

        sut.display(model: .attributes([byWord]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_byWordText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_BYWORD"

        //WHEN
        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .patternDash])

        sut.display(model: .attributes([byWord]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // Known UIKit behavior: dashed underline rendering is platform-specific.
    func test_labelOutput_with_patternDashText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASH"

        //WHEN
        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.patternDash])
        sut.backgroundColor = .cyan

        sut.display(model: .attributes([dashed]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_patternDashText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASH"

        //WHEN
        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.single])
        sut.backgroundColor = .cyan

        sut.display(model: .attributes([dashed]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // Known UIKit behavior: dash-dot underline rendering is platform-specific.
    func test_labelOutput_with_patternDashDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"

        //WHEN
        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.patternDashDot])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([dashDot]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_patternDashDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"

        //WHEN
        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([dashDot]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // Known UIKit behavior: dash-dot-dot underline rendering is platform-specific.
    func test_labelOutput_with_patternDashDotDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"

        //WHEN
        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.patternDashDotDot])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([dashDotDot]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_patterntDashDotDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"

        //WHEN
        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([dashDotDot]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // Known UIKit behavior: dotted underline rendering is platform-specific.
    func test_labelOutput_with_patternDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOT"

        //WHEN
        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.patternDot])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([dot]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_patterntDotText_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOT"

        //WHEN
        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([dot]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_thickUnderline_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_THICK"

        //WHEN
        let thick = TextAttributes(text: "Thick string", underlineStyle: [.thick])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([thick]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_thickUnderline_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_THICK"

        //WHEN
        let thick = TextAttributes(text: "Thick string", underlineStyle: [.single])
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([thick]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star.fill"))
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([leadingImage]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_leadingImage_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"
        //WHEN
        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star"))
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([leadingImage]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"

        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star.fill"))
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([trailingImage]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_trailingImage_attributes() {
        //GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"

        //WHEN
        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star"))
        sut.backgroundColor = .systemBlue

        sut.display(model: .attributes([trailingImage]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - Tests for label taps
    func test_labelOutput_textAttributesOnTap() {
        // GIVEN
        let sut = makeSUT()
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
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_textAttributesOnTap() {
        // GIVEN
        let sut = makeSUT()
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
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let sut = makeSUT()
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
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_displayAnimatedNumber() {
        // GIVEN
        let sut = makeSUT()
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
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"

        sut.textColor = .red
        sut.font = .systemFont(ofSize: 16)
        sut.textAlignment = .right

        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .blue)
        let regular = TextAttributes(text: "Text attribute with default label color")

        sut.display(model: .attributes([bold, regular]))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_default_TextAttribute_behavior() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"

        sut.textColor = .red
        sut.font = .systemFont(ofSize: 16)
        sut.textAlignment = .right

        // WHEN
        let bold = TextAttributes(text: "Text attribute with color", color: .systemBlue)
        let regular = TextAttributes(text: "Text attribute with default label color.")

        sut.display(model: .attributes([bold, regular]))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"

        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(20), insets: .init(top: 20, leading: 50, bottom: 20, trailing: 20)))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_labelOutput_with_cornerStyle_and_insets() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"

        // THEN
        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(29), insets: .init(top: 21, leading: 50, bottom: 20, trailing: 20)))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_Br() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML"

        // THEN
        sut.display(htmlString: HtmlTestCases.example1, config: .init(size: 13, color: .red))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_label_output_html_Br() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML"

        // WHEN
        let htmlWithoutExplicitLineBreaks = HtmlTestCases.example1
            .replacingOccurrences(of: "<br>", with: " ")
        sut.display(
            htmlString: htmlWithoutExplicitLineBreaks,
            config: .init(size: 13, color: .red)
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_boldItalic() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_boldItalic"

        // THEN
        sut.display(htmlString: HtmlTestCases.boldItalic, config: .init(color: .green))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_inlineStyle() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_inlineStyle"

        // THEN
        sut.display(htmlString: HtmlTestCases.inlineStyle, config: .default)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_label_output_html_inlineStyleColor() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_inlineStyle"

        // WHEN
        let htmlWithMutatedInlineColor = HtmlTestCases.inlineStyle
            .replacingOccurrences(of: "#FF0000", with: "#00FFFF")
        sut.display(htmlString: htmlWithMutatedInlineColor, config: .default)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_paragraphs() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_paragraphs"

        // THEN
        sut.display(htmlString: HtmlTestCases.paragraphs, config: .init(paragraphSpacing: 12))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_lists() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_lists"

        // THEN
        sut.display(htmlString: HtmlTestCases.lists, config: .init(lineSpacing: 8))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_longText() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_longText"

        // THEN
        sut.display(
            htmlString: HtmlTestCases.longText,
            config: .init(textAlignment: .center, lineBreakMode: .byWordWrapping)
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_label_output_html_longTextLineBreak() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_longText"

        // WHEN
        let htmlWithExtraLineBreak = HtmlTestCases.longText
            .replacingOccurrences(of: "<p>", with: "<p><br>")
        sut.display(
            htmlString: htmlWithExtraLineBreak,
            config: .init(textAlignment: .center, lineBreakMode: .byWordWrapping)
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_label_output_html_other() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_HTML_other"

        // THEN
        sut.display(htmlString: HtmlTestCases.other, config: .init(color: .red))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_emoji() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_EMOJI_STATE"

        // WHEN
        sut.display(model: .text("it's fine 🙂"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_labelOutput_utfLikeText() {
        // GIVEN
        let sut = makeSUT()
        let snapshotName = "LABEL_FAKE_EMOJI_STATE"

        // WHEN
        sut.display(model: .text("Saima 500+O!TV- SALE 30%_850"))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }
}

private extension SUILabelSnapshotTests {
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUILabelSnapshotSUT {
        let container = makeContainer()
        let sut = SwiftUILabelSnapshotSUT(uiKitContainer: container)

        container.addSubview(sut.uiKitLabel)
        sut.uiKitLabel.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(150, priority: .required)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitLabel, file: file, line: line)
        return sut
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        container.backgroundColor = .clear
        return container
    }
}

private struct RenderedLabelPixels {
    let uiKit: LabelRGBAPixels
    let swiftUI: LabelRGBAPixels
}

private struct LabelRGBAPixels {
    let width: Int
    let height: Int
    let bytes: [UInt8]

    init?(image: UIImage) {
        guard let image = image.cgImage else { return nil }
        width = image.width
        height = image.height
        let bytesPerRow = width * 4
        var bytes = [UInt8](repeating: 0, count: height * bytesPerRow)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        self.bytes = bytes
    }

    var dominantRedBounds: CGRect? {
        dominantRedInk.bounds
    }

    var dominantRedInk: LabelPixelMask {
        var indices = Set<Int>()
        for byteIndex in stride(from: 0, to: bytes.count, by: 4) {
            let red = Int(bytes[byteIndex])
            let green = Int(bytes[byteIndex + 1])
            let blue = Int(bytes[byteIndex + 2])
            let alpha = Int(bytes[byteIndex + 3])
            guard alpha > 32,
                  red > 160,
                  red > green + 60,
                  red > blue + 60
            else {
                continue
            }
            indices.insert(byteIndex / 4)
        }
        return LabelPixelMask(width: width, indices: indices)
    }
}

private struct LabelPixelMask {
    struct Row: Equatable {
        let y: Int
        let columnRuns: [ClosedRange<Int>]
    }

    let width: Int
    let indices: Set<Int>

    var isEmpty: Bool {
        indices.isEmpty
    }

    func subtracting(_ other: Self) -> Self {
        precondition(width == other.width)
        return .init(width: width, indices: indices.subtracting(other.indices))
    }

    var bounds: CGRect? {
        guard let first = indices.first else { return nil }
        var minimumX = first % width
        var maximumX = minimumX
        var minimumY = first / width
        var maximumY = minimumY

        for index in indices.dropFirst() {
            let x = index % width
            let y = index / width
            minimumX = min(minimumX, x)
            maximumX = max(maximumX, x)
            minimumY = min(minimumY, y)
            maximumY = max(maximumY, y)
        }
        return CGRect(
            x: minimumX,
            y: minimumY,
            width: maximumX - minimumX + 1,
            height: maximumY - minimumY + 1
        )
    }

    var rowRuns: [ClosedRange<Int>] {
        contiguousRuns(indices.map { $0 / width })
    }

    var columnRunsByRow: [Row] {
        let rows = Dictionary(grouping: indices) { $0 / width }
        return rows.keys.sorted().map { y in
            Row(
                y: y,
                columnRuns: contiguousRuns((rows[y] ?? []).map { $0 % width })
            )
        }
    }

    private func contiguousRuns<S: Sequence>(_ values: S) -> [ClosedRange<Int>] where S.Element == Int {
        let sorted = Set(values).sorted()
        guard let first = sorted.first else { return [] }
        var result: [ClosedRange<Int>] = []
        var lowerBound = first
        var upperBound = first

        for value in sorted.dropFirst() {
            if value == upperBound + 1 {
                upperBound = value
            } else {
                result.append(lowerBound...upperBound)
                lowerBound = value
                upperBound = value
            }
        }
        result.append(lowerBound...upperBound)
        return result
    }
}
