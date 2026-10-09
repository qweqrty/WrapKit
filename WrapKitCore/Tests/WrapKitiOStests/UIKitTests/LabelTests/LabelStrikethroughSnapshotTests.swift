#if os(iOS)
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@MainActor
final class LabelStrikethroughSnapshotTests: XCTestCase {
    func test_strikethrough_raw_style_is_preserved_in_attributed_text() throws {
        let sut = Label(font: .systemFont(ofSize: 28))
        let styles: [NSUnderlineStyle?] = [
            nil, .init(rawValue: 0), .single, .double, .thick,
            [.single, .byWord], [.double, .byWord], [.thick, .byWord],
            [.single, .patternDot], [.single, .patternDash],
            [.single, .patternDashDot], [.single, .patternDashDotDot],
            [.double, .patternDash, .byWord], [.thick, .patternDot, .byWord],
            .patternDash, .byWord
        ]

        for style in styles {
            sut.display(model: model(style: style))
            let attributed = try XCTUnwrap(sut.attributedText)
            let actual = (attributed.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? NSNumber)?.intValue
            XCTAssertEqual(actual, style?.rawValue, "Style: \(String(describing: style))")
        }
    }

    func test_underlining_and_strikethrough_keep_their_own_raw_style() throws {
        let sut = Label(font: .systemFont(ofSize: 28))
        let underline: NSUnderlineStyle = [.single, .patternDot]
        let strike: NSUnderlineStyle = [.double, .patternDash, .byWord]
        sut.display(model: .attributes([
            .init(text: "Both decorations", underlineStyle: underline, strikethroughStyle: strike)
        ]))
        let attributed = try XCTUnwrap(sut.attributedText)

        XCTAssertEqual((attributed.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? NSNumber)?.intValue, underline.rawValue)
        XCTAssertEqual((attributed.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? NSNumber)?.intValue, strike.rawValue)
    }

    func test_strikethrough_is_limited_to_its_attributed_segment() throws {
        let sut = Label(font: .systemFont(ofSize: 28))
        sut.display(model: .attributes([
            .init(text: "Original "),
            .init(text: "$175", color: .systemRed, strikethroughStyle: .double),
            .init(text: " now $35", color: .label)
        ]))
        let attributed = try XCTUnwrap(sut.attributedText)
        let oldPriceRange = (attributed.string as NSString).range(of: "$175")

        for index in 0..<attributed.length {
            let actual = (attributed.attribute(.strikethroughStyle, at: index, effectiveRange: nil) as? NSNumber)?.intValue
            XCTAssertEqual(actual, NSLocationInRange(index, oldPriceRange) ? NSUnderlineStyle.double.rawValue : nil, "Character: \(index)")
        }
    }

    func test_display_removes_and_restores_strikethrough_without_stale_attributes() throws {
        let sut = Label(font: .systemFont(ofSize: 28))
        let style: NSUnderlineStyle = [.double, .patternDash, .byWord]
        let styles: [NSUnderlineStyle?] = [style, .init(rawValue: 0), nil, style]

        for current in styles {
            sut.display(model: model(style: current))
            let attributed = try XCTUnwrap(sut.attributedText)
            XCTAssertEqual((attributed.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? NSNumber)?.intValue, current?.rawValue)
        }
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
        let container = makeContainer(size: CGSize(width: 390, height: 750))
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        pin(stack, in: container)

        for (title, style) in styles {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .label
            titleLabel.font = .systemFont(ofSize: 12)
            titleLabel.widthAnchor.constraint(equalToConstant: 170).isActive = true
            let label = Label(font: .systemFont(ofSize: 28))
            label.display(model: model(style: style))
            let row = UIStackView(arrangedSubviews: [titleLabel, label])
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 8
            stack.addArrangedSubview(row)
        }

        assertGallery(container, named: "LABEL_STRIKETHROUGH_STYLES")
    }

