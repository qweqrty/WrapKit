//
//  SUILabelSnapshotTests.swift
//  WrapKit
//
//  Created by Codex on 13/4/26.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import SwiftUI

@available(iOS 17, *)
final class SUILabelSnapshotTests: XCTestCase {
    func test_labelOutput_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"

        sut.display(model: .text("default"))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"

        sut.display(model: .text("nothing"))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_long_text() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"

        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_long_text() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"

        sut.display(model: .text("This is really long text that should wrap and check for number of lines."))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_hidden_text() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"

        sut.display(text: "Hidden")
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_hidden_text() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_HIDDEN"

        sut.display(text: "Hidden")
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_withInsets() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_INSETS"

        sut.display(
            model: .textStyled(
                text: .text("Insetted text"),
                insets: .init(top: 10, leading: 80, bottom: 10, trailing: 20),
                backgroundColor: .cyan
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_withInsets() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_INSETS"

        sut.display(
            model: .textStyled(
                text: .text("Insetted text"),
                insets: .init(top: 15, leading: 80, bottom: 10, trailing: 25),
                backgroundColor: .cyan
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func tests_labelOutput_multiple_display() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_MULTIPLE_DISPLAY"

        sut.display(text: "First text")
        let secondText = TextAttributes(text: "Second Text")
        sut.display(attributes: [secondText])

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func tests_fail_labelOutput_multiple_display() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_MULTIPLE_DISPLAY"

        sut.display(text: "First text.")
        let secondText = TextAttributes(text: "Second Text.")
        sut.display(attributes: [secondText])

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_automaticCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"

        sut.display(
            model: .textStyled(
                text: .text("Rounded"),
                cornerStyle: .automatic,
                backgroundColor: .blue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_automaticCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_AUTOMATIC"

        sut.display(
            model: .textStyled(
                text: .text("Rounded"),
                cornerStyle: CornerStyle.none,
                backgroundColor: .blue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_fixedCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"

        sut.display(
            model: .textStyled(
                text: .text("Rounded"),
                cornerStyle: .fixed(30),
                backgroundColor: .blue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_fixedCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_FIXED"

        sut.display(
            model: .textStyled(
                text: .text("Rounded."),
                cornerStyle: .fixed(31),
                backgroundColor: .blue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_noneCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"

        sut.display(
            model: .textStyled(
                text: .text("Rounded"),
                cornerStyle: CornerStyle.none,
                backgroundColor: .blue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_noneCornerStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNER_NONE"

        sut.display(
            model: .textStyled(
                text: .text("Rounded"),
                cornerStyle: .fixed(1),
                backgroundColor: .blue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_color() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"

        let blue = TextAttributes(text: "Blue", color: .blue)
        let yellow = TextAttributes(text: "Yellow", color: .yellow)

        sut.display(model: .attributes([blue, yellow]))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_color() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_COLOR"

        let blue = TextAttributes(text: "Blue", color: .systemBlue)
        let yellow = TextAttributes(text: "Yellow", color: .systemYellow)

        sut.display(model: .attributes([blue, yellow]))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_font_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_FONT"

        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 16))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 16))

        sut.display(model: .attributes([bold, regular]))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_font_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_FONT"

        let bold = TextAttributes(text: "Bold", font: .boldSystemFont(ofSize: 17))
        let regular = TextAttributes(text: "Regular", font: .systemFont(ofSize: 15))

        sut.display(model: .attributes([bold, regular]))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_singleLineText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"

        let single = TextAttributes(text: "Single", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])

        sut.display(model: .attributes([single, line]))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_singleLineText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_SINGLELINE"

        let single = TextAttributes(text: "Single", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])

        sut.display(model: .attributes([single, line]))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_doubleLineText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"

        let double = TextAttributes(text: "Double", underlineStyle: [.double])
        let line = TextAttributes(text: "Line", underlineStyle: [.double])

        sut.display(model: .attributes([double, line]))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_doubleLineText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOUBLELINE"

        let double = TextAttributes(text: "Double", underlineStyle: [.single])
        let line = TextAttributes(text: "Line", underlineStyle: [.single])

        sut.display(model: .attributes([double, line]))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_byWordText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_BYWORD"

        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .byWord])

        sut.display(model: .attributes([byWord]))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_byWordText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_BYWORD"

        let byWord = TextAttributes(text: "Single line By Word", underlineStyle: [.single, .patternDash])

        sut.display(model: .attributes([byWord]))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_patternDashText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASH"

        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.patternDash])

        sut.display(
            model: .textStyled(
                text: .attributes([dashed]),
                backgroundColor: .cyan
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_patternDashText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASH"

        let dashed = TextAttributes(text: "Dashed string", underlineStyle: [.single])

        sut.display(
            model: .textStyled(
                text: .attributes([dashed]),
                backgroundColor: .cyan
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_patternDashDotText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"

        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.patternDashDot])

        sut.display(
            model: .textStyled(
                text: .attributes([dashDot]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_patternDashDotText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOT"

        let dashDot = TextAttributes(text: "DashedDot string", underlineStyle: [.single])

        sut.display(
            model: .textStyled(
                text: .attributes([dashDot]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_patternDashDotDotText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"

        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.patternDashDotDot])

        sut.display(
            model: .textStyled(
                text: .attributes([dashDotDot]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_patterntDashDotDotText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DASHDOTDOT"

        let dashDotDot = TextAttributes(text: "Dash Dot Dot string", underlineStyle: [.single])

        sut.display(
            model: .textStyled(
                text: .attributes([dashDotDot]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_patternDotText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOT"

        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.patternDot])

        sut.display(
            model: .textStyled(
                text: .attributes([dot]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_patterntDotText_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_DOT"

        let dot = TextAttributes(text: "Dotted string", underlineStyle: [.single])

        sut.display(
            model: .textStyled(
                text: .attributes([dot]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_thickUnderline_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_THICK"

        let thick = TextAttributes(text: "Thick string", underlineStyle: [.thick])

        sut.display(
            model: .textStyled(
                text: .attributes([thick]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_thickUnderline_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_THICK"

        let thick = TextAttributes(text: "Thick string", underlineStyle: [.single])

        sut.display(
            model: .textStyled(
                text: .attributes([thick]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_leadingImage_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"

        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star.fill"))

        sut.display(
            model: .textStyled(
                text: .attributes([leadingImage]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_leadingImage_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_LEADINGIMAGE"

        let leadingImage = TextAttributes(text: "Text with leading image", leadingImage: UIImage(systemName: "star"))

        sut.display(
            model: .textStyled(
                text: .attributes([leadingImage]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_trailingImage_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"

        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star.fill"))

        sut.display(
            model: .textStyled(
                text: .attributes([trailingImage]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_trailingImage_attributes() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TRAILINGIMAGE"

        let trailingImage = TextAttributes(text: "Text with trailing image", trailingImage: UIImage(systemName: "star"))

        sut.display(
            model: .textStyled(
                text: .attributes([trailingImage]),
                backgroundColor: .systemBlue
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_textAttributesOnTap() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP"

        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 3

        let firstAttr = TextAttributes(text: "First") {
            sut.display(model: .textStyled(text: .text("First Second Third"), backgroundColor: .red))
            exp.fulfill()
        }
        let secondAttr = TextAttributes(text: "Second") {
            sut.display(model: .textStyled(text: .text("First Second Third"), cornerStyle: .fixed(20), backgroundColor: .red))
            exp.fulfill()
        }
        let thirdAttr = TextAttributes(text: "Third") {
            let updatedThird = TextAttributes(text: "Updated Third!")
            sut.display(attributes: [firstAttr, secondAttr, updatedThird])
            exp.fulfill()
        }

        sut.display(model: .attributes([firstAttr, secondAttr, thirdAttr]))

        firstAttr.onTap?()
        secondAttr.onTap?()
        thirdAttr.onTap?()

        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_textAttributesOnTap() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_TEXTATTRIBUTES_ONTAP"

        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 3

        let firstAttr = TextAttributes(text: "First") {
            sut.display(model: .textStyled(text: .text("First Second Third"), backgroundColor: .systemRed))
            exp.fulfill()
        }
        let secondAttr = TextAttributes(text: "Second") {
            sut.display(model: .textStyled(text: .text("First Second Third"), cornerStyle: .fixed(21), backgroundColor: .systemRed))
            exp.fulfill()
        }
        let thirdAttr = TextAttributes(text: "Third") {
            let updatedThird = TextAttributes(text: "Updated Third!.")
            sut.display(attributes: [firstAttr, secondAttr, updatedThird])
            exp.fulfill()
        }

        sut.display(model: .attributes([firstAttr, secondAttr, thirdAttr]))

        firstAttr.onTap?()
        secondAttr.onTap?()
        thirdAttr.onTap?()

        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_displayAnimatedNumber() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_ANIMATED_FINAL_STATE"

        let exp = expectation(description: "Wait for animation completion")

        let mapToString: (Decimal) -> TextOutputPresentableModel.TextModel = { value in
            .text(String(format: "%.0f", value.doubleValue))
        }

        sut.display(
            id: nil,
            from: 0,
            to: 100,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.1
        ) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.3)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_displayAnimatedNumber() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_ANIMATED_FINAL_STATE"

        let exp = expectation(description: "Wait for animation completion")

        let mapToString: (Decimal) -> TextOutputPresentableModel.TextModel = { value in
            .text(String(format: "%.0f", value.doubleValue))
        }

        sut.display(
            id: "testAnimation",
            from: 0,
            to: 99,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.1
        ) {
            sut.display(model: .textStyled(text: .text("99"), backgroundColor: .cyan))
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_default_TextAttribute_behavior() {
        let (sut, container) = makeSUT(
            font: .systemFont(ofSize: 16),
            textColor: .red,
            textAlignment: .right
        )
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"

        let bold = TextAttributes(text: "Text attribute with color", color: .blue)
        let regular = TextAttributes(text: "Text attribute with default label color")

        sut.display(model: .attributes([bold, regular]))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_default_TextAttribute_behavior() {
        let (sut, container) = makeSUT(
            font: .systemFont(ofSize: 16),
            textColor: .red,
            textAlignment: .right
        )
        let snapshotName = "LABEL_TEXTATTRIBUTE_DEFAULT_BEHAVIOR_FONT"

        let bold = TextAttributes(text: "Text attribute with color", color: .systemBlue)
        let regular = TextAttributes(text: "Text attribute with default label color.")

        sut.display(model: .attributes([bold, regular]))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_with_cornerStyle_and_insets() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"

        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(20), insets: .init(top: 20, leading: 50, bottom: 20, trailing: 20)))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_cornerStyle_and_insets() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_CORNERSTYLE_INSETS"

        sut.display(model: .textStyled(text: .text("Hello"), cornerStyle: .fixed(29), insets: .init(top: 21, leading: 50, bottom: 20, trailing: 20)))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_Br() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML"

        sut.display(htmlString: HtmlTestCases.example1, config: .init(size: 13, color: .red))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_boldItalic() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_boldItalic"

        sut.display(htmlString: HtmlTestCases.boldItalic, config: .init(color: .green))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_inlineStyle() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_inlineStyle"

        sut.display(htmlString: HtmlTestCases.inlineStyle, config: .default)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_paragraphs() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_paragraphs"

        sut.display(htmlString: HtmlTestCases.paragraphs, config: .init(paragraphSpacing: 12))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_lists() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_lists"

        sut.display(htmlString: HtmlTestCases.lists, config: .init(lineSpacing: 8))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_longText() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_longText"

        sut.display(htmlString: HtmlTestCases.longText, config: .init(textAlignment: .center, lineBreakMode: .byWordWrapping))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_label_output_html_other() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_other"

        sut.display(htmlString: HtmlTestCases.other, config: .init(color: .red))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_emoji() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_EMOJI_STATE"

        sut.display(model: .text("it's fine 🙂"))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_labelOutput_utfLikeText() {
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_FAKE_EMOJI_STATE"

        sut.display(model: .text("Saima 500+O!TV- SALE 30%_850"))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light), useUIKit: true), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark), useUIKit: true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

@available(iOS 17, *)
extension SUILabelSnapshotTests {
    func makeSUT(
        font: UIFont = .systemFont(ofSize: 20),
        textColor: UIColor = .darkText,
        textAlignment: NSTextAlignment = .natural,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: TextOutput, container: AnyView) {
        let adapter = TextOutputSwiftUIAdapter()

        let container = AnyView(
            VStack(spacing: .zero) {
                SUILabel(
                    adapter: adapter,
                    font: font,
                    textColor: textColor,
                    textAlignment: textAlignment
                )
                    .frame(height: 150, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
        )

        checkForMemoryLeaks(adapter, file: file, line: line)
        return (adapter.weakReferenced, container)
    }

}
