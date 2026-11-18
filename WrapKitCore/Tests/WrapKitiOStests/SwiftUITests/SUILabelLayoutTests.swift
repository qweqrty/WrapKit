#if canImport(SwiftUI) && canImport(UIKit)
import CoreText
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
@available(iOS 16.0, *)
final class SUILabelLayoutTests: XCTestCase {
    @available(iOS 17.0, *)
    func test_attributedCanvasExposesVisibleTextAsStaticTextAndUpdatesIt() throws {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(model: .init(
            accessibilityIdentifier: "pin.instruction",
            model: .attributes([.init(text: "Enter your "), .init(text: "PIN2 code")])
        ))
        let host = SwiftUIAccessibilityTestHost(rootView: SUILabel(adapter: adapter))

        let instruction = try XCTUnwrap(host.element(withIdentifier: "pin.instruction"), host.diagnosticDescription)
        XCTAssertEqual(instruction.accessibilityLabel, "Enter your PIN2 code")
        XCTAssertTrue(instruction.accessibilityTraits.contains(.staticText))
        XCTAssertFalse(instruction.accessibilityTraits.contains(.button))

        adapter.display(attributes: [.init(text: "Updated PIN2 instruction")])
        host.settle()

        XCTAssertNil(host.element(withLabel: "Enter your PIN2 code"))
        XCTAssertNotNil(host.element(withLabel: "Updated PIN2 instruction"), host.diagnosticDescription)
    }

    @available(iOS 17.0, *)
    func test_attributedCanvasPreservesExplicitAccessibilityLabelAndHint() throws {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(model: .init(
            accessibilityIdentifier: "pin.instruction",
            accessibility: .init(label: "PIN instructions", hint: "Ask your mobile operator"),
            model: .attributes([.init(text: "Enter your PIN2 code")])
        ))
        let host = SwiftUIAccessibilityTestHost(rootView: SUILabel(adapter: adapter))

        let instruction = try XCTUnwrap(host.element(withIdentifier: "pin.instruction"), host.diagnosticDescription)
        XCTAssertEqual(instruction.accessibilityLabel, "PIN instructions")
        XCTAssertEqual(instruction.accessibilityHint, "Ask your mobile operator")
        XCTAssertTrue(instruction.accessibilityTraits.contains(.staticText))
        XCTAssertNil(host.element(withLabel: "Enter your PIN2 code"))
    }

    @available(iOS 17.0, *)
    func test_tappableAttributedCanvasKeepsButtonTraitAndVisibleText() throws {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(model: .init(
            accessibilityIdentifier: "pin.help",
            model: .attributes([.init(text: "Get PIN2 help", onTap: {})])
        ))
        let host = SwiftUIAccessibilityTestHost(rootView: SUILabel(adapter: adapter))

        let help = try XCTUnwrap(host.element(withIdentifier: "pin.help"), host.diagnosticDescription)
        XCTAssertEqual(help.accessibilityLabel, "Get PIN2 help")
        XCTAssertTrue(help.accessibilityTraits.contains(.button))
    }

