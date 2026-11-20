//
//  LabelSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

@testable import WrapKit
import XCTest
import WrapKitTestUtils

final class LabelSnapshotTests: XCTestCase {

    func test_labelOutput_alignment_centerThenUnspecified_usesConfiguredAlignment() throws {
        let alignments: [(String, NSTextAlignment)] = [("natural", .natural), ("left", .left), ("center", .center), ("right", .right)]
        let rows = try alignments.map { name, alignment -> (String, Label) in
            let label = makeAlignmentLabel(alignment: alignment)
            label.display(model: .attributes([.init(text: "Centered button", textAlignment: .center)]))
            try assertAlignment(.center, in: label)

            label.display(model: .attributes([.init(text: "1 080 с / 1 календарный месяц")]))
            try assertAlignment(alignment, in: label)
            return ("Base \(name): center → unspecified", label)
        }
        assertAlignmentSnapshots(rows, named: "LABEL_ALIGNMENT_CENTER_TO_DEFAULT")
    }

    func test_labelOutput_alignment_callerChangesAlignment_afterInitializationAndContent() throws {
        let configuredBeforeContent = makeAlignmentLabel(alignment: .natural)
        configuredBeforeContent.textAlignment = .right
        configuredBeforeContent.display(model: .attributes([.init(text: "Centered button", textAlignment: .center)]))
        configuredBeforeContent.display(model: .attributes([.init(text: "Caller configured right")]))
        try assertAlignment(.right, in: configuredBeforeContent)

        let configuredAfterContent = makeAlignmentLabel(alignment: .left)
        configuredAfterContent.display(model: .attributes([.init(text: "Centered button", textAlignment: .center)]))
        configuredAfterContent.textAlignment = .right
        configuredAfterContent.display(model: .attributes([.init(text: "Caller changed alignment to right")]))
        try assertAlignment(.right, in: configuredAfterContent)

        assertAlignmentSnapshots([
            ("Caller sets right before centered content", configuredBeforeContent),
            ("Caller sets right after centered content", configuredAfterContent)
        ], named: "LABEL_ALIGNMENT_CALLER_CONFIGURED_RIGHT")
    }

    func test_labelOutput_alignment_repeatedDisplayAndNil_keepExplicitAndDefaultAlignment() throws {
        let centered = makeAlignmentLabel(alignment: .left)
        let model = TextOutputPresentableModel.attributes([.init(text: "Repeated centered button", textAlignment: .center)])
        centered.display(model: model)
        centered.display(model: model)
        try assertAlignment(.center, in: centered)

        let restored = makeAlignmentLabel(alignment: .right)
        restored.display(model: model)
        restored.display(model: model)
        restored.display(model: nil)
        XCTAssertTrue(restored.isHidden)
        restored.display(model: .attributes([.init(text: "Right alignment after nil")]))
        restored.display(model: .attributes([.init(text: "Right alignment after repeated display")]))
        XCTAssertFalse(restored.isHidden)
        try assertAlignment(.right, in: restored)

        assertAlignmentSnapshots([
            ("Explicit center survives repeated display", centered),
            ("Base right survives center → nil → unspecified", restored)
        ], named: "LABEL_ALIGNMENT_REPEATED_DISPLAY_AND_NIL")
    }

    func test_labelOutput_alignment_centerThenPlainText_restoresConfiguredAlignment() {
        let throughDisplay = makeAlignmentLabel(alignment: .left)
        throughDisplay.display(model: .attributes([.init(text: "Centered button", textAlignment: .center)]))
        throughDisplay.display(model: .text("Plain text through display: left"))
        XCTAssertEqual(throughDisplay.textAlignment, .left)

        let directText = makeAlignmentLabel(alignment: .right)
        directText.display(model: .attributes([.init(text: "Centered button", textAlignment: .center)]))
        directText.text = "Plain text through property: right"
        XCTAssertEqual(directText.textAlignment, .right)

        assertAlignmentSnapshots([
            ("Base left: attributes → display plain text", throughDisplay),
            ("Base right: attributes → direct text assignment", directText)
        ], named: "LABEL_ALIGNMENT_CENTER_TO_PLAIN_TEXT")
    }

