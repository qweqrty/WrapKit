#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@MainActor
final class ButtonRenderingCompatibilityTests: XCTestCase {
    func test_nativeHeaderGiftPill_preservesOriginalArtworkBesideTitle() throws {
        let artwork = makeGiftArtwork()
        XCTAssertEqual(artwork.renderingMode, .alwaysOriginal)
        XCTAssertGreaterThan(try whitePixelCount(in: artwork, rect: CGRect(origin: .zero, size: artwork.size)), 20)
        let artworkAttachment = XCTAttachment(image: artwork)
        artworkAttachment.name = "uikit_native_header_gift_pill_source_artwork"
        artworkAttachment.lifetime = .keepAlways
        add(artworkAttachment)
        let root = UIViewController()
        root.view.backgroundColor = .white
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.loadViewIfNeeded()
        let bar = navigationController.navigationBar
        bar.display(model: .init(
            style: .init(backgroundColor: .white, horizontalSpacing: 8,
                         primeFont: .systemFont(ofSize: 17), primeColor: .black,
                         secondaryFont: .systemFont(ofSize: 12), secondaryColor: .gray),
            primeTrailingImage: .init(
                title: "+1", image: artwork, spacing: 2,
                contentInset: .init(top: 4, leading: 8, bottom: 4, trailing: 8),
                isGlassEffectEnabled: false, height: 28,
                style: .init(backgroundColor: .gradient(.init(colors: [.magenta, .systemPink])),
                             titleColor: .white, imageTintColor: .white,
                             font: .systemFont(ofSize: 13, weight: .semibold), cornerRadius: 14), onPress: {}
            )
        ))
        let rendered = navigationController.snapshot(for: .iPhone(style: .light))
        let attachment = XCTAttachment(image: rendered)
        attachment.name = "uikit_native_header_gift_pill_context"
        attachment.lifetime = .keepAlways
        add(attachment)
        let host = try XCTUnwrap(bar.topItem?.rightBarButtonItem?.customView)
        let button = try XCTUnwrap(firstButton(in: host))
        let imageView = try XCTUnwrap(button.imageView)
        let stateImage = try XCTUnwrap(button.image(for: .normal))
        let imageRect = button.imageRect(forContentRect: button.contentRect(forBounds: button.bounds))
        let titleRect = button.titleRect(forContentRect: button.contentRect(forBounds: button.bounds))
        let layers = button.layer.sublayers ?? []
        let layerOrder = layers.enumerated().map { index, layer in
            "\(index):\(type(of: layer))/\(layer.name ?? "nil")/image=\(layer === imageView.layer)/title=\(layer === button.titleLabel?.layer)"
        }.joined(separator: "; ")
        print("Gift pill layer order: \(layerOrder)")
        let geometry = XCTAttachment(string:
            "host=\(host.frame), intrinsic=\(host.intrinsicContentSize), button=\(button.frame), "
            + "buttonIntrinsic=\(button.intrinsicContentSize), imageRect=\(imageRect), "
            + "imageView=\(imageView.frame), imageViewBounds=\(imageView.bounds), "
            + "imageViewHidden=\(imageView.isHidden), imageViewAlpha=\(imageView.alpha), imageViewTint=\(String(describing: imageView.tintColor)), "
            + "imageViewImage=\(String(describing: imageView.image?.size)), imageViewImageMode=\(String(describing: imageView.image?.renderingMode.rawValue)), "
            + "stateImage=\(stateImage.size)/\(stateImage.renderingMode.rawValue), "
            + "currentImage=\(String(describing: button.currentImage?.size)), "
            + "titleRect=\(titleRect), titleLabel=\(String(describing: button.titleLabel?.frame)), "
            + "contentEdgeInsets=\(button.contentEdgeInsets), imageEdgeInsets=\(button.imageEdgeInsets), "
            + "titleEdgeInsets=\(button.titleEdgeInsets), configuration=\(String(describing: button.configuration))"
            + ", layers=[\(layerOrder)]"
        )
        geometry.name = "uikit_native_header_gift_pill_geometry"
        geometry.lifetime = .keepAlways
        add(geometry)
        let renderedButton = capture(button, named: "uikit_native_header_gift_pill_button")

        XCTAssertEqual(stateImage.size, CGSize(width: 16, height: 16))
        XCTAssertGreaterThanOrEqual(imageRect.width, 16)
        XCTAssertGreaterThanOrEqual(imageView.bounds.width, 16)
        XCTAssertGreaterThanOrEqual(imageView.bounds.height, 16)
        XCTAssertGreaterThan(titleRect.width, 0)
        XCTAssertLessThanOrEqual(imageView.frame.maxX, button.titleLabel?.frame.minX ?? 0)
        XCTAssertEqual(layers.first?.name, "ButtonBackgroundGradientLayer", "The gradient must stay behind UIKit's lazily inserted image layer")
        XCTAssertGreaterThan(try whitePixelCount(in: renderedButton, rect: imageRect), 20,
                             "The white gift artwork must remain visible, not merely reserve a 16-point frame")
    }

