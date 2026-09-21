#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import WrapKitTestUtils
import UIKit
import XCTest

@MainActor
@available(iOS 17.0, *)
final class SUIImageViewParityTests: XCTestCase {
    func test_squareImageBorder_hasExactRectangularCorners() throws {
        let cornerRadii: [CGFloat?] = [nil, 0]
        for cornerRadius in cornerRadii {
            for appearance in SnapshotAppearance.allCases {
                let adapter = ImageViewOutputSwiftUIAdapter()
                adapter.display(model: .systemSymbol(
                    "star.fill",
                    size: squareBorderSize,
                    borderWidth: squareBorderWidth,
                    borderColor: .black,
                    cornerRadius: cornerRadius
                ))

                let image = renderSquareBorder(
                    SUIImageView(adapter: adapter),
                    appearance: appearance
                )

                try assertRectangularBorderCoverage(
                    image,
                    context: "ImageView, cornerRadius=\(String(describing: cornerRadius)), \(appearance)"
                )
            }
        }
    }

    func test_squareCardBackgroundBorder_hasExactRectangularCorners() throws {
        let cornerRadii: [CGFloat?] = [nil, 0]
        for cornerRadius in cornerRadii {
            for appearance in SnapshotAppearance.allCases {
                let adapter = CardViewOutputSwiftUIAdapter()
                adapter.display(backgroundImage: .systemSymbol(
                    "star.fill",
                    size: .init(width: 24, height: 24),
                    borderWidth: squareBorderWidth,
                    borderColor: .black,
                    cornerRadius: cornerRadius
                ))

                let image = renderSquareBorder(
                    SUICardView(adapter: adapter),
                    appearance: appearance
                )

                try assertRectangularBorderCoverage(
                    image,
                    context: "Card background, cornerRadius=\(String(describing: cornerRadius)), \(appearance)"
                )
            }
        }
    }

    func test_squareBorder_translucentColorBlendsCornersOnce() throws {
        for cardBackground in [false, true] {
            for appearance in SnapshotAppearance.allCases {
                let image = renderSquareBorder(
                    width: squareBorderWidth,
                    color: UIColor.black.withAlphaComponent(0.5),
                    cardBackground: cardBackground,
                    appearance: appearance
                )

                try assertRectangularBorderCoverage(
                    image,
                    opacity: 0.5,
                    includeInterior: true,
                    context: "Translucent border, cardBackground=\(cardBackground), \(appearance)"
                )
            }
        }
    }

    func test_squareBorder_zeroFractionalHalfAndOversizedWidthsKeepRectangularCoverage() throws {
        let widths: [CGFloat] = [0, 0.5, squareBorderSize.height / 2, squareBorderSize.width]
        for borderWidth in widths {
            for cardBackground in [false, true] {
                for appearance in SnapshotAppearance.allCases {
                    let image = renderSquareBorder(
                        width: borderWidth,
                        color: .black,
                        cardBackground: cardBackground,
                        appearance: appearance
                    )

                    try assertRectangularBorderCoverage(
                        image,
                        borderWidth: borderWidth,
                        includeInterior: true,
                        context: "Width=\(borderWidth), cardBackground=\(cardBackground), \(appearance)"
                    )
                }
            }
        }
    }

    func test_fullModelThenNil_hidesClearsContentAndRetainsLayoutLikeUIKit() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let output: ImageViewOutput = adapter
        var events: [String] = []
        let size = CGSize(width: 32, height: 24)
        let borderColor = UIColor.systemRed.resolvedColor(with: UITraitCollection.current)
        output.display(model: .init(
            accessibilityIdentifier: "status.image",
            accessibility: .init(label: "Status", hint: "Opens details"),
            size: size,
            image: .symbolName("checkmark.circle.fill"),
            onPress: { events.append("press") },
            onLongPress: { events.append("longPress") },
            contentModeIsFit: false,
            borderWidth: 2,
            borderColor: borderColor,
            cornerRadius: 6,
            alpha: 0.4
        ))
        let stateModel = SUIImageViewStateModel(adapter: adapter)