    func test_labelOutput_alignment_externalContentAndMixedParagraphs_doNotLeakAlignment() throws {
        let html = makeAlignmentLabel(alignment: .right)
        html.display(htmlString: "<p>Centered HTML</p>", config: .init(textAlignment: .center))
        try assertAlignment(.center, in: html)
        html.display(model: .attributes([.init(text: "Right alignment after HTML", color: .label, font: .systemFont(ofSize: 18))]))
        try assertAlignment(.right, in: html)

        let directAttributedText = makeAlignmentLabel(alignment: .left)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        directAttributedText.attributedText = NSAttributedString(string: "Centered attributed text", attributes: [
            .font: UIFont.systemFont(ofSize: 18),
            .paragraphStyle: paragraph
        ])
        directAttributedText.display(model: .attributes([.init(text: "Left alignment after attributed text")]))
        try assertAlignment(.left, in: directAttributedText)

        let mixed = makeAlignmentLabel(alignment: .left)
        let mixedModel = TextOutputPresentableModel.attributes([
            .init(text: "Centered paragraph\n", textAlignment: .center),
            .init(text: "Right paragraph\n", textAlignment: .right),
            .init(text: "Unspecified paragraph")
        ])
        mixed.display(model: mixedModel)
        mixed.display(model: mixedModel)
        try assertAlignment(.center, in: mixed, containing: "Centered paragraph")
        try assertAlignment(.right, in: mixed, containing: "Right paragraph")
        try assertAlignment(.left, in: mixed, containing: "Unspecified paragraph")

        assertAlignmentSnapshots([
            ("Base right: centered HTML → unspecified", html),
            ("Base left: attributed text → unspecified", directAttributedText),
            ("Mixed paragraphs retain their own alignment", mixed)
        ], named: "LABEL_ALIGNMENT_EXTERNAL_CONTENT_AND_PARAGRAPHS")
    }

    func test_labelOutput_defaultWidth_preservesCallerMeasurementAcrossTextAndLayoutChanges() {
        let label = Label(font: .systemFont(ofSize: 18))
        XCTAssertFalse(label.automaticallyUpdatesPreferredMaxLayoutWidth)
        label.preferredMaxLayoutWidth = 74
        label.text = "ДҮЙНӨ аймагы боюнча ылдамдык"
        label.frame = CGRect(x: 0, y: 0, width: 160, height: 120)
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 74)