    func test_contentInsetModelAndGranularOutput_applyAllEdges() {
        let button = makeButton()
        button.display(model: .init(contentInset: .init(top: 3, leading: 5, bottom: 7, trailing: 11)))

        XCTAssertEqual(button.contentInset, UIEdgeInsets(top: 3, left: 5, bottom: 7, right: 11))

        button.display(contentInset: .init(horizontal: 13, vertical: 17))

        XCTAssertEqual(button.contentInset, UIEdgeInsets(top: 17, left: 13, bottom: 17, right: 13))
    }

    func test_modelWithoutContentInset_preservesEarlierValueAndExplicitZeroClearsIt() {
        let button = makeButton()
        button.display(model: .init(contentInset: .init(all: 9)))

        button.display(model: .init(title: "Updated"))

        XCTAssertEqual(button.contentInset, UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9))

        button.display(contentInset: .zero)

        XCTAssertEqual(button.contentInset, .zero)
    }

    func test_gradient_appliesColorsPointsBoundsAndCorners() throws {
        let button = makeButton()
        let gradient = ColorStyle.Gradient(
            colors: [.red, .blue], startPoint: .init(x: 0.1, y: 0.2), endPoint: .init(x: 0.8, y: 0.9)
        )
        button.display(style: .init(backgroundColor: .gradient(gradient), cornerStyle: .fixed(14)))
        button.layoutIfNeeded()

        let layer = try gradientLayer(in: button)
        XCTAssertEqual(layer.colors as? [CGColor], [UIColor.red.cgColor, UIColor.blue.cgColor])
        XCTAssertEqual(layer.startPoint, gradient.startPoint)
        XCTAssertEqual(layer.endPoint, gradient.endPoint)
        XCTAssertEqual(layer.frame, button.bounds)
        XCTAssertEqual(layer.cornerRadius, button.layer.cornerRadius, accuracy: 0.01)
        XCTAssertEqual(button.normalBackgroundStyle, .gradient(gradient))
        capture(button, named: "uikit_gradient_custom_points")
    }

    func test_gradient_resizesWithButtonBounds() throws {
        let button = makeButton()
        button.display(style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue]))))
        button.bounds.size = CGSize(width: 320, height: 80)
        button.setNeedsLayout()
        button.layoutIfNeeded()

        XCTAssertEqual(try gradientLayer(in: button).frame, button.bounds)
    }

    func test_replacingGradient_updatesColorsAndGeometryWithoutDuplicatingLayer() throws {
        let button = makeButton()
        button.display(style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue]))))
        let replacement = ColorStyle.Gradient(
            colors: [.yellow, .green], startPoint: .init(x: 0.5, y: 0), endPoint: .init(x: 0.5, y: 1)
        )

        button.display(style: .init(backgroundColor: .gradient(replacement)))

        let layer = try gradientLayer(in: button)
        XCTAssertEqual(layer.colors as? [CGColor], [UIColor.yellow.cgColor, UIColor.green.cgColor])
        XCTAssertEqual(layer.startPoint, replacement.startPoint)
        XCTAssertEqual(layer.endPoint, replacement.endPoint)
        XCTAssertEqual(gradientLayers(in: button).count, 1)
        capture(button, named: "uikit_gradient_replaced_vertical")
    }

    func test_solidOrClearBackground_removesPreviousGradient() {
        let button = makeButton()
        button.display(style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue]))))

        button.display(style: .init(backgroundColor: UIColor.green))

        XCTAssertTrue(gradientLayers(in: button).isEmpty)
        XCTAssertEqual(button.backgroundColor, .green)
        capture(button, named: "uikit_gradient_replaced_solid")
        XCTAssertEqual(button.normalBackgroundStyle, .solid(.green))

        button.display(style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue]))))
        button.display(style: .init(backgroundColor: ColorStyle.solid(nil)))

        XCTAssertTrue(gradientLayers(in: button).isEmpty)
        XCTAssertEqual(button.normalBackgroundStyle, .solid(nil))
    }

    func test_emptyGradient_removesEarlierFill() {
        let button = makeButton()
        button.display(style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue]))))

        button.display(style: .init(backgroundColor: .gradient(.init(colors: []))))

        XCTAssertTrue(gradientLayers(in: button).isEmpty)
        XCTAssertEqual(button.backgroundColor?.cgColor.alpha ?? 0, 0)
    }

    func test_pressedColor_temporarilyReplacesGradientAndTouchEndRestoresIt() throws {
        let button = makeButton()
        let gradient = ColorStyle.gradient(.init(colors: [.red, .blue]))
        button.display(style: .init(backgroundColor: gradient, pressedColor: .green))

        UIView.performWithoutAnimation { button.touchesBegan([UITouch()], with: nil) }

        XCTAssertTrue(gradientLayers(in: button).isEmpty)
        XCTAssertEqual(button.backgroundColor, .green)
        capture(button, named: "uikit_gradient_pressed_solid_override")

        UIView.performWithoutAnimation { button.touchesEnded([UITouch()], with: nil) }

        XCTAssertEqual(try gradientLayer(in: button).colors as? [CGColor], [UIColor.red.cgColor, UIColor.blue.cgColor])
        XCTAssertEqual(button.normalBackgroundStyle, gradient)
        capture(button, named: "uikit_gradient_restored_after_press")
    }

    func test_cancelledTouch_restoresGradientInsteadOfSolidFallback() throws {
        let button = makeButton()
        button.display(style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue])), pressedColor: .green))
        UIView.performWithoutAnimation { button.touchesBegan([UITouch()], with: nil) }

        UIView.performWithoutAnimation { button.touchesCancelled([UITouch()], with: nil) }

        XCTAssertEqual(try gradientLayer(in: button).colors as? [CGColor], [UIColor.red.cgColor, UIColor.blue.cgColor])
    }

    func test_explicitGlassOptOut_usesLegacyStyleAndRetainsContentInsets() {
        let button = makeButton()
        button.display(model: .init(
            title: "Legacy", contentInset: .init(all: 7), isGlassEffectEnabled: false,
            style: .init(backgroundColor: .red, glassConfiguration: .glass)
        ))

        XCTAssertNil(button.configuration)
        XCTAssertEqual(button.backgroundColor, .red)
        XCTAssertEqual(button.contentInset, UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7))
    }

    func test_modelGlassOptOutWithoutStyle_clearsManuallyAssignedNativeConfiguration() throws {
        guard #available(iOS 26, *) else { throw XCTSkip("Native glass requires iOS 26") }
        let button = makeButton()
        button.configuration = .glass()
        button.configurationUpdateHandler = { _ in }

        button.display(model: .init(title: "Plain", isGlassEffectEnabled: false))

        XCTAssertNil(button.configuration)
        XCTAssertNil(button.configurationUpdateHandler)
        XCTAssertEqual(button.title(for: .normal), "Plain")
    }

    func test_modelGlassOverride_reappliesExistingStyleWithoutRequiringAnotherStyle() throws {
        guard #available(iOS 26, *) else { throw XCTSkip("Native glass requires iOS 26") }
        let button = makeButton()
        button.display(model: .init(title: "Glass", style: .init(backgroundColor: .red, glassConfiguration: .glass)))
        XCTAssertNotNil(button.configuration)

        button.display(model: .init(isGlassEffectEnabled: false))

        XCTAssertNil(button.configuration)
        XCTAssertEqual(button.backgroundColor, .red)

        button.display(model: .init(isGlassEffectEnabled: true))

        XCTAssertNotNil(button.configuration)
    }

    func test_nativeHeaderCustomButton_honorsGlassOptOutAndContentInset() throws {
        let bar = UINavigationBar()
        bar.display(model: .init(primeTrailingImage: .init(
            title: "Action", image: UIImage(systemName: "star"), contentInset: .init(all: 6),
            isGlassEffectEnabled: false, height: 36, width: 110,
            style: .init(backgroundColor: .red, glassConfiguration: .glass), onPress: {}
        )))

        let host = try XCTUnwrap(bar.topItem?.rightBarButtonItem?.customView)
        let button = try XCTUnwrap(firstButton(in: host))

        XCTAssertNil(button.configuration)
        XCTAssertEqual(button.contentInset, UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        XCTAssertEqual(button.backgroundColor, .red)
    }

    func test_nativeHeader_nilContentInsetPreservesCustomButtonAndExplicitZeroClearsIt() throws {
        let bar = UINavigationBar()
        let image = UIImage(systemName: "star")
        bar.display(primeTrailingImage: .init(image: image, contentInset: .init(all: 6), onPress: {}))
        let initialHost = try XCTUnwrap(bar.topItem?.rightBarButtonItem?.customView)
        let initialButton = try XCTUnwrap(firstButton(in: initialHost))

        bar.display(primeTrailingImage: .init(image: image, onPress: {}))

        let retainedHost = try XCTUnwrap(bar.topItem?.rightBarButtonItem?.customView)
        let retainedButton = try XCTUnwrap(firstButton(in: retainedHost))
        XCTAssertTrue(retainedButton === initialButton)
        XCTAssertEqual(retainedButton.contentInset, UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))

        bar.display(primeTrailingImage: .init(image: image, contentInset: .zero, onPress: {}))

        let clearedHost = try XCTUnwrap(bar.topItem?.rightBarButtonItem?.customView)
        XCTAssertEqual(try XCTUnwrap(firstButton(in: clearedHost)).contentInset, .zero)
    }

    func test_nativeHeader_nilGlassFlagPreservesPreviousOverrideAndExplicitTrueReenablesIt() throws {
        guard #available(iOS 26, *) else { throw XCTSkip("Native toolbar glass requires iOS 26") }
        let bar = UINavigationBar()
        let image = UIImage(systemName: "star")
        bar.display(primeTrailingImage: .init(image: image, isGlassEffectEnabled: false, onPress: {}))
        XCTAssertTrue(try XCTUnwrap(bar.topItem?.rightBarButtonItem).hidesSharedBackground)

        bar.display(primeTrailingImage: .init(image: image, onPress: {}))

        XCTAssertTrue(try XCTUnwrap(bar.topItem?.rightBarButtonItem).hidesSharedBackground)

        bar.display(primeTrailingImage: .init(image: image, isGlassEffectEnabled: true, onPress: {}))
        XCTAssertFalse(try XCTUnwrap(bar.topItem?.rightBarButtonItem).hidesSharedBackground)

        bar.display(primeTrailingImage: .init(image: image, onPress: {}))

        XCTAssertFalse(try XCTUnwrap(bar.topItem?.rightBarButtonItem).hidesSharedBackground)
    }

    private func makeButton() -> WrapKit.Button {
        let button = WrapKit.Button()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        return button
    }

    private func makeGiftArtwork() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16), format: format).image { context in
            UIColor.white.setStroke()
            let path = UIBezierPath()
            path.lineWidth = 1.5
            path.append(UIBezierPath(rect: CGRect(x: 2, y: 6, width: 12, height: 3)))
            path.append(UIBezierPath(rect: CGRect(x: 3, y: 9, width: 10, height: 5)))
            path.move(to: CGPoint(x: 8, y: 5))
            path.addLine(to: CGPoint(x: 8, y: 14))
            path.move(to: CGPoint(x: 8, y: 6))
            path.addCurve(to: CGPoint(x: 4, y: 3), controlPoint1: CGPoint(x: 2, y: 6), controlPoint2: CGPoint(x: 2, y: 2))
            path.addCurve(to: CGPoint(x: 8, y: 6), controlPoint1: CGPoint(x: 6, y: 2), controlPoint2: CGPoint(x: 7, y: 4))
            path.addCurve(to: CGPoint(x: 12, y: 3), controlPoint1: CGPoint(x: 10, y: 0), controlPoint2: CGPoint(x: 15, y: 2))
            path.addCurve(to: CGPoint(x: 8, y: 6), controlPoint1: CGPoint(x: 12, y: 5), controlPoint2: CGPoint(x: 10, y: 6))
            path.stroke()
        }.withRenderingMode(.alwaysOriginal)
    }

    private func gradientLayers(in button: WrapKit.Button) -> [CAGradientLayer] {
        button.layer.sublayers?.compactMap { layer in
            guard layer.name == "ButtonBackgroundGradientLayer" else { return nil }
            return layer as? CAGradientLayer
        } ?? []
    }

    private func gradientLayer(in button: WrapKit.Button, file: StaticString = #filePath, line: UInt = #line) throws -> CAGradientLayer {
        try XCTUnwrap(gradientLayers(in: button).first, file: file, line: line)
    }

    private func firstButton(in view: UIView) -> WrapKit.Button? {
        if let button = view as? WrapKit.Button { return button }
        return view.subviews.lazy.compactMap { self.firstButton(in: $0) }.first
    }

    @discardableResult
    private func capture(_ button: WrapKit.Button, named name: String) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(bounds: button.bounds, format: format).image { context in
            button.layer.render(in: context.cgContext)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return image
    }

    private func whitePixelCount(in image: UIImage, rect: CGRect) throws -> Int {
        let cgImage = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: cgImage.width, height: cgImage.height,
                bitsPerComponent: 8, bytesPerRow: cgImage.width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        }
        return (max(0, Int(rect.minY))..<min(cgImage.height, Int(rect.maxY))).reduce(0) { count, y in
            count + (max(0, Int(rect.minX))..<min(cgImage.width, Int(rect.maxX))).filter { x in
                let offset = (y * cgImage.width + x) * 4
                return bytes[offset] > 220 && bytes[offset + 1] > 220 && bytes[offset + 2] > 220 && bytes[offset + 3] > 220
            }.count
        }
    }
}
#endif