        XCTAssertFalse(stateModel.isHidden)
        XCTAssertEqual(stateModel.model.accessibilityIdentifier, "status.image")
        XCTAssertEqual(stateModel.model.accessibility?.label, "Status")
        XCTAssertEqual(stateModel.model.accessibility?.hint, "Opens details")
        XCTAssertEqual(stateModel.model.size, size)
        XCTAssertEqual(stateModel.model.image, .symbolName("checkmark.circle.fill"))
        XCTAssertEqual(stateModel.model.contentModeIsFit, false)
        XCTAssertEqual(stateModel.model.borderWidth, 2)
        XCTAssertTrue(stateModel.model.borderColor?.isEqual(borderColor) == true)
        XCTAssertEqual(stateModel.model.cornerRadius, 6)
        XCTAssertEqual(stateModel.model.alpha, 0.4)
        stateModel.model.onPress?()
        stateModel.model.onLongPress?()

        output.display(model: nil)

        XCTAssertTrue(stateModel.isHidden)
        XCTAssertNil(stateModel.model.accessibilityIdentifier)
        XCTAssertNil(stateModel.model.accessibility)
        XCTAssertNil(stateModel.model.image)
        XCTAssertNil(stateModel.model.onPress)
        XCTAssertNil(stateModel.model.onLongPress)
        XCTAssertEqual(stateModel.model.size, size)
        XCTAssertEqual(stateModel.model.contentModeIsFit, false)
        XCTAssertEqual(stateModel.model.borderWidth, 2)
        XCTAssertTrue(stateModel.model.borderColor?.isEqual(borderColor) == true)
        XCTAssertEqual(stateModel.model.cornerRadius, 6)
        XCTAssertEqual(stateModel.model.alpha, 0.4)
        XCTAssertEqual(events, ["press", "longPress"])
    }

    func test_onPressOutputReplaysReplacementAndClearsAction() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let stateModel = SUIImageViewStateModel(adapter: adapter)
        var events: [String] = []

        adapter.display(onPress: { events.append("initial") })
        stateModel.model.onPress?()

        adapter.display(onPress: { events.append("replacement") })
        stateModel.model.onPress?()

        adapter.display(onPress: nil)

        XCTAssertNil(stateModel.model.onPress)
        XCTAssertEqual(events, ["initial", "replacement"])
    }

    func test_mountedViewUsesClosureOnlyModelReplacement() throws {
        let adapter = ImageViewOutputSwiftUIAdapter()
        var events: [String] = []
        adapter.display(model: .systemSymbol(
            "star.fill",
            accessibility: .init(label: "Image action"),
            size: .init(width: 24, height: 24),
            onPress: { events.append("initial") }
        ))
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter),
            size: CGSize(width: 100, height: 100)
        )
        host.settle()
        let initialElement = try XCTUnwrap(host.element(withLabel: "Image action"))
        XCTAssertTrue(initialElement.accessibilityActivate())

        adapter.display(model: .systemSymbol(
            "star.fill",
            accessibility: .init(label: "Image action"),
            size: .init(width: 24, height: 24),
            onPress: { events.append("replacement") }
        ))
        host.settle()
        let replacementElement = try XCTUnwrap(host.element(withLabel: "Image action"))
        XCTAssertTrue(replacementElement.accessibilityActivate())

        XCTAssertEqual(events, ["initial", "replacement"])
    }

    func test_publicModelViewAppliesClosureOnlyReplacementWithoutReloadingImage() throws {
        final class ActionOwner {}

        let server = try HangingHTTPServer()
        defer { server.stop() }
        let imageURL = server.url(path: "/closure-replacement.png")
        let initialRequest = expectation(description: "Initial image requested")
        server.observeStart { url in
            guard url == imageURL else { return }
            initialRequest.fulfill()
        }

        var events: [String] = []
        weak var oldOwner: ActionOwner?
        let input: ImageModelInput
        do {
            let owner = ActionOwner()
            oldOwner = owner
            input = ImageModelInput(.init(
                accessibility: .init(label: "Raw image action"),
                size: .init(width: 24, height: 24),
                image: .url(imageURL, imageURL),
                onPress: {
                    _ = owner
                    events.append("initial")
                }
            ))
        }

        let host = SwiftUIAccessibilityTestHost(
            rootView: ImageModelInputView(input: input),
            size: CGSize(width: 100, height: 100)
        )
        wait(for: [initialRequest], timeout: 1)
        host.settle()
        var initialElement: NSObject? = try XCTUnwrap(
            host.element(withLabel: "Raw image action")
        )
        XCTAssertTrue(try XCTUnwrap(initialElement).accessibilityActivate())
        initialElement = nil

        let stateModel = SUIImageViewStateModel(model: input.model)
        let reloadToken = stateModel.reloadToken
        stateModel.apply(model: .init(
            accessibility: .init(label: "Raw image action"),
            size: .init(width: 24, height: 24),
            image: .url(imageURL, imageURL),
            onPress: { events.append("state replacement") }
        ))
        XCTAssertEqual(stateModel.reloadToken, reloadToken)

        let reloadRequest = expectation(description: "Image is not reloaded")
        reloadRequest.isInverted = true
        server.observeStart { url in
            guard url == imageURL else { return }
            reloadRequest.fulfill()
        }
        input.model = .init(
            accessibility: .init(label: "Raw image action"),
            size: .init(width: 24, height: 24),
            image: .url(imageURL, imageURL),
            onPress: { events.append("replacement") }
        )
        host.settle()
        wait(for: [reloadRequest], timeout: 0.3)

        XCTAssertNil(oldOwner)
        XCTAssertEqual(server.startedURLs, [imageURL])
        let replacementElement = try XCTUnwrap(host.element(withLabel: "Raw image action"))
        XCTAssertTrue(replacementElement.accessibilityActivate())
        XCTAssertEqual(events, ["initial", "replacement"])
    }

    func test_premountGranularThenFullModelUsesFinalFullModelValues() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        var events: [String] = []
        var staleCompletionCalled = false

        adapter.display(size: CGSize(width: 12, height: 14))
        adapter.display(image: .symbolName("xmark")) { _ in
            staleCompletionCalled = true
        }
        adapter.display(onPress: { events.append("stale press") })
        adapter.display(onLongPress: { events.append("stale long press") })
        adapter.display(contentModeIsFit: false)
        adapter.display(borderWidth: 1)
        adapter.display(borderColor: .systemRed)
        adapter.display(cornerRadius: 2)
        adapter.display(alpha: 0.2)
        adapter.display(isHidden: true)
        adapter.display(model: .init(
            accessibilityIdentifier: "final.image",
            accessibility: .init(label: "Final image"),
            size: CGSize(width: 32, height: 36),
            image: .symbolName("checkmark"),
            onPress: { events.append("final press") },
            onLongPress: { events.append("final long press") },
            contentModeIsFit: true,
            borderWidth: 3,
            borderColor: .systemBlue,
            cornerRadius: 8,
            alpha: 0.8
        ))

        let sut = SUIImageViewStateModel(adapter: adapter)
        sut.model.onPress?()
        sut.model.onLongPress?()

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.model.accessibilityIdentifier, "final.image")
        XCTAssertEqual(sut.model.accessibility?.label, "Final image")
        XCTAssertEqual(sut.model.size, CGSize(width: 32, height: 36))
        XCTAssertEqual(sut.model.image, .symbolName("checkmark"))
        XCTAssertEqual(sut.model.contentModeIsFit, true)
        XCTAssertEqual(sut.model.borderWidth, 3)
        XCTAssertTrue(sut.model.borderColor?.isEqual(
            UIColor.systemBlue.resolvedColor(with: UITraitCollection.current)
        ) == true)
        XCTAssertEqual(sut.model.cornerRadius, 8)
        XCTAssertEqual(sut.model.alpha, 0.8)
        XCTAssertNil(sut.pendingCompletion)
        XCTAssertFalse(staleCompletionCalled)
        XCTAssertEqual(events, ["final press", "final long press"])
    }

    func test_premountFullModelThenGranularUsesFinalGranularValuesAndNilSemantics() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        var staleCompletionCalled = false
        adapter.display(model: .init(
            accessibilityIdentifier: "retained.image",
            accessibility: .init(label: "Retained image"),
            size: CGSize(width: 28, height: 30),
            image: .symbolName("checkmark"),
            onPress: {},
            onLongPress: {},
            contentModeIsFit: true,
            borderWidth: 4,
            borderColor: .systemBlue,
            cornerRadius: 7,
            alpha: 0.7
        )) { _ in
            staleCompletionCalled = true
        }
        adapter.display(size: nil)
        adapter.display(image: nil)
        adapter.display(onPress: nil)
        adapter.display(onLongPress: nil)
        adapter.display(contentModeIsFit: false)
        adapter.display(borderWidth: nil)
        adapter.display(borderColor: nil)
        adapter.display(cornerRadius: nil)
        adapter.display(alpha: nil)
        adapter.display(isHidden: true)

        let sut = SUIImageViewStateModel(adapter: adapter)

        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.model.accessibilityIdentifier, "retained.image")
        XCTAssertEqual(sut.model.accessibility?.label, "Retained image")
        XCTAssertEqual(sut.model.size, CGSize(width: 28, height: 30))
        XCTAssertNil(sut.model.image)
        XCTAssertNil(sut.model.onPress)
        XCTAssertNil(sut.model.onLongPress)
        XCTAssertEqual(sut.model.contentModeIsFit, false)
        XCTAssertEqual(sut.model.borderWidth, 4)
        XCTAssertNil(sut.model.borderColor)
        XCTAssertEqual(sut.model.cornerRadius, 7)
        XCTAssertEqual(sut.model.alpha, 0.7)
        XCTAssertNil(sut.pendingCompletion)
        XCTAssertFalse(staleCompletionCalled)
    }

    func test_premountFullModelWithNilOptionalsPreservesGranularGeometryAndStyle() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        adapter.display(model: .init(
            accessibilityIdentifier: "stale.image",
            accessibility: .init(label: "Stale accessibility"),
            image: .symbolName("xmark")
        ))
        adapter.display(size: CGSize(width: 24, height: 26))
        adapter.display(contentModeIsFit: false)
        adapter.display(borderWidth: 2)
        adapter.display(borderColor: .systemRed)
        adapter.display(cornerRadius: 5)
        adapter.display(alpha: 0.5)
        adapter.display(model: .init(
            accessibilityIdentifier: "updated.image",
            image: .url(nil, nil)
        ))

        let sut = SUIImageViewStateModel(adapter: adapter)

        XCTAssertEqual(sut.model.accessibilityIdentifier, "updated.image")
        XCTAssertNil(sut.model.accessibility)
        XCTAssertEqual(sut.model.image, .url(nil, nil))
        XCTAssertEqual(sut.model.size, CGSize(width: 24, height: 26))
        XCTAssertEqual(sut.model.contentModeIsFit, false)
        XCTAssertEqual(sut.model.borderWidth, 2)
        XCTAssertTrue(sut.model.borderColor?.isEqual(
            UIColor.systemRed.resolvedColor(with: UITraitCollection.current)
        ) == true)
        XCTAssertEqual(sut.model.cornerRadius, 5)
        XCTAssertEqual(sut.model.alpha, 0.5)
    }

    func test_premountLatestCompletionOverloadWinsAcrossModelAndImageOutputs() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        var events: [String] = []
        adapter.display(image: .symbolName("xmark"))
        adapter.display(model: .init(image: .symbolName("checkmark"))) { _ in
            events.append("latest completion")
        }

        let sut = SUIImageViewStateModel(adapter: adapter)
        sut.pendingCompletion?(nil)

        XCTAssertEqual(sut.model.image, .symbolName("checkmark"))
        XCTAssertEqual(events, ["latest completion"])
    }

    func test_premountCompletionAndNonCompletionOverloadsShareSemanticOrder() {
        let modelAdapter = ImageViewOutputSwiftUIAdapter()
        var staleModelCompletionCalled = false
        modelAdapter.display(model: .init(image: .symbolName("xmark"))) { _ in
            staleModelCompletionCalled = true
        }
        modelAdapter.display(model: .init(image: .symbolName("checkmark")))

        let imageAdapter = ImageViewOutputSwiftUIAdapter()
        var staleImageCompletionCalled = false
        imageAdapter.display(image: .symbolName("xmark")) { _ in
            staleImageCompletionCalled = true
        }
        imageAdapter.display(image: .symbolName("checkmark"))

        let modelSUT = SUIImageViewStateModel(adapter: modelAdapter)
        let imageSUT = SUIImageViewStateModel(adapter: imageAdapter)

        XCTAssertEqual(modelSUT.model.image, .symbolName("checkmark"))
        XCTAssertNil(modelSUT.pendingCompletion)
        XCTAssertFalse(staleModelCompletionCalled)
        XCTAssertEqual(imageSUT.model.image, .symbolName("checkmark"))
        XCTAssertNil(imageSUT.pendingCompletion)
        XCTAssertFalse(staleImageCompletionCalled)
    }

    func test_consumedCompletionIsNotReplayedAfterRemount() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        var completionCount = 0
        adapter.display(image: .symbolName("checkmark")) { _ in
            completionCount += 1
        }

        var firstMount: SUIImageViewStateModel? = .init(adapter: adapter)
        let completion = firstMount?.takePendingCompletion()
        XCTAssertNil(firstMount?.pendingCompletion)
        firstMount = nil

        let secondMount = SUIImageViewStateModel(adapter: adapter)
        XCTAssertNil(secondMount.pendingCompletion)

        completion?(nil)
        XCTAssertEqual(completionCount, 1)
    }

    func test_symbolNameIsTheSingleImageSourceAcrossModelUpdates() {
        let model = ImageViewPresentableModel(
            size: .init(width: 24, height: 24),
            image: .symbolName("checkmark.circle.fill"),
            contentModeIsFit: true
        )

        let updated = model.replacingBorderColor(.systemBlue)

        XCTAssertEqual(updated.image, .symbolName("checkmark.circle.fill"))
        XCTAssertNotNil(ImageFactory.systemImage(named: "checkmark.circle.fill"))
    }

    func test_distinctRemoteURLsFollowColorSchemeChanges() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let lightURL = server.url(path: "/image-light.png")
        let darkURL = server.url(path: "/image-dark.png")
        let lightRequest = expectation(description: "Light URL requested")
        let darkRequest = expectation(description: "Dark URL requested")
        server.observeStart { url in
            if url == lightURL {
                lightRequest.fulfill()
            } else if url == darkURL {
                darkRequest.fulfill()
            }
        }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let appearance = ImageAppearanceFixture(.light)
        let host = SwiftUIAccessibilityTestHost(
            rootView: ImageAppearanceHarness(adapter: adapter, appearance: appearance),
            size: CGSize(width: 160, height: 100)
        )

        adapter.display(image: .url(lightURL, darkURL))
        wait(for: [lightRequest], timeout: 1)

        appearance.colorScheme = .dark
        host.settle()
        wait(for: [darkRequest], timeout: 1)
    }

    func test_lightOnlyURLDoesNotFallbackInDarkAppearance() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let request = expectation(description: "No URL requested")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter)
                .environment(\.colorScheme, .dark),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Missing dark URL completed")
        adapter.display(image: .url(server.url(path: "/light-only.png"), nil)) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion, request], timeout: 0.3)
    }

    func test_lightOnlyURLStringDoesNotFallbackInDarkAppearance() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let request = expectation(description: "No URL requested")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter)
                .environment(\.colorScheme, .dark),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Missing dark URL string completed")
        adapter.display(
            image: .urlString(server.url(path: "/light-only-string.png").absoluteString, nil)
        ) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion, request], timeout: 0.3)
    }

    func test_darkOnlyURLDoesNotFallbackInLightAppearance() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let request = expectation(description: "No URL requested")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter)
                .environment(\.colorScheme, .light),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Missing light URL completed")
        adapter.display(image: .url(nil, server.url(path: "/dark-only.png"))) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion, request], timeout: 0.3)
    }

    func test_validDataDecodesAndCompletesWithImage() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter),
            size: CGSize(width: 160, height: 100)
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let data = UIGraphicsImageRenderer(
            size: CGSize(width: 3, height: 2),
            format: format
        ).pngData { context in
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 3, height: 2))
        }
        let completion = expectation(description: "Valid data decoded")

        adapter.display(image: .data(data)) { image in
            XCTAssertEqual(image?.size, CGSize(width: 3, height: 2))
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion], timeout: 1)
    }

    func test_invalidDataClearsImageWithoutFallback() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(
                adapter: adapter,
                fallbackView: AnyView(SwiftUI.Color.red)
            ),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Invalid data completed")

        adapter.display(image: .data(Data("not an image".utf8))) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion], timeout: 1)
    }

    private var squareBorderSize: CGSize { .init(width: 390, height: 200) }
    private var squareBorderWidth: CGFloat { 4 }

    private func renderSquareBorder(
        width: CGFloat,
        color: UIColor,
        cardBackground: Bool,
        appearance: SnapshotAppearance
    ) -> UIImage {
        let model = ImageViewPresentableModel(
            size: squareBorderSize,
            borderWidth: width,
            borderColor: color
        )
        if cardBackground {
            let adapter = CardViewOutputSwiftUIAdapter()
            adapter.display(backgroundImage: model)
            return renderSquareBorder(SUICardView(adapter: adapter), appearance: appearance)
        }
        let adapter = ImageViewOutputSwiftUIAdapter()
        adapter.display(model: model)
        return renderSquareBorder(SUIImageView(adapter: adapter), appearance: appearance)
    }

    private func renderSquareBorder(
        _ view: some View,
        appearance: SnapshotAppearance
    ) -> UIImage {
        let rootView = view
            .frame(width: squareBorderSize.width, height: squareBorderSize.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
            .ignoresSafeArea(.all)
        let controller = UIHostingController(rootView: rootView)
        controller.view.backgroundColor = .clear
        controller.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
        return controller.snapshot(for: appearance.uiKitConfiguration)
    }

    private func assertRectangularBorderCoverage(
        _ image: UIImage,
        borderWidth: CGFloat = 4,
        opacity: CGFloat = 1,
        includeInterior: Bool = false,
        context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let cgImage = try XCTUnwrap(image.cgImage, file: file, line: line)
        let scale = SnapshotRenderDefaults.scale
        let width = Int(squareBorderSize.width * scale)
        let height = Int(squareBorderSize.height * scale)
        let border = borderWidth * scale
        XCTAssertEqual(image.scale, scale, context, file: file, line: line)
        XCTAssertEqual(cgImage.width, width, context, file: file, line: line)
        guard cgImage.width == width, cgImage.height >= height else {
            XCTFail("Unexpected snapshot dimensions: \(context)", file: file, line: line)
            return
        }

        var pixels = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        try pixels.withUnsafeMutableBytes { bytes in
            let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB), file: file, line: line)
            let bitmap = try XCTUnwrap(CGContext(
                data: bytes.baseAddress,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: 8,
                bytesPerRow: cgImage.width * 4,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ), file: file, line: line)
            bitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        }

        // The four corners include the first clear pixel inside the bottom-right corner.
        // Image-free fixtures also check the complete interior and the row below the view.
        let probeSize = Int(ceil(border)) + 2
        let regions: [(x: Range<Int>, y: Range<Int>)] = includeInterior
            ? [(0..<width, 0..<min(height + 2, cgImage.height))]
            : [
                (0..<probeSize, 0..<probeSize),
                ((width - probeSize)..<width, 0..<probeSize),
                (0..<probeSize, (height - probeSize)..<height),
                ((width - probeSize)..<width, (height - probeSize)..<height)
            ]
        let innerWidth = max(0, CGFloat(width) - 2 * border)
        let innerHeight = max(0, CGFloat(height) - 2 * border)
        var mismatchCount = 0
        var mismatches: [String] = []
        for region in regions {
            for y in region.y {
                for x in region.x {
                    // Independent geometric oracle: coverage is the unit pixel's area
                    // outside the inset rectangle, not a second rendering of the shape.
                    let innerX = max(0, min(CGFloat(x + 1), border + innerWidth) - max(CGFloat(x), border))
                    let innerY = max(0, min(CGFloat(y + 1), border + innerHeight) - max(CGFloat(y), border))
                    let coverage: CGFloat = y < height ? 1 - innerX * innerY : 0
                    let alpha = coverage * opacity * 255
                    let expectedAlpha = Int(alpha.rounded())
                    let tolerance = alpha == alpha.rounded() ? 0 : 1
                    let index = (y * cgImage.width + x) * 4
                    if pixels[index] != 0 || pixels[index + 1] != 0 || pixels[index + 2] != 0
                        || abs(Int(pixels[index + 3]) - expectedAlpha) > tolerance {
                        mismatchCount += 1
                        if mismatches.count < 8 {
                            let actual = Array(pixels[index..<(index + 4)])
                            mismatches.append("(\(x),\(y)): \(actual), expected [0, 0, 0, \(expectedAlpha)]")
                        }
                    }
                }
            }
        }

        guard mismatchCount > 0 else { return }
        let attachment = XCTAttachment(image: image)
        attachment.name = "Non-rectangular border: \(context)"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTFail(
            "\(context): \(mismatchCount) incorrect border pixels. " + mismatches.joined(separator: "; "),
            file: file,
            line: line
        )
    }
}

@MainActor
private final class ImageAppearanceFixture: ObservableObject {
    @Published var colorScheme: ColorScheme

    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
}

private struct ImageAppearanceHarness: View {
    let adapter: ImageViewOutputSwiftUIAdapter
    @ObservedObject var appearance: ImageAppearanceFixture

    var body: some View {
        SUIImageView(adapter: adapter)
            .environment(\.colorScheme, appearance.colorScheme)
    }
}

@MainActor
private final class ImageModelInput: ObservableObject {
    @Published var model: ImageViewPresentableModel

    init(_ model: ImageViewPresentableModel) {
        self.model = model
    }
}

private struct ImageModelInputView: View {
    @ObservedObject var input: ImageModelInput

    var body: some View {
        SUIImageViewView(model: input.model)
    }
}
#endif