        label.attributedText = NSAttributedString(string: "A longer attributed label", attributes: [.font: UIFont.systemFont(ofSize: 18)])
        label.frame.size.width = 240
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 74)

        label.attributedText = nil
        label.text = "Short"
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 74)
    }

    func test_labelOutput_automaticWidth_followsResizingAndResetsReusedText() {
        let label = Label(font: .systemFont(ofSize: 18), automaticallyUpdatesPreferredMaxLayoutWidth: true)
        XCTAssertTrue(label.automaticallyUpdatesPreferredMaxLayoutWidth)
        label.text = "ДҮЙНӨ аймагы боюнча ылдамдык"
        label.frame = CGRect(x: 0, y: 0, width: 140, height: 140)
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 140)
        let narrowHeight = label.intrinsicContentSize.height

        label.frame.size.width = 280
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 280)
        XCTAssertLessThan(label.intrinsicContentSize.height, narrowHeight)

        label.text = "Short"
        XCTAssertEqual(label.preferredMaxLayoutWidth, 0)
        label.setNeedsLayout()
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 280)
        XCTAssertLessThan(label.intrinsicContentSize.height, narrowHeight)

        label.attributedText = NSAttributedString(string: "KG аймагы боюнча ылдамдык", attributes: [.font: UIFont.systemFont(ofSize: 18)])
        XCTAssertEqual(label.preferredMaxLayoutWidth, 0)
        label.frame.size.width = 140
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 140)

        label.automaticallyUpdatesPreferredMaxLayoutWidth = false
        XCTAssertEqual(label.preferredMaxLayoutWidth, 140)
        label.preferredMaxLayoutWidth = 74
        label.text = "Restored caller width"
        label.frame.size.width = 240
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 74)
    }

    func test_labelOutput_automaticWidth_addsInsetsOnce() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 230))
        container.backgroundColor = .white
        let plain = Label(font: .systemFont(ofSize: 18), textColor: .black, automaticallyUpdatesPreferredMaxLayoutWidth: true)
        let inset = Label(font: .systemFont(ofSize: 18), textColor: .black, textInsets: .init(top: 4, left: 8, bottom: 6, right: 8), automaticallyUpdatesPreferredMaxLayoutWidth: true)
        for (offset, label) in [plain, inset].enumerated() {
            label.text = "ДҮЙНӨ аймагы боюнча ылдамдык"
            label.frame = CGRect(x: 16, y: 16 + offset * 90, width: offset == 0 ? 150 : 166, height: 80)
            container.addSubview(label)
            label.layoutIfNeeded()
        }
        XCTAssertEqual(inset.intrinsicContentSize.height, plain.intrinsicContentSize.height + 10, accuracy: 0.001)
        XCTAssertEqual(inset.sizeThatFits(.init(width: 166, height: 500)).height, plain.sizeThatFits(.init(width: 150, height: 500)).height + 10, accuracy: 0.001)
        let attachment = XCTAttachment(image: container.snapshot(for: .iPhone(style: .light)))
        attachment.name = "automatic_width_multiline_plain_and_insets"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func test_labelOutput_automaticWidth_doesNotOverrideSingleLineOrHiddenMeasurement() {
        let label = Label(font: .systemFont(ofSize: 18), numberOfLines: 1, automaticallyUpdatesPreferredMaxLayoutWidth: true)
        label.text = "Single line"
        label.preferredMaxLayoutWidth = 74
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 74)

        label.numberOfLines = 0
        label.isHidden = true
        label.setNeedsLayout()
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 74)

        label.isHidden = false
        label.setNeedsLayout()
        label.layoutIfNeeded()
        XCTAssertEqual(label.preferredMaxLayoutWidth, 200)
    }

    func test_labelOutput_textInsets_areAddedOnceToIntrinsicContentSize() {
        // GIVEN
        let text = "Sample text"
        let insets = UIEdgeInsets(top: 2, left: 8, bottom: 4, right: 8)
        let labelWithoutInsets = Label(font: .systemFont(ofSize: 16), numberOfLines: 1)
        let labelWithInsets = Label(font: .systemFont(ofSize: 16), numberOfLines: 1, textInsets: insets)

        // WHEN
        labelWithoutInsets.text = text
        labelWithInsets.text = text

        // THEN
        XCTAssertEqual(
            labelWithInsets.intrinsicContentSize.width,
            labelWithoutInsets.intrinsicContentSize.width + insets.left + insets.right,
            accuracy: 0.001
        )
        XCTAssertEqual(
            labelWithInsets.intrinsicContentSize.height,
            labelWithoutInsets.intrinsicContentSize.height + insets.top + insets.bottom,
            accuracy: 0.001
        )
    }

    func test_labelOutput_textInsets_areAddedOnceToSizeThatFits() {
        // GIVEN
        let text = "Sample text"
        let insets = UIEdgeInsets(top: 2, left: 8, bottom: 4, right: 8)
        let labelWithoutInsets = Label(font: .systemFont(ofSize: 16), numberOfLines: 1)
        let labelWithInsets = Label(font: .systemFont(ofSize: 16), numberOfLines: 1, textInsets: insets)
        let fittingSize = CGSize(width: 1_000, height: 1_000)

        // WHEN
        labelWithoutInsets.text = text
        labelWithInsets.text = text
        let sizeWithoutInsets = labelWithoutInsets.sizeThatFits(fittingSize)
        let sizeWithInsets = labelWithInsets.sizeThatFits(fittingSize)

        // THEN
        XCTAssertEqual(
            sizeWithInsets.width,
            sizeWithoutInsets.width + insets.left + insets.right,
            accuracy: 0.001
        )
        XCTAssertEqual(
            sizeWithInsets.height,
            sizeWithoutInsets.height + insets.top + insets.bottom,
            accuracy: 0.001
        )
    }

    func test_labelOutput_animatedDecimalTextInsets_areAddedOnceToIntrinsicContentSize() {
        // GIVEN
        let insets = UIEdgeInsets(top: 2, left: 8, bottom: 4, right: 8)
        let labelWithoutInsets = Label(font: .systemFont(ofSize: 16), numberOfLines: 1)
        let labelWithInsets = Label(font: .systemFont(ofSize: 16), numberOfLines: 1, textInsets: insets)
        let mapToString: (Decimal) -> TextOutputPresentableModel.TextModel = {
            .text(Int($0.doubleValue).asString())
        }

        // WHEN
        labelWithoutInsets.display(from: 5, to: 0, mapToString: mapToString, duration: 60)
        labelWithInsets.display(from: 5, to: 0, mapToString: mapToString, duration: 60)

        // THEN
        XCTAssertEqual(
            labelWithInsets.intrinsicContentSize.width,
            labelWithoutInsets.intrinsicContentSize.width + insets.left + insets.right,
            accuracy: 0.001
        )
        XCTAssertEqual(
            labelWithInsets.intrinsicContentSize.height,
            labelWithoutInsets.intrinsicContentSize.height + insets.top + insets.bottom,
            accuracy: 0.001
        )
    }

    func test_labelOutput_animatedDecimalCircle_shouldDisplayWithoutClipping() throws {
        // GIVEN
        let sut = Label(
            font: .systemFont(ofSize: 16),
            textAlignment: .center,
            numberOfLines: 1
        )

        // WHEN
        sut.display(
            from: 5,
            to: 0,
            mapToString: { .text(Int($0.doubleValue).asString()) },
            animationStyle: .circle(lineColor: .red),
            duration: 60
        )
        sut.frame.size = sut.intrinsicContentSize
        sut.layoutIfNeeded()

        // THEN
        let progressView = try XCTUnwrap(sut.subviews.compactMap { $0 as? CircularProgressView }.first)
        XCTAssertEqual(sut.text, "5")
        XCTAssertGreaterThan(sut.intrinsicContentSize.width, 0)
        XCTAssertGreaterThan(sut.intrinsicContentSize.height, 0)
        XCTAssertFalse(sut.clipsToBounds)
        let expectedProgressFrame = sut.bounds.insetBy(dx: -8, dy: -8)
        XCTAssertEqual(progressView.frame.minX, expectedProgressFrame.minX, accuracy: 0.001)
        XCTAssertEqual(progressView.frame.minY, expectedProgressFrame.minY, accuracy: 0.001)
        XCTAssertEqual(progressView.frame.width, expectedProgressFrame.width, accuracy: 0.001)
        XCTAssertEqual(progressView.frame.height, expectedProgressFrame.height, accuracy: 0.001)
        let progressLayer = try XCTUnwrap(progressView.layer.sublayers?.compactMap { $0 as? CAShapeLayer }.first)
        XCTAssertNotNil(progressLayer.path)
        XCTAssertEqual(progressLayer.strokeColor, UIColor.red.cgColor)
    }

    func test_labelOutput_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_DEFAULT_STATE"
        
        // WHEN
        sut.display(model: .text("default"))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_labelOutput_long_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines"))
        
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_labelOutput_long_text() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_LONG_TITLE"
        
        // WHEN
        sut.display(model: .text("This is really long text that should wrap and check for number of lines."))
        
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }
    
    func test_labelOutput_with_strikethrough_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_STRIKETHROUGH"

        //WHEN
        let prefix = TextAttributes(text: "SILVER - ")
        let oldPrice = TextAttributes(text: "175 som", strikethroughStyle: .single)
        let price = TextAttributes(text: " 35 som")

        sut.display(model: .attributes([prefix, oldPrice, price]))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_labelOutput_with_strikethrough_attributes() {
        //GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_TITLE_WITH_STRIKETHROUGH"

        //WHEN
        let prefix = TextAttributes(text: "SILVER - ")
        let oldPrice = TextAttributes(text: "175 som")
        let price = TextAttributes(text: " 35 som")

        sut.display(model: .attributes([prefix, oldPrice, price]))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName))_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        } 
    }

    func test_label_output_html_Br() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML"

        // THEN
        sut.display(htmlString: HtmlTestCases.example1, config: .init(size: 13, color: .red))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_label_output_html_inlineStyle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "LABEL_HTML_inlineStyle"

        // THEN
        sut.display(htmlString: HtmlTestCases.inlineStyle)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension LabelSnapshotTests {
    private func makeAlignmentLabel(alignment: NSTextAlignment) -> Label {
        Label(font: .systemFont(ofSize: 18), textColor: .label, textAlignment: alignment)
    }

    private func assertAlignment(
        _ expected: NSTextAlignment,
        in label: Label,
        containing text: String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let attributedText = try XCTUnwrap(label.attributedText, file: file, line: line)
        let range = text.map { (attributedText.string as NSString).range(of: $0) } ?? NSRange(location: 0, length: 0)
        guard range.location != NSNotFound else {
            XCTFail("Expected paragraph was not found: \(text ?? "")", file: file, line: line)
            return
        }
        let paragraph = try XCTUnwrap(
            attributedText.attribute(.paragraphStyle, at: range.location, effectiveRange: nil) as? NSParagraphStyle,
            file: file,
            line: line
        )
        XCTAssertEqual(paragraph.alignment, expected, file: file, line: line)
    }

    private func assertAlignmentSnapshots(
        _ rows: [(String, Label)],
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 16 + rows.count * 140))
        container.backgroundColor = .systemBackground
        for (index, row) in rows.enumerated() {
            let caption = UILabel(frame: CGRect(x: 16, y: 16 + index * 140, width: 358, height: 32))
            caption.text = row.0
            caption.font = .systemFont(ofSize: 12, weight: .medium)
            caption.textColor = .secondaryLabel
            caption.numberOfLines = 0
            container.addSubview(caption)

            let label = row.1
            label.translatesAutoresizingMaskIntoConstraints = true
            label.frame = CGRect(x: 16, y: 52 + index * 140, width: 358, height: 92)
            label.backgroundColor = .secondarySystemBackground
            container.addSubview(label)
        }

        let os = if #available(iOS 26, *) { "iOS26" } else { "iOS18.5" }
        for (theme, style) in [("LIGHT", UIUserInterfaceStyle.light), ("DARK", UIUserInterfaceStyle.dark)] {
            let configuration = SnapshotConfiguration(
                size: container.bounds.size,
                safeAreaInsets: .zero,
                layoutMargins: .zero,
                traitCollection: SnapshotConfiguration.iPhone(style: style).traitCollection
            )
            let snapshot = container.snapshot(for: configuration)
            let snapshotName = "\(os)_\(name)_\(theme)"
            let attachment = XCTAttachment(image: snapshot)
            attachment.name = snapshotName
            attachment.lifetime = .keepAlways
            add(attachment)
            assert(snapshot: snapshot, named: snapshotName, file: file, line: line)
        }
    }

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
        container.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        container.backgroundColor = .clear
        return container
    }
}