    func test_mixed_strikethrough_segments_wrap_and_keep_underlining() {
        let container = makeContainer(size: CGSize(width: 290, height: 300))
        let label = Label(font: .systemFont(ofSize: 28), numberOfLines: 0)
        pin(label, in: container)
        label.display(model: .attributes([
            .init(text: "Original price ", color: .label),
            .init(text: "$175 USD", color: .systemRed, strikethroughStyle: .double),
            .init(text: "\nNew price $35 USD\n", color: .label),
            .init(text: "Double dashed words", color: .systemBlue, strikethroughStyle: [.double, .patternDash, .byWord]),
            .init(text: "\n", color: .label),
            .init(text: "Underline and thick strike", color: .label, underlineStyle: .single, strikethroughStyle: .thick)
        ]))

        assertGallery(container, named: "LABEL_STRIKETHROUGH_MIXED")
    }

    private func model(style: NSUnderlineStyle?) -> TextOutputPresentableModel {
        .attributes([.init(text: "175 USD", color: .label, strikethroughStyle: style)])
    }

    private func makeContainer(size: CGSize) -> UIView {
        let container = UIView(frame: CGRect(origin: .zero, size: size))
        container.backgroundColor = .systemBackground
        return container
    }

    private func pin(_ view: UIView, in container: UIView) {
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
    }

    private func assertGallery(_ container: UIView, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let os = if #available(iOS 26, *) { "iOS26" } else { "iOS18.5" }
        for (style, theme) in [(UIUserInterfaceStyle.light, "LIGHT"), (.dark, "DARK")] {
            let traits = SnapshotConfiguration.iPhone(style: style).traitCollection
            let configuration = SnapshotConfiguration(
                size: container.frame.size,
                safeAreaInsets: .zero,
                layoutMargins: .zero,
                traitCollection: traits
            )
            let snapshot = container.snapshot(for: configuration)
            guard assertMeaningfulSnapshot(snapshot, traits: traits, file: file, line: line) else { continue }
            assert(snapshot: snapshot, named: "\(os)_\(name)_\(theme)", file: file, line: line)
        }
    }

    /// Never compare or record an empty render, even if an empty baseline exists.
    /// Require both the correct themed background and visible contrasting text.
    private func assertMeaningfulSnapshot(_ image: UIImage, traits: UITraitCollection, file: StaticString, line: UInt) -> Bool {
        guard let cgImage = image.cgImage else {
            XCTFail("The label snapshot has no pixel data.", file: file, line: line)
            return false
        }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let normalized = pixels.withUnsafeMutableBytes { bytes in
            guard let context = CGContext(
                data: bytes.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ) else { return false }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard normalized else {
            XCTFail("The label snapshot could not be normalized.", file: file, line: line)
            return false
        }

        let background = UIColor.systemBackground.resolvedColor(with: traits)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard background.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            XCTFail("The snapshot background could not be resolved for its theme.", file: file, line: line)
            return false
        }
        let expectedBackground = [red, green, blue].map { Int(($0 * 255).rounded()) }
        var visiblePixels = 0
        var contrastingPixels = 0
        for offset in stride(from: 0, to: pixels.count, by: 4) {
            guard pixels[offset + 3] > 0 else { continue }
            visiblePixels += 1
            if (0..<3).contains(where: { abs(Int(pixels[offset + $0]) - expectedBackground[$0]) > 8 }) {
                contrastingPixels += 1
            }
        }
        let backgroundMatches = (0..<3).allSatisfy { abs(Int(pixels[$0]) - expectedBackground[$0]) <= 3 }
        XCTAssertGreaterThan(visiblePixels, 0, "The snapshot is fully transparent.", file: file, line: line)
        XCTAssertTrue(backgroundMatches, "The snapshot does not have the requested light/dark background.", file: file, line: line)
        XCTAssertGreaterThan(contrastingPixels, 100, "The snapshot contains no meaningful label content.", file: file, line: line)
        return visiblePixels > 0 && backgroundMatches && contrastingPixels > 100
    }
}
#endif
