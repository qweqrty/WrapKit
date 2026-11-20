//
//  ButtonSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 5/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

final class ButtonSnapshotTests: XCTestCase {
    func test_buttonOutput_alignment_initialGlassConfiguration_respectsContentAlignment() throws {
        let (container, buttons) = makeAlignmentSUT()

        for (alignment, button) in buttons {
            button.contentHorizontalAlignment = alignment.value
            button.display(contentInset: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
            button.display(style: alignmentStyle(.glass))
            button.display(title: "Подробнее")

            assertConfiguredAlignment(of: button, matches: alignment)
        }

        try assertAlignmentSnapshots(container: container, buttons: buttons, named: "BUTTON_ALIGNMENT_INITIAL_GLASS")
    }

    func test_buttonOutput_alignment_repeatedDisplay_preservesContentAlignment() throws {
        let (container, buttons) = makeAlignmentSUT()

        for (alignment, button) in buttons {
            button.contentHorizontalAlignment = alignment.value
            let model = ButtonPresentableModel(
                title: "Подробнее",
                contentInset: .init(top: 0, leading: 16, bottom: 0, trailing: 16),
                height: 48,
                style: alignmentStyle(.glass)
            )
            button.display(model: model)
            assertConfiguredAlignment(of: button, matches: alignment)

            button.display(model: nil)
            XCTAssertTrue(button.isHidden)
            button.display(model: model)
            button.display(model: model)

            XCTAssertFalse(button.isHidden)
            XCTAssertEqual(button.configuration?.title ?? button.currentTitle, model.title)
            assertConfiguredAlignment(of: button, matches: alignment)
        }

        try assertAlignmentSnapshots(container: container, buttons: buttons, named: "BUTTON_ALIGNMENT_REPEATED_DISPLAY")
    }

    func test_buttonOutput_alignment_styleTransitions_preserveContentAlignment() throws {
        let (container, buttons) = makeAlignmentSUT(alignments: Array(buttonAlignments.prefix(3)))
        let title = "Подробнее"
        let image = UIImage(systemName: "star")
        let styles: [ButtonStyle.GlassConfiguration?] = [
            nil, .glass, .clearGlass, .prominentGlass, .prominentClearGlass, nil, .glass
        ]

        for (alignment, button) in buttons {
            button.contentHorizontalAlignment = alignment.value
            for glassStyle in styles {
                button.display(model: .init(
                    title: title,
                    image: image,
                    spacing: 8,
                    contentInset: .init(top: 0, leading: 16, bottom: 0, trailing: 16),
                    height: 48,
                    style: alignmentStyle(glassStyle)
                ))
                assertConfiguredAlignment(of: button, matches: alignment, expectsGlass: glassStyle != nil)
                button.display(style: alignmentStyle(glassStyle))
                assertDisplayedContent(title: title, image: image, of: button)
                assertConfiguredAlignment(of: button, matches: alignment, expectsGlass: glassStyle != nil)
            }

            button.display(title: nil)
            button.display(image: nil)
            button.display(style: alignmentStyle(.glass))
            assertDisplayedContent(title: nil, image: nil, of: button)
            button.display(title: title)
            button.display(image: image)

            button.isHighlighted = true
            if #available(iOS 15.0, *) { button.updateConfiguration() }
            assertConfiguredAlignment(of: button, matches: alignment)
            button.isHighlighted = false
            button.display(enabled: false)
            if #available(iOS 15.0, *) { button.updateConfiguration() }
            assertConfiguredAlignment(of: button, matches: alignment)
            button.display(enabled: true)
            if #available(iOS 15.0, *) { button.updateConfiguration() }
            assertConfiguredAlignment(of: button, matches: alignment)
        }

        try assertAlignmentSnapshots(container: container, buttons: buttons, named: "BUTTON_ALIGNMENT_STYLE_TRANSITIONS")
    }

    func test_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "Default")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "Default.")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: false)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: true)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image =  UIImage(systemName: "star.fill")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_removingImageTint_restoresLegacyImageAppearance() {
        let (sut, _) = makeSUT()
        let normalImage = UIImage(systemName: "star.fill")!.withRenderingMode(.alwaysOriginal)
        let highlightedImage = UIImage(systemName: "star")!.withRenderingMode(.alwaysOriginal)
        let originalTintColor = UIColor.systemGreen
        let originalSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)

        if #available(iOS 15.0, *) {
            sut.configuration = nil
        }
        sut.tintColor = originalTintColor
        sut.setImage(normalImage, for: .normal)
        sut.setImage(highlightedImage, for: .highlighted)
        sut.setPreferredSymbolConfiguration(originalSymbolConfiguration, forImageIn: .normal)

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .highlighted)?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === normalImage)
        XCTAssertTrue(sut.image(for: .highlighted) === highlightedImage)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysOriginal)
        XCTAssertEqual(sut.image(for: .highlighted)?.renderingMode, .alwaysOriginal)
        XCTAssertEqual(sut.tintColor, originalTintColor)
        XCTAssertEqual(
            sut.preferredSymbolConfigurationForImage(in: .normal),
            originalSymbolConfiguration
        )
    }

    func test_buttonOutput_imageTint_preservesStateSpecificImages() {
        let (sut, _) = makeSUT()
        let normalImage = makeImage(width: 11)
        let highlightedImage = makeImage(width: 12)
        let selectedImage = makeImage(width: 13)
        let disabledImage = makeImage(width: 14)

        if #available(iOS 15.0, *) {
            sut.configuration = nil
        }
        sut.setImage(normalImage, for: .normal)
        sut.setImage(highlightedImage, for: .highlighted)
        sut.setImage(selectedImage, for: .selected)
        sut.setImage(disabledImage, for: .disabled)

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.image(for: .normal)?.size, normalImage.size)
        XCTAssertEqual(sut.image(for: .highlighted)?.size, highlightedImage.size)
        XCTAssertEqual(sut.image(for: .selected)?.size, selectedImage.size)
        XCTAssertEqual(sut.image(for: .disabled)?.size, disabledImage.size)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .highlighted)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .selected)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .disabled)?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === normalImage)
        XCTAssertTrue(sut.image(for: .highlighted) === highlightedImage)
        XCTAssertTrue(sut.image(for: .selected) === selectedImage)
        XCTAssertTrue(sut.image(for: .disabled) === disabledImage)
    }

    @available(iOS 15.0, *)
    func test_buttonOutput_imageTint_updatesConfigurationWithStateSpecificImages() {
        let (sut, _) = makeSUT()
        let normalImage = makeImage(width: 11)
        let highlightedImage = makeImage(width: 12)
        let selectedImage = makeImage(width: 13)
        let disabledImage = makeImage(width: 14)
        var configuration = UIButton.Configuration.plain()
        configuration.image = normalImage
        sut.configuration = configuration
        sut.setImage(normalImage, for: .normal)
        sut.setImage(highlightedImage, for: .highlighted)
        sut.setImage(selectedImage, for: .selected)
        sut.setImage(disabledImage, for: .disabled)

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.configuration?.image?.size, normalImage.size)
        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysTemplate)

        sut.isHighlighted = true
        sut.updateConfiguration()
        XCTAssertEqual(sut.configuration?.image?.size, highlightedImage.size)

        sut.isHighlighted = false
        sut.isSelected = true
        sut.updateConfiguration()
        XCTAssertEqual(sut.configuration?.image?.size, selectedImage.size)

        sut.isSelected = false
        sut.isEnabled = false
        sut.updateConfiguration()
        XCTAssertEqual(sut.configuration?.image?.size, disabledImage.size)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === normalImage)
        XCTAssertTrue(sut.image(for: .highlighted) === highlightedImage)
        XCTAssertTrue(sut.image(for: .selected) === selectedImage)
        XCTAssertTrue(sut.image(for: .disabled) === disabledImage)
        XCTAssertTrue(sut.configuration?.image === normalImage)
    }

    @available(iOS 15.0, *)
    func test_buttonOutput_removingImageTint_restoresConfigurationImageAppearance() {
        let (sut, _) = makeSUT()
        let originalImage = UIImage(systemName: "star.fill")!.withRenderingMode(.alwaysOriginal)
        let originalTintColor = UIColor.systemGreen
        let originalSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let originalColorTransformer = UIConfigurationColorTransformer { _ in .systemBlue }
        var configuration = UIButton.Configuration.plain()
        configuration.image = originalImage
        configuration.imageColorTransformer = originalColorTransformer
        configuration.preferredSymbolConfigurationForImage = originalSymbolConfiguration
        sut.configuration = configuration
        sut.tintColor = originalTintColor

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.configuration?.imageColorTransformer?(.black), .systemRed)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.configuration?.image === originalImage)
        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysOriginal)
        XCTAssertEqual(sut.configuration?.imageColorTransformer?(.black), .systemBlue)
        XCTAssertEqual(
            sut.configuration?.preferredSymbolConfigurationForImage,
            originalSymbolConfiguration
        )
        XCTAssertEqual(sut.tintColor, originalTintColor)
    }

    func test_buttonOutput_replacingImageWhileTinted_restoresLatestOriginalImage() {
        let (sut, _) = makeSUT()
        let firstImage = UIImage(systemName: "star")!.withRenderingMode(.alwaysOriginal)
        let replacementImage = UIImage(systemName: "heart.fill")!.withRenderingMode(.alwaysOriginal)

        if #available(iOS 15.0, *) {
            sut.configuration = nil
        }
        sut.display(image: firstImage)
        sut.display(style: .init(imageTintColor: .systemRed))
        sut.display(image: replacementImage)

        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === replacementImage)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysOriginal)
    }

    func test_buttonOutput_leavingGlassStyle_restoresUnderlyingOriginalImage() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass is available on iOS 26 and newer")
        }
        let (sut, _) = makeSUT()
        let originalImage = UIImage(systemName: "star.fill")!.withRenderingMode(.alwaysOriginal)

        sut.configuration = nil
        sut.setImage(originalImage, for: .normal)
        sut.display(style: .init(
            imageTintColor: .systemRed,
            glassConfiguration: .glass
        ))

        XCTAssertNotNil(sut.configuration)
        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertNil(sut.configuration)
        XCTAssertTrue(sut.image(for: .normal) === originalImage)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysOriginal)
    }

    func test_buttonOutput_prominentGlass_preservesMaterialThroughColorStateChanges() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass is available on iOS 26 and newer")
        }
        for glassConfiguration in [ButtonStyle.GlassConfiguration.prominentGlass, .prominentClearGlass] {
            try withLiveGlassButton { sut in
                let normalColor = UIColor(red: 0.21, green: 0.46, blue: 0.73, alpha: 1)
                let pressedColor = UIColor.systemTeal
                let nativeBackground = glassConfiguration == .prominentGlass ? UIButton.Configuration.prominentGlass().background : UIButton.Configuration.prominentClearGlass().background
                sut.display(style: .init(
                    backgroundColor: .solid(normalColor),
                    titleColor: .white,
                    pressedColor: pressedColor,
                    glassConfiguration: glassConfiguration
                ))
                for (highlighted, expectedColor) in [(false, normalColor), (true, pressedColor), (false, normalColor)] {
                    sut.isHighlighted = highlighted
                    flushConfigurationUpdates(of: sut)
                    XCTAssertEqual(sut.configuration?.baseBackgroundColor, expectedColor)
                    XCTAssertEqual(sut.configuration?.background.backgroundColor, nativeBackground.backgroundColor)
                    XCTAssertEqual(sut.backgroundColor, .clear)
                }
                sut.display(enabled: false)
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, normalColor)
                sut.display(enabled: true)
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, nativeBackground.backgroundColor)

                sut.textBackgroundColor = .systemRed
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.baseBackgroundColor, .systemRed)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, nativeBackground.backgroundColor)
                sut.display(enabled: false)
                sut.isHighlighted = true
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, .systemRed, "Disabled fill must use the current normal color even when highlighted")
                sut.textBackgroundColor = .systemPurple
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, .systemPurple)
                sut.display(enabled: true)
                for (highlighted, expectedColor) in [(false, UIColor.systemPurple), (true, pressedColor), (false, UIColor.systemPurple)] {
                    sut.isHighlighted = highlighted
                    flushConfigurationUpdates(of: sut)
                    XCTAssertEqual(sut.configuration?.baseBackgroundColor, expectedColor)
                    XCTAssertEqual(sut.configuration?.background.backgroundColor, nativeBackground.backgroundColor)
                }
            }
        }
    }

    func test_buttonOutput_neutralGlass_preservesMaterialThroughHighlightAndRedisplay() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass is available on iOS 26 and newer")
        }
        try withLiveGlassButton { sut in
            let style = ButtonStyle(backgroundColor: .solid(.clear), pressedColor: .clear, glassConfiguration: .glass)
            sut.display(style: style)

            for highlighted in [false, true, false] {
                sut.isHighlighted = highlighted
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, .clear)
            }

            sut.display(style: style)
            flushConfigurationUpdates(of: sut)
            XCTAssertEqual(sut.configuration?.background.backgroundColor, .clear)
        }
    }

    func test_buttonOutput_ordinaryGlass_preservesLegacyFillThroughColorStateChanges() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass is available on iOS 26 and newer")
        }
        try withLiveGlassButton { sut in
            let normalColor = UIColor.systemGreen
            let pressedColor = UIColor.systemTeal
            sut.display(style: .init(
                backgroundColor: .solid(normalColor),
                pressedColor: pressedColor,
                glassConfiguration: .glass
            ))

            for (highlighted, expectedColor) in [(false, normalColor), (true, pressedColor), (false, normalColor)] {
                sut.isHighlighted = highlighted
                flushConfigurationUpdates(of: sut)
                XCTAssertEqual(sut.configuration?.background.backgroundColor, expectedColor)
            }

            sut.textBackgroundColor = .systemRed
            flushConfigurationUpdates(of: sut)
            XCTAssertEqual(sut.configuration?.background.backgroundColor, .systemRed)
            sut.isHighlighted = true
            flushConfigurationUpdates(of: sut)
            XCTAssertEqual(sut.configuration?.background.backgroundColor, pressedColor)
            sut.isHighlighted = false
            flushConfigurationUpdates(of: sut)
            XCTAssertEqual(sut.configuration?.background.backgroundColor, .systemRed)
        }
    }

    func test_buttonOutput_leavingGlass_preservesPlainAndCustomConfigurationColors() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass is available on iOS 26 and newer")
        }
        let (sut, _) = makeSUT()
        sut.display(style: .init(backgroundColor: .solid(.systemGreen), glassConfiguration: .prominentGlass))
        sut.display(style: .init(backgroundColor: .solid(.systemOrange)))

        XCTAssertNil(sut.configuration)
        XCTAssertNil(sut.configurationUpdateHandler)
        XCTAssertEqual(sut.backgroundColor, .systemOrange)
        sut.textBackgroundColor = .systemPurple
        XCTAssertEqual(sut.backgroundColor, .systemPurple)

        var customConfiguration = UIButton.Configuration.plain()
        customConfiguration.baseBackgroundColor = .systemYellow
        sut.configuration = customConfiguration
        sut.textBackgroundColor = .systemBlue
        XCTAssertEqual(sut.configuration?.background.backgroundColor, .systemBlue)
        XCTAssertEqual(sut.configuration?.baseBackgroundColor, .systemYellow)
    }

    func test_buttonOutput_glassCapsules_resetClippingAcrossStyleReuse() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("Liquid Glass requires iOS 26") }
        let plain = ButtonStyle(backgroundColor: .solid(.systemOrange), cornerStyle: .automatic)
        for factory in [ButtonStyle.GlassConfiguration.glass, .clearGlass, .prominentGlass, .prominentClearGlass] {
            for color in [UIColor.clear, .systemGreen] {
                let style = ButtonStyle(backgroundColor: .solid(color), cornerStyle: .automatic, glassConfiguration: factory)
                let (sut, _) = makeSUT(button: Button(style: style, title: "Native"))
                XCTAssertFalse(sut.clipsToBounds, "A native capsule must not inherit clipping during initialization")
                sut.display(style: plain)
                XCTAssertTrue(sut.clipsToBounds)
                sut.display(style: style)
                XCTAssertFalse(sut.clipsToBounds)
                sut.clipsToBounds = true
                sut.display(style: style)
                XCTAssertFalse(sut.clipsToBounds, "Reapplying a native capsule resets clipping regardless of its fill")
                sut.display(style: plain)
                XCTAssertTrue(sut.clipsToBounds, "Plain automatic corners recompute their own clipping")
            }
        }
    }

    func test_buttonOutput_glass_explicitCornersRetainClipping() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("Liquid Glass requires iOS 26") }
        for factory in [ButtonStyle.GlassConfiguration.glass, .clearGlass, .prominentGlass, .prominentClearGlass] {
            let fixed = ButtonStyle(backgroundColor: .solid(.systemGreen), cornerStyle: .fixed(12), glassConfiguration: factory)
            let automatic = ButtonStyle(backgroundColor: .solid(.systemGreen), cornerStyle: .automatic, glassConfiguration: factory)
            let (sut, _) = makeSUT(button: Button(style: fixed))
            XCTAssertTrue(sut.clipsToBounds)
            sut.display(style: automatic)
            XCTAssertFalse(sut.clipsToBounds)
            sut.display(style: fixed)
            XCTAssertTrue(sut.clipsToBounds)
            sut.display(style: automatic)
            sut.display(style: .init(backgroundColor: .solid(.systemGreen), cornerStyle: .corners(.init(top: 12)), glassConfiguration: factory))
            XCTAssertTrue(sut.clipsToBounds)
        }
    }

    func test_buttonOutput_styleInitializer_preservesContentBackgroundAndDisabledAppearance() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("Live configuration updates require iOS 26") }
        let gradient = ColorStyle.gradient(.init(colors: [.red, .blue]))
        let styles = [
            ButtonStyle(backgroundColor: .solid(.systemBlue), titleColor: .systemYellow, font: .systemFont(ofSize: 18), cornerStyle: .fixed(12)),
            ButtonStyle(backgroundColor: gradient, titleColor: .systemYellow, font: .systemFont(ofSize: 18), cornerStyle: .fixed(12)),
            ButtonStyle(backgroundColor: .solid(.systemBlue), titleColor: .systemYellow, font: .systemFont(ofSize: 18), glassConfiguration: .prominentGlass)
        ]
        for style in styles {
            try withLiveGlassButton(makeButton: { Button(style: style, title: "Initialized", enabled: false) }) { sut in
                flushConfigurationUpdates(of: sut)
                XCTAssertFalse(sut.isEnabled)
                XCTAssertEqual(sut.alpha, 0.5)
                XCTAssertTrue(sut.isAccessibilityElement)
                XCTAssertTrue(sut.accessibilityTraits.contains(.notEnabled))
                XCTAssertEqual(sut.contentHorizontalAlignment, .center)
                XCTAssertEqual(sut.titleLabel?.lineBreakMode, .byTruncatingTail)
                XCTAssertEqual(sut.titleLabel?.font, style.font)
                XCTAssertEqual(sut.textColor, .systemYellow)
                XCTAssertEqual(sut.normalBackgroundStyle, style.backgroundStyle)
                if let configuration = sut.configuration {
                    XCTAssertEqual(configuration.title, "Initialized")
                    XCTAssertEqual(configuration.background.backgroundColor, .systemBlue)
                    XCTAssertEqual(configuration.contentInsets, .zero)
                    XCTAssertEqual(configuration.imagePadding, 0)
                } else {
                    XCTAssertEqual(sut.title(for: .normal), "Initialized")
                    XCTAssertEqual(sut.accessibilityLabel, "Initialized")
                    let gradients = sut.layer.sublayers?.compactMap { $0 as? CAGradientLayer } ?? []
                    if style.backgroundStyle == gradient {
                        XCTAssertEqual(gradients.count, 1)
                        XCTAssertEqual(gradients.first?.colors as? [CGColor], [UIColor.red.cgColor, UIColor.blue.cgColor])
                        XCTAssertEqual(gradients.first?.frame, sut.bounds)
                    } else {
                        XCTAssertTrue(gradients.isEmpty)
                        XCTAssertEqual(sut.backgroundColor, .systemBlue)
                    }
                }
                sut.display(enabled: true)
                flushConfigurationUpdates(of: sut)
                XCTAssertTrue(sut.isEnabled)
                XCTAssertEqual(sut.alpha, 1)
                if sut.configuration != nil {
                    XCTAssertEqual(sut.configuration?.background.backgroundColor, UIButton.Configuration.prominentGlass().background.backgroundColor)
                }
            }
        }
    }

    func test_fail_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image =  UIImage(systemName: "star")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - Set image tests
    func test_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let image = UIImage(systemName: "star.fill")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_fail_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.url
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_fail_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.url
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.dark.url
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.dark.url
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.urlString
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_fail_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.urlString
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let dark = ImageSnapshotFixture.dark.urlString
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let dark = ImageSnapshotFixture.dark.urlString
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 50,
            style: .init(backgroundColor: .solid(.red))
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 40,
            style: .init(backgroundColor: .solid(.red))
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_with_onPress() {
        let snapshotName = "BUTTON_WITH_TAP"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.display { [weak sut] in
            sut?.backgroundColor = .red
        }

        sut.onPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_with_onPress() {
        let snapshotName = "BUTTON_WITH_TAP"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.display { [weak sut] in
            sut?.backgroundColor = .systemRed
        }

        sut.onPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH height",
            image: UIImage(systemName: "star"),
            spacing: 50,
            height: 100,
            style: .init(backgroundColor: .solid(.red)),
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH height",
            image: UIImage(systemName: "star"),
            spacing: 50,
            height: 0,
            style: .init(backgroundColor: .solid(.red)),
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.display(isHidden: false)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.display(isHidden: true)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - ButtonStyle tests
    func test_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.systemRed)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.red)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(backgroundColor: .solid(.cyan), titleColor: .red))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "TITLE WITH COLOR.")
        sut.display(style: .init(backgroundColor: .solid(.cyan), titleColor: .red))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.cyan),
            borderWidth: 4.0,
            borderColor: .red
        ))
        
        sut.display(title: "BUTTON WITH BORDER")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.cyan),
            borderWidth: 5.0,
            borderColor: .red
        ))
        
        sut.display(title: "BUTTON WITH BORDER")
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - Do it
    func test_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.blue),
            pressedColor: .red,
        ))
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.blue),
            pressedColor: .systemRed,
        ))
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.white),
            titleColor: .blue,
            pressedTintColor: .red,
        ))
        sut.display(title: "PRESSED TINT COLOR")
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.white),
            titleColor: .blue,
            pressedTintColor: .systemRed,
        ))
        sut.display(title: "PRESSED TINT COLOR")
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.cyan), font: .systemFont(ofSize: 24, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.cyan), font: .systemFont(ofSize: 25, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT(height: 100)
        
        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .solid(.cyan), cornerRadius: 40))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT(height: 100)
        
        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .solid(.cyan), cornerRadius: 41))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.setImage(.url(nil, nil), completion: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        sut.setImage(.url(nil, nil), completion: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = ButtonStyle(
            backgroundColor: .solid(.systemBlue),
            loadingIndicatorColor: .red
        )
        
        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = ButtonStyle(
            backgroundColor: .solid(.systemBlue),
            loadingIndicatorColor: .red
        )
        
        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_buttonOutput_isLoading_state_false() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE_FALSE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = ButtonStyle(
            backgroundColor: .solid(.systemBlue),
            loadingIndicatorColor: .red
        )
        
        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: false)
        
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

extension ButtonSnapshotTests {
    private func assertDisplayedContent(
        title: String?,
        image: UIImage?,
        of button: Button,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if let configuration = button.configuration {
            XCTAssertEqual(configuration.title, title, file: file, line: line)
            XCTAssertEqual(configuration.image, image, file: file, line: line)
        } else {
            XCTAssertEqual(button.title(for: .normal), title, file: file, line: line)
            XCTAssertEqual(button.image(for: .normal), image, file: file, line: line)
        }
    }

    private struct ButtonAlignmentCase {
        let name: String
        let value: UIControl.ContentHorizontalAlignment
        let titleAlignment: UIButton.Configuration.TitleAlignment
    }

    private var buttonAlignments: [ButtonAlignmentCase] {
        [
            .init(name: "leading", value: .leading, titleAlignment: .leading),
            .init(name: "center", value: .center, titleAlignment: .center),
            .init(name: "trailing", value: .trailing, titleAlignment: .trailing),
            .init(name: "left", value: .left, titleAlignment: .leading),
            .init(name: "right", value: .right, titleAlignment: .trailing),
            .init(name: "fill", value: .fill, titleAlignment: .center)
        ]
    }

    private func alignmentStyle(_ glassStyle: ButtonStyle.GlassConfiguration?) -> ButtonStyle {
        .init(
            backgroundColor: .solid(.secondarySystemBackground),
            titleColor: .label,
            font: .systemFont(ofSize: 17),
            cornerStyle: .fixed(12),
            glassConfiguration: glassStyle
        )
    }

    private func makeAlignmentSUT(
        alignments: [ButtonAlignmentCase]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (UIView, [(ButtonAlignmentCase, Button)]) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 700))
        container.backgroundColor = .systemBackground
        let buttons = (alignments ?? buttonAlignments).enumerated().map { index, alignment in
            let top = CGFloat(index) * 104 + 24
            let label = UILabel(frame: CGRect(x: 24, y: top, width: 342, height: 20))
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.text = alignment.name
            container.addSubview(label)

            let button = Button()
            container.addSubview(button)
            button.anchor(
                .top(container.topAnchor, constant: top + 28),
                .leading(container.leadingAnchor, constant: 24),
                .trailing(container.trailingAnchor, constant: 24),
                .height(48)
            )
            checkForMemoryLeaks(button, file: file, line: line)
            return (alignment, button)
        }
        container.layoutIfNeeded()
        return (container, buttons)
    }

    private func assertConfiguredAlignment(
        of button: Button,
        matches alignment: ButtonAlignmentCase,
        expectsGlass: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(button.contentHorizontalAlignment, alignment.value, alignment.name, file: file, line: line)
        if #available(iOS 26.0, *), expectsGlass {
            XCTAssertEqual(button.configuration?.titleAlignment, alignment.titleAlignment, alignment.name, file: file, line: line)
            if let transformer = button.configuration?.titleTextAttributesTransformer {
                let attributes = transformer(AttributeContainer())
                XCTAssertEqual(attributes.font, UIFont.systemFont(ofSize: 17), alignment.name, file: file, line: line)
                XCTAssertEqual(attributes.foregroundColor, button.textColor, alignment.name, file: file, line: line)
            } else {
                XCTFail("The configured font must have a title transformer", file: file, line: line)
            }
        } else {
            XCTAssertNil(button.configuration, alignment.name, file: file, line: line)
        }
    }

    private func assertAlignmentSnapshots(
        container: UIView,
        buttons: [(ButtonAlignmentCase, Button)],
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let os = if #available(iOS 26.0, *) { "iOS26" } else { "iOS18.5" }
        for (style, suffix) in [(UIUserInterfaceStyle.light, "LIGHT"), (.dark, "DARK")] {
            assert(snapshot: container.snapshot(for: .iPhone(style: style)), named: "\(os)_\(name)_\(suffix)")

            for (alignment, button) in buttons {
                assertConfiguredAlignment(of: button, matches: alignment, file: file, line: line)
                let title = try XCTUnwrap(button.titleLabel, file: file, line: line)
                let titleFrame = button.convert(title.bounds, from: title)
                var contentFrame = titleFrame
                let hasImage = button.imageView?.image != nil
                XCTAssertGreaterThan(contentFrame.width, 0, alignment.name, file: file, line: line)
                if let image = button.imageView, hasImage {
                    let imageFrame = button.convert(image.bounds, from: image)
                    XCTAssertLessThanOrEqual(imageFrame.maxX, titleFrame.minX + 1, alignment.name, file: file, line: line)
                    contentFrame = contentFrame.union(imageFrame)
                }
                XCTAssertTrue(button.bounds.insetBy(dx: -1, dy: -1).contains(contentFrame), alignment.name, file: file, line: line)

                switch alignment.value {
                case .center, .fill:
                    if !hasImage {
                        XCTAssertEqual(contentFrame.midX, button.bounds.midX, accuracy: 2, alignment.name, file: file, line: line)
                    }
                case .leading, .left:
                    XCTAssertLessThan(contentFrame.maxX, button.bounds.midX, alignment.name, file: file, line: line)
                case .trailing, .right:
                    XCTAssertGreaterThan(contentFrame.minX, button.bounds.midX, alignment.name, file: file, line: line)
                @unknown default:
                    XCTFail("Unsupported alignment", file: file, line: line)
                }
            }
        }
    }

    @available(iOS 26.0, *)
    private func withLiveGlassButton(makeButton: (() -> Button)? = nil, _ body: (Button) -> Void) throws {
        try autoreleasepool {
            let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
            let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
            let window = UIWindow(windowScene: scene)
            let root = UIViewController()
            root.view.backgroundColor = .systemBackground
            let (sut, container) = makeSUT(button: makeButton?())
            root.view.addSubview(container)
            window.rootViewController = root
            window.makeKeyAndVisible()
            window.layoutIfNeeded()
            defer {
                sut.layer.removeAllAnimations()
                sut.removeFromSuperview()
                container.removeFromSuperview()
                root.view.subviews.forEach { $0.removeFromSuperview() }
                window.resignKey()
                window.isHidden = true
                window.rootViewController = nil
                window.windowScene = nil
                previousKeyWindow?.makeKeyAndVisible()
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            }
            body(sut)
        }
    }

    @available(iOS 26.0, *)
    private func flushConfigurationUpdates(of button: UIButton) {
        // UIKit invokes configurationUpdateHandler during its deferred update pass.
        button.setNeedsUpdateConfiguration()
        button.window?.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        button.window?.layoutIfNeeded()
    }

    func makeImage(width: CGFloat) -> UIImage {
        UIGraphicsImageRenderer(size: .init(width: width, height: 10)).image { context in
            UIColor.black.setFill()
            context.fill(.init(x: 0, y: 0, width: width, height: 10))
        }
        .withRenderingMode(.alwaysOriginal)
    }

    func makeSUT(
        button: Button? = nil,
        height: CGFloat = 60,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: Button, container: UIView) {
        let sut = button ?? Button()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(height, priority: .required)
        )
        
        container.layoutIfNeeded()
        
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
