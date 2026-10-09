#if os(iOS) && canImport(SwiftUI)
import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17, *)
@MainActor
final class SUILabelStrikethroughSnapshotTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        guard #available(iOS 18, *) else {
            throw XCTSkip("Advanced strikethrough rendering requires TextRenderer on iOS 18 or later.")
        }
    }

    func test_zero_and_pattern_without_line_do_not_strike_text() {
        let plain = snapshot(style: nil)

        for style: NSUnderlineStyle in [.init(rawValue: 0), .patternDash, .byWord] {
            XCTAssertNil(Diffing.image().diff(plain, snapshot(style: style)), "Style: \(style.rawValue)")
        }
        XCTAssertNotNil(Diffing.image().diff(plain, snapshot(style: .single)))
    }

    func test_strikethrough_preserves_patterns() {
        let solid = snapshot(style: .single)
        let patterns: [NSUnderlineStyle] = [.patternDot, .patternDash, .patternDashDot, .patternDashDotDot]

        for pattern in patterns {
            XCTAssertNotNil(Diffing.image().diff(solid, snapshot(style: [.single, pattern])), "Pattern: \(pattern.rawValue)")
        }
    }

    func test_double_and_thick_do_not_fall_back_to_single() {
        for pattern: NSUnderlineStyle in [.init(rawValue: 0), .patternDash, .patternDot] {
            let single = snapshot(style: [.single, pattern])
            let double = snapshot(style: [.double, pattern])
            let thick = snapshot(style: [.thick, pattern])

            XCTAssertNotNil(Diffing.image().diff(single, double), "Double, pattern: \(pattern.rawValue)")
            XCTAssertNotNil(Diffing.image().diff(single, thick), "Thick, pattern: \(pattern.rawValue)")
            XCTAssertNotNil(Diffing.image().diff(double, thick), "Double versus thick, pattern: \(pattern.rawValue)")
        }
    }

    func test_solid_styles_draw_the_requested_number_and_thickness_of_lines() throws {
        let font = UIFont.monospacedSystemFont(ofSize: 32, weight: .regular)
        let text = "LEFT          RIGHT"
        let size = CGSize(width: 420, height: 70)
        let gap = CGRect(
            x: ("LEFT  " as NSString).size(withAttributes: [.font: font]).width,
            y: 0,
            width: ("      " as NSString).size(withAttributes: [.font: font]).width,
            height: size.height
        )
        let single = try darkPixelBands(in: crop(render(SUILabelView(model: model(text: text, style: .single), font: font), size: size), rect: gap))
        let double = try darkPixelBands(in: crop(render(SUILabelView(model: model(text: text, style: .double), font: font), size: size), rect: gap))
        let thick = try darkPixelBands(in: crop(render(SUILabelView(model: model(text: text, style: .thick), font: font), size: size), rect: gap))

        XCTAssertEqual(single.count, 1, "Single must draw one continuous line: \(single)")
        XCTAssertEqual(double.count, 2, "Double must draw two separated lines: \(double)")
        XCTAssertEqual(thick.count, 1, "Thick must draw one line, not a second line: \(thick)")
        let singleBand = try XCTUnwrap(single.first)
        let thickBand = try XCTUnwrap(thick.first)
        XCTAssertGreaterThan(thickBand.count, singleBand.count, "Thick must be wider than single.")
    }

    func test_item_font_produces_the_same_text_and_decoration_as_the_matching_default_font() {
        let itemFont = UIFont.monospacedSystemFont(ofSize: 40, weight: .bold)
        let otherDefaultFont = UIFont.systemFont(ofSize: 18)
        let size = CGSize(width: 410, height: 90)

        for style: NSUnderlineStyle in [.single, .double, .thick, [.double, .patternDash], [.thick, .byWord]] {
            let explicitFont: TextOutputPresentableModel = .attributes([
                .init(text: "OLD    NEW", color: .label, font: itemFont, strikethroughStyle: style)
            ])
            let actual = render(SUILabelView(model: explicitFont, font: otherDefaultFont), size: size)
            let expected = render(SUILabelView(model: model(text: "OLD    NEW", style: style), font: itemFont), size: size)

            XCTAssertNil(Diffing.image().diff(expected, actual), "Item font must drive both glyphs and strike metrics: \(style.rawValue)")
        }
    }

    func test_advanced_strike_preserves_existing_unsupported_underline_rendering() throws {
        let font = UIFont.monospacedSystemFont(ofSize: 32, weight: .regular)
        let text = "LEFT          RIGHT"
        let size = CGSize(width: 420, height: 90)
        let gap = CGRect(
            x: ("LEFT  " as NSString).size(withAttributes: [.font: font]).width,
            y: 0,
            width: ("      " as NSString).size(withAttributes: [.font: font]).width,
            height: size.height
        )
        for underline: NSUnderlineStyle in [.double, .thick, .byWord] {
            let native = render(SUILabelView(model: model(text: text, style: nil, underlineStyle: underline), font: font), size: size)
            let expectedUnderline = try XCTUnwrap(darkPixelBands(in: crop(native, rect: gap)).last)
            for strike: NSUnderlineStyle in [.double, .thick, [.single, .byWord]] {
                let decorated = render(SUILabelView(model: model(text: text, style: strike, underlineStyle: underline), font: font), size: size)
                XCTAssertEqual(try darkPixelBands(in: crop(decorated, rect: gap)).last, expectedUnderline,
                               "Underline \(underline.rawValue) must not change with strike \(strike.rawValue).")
            }
        }
    }

    func test_single_strikethrough_keeps_native_swiftui_rendering() {
        let font = UIFont.systemFont(ofSize: 28)
        let attributes = TextAttributes(text: "175 USD", color: .label, strikethroughStyle: .single)
        let native = Text(AttributedString(attributes.makeNSAttributedString(font: font)))
            .font(SwiftUIFont(font))
        let sut = SUILabelView(model: .attributes([attributes]), font: font)

        XCTAssertNil(Diffing.image().diff(render(native), render(sut)))
    }

    func test_neighboring_custom_strike_does_not_change_native_single_segment() throws {
        let font = UIFont.monospacedSystemFont(ofSize: 28, weight: .regular)
        let prefix = TextAttributes(text: "175 USD", color: .label, strikethroughStyle: .single)
        let native: TextOutputPresentableModel = .attributes([
            prefix, .init(text: " 35 USD", color: .label)
        ])
        let custom: TextOutputPresentableModel = .attributes([
            prefix, .init(text: " 35 USD", color: .label, strikethroughStyle: .double)
        ])
        let size = CGSize(width: 330, height: 70)
        let prefixRect = CGRect(
            x: 0, y: 0,
            width: (prefix.text as NSString).size(withAttributes: [.font: font]).width - 2,
            height: size.height
        )
        let nativeImage = render(SUILabelView(model: native, font: font), size: size)
        let customImage = render(SUILabelView(model: custom, font: font), size: size)
        let nativePrefix = try crop(nativeImage, rect: prefixRect)
        let customPrefix = try crop(customImage, rect: prefixRect)
        if let diff = Diffing.image().diff(nativePrefix, customPrefix) {
            for (name, image) in [("Native single", nativePrefix), ("Single with custom neighbor", customPrefix), ("Difference", diff.artifacts.diff)] {
                let attachment = XCTAttachment(image: image)
                attachment.name = name
                attachment.lifetime = .keepAlways
                add(attachment)
            }
            XCTFail(diff.message)
        }
    }

    func test_byWord_does_not_draw_through_whitespace() throws {
        let font = UIFont.monospacedSystemFont(ofSize: 32, weight: .regular)
        let text = "LEFT      RIGHT"
        let size = CGSize(width: 330, height: 70)
        let prefixWidth = ("LEFT " as NSString).size(withAttributes: [.font: font]).width
        let gapWidth = ("    " as NSString).size(withAttributes: [.font: font]).width
        let gap = CGRect(x: prefixWidth, y: 0, width: gapWidth, height: size.height)
        let plain = render(SUILabelView(model: model(text: text, style: nil), font: font), size: size)
        let plainGap = try crop(plain, rect: gap)

        for line: NSUnderlineStyle in [.single, .double, .thick] {
            let continuous = render(SUILabelView(model: model(text: text, style: line), font: font), size: size)
            let byWord = render(SUILabelView(model: model(text: text, style: [line, .byWord]), font: font), size: size)

            XCTAssertNotNil(Diffing.image().diff(plain, byWord), "Words must still be struck: \(line.rawValue)")
            XCTAssertNotNil(Diffing.image().diff(plainGap, try crop(continuous, rect: gap)), "Continuous line must cross spaces: \(line.rawValue)")
            XCTAssertNil(Diffing.image().diff(plainGap, try crop(byWord, rect: gap)), "By-word line must leave spaces clear: \(line.rawValue)")
        }
    }

    func test_combined_patterns_keep_double_thick_and_byWord() {
        for line: NSUnderlineStyle in [.double, .thick] {
            let solid = snapshot(style: line)
            for pattern: NSUnderlineStyle in [.patternDot, .patternDash, .patternDashDot, .patternDashDotDot] {
                let patterned = snapshot(style: [line, pattern])
                XCTAssertNotNil(Diffing.image().diff(solid, patterned), "Line: \(line.rawValue), pattern: \(pattern.rawValue)")
                XCTAssertNotNil(Diffing.image().diff(snapshot(style: [.single, pattern]), patterned), "Thickness must survive pattern: \(pattern.rawValue)")
                XCTAssertNotNil(Diffing.image().diff(patterned, snapshot(style: [line, pattern, .byWord])), "By-word must survive pattern: \(pattern.rawValue)")
            }
        }
    }

    func test_underlining_and_strikethrough_are_independent() {
        let strike = snapshot(style: .double)
        let underline = render(SUILabelView(model: model(style: nil, underlineStyle: .single), font: .systemFont(ofSize: 28)))
        let both = render(SUILabelView(model: model(style: .double, underlineStyle: .single), font: .systemFont(ofSize: 28)))

        XCTAssertNotNil(Diffing.image().diff(strike, both))
        XCTAssertNotNil(Diffing.image().diff(underline, both))
    }

    func test_strikethrough_is_limited_to_its_attributed_segment() throws {
        let font = UIFont.monospacedSystemFont(ofSize: 28, weight: .regular)
        let prefix = "NEW "
        let old = "175 USD"
        let suffix = " 35 USD"
        let plain: TextOutputPresentableModel = .attributes([
            .init(text: prefix, color: .label),
            .init(text: old, color: .systemRed),
            .init(text: suffix, color: .label)
        ])
        let struck: TextOutputPresentableModel = .attributes([
            .init(text: prefix, color: .label),
            .init(text: old, color: .systemRed, strikethroughStyle: .double),
            .init(text: suffix, color: .label)
        ])
        let size = CGSize(width: 380, height: 70)
        let plainImage = render(SUILabelView(model: plain, font: font), size: size)
        let struckImage = render(SUILabelView(model: struck, font: font), size: size)
        let prefixWidth = (prefix as NSString).size(withAttributes: [.font: font]).width
        let oldWidth = (old as NSString).size(withAttributes: [.font: font]).width
        let prefixRect = CGRect(x: 0, y: 0, width: prefixWidth - 2, height: size.height)
        let oldRect = CGRect(x: prefixWidth + 2, y: 0, width: oldWidth - 4, height: size.height)
        let suffixRect = CGRect(x: prefixWidth + oldWidth + 2, y: 0, width: size.width - prefixWidth - oldWidth - 2, height: size.height)

        XCTAssertNil(Diffing.image().diff(try crop(plainImage, rect: prefixRect), try crop(struckImage, rect: prefixRect)))
        XCTAssertNotNil(Diffing.image().diff(try crop(plainImage, rect: oldRect), try crop(struckImage, rect: oldRect)))
        XCTAssertNil(Diffing.image().diff(try crop(plainImage, rect: suffixRect), try crop(struckImage, rect: suffixRect)))
    }

    func test_display_can_remove_and_restore_strikethrough() {
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabel(adapter: adapter, font: .systemFont(ofSize: 28))

        adapter.display(model: model(style: [.double, .byWord]))
        let struck = render(sut)
        adapter.display(model: model(style: .init(rawValue: 0)))
        let withoutLine = render(sut)
        adapter.display(model: model(style: nil))
        XCTAssertNil(Diffing.image().diff(withoutLine, render(sut)))
        XCTAssertNotNil(Diffing.image().diff(struck, withoutLine))
        adapter.display(model: model(style: [.double, .byWord]))
        XCTAssertNil(Diffing.image().diff(struck, render(sut)))
        adapter.display(model: model(style: [.single, .patternDash]))
        XCTAssertNotNil(Diffing.image().diff(struck, render(sut)))
    }

    func test_strikethrough_styles_in_light_and_dark_theme() {
        let styles: [(String, NSUnderlineStyle?)] = [
            ("nil", nil),
            ("zero", .init(rawValue: 0)),
            ("single", .single),
            ("double", .double),
            ("thick", .thick),
            ("dot", [.single, .patternDot]),
            ("dash", [.single, .patternDash]),
            ("dash-dot", [.single, .patternDashDot]),
            ("dash-dot-dot", [.single, .patternDashDotDot]),
            ("single by word", [.single, .byWord]),
            ("double + dash", [.double, .patternDash]),
            ("double by word", [.double, .byWord]),
            ("thick + dash-dot", [.thick, .patternDashDot]),
            ("double dash by word", [.double, .patternDash, .byWord]),
            ("thick dot by word", [.thick, .patternDot, .byWord]),
            ("pattern only: no line", .patternDash)
        ]
        let gallery = VStack(alignment: .leading, spacing: 12) {
            ForEach(styles.indices, id: \.self) { index in
                HStack {
                    Text(styles[index].0)
                        .font(.system(size: 12))
                        .frame(width: 170, alignment: .leading)
                    SUILabelView(model: self.model(style: styles[index].1), font: .systemFont(ofSize: 28))
                }
            }
        }
        .padding(16)

        let os = if #available(iOS 26, *) { "iOS26" } else { "iOS18.5" }
        for (scheme, name) in [(ColorScheme.light, "LIGHT"), (.dark, "DARK")] {
            assert(snapshot: render(gallery, scheme: scheme, size: CGSize(width: 390, height: 750)), named: "\(os)_SUI_LABEL_STRIKETHROUGH_STYLES_\(name)")
        }
    }

    func test_mixed_strikethrough_segments_wrap_and_keep_underlining() {
        let serifDescriptor = UIFont.systemFont(ofSize: 32).fontDescriptor.withDesign(.serif)
            ?? UIFont.systemFont(ofSize: 32).fontDescriptor
        let serifFont = UIFont(descriptor: serifDescriptor, size: 32)
        let icon = UIImage(systemName: "star.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        let model: TextOutputPresentableModel = .attributes([
            .init(text: "Original price ", color: .label),
            .init(text: "$175 USD", color: .systemRed, strikethroughStyle: .double),
            .init(text: "\nNew price $35 USD\n", color: .label),
            .init(text: "Double dashed words", color: .systemBlue, strikethroughStyle: [.double, .patternDash, .byWord]),
            .init(text: "\n", color: .label),
            .init(text: "Underline and thick strike\n", color: .label, underlineStyle: .single, strikethroughStyle: .thick),
            .init(text: "Bold small double\n", color: .systemPurple, font: .boldSystemFont(ofSize: 16), strikethroughStyle: .double),
            .init(text: "Serif thick strike\n", color: .label, font: serifFont, strikethroughStyle: .thick),
            .init(text: "Latin مرحبا 🙂\n", color: .label, strikethroughStyle: [.double, .patternDash]),
            .init(text: "Inline icons", color: .label, font: .systemFont(ofSize: 20), strikethroughStyle: .double,
                  leadingImage: icon, leadingImageBounds: CGRect(x: 0, y: 0, width: 16, height: 16),
                  trailingImage: icon, trailingImageBounds: CGRect(x: 0, y: 0, width: 16, height: 16))
        ])
        let gallery = SUILabelView(model: model, font: .systemFont(ofSize: 28))
            .padding(16)
        let os = if #available(iOS 26, *) { "iOS26" } else { "iOS18.5" }

        for (scheme, name) in [(ColorScheme.light, "LIGHT"), (.dark, "DARK")] {
            assert(snapshot: render(gallery, scheme: scheme, size: CGSize(width: 290, height: 480)), named: "\(os)_SUI_LABEL_STRIKETHROUGH_MIXED_\(name)")
        }
    }

    private func model(
        text: String = "175 USD",
        style: NSUnderlineStyle?,
        underlineStyle: NSUnderlineStyle? = nil
    ) -> TextOutputPresentableModel {
        .attributes([.init(text: text, color: .label, underlineStyle: underlineStyle, strikethroughStyle: style)])
    }

    private func snapshot(style: NSUnderlineStyle?) -> UIImage {
        render(SUILabelView(model: model(style: style), font: .systemFont(ofSize: 28)))
    }

    private func crop(_ image: UIImage, rect: CGRect) throws -> UIImage {
        let scaled = CGRect(x: rect.minX * image.scale, y: rect.minY * image.scale, width: rect.width * image.scale, height: rect.height * image.scale)
        let cropped = try XCTUnwrap(image.cgImage?.cropping(to: scaled))
        return UIImage(cgImage: cropped, scale: image.scale, orientation: .up)
    }

    /// The fixture contains only whitespace here. Count horizontal dark-pixel
    /// bands rather than accepting any visual difference as a correct style.
    private func darkPixelBands(in image: UIImage) throws -> [ClosedRange<Int>] {
        let cgImage = try XCTUnwrap(image.cgImage)
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        try pixels.withUnsafeMutableBytes { bytes in
            let context = try XCTUnwrap(CGContext(
                data: bytes.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        var bands: [ClosedRange<Int>] = []
        var start: Int?
        for row in 0..<height {
            let darkPixelCount = (0..<width).reduce(into: 0) { count, column in
                let offset = (row * width + column) * 4
                if pixels[offset] < 128 && pixels[offset + 1] < 128 && pixels[offset + 2] < 128 {
                    count += 1
                }
            }
            if darkPixelCount >= width / 2 {
                if start == nil { start = row }
            } else if let first = start {
                bands.append(first...(row - 1))
                start = nil
            }
        }
        if let first = start { bands.append(first...(height - 1)) }
        return bands
    }

    private func render<V: View>(
        _ view: V,
        scheme: ColorScheme = .light,
        size: CGSize = CGSize(width: 220, height: 70)
    ) -> UIImage {
        var image: UIImage!
        // NSAttributedString resolves UIKit dynamic colors before SwiftUI's
        // environment can apply to the resulting Text.
        UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light).performAsCurrent {
            let renderer = ImageRenderer(content: view
                .frame(width: size.width, height: size.height, alignment: .leading)
                .background(Color(uiColor: .systemBackground))
                .environment(\.colorScheme, scheme))
            renderer.scale = 3
            image = renderer.uiImage!
        }
        return image
    }
}
#endif