    func test_foundationSizedFrame_containsEveryFontCatalogLine() {
        for size in [CGFloat(50), 40, 30, 27, 24, 19, 17, 15, 13] {
            for weight in [UIFont.Weight.regular, .bold] {
                let text = catalogText(size: size, weight: weight)
                let width: CGFloat = 378
                let foundationHeight = text.boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                ).height
                let height = CoreTextAttributedLabelMetrics.drawingHeight(
                    in: text,
                    width: width,
                    minimumHeight: foundationHeight,
                    displayScale: 3
                )
                let framesetter = CTFramesetterCreateWithAttributedString(text as CFAttributedString)
                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRange(location: 0, length: text.length),
                    CGPath(rect: CGRect(x: 0, y: 0, width: width, height: height), transform: nil),
                    nil
                )

                XCTAssertEqual(
                    CTFrameGetVisibleStringRange(frame).length,
                    text.length,
                    "Missing text at \(size)pt, weight \(weight.rawValue)"
                )
            }
        }
    }

    func test_foundationSizedLabel_rendersEveryFontCatalogSize() {
        for size in [CGFloat(50), 30, 27, 24] {
            for weight in [UIFont.Weight.regular, .bold] {
                let host = LabelRenderingHost(
                    rootView: CoreTextAttributedLabel(
                        attributedText: catalogText(size: size, weight: weight),
                        alignment: .left,
                        usesFoundationLayoutMetrics: true,
                        tapActions: [],
                        contentRevision: 0
                    ),
                    size: CGSize(width: 378, height: 200)
                )

                XCTAssertGreaterThan(
                    host.pixelCount { red, green, blue in red < 80 && green < 80 && blue < 80 },
                    100,
                    "Empty drawing at \(size)pt, weight \(weight.rawValue)"
                )
            }
        }
    }

    func test_circleCountdown_doesNotChangeTextIntrinsicSize() {
        let plainHost = UIHostingController(rootView: countdown(style: .none).fixedSize())
        let circleHost = UIHostingController(rootView: countdown(style: .circle(lineColor: .blue)).fixedSize())
        let constraint = CGSize(width: 1_000, height: 1_000)
        let plainSize = plainHost.sizeThatFits(in: constraint)
        let circleSize = circleHost.sizeThatFits(in: constraint)

        XCTAssertGreaterThan(circleSize.width, 0)
        XCTAssertGreaterThan(circleSize.height, 0)
        XCTAssertEqual(circleSize.width, plainSize.width, accuracy: 0.5)
        XCTAssertEqual(circleSize.height, plainSize.height, accuracy: 0.5)
    }

    func test_circleCountdown_inCardRendersNumberAndProgress() {
        let adapter = CardViewOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: cardStyle,
            title: .text("Number removed"),
            leadingTitles: .init(.animated(
                5.9,
                0.9,
                mapToString: { .text(String(Int($0))) },
                animationStyle: .circle(lineColor: .blue),
                duration: 1_000,
                completion: nil
            ), nil),
            subTitle: .text("Undo")
        ))
        let host = LabelRenderingHost(
            rootView: SUICardView(adapter: adapter),
            size: CGSize(width: 360, height: 64)
        )
        let attachment = XCTAttachment(image: host.renderedImage())
        attachment.name = "Card circle countdown"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertGreaterThan(host.pixelCount { red, green, blue in
            Int(red) > Int(green) + 40 && Int(red) > Int(blue) + 40
        }, 5, "The leading countdown number must remain visible")
        XCTAssertGreaterThan(host.pixelCount { red, green, blue in
            Int(blue) > Int(red) + 40 && Int(blue) > Int(green) + 40
        }, 5, "The countdown progress ring must remain visible")
    }

    private func catalogText(size: CGFloat, weight: UIFont.Weight) -> NSAttributedString {
        NSAttributedString(
            string: "\(Int(size)) font size, regular font weight",
            attributes: [
                .font: UIFont.systemFont(ofSize: size, weight: weight),
                .foregroundColor: UIColor.black
            ]
        )
    }

    private func countdown(style: LabelAnimationStyle) -> some View {
        SUICountingLabelAnimation(
            from: 5.9,
            to: 0.9,
            mapToString: { .text(String(Int($0.doubleValue))) },
            animationStyle: style,
            duration: 1_000,
            font: .systemFont(ofSize: 16),
            textColor: .red,
            textAlignment: .center
        )
    }

    private var cardStyle: CardViewPresentableModel.Style {
        .init(
            backgroundColor: .white,
            vStacklayoutMargins: .init(horizontal: 16, vertical: 12),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .red,
            titleKeyTextColor: .black,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .black,
            subTitleTextColor: .black,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 16),
            titleKeyLabelFont: .systemFont(ofSize: 16),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 16),
            titleValueLabelFont: .systemFont(ofSize: 16),
            subTitleLabelFont: .systemFont(ofSize: 16),
            cornerRadius: 12,
            stackSpace: 0,
            hStackViewSpacing: 12,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0
        )
    }
}

@MainActor
private final class LabelRenderingHost {
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow

    init(rootView: some View, size: CGSize) {
        hostingController = UIHostingController(rootView: AnyView(rootView.ignoresSafeArea()))
        hostingController.overrideUserInterfaceStyle = .light
        window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.backgroundColor = .white
        window.rootViewController = hostingController
        hostingController.view.frame = window.bounds
        hostingController.view.backgroundColor = .white
        window.makeKeyAndVisible()
        settle()
    }

    deinit {
        window.isHidden = true
    }

    func pixelCount(where matches: (UInt8, UInt8, UInt8) -> Bool) -> Int {
        guard let image = renderedImage().cgImage else { return 0 }
        let width = image.width
        let height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else { return 0 }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return stride(from: 0, to: pixels.count, by: 4).reduce(into: 0) { count, index in
            if pixels[index + 3] > 32, matches(pixels[index], pixels[index + 1], pixels[index + 2]) {
                count += 1
            }
        }
    }

    func renderedImage() -> UIImage {
        settle()
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(bounds: hostingController.view.bounds, format: format).image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }

    private func settle() {
        window.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }
}
#endif
