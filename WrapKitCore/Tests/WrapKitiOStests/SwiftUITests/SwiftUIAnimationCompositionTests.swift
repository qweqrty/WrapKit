#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import Combine
import SwiftUI
import UIKit
import XCTest

@available(iOS 17.0, *)
final class SwiftUIAnimationCompositionTests: XCTestCase {
    func test_publicButton_loadingRendersMovingSpinner() {
        let buttonAdapter = ButtonOutputSwiftUIAdapter()
        let loadingAdapter = LoadingOutputSwiftUIAdapter()
        buttonAdapter.display(model: .init(
            title: "Loading",
            height: 60,
            width: 160,
            style: .init(
                backgroundColor: .black,
                titleColor: .white,
                cornerStyle: .fixed(8),
                loadingIndicatorColor: .magenta
            ),
            enabled: true,
            onPress: {}
        ))
        loadingAdapter.display(isLoading: true)

        let host = LiveSwiftUIAnimationHost(
            rootView: ButtonAnimationFixture(
                buttonAdapter: buttonAdapter,
                loadingAdapter: loadingAdapter
            ),
            size: CGSize(width: 200, height: 100)
        )
        let frames = host.sampleFrames(count: 24, interval: 0.05)
        XCTAssertTrue(frames.allSatisfy(\.didDrawHierarchy))

        let masks = frames.map { FixturePixelMask(image: $0.image, color: .magenta) }
        let visibleMasks = masks.filter { !$0.indices.isEmpty }
        XCTAssertGreaterThanOrEqual(
            visibleMasks.count,
            8,
            "The public SUIButton loading state must compose the magenta spinner."
        )
        XCTAssertGreaterThan(
            maximumSymmetricDifference(in: visibleMasks),
            8,
            "The spinner pixels must move between live rendered frames."
        )
        XCTAssertGreaterThan(
            horizontalCentroidRange(in: visibleMasks),
            1,
            "The spinner arc must move spatially, not merely repaint a static fixture."
        )
    }

    func test_publicButton_loadingRestartsSpinnerAfterReduceMotionTurnsOff() {
        let buttonAdapter = ButtonOutputSwiftUIAdapter()
        let loadingAdapter = LoadingOutputSwiftUIAdapter()
        let reduceMotion = ReduceMotionControl()
        buttonAdapter.display(model: .init(
            title: "Loading",
            height: 60,
            width: 160,
            style: .init(
                backgroundColor: .black,
                titleColor: .white,
                cornerStyle: .fixed(8),
                loadingIndicatorColor: .magenta
            ),
            enabled: true,
            onPress: {}
        ))
        loadingAdapter.display(isLoading: true)

        let host = LiveSwiftUIAnimationHost(
            rootView: DynamicReduceMotionButtonFixture(
                buttonAdapter: buttonAdapter,
                loadingAdapter: loadingAdapter,
                reduceMotion: reduceMotion
            ),
            size: CGSize(width: 200, height: 100)
        )
        let reducedMotionFrames = host.sampleFrames(count: 4, interval: 0.04)
        let reducedMotionMasks = reducedMotionFrames.map {
            FixturePixelMask(image: $0.image, color: .magenta)
        }
        XCTAssertTrue(reducedMotionFrames.allSatisfy(\.didDrawHierarchy))
        XCTAssertTrue(reducedMotionMasks.allSatisfy { !$0.indices.isEmpty })
        XCTAssertEqual(maximumSymmetricDifference(in: reducedMotionMasks), 0)

        reduceMotion.isEnabled = false

        let animatedFrames = host.sampleFrames(count: 24, interval: 0.05)
        let animatedMasks = animatedFrames.map {
            FixturePixelMask(image: $0.image, color: .magenta)
        }
        let visibleAnimatedMasks = animatedMasks.filter { !$0.indices.isEmpty }
        XCTAssertTrue(animatedFrames.allSatisfy(\.didDrawHierarchy))
        XCTAssertGreaterThanOrEqual(visibleAnimatedMasks.count, 8)
        XCTAssertGreaterThan(maximumSymmetricDifference(in: visibleAnimatedMasks), 8)
        XCTAssertGreaterThan(horizontalCentroidRange(in: visibleAnimatedMasks), 1)
    }

    func test_publicSwitch_loadingRendersMovingShimmer() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("iOS 18 drawHierarchy does not expose SwiftUI's presentation-layer shimmer frames.")
        }

        let adapter = SwitchCotrolOutputSwiftUIAdapter()
        let shimmerStyle = ShimmerStyle(
            backgroundColor: .black,
            gradientColorOne: .black,
            gradientColorTwo: .yellow,
            cornerRadius: 16
        )
        adapter.display(model: .init(
            accessibilityIdentifier: "animated-switch",
            isOn: true,
            isEnabled: true,
            style: .init(
                tintColor: .black,
                thumbTintColor: .black,
                backgroundColor: .black,
                cornerRadius: 16,
                shimmerStyle: shimmerStyle
            )
        ))
        adapter.display(isLoading: true)

        let host = LiveSwiftUIAnimationHost(
            rootView: SwitchAnimationFixture(adapter: adapter),
            size: CGSize(width: 120, height: 80)
        )
        let frames = host.sampleFrames(count: 48, interval: 0.035)
        XCTAssertTrue(frames.allSatisfy(\.didDrawHierarchy))

        let masks = frames.map { FixturePixelMask(image: $0.image, color: .yellow) }
        let visibleMasks = masks.filter { !$0.indices.isEmpty }
        XCTAssertGreaterThanOrEqual(
            visibleMasks.count,
            2,
            "The public SUISwitchControl loading state must compose its yellow shimmer."
        )
        XCTAssertGreaterThan(
            maximumSymmetricDifference(in: visibleMasks),
            8,
            "The shimmer pixels must change between live rendered frames."
        )
        XCTAssertGreaterThan(
            horizontalCentroidRange(in: visibleMasks),
            4,
            "The shimmer highlight must travel horizontally through the switch."
        )
    }

    func test_publicShimmerView_rendersMovingHighlight() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("iOS 18 drawHierarchy does not expose SwiftUI's presentation-layer shimmer frames.")
        }

        let host = LiveSwiftUIAnimationHost(
            rootView: ShimmerAnimationFixture(highlightColor: .yellow),
            size: CGSize(width: 160, height: 60)
        )
        let frames = host.sampleFrames(count: 62, interval: 0.035)
        XCTAssertTrue(frames.allSatisfy(\.didDrawHierarchy))

        let masks = frames.map { FixturePixelMask(image: $0.image, color: .yellow) }
        let visibleMasks = masks.filter { !$0.indices.isEmpty }
        XCTAssertGreaterThanOrEqual(
            visibleMasks.count,
            2,
            "The public SUIShimmerView must render its configured highlight."
        )
        XCTAssertGreaterThan(
            maximumSymmetricDifference(in: visibleMasks),
            8,
            "The public shimmer pixels must change between live rendered frames."
        )
        XCTAssertGreaterThan(
            horizontalCentroidRange(in: visibleMasks),
            4,
            "The public shimmer highlight must move horizontally."
        )
        XCTAssertTrue(
            masks.suffix(8).allSatisfy { $0.indices.isEmpty },
            "The shimmer must stay offscreen during UIKit's pause between sweeps."
        )
    }

    func test_publicShimmerView_rendersConfiguredHighlightColor() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("iOS 18 drawHierarchy does not expose SwiftUI's presentation-layer shimmer frames.")
        }

        let host = LiveSwiftUIAnimationHost(
            rootView: ShimmerAnimationFixture(highlightColor: .cyan),
            size: CGSize(width: 160, height: 60)
        )
        let frames = host.sampleFrames(count: 48, interval: 0.035)

        let cyanMasks = frames.map { FixturePixelMask(image: $0.image, color: .cyan) }
        XCTAssertGreaterThanOrEqual(
            cyanMasks.filter { !$0.indices.isEmpty }.count,
            2,
            "The public shimmer must render the highlight color from ShimmerStyle."
        )
    }

    func test_publicLabel_restartsRenderedProgressForReplacementAnimation() throws {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(
            id: "first",
            from: 0,
            to: 1,
            mapToString: animationProgressColor,
            animationStyle: .none,
            duration: 1,
            completion: nil
        )
        let host = LiveSwiftUIAnimationHost(
            rootView: LabelAnimationFixture(adapter: adapter),
            size: CGSize(width: 120, height: 60)
        )

        _ = host.sampleFrames(count: 2, interval: 0.4)
        adapter.display(
            id: "second",
            from: 0,
            to: 1,
            mapToString: animationProgressColor,
            animationStyle: .none,
            duration: 1,
            completion: nil
        )

        let restartedFrame = try XCTUnwrap(
            host.sampleFrames(count: 2, interval: 0.03).last
        )
        let earlyProgress = FixturePixelMask(image: restartedFrame.image, color: .magenta)
        let staleProgress = FixturePixelMask(image: restartedFrame.image, color: .cyan)

        XCTAssertTrue(restartedFrame.didDrawHierarchy)
        XCTAssertGreaterThan(
            earlyProgress.indices.count,
            100,
            "A replacement label animation must render again from its start value."
        )
        XCTAssertTrue(
            staleProgress.indices.isEmpty,
            "The replacement animation must not inherit the previous animation's progress."
        )
    }

    @MainActor
    func test_publicLabel_remountContinuesRenderedProgressFromOriginalTimeline() throws {
        let adapter = TextOutputSwiftUIAdapter()
        let remount = LabelRemountControl()
        adapter.display(
            id: "remount",
            from: 0,
            to: 1,
            mapToString: animationProgressColor,
            animationStyle: .none,
            duration: 1,
            completion: nil
        )
        let host = LiveSwiftUIAnimationHost(
            rootView: RemountingLabelAnimationFixture(
                adapter: adapter,
                remount: remount
            ),
            size: CGSize(width: 120, height: 60)
        )

        let progressedFrame = try XCTUnwrap(
            host.sampleFrames(count: 2, interval: 0.3).last
        )
        XCTAssertGreaterThan(
            FixturePixelMask(image: progressedFrame.image, color: .cyan).indices.count,
            100
        )

        remount.revision += 1

        let remountedFrame = try XCTUnwrap(
            host.sampleFrames(count: 3, interval: 0.04).last
        )
        let resumedProgress = FixturePixelMask(image: remountedFrame.image, color: .cyan)
        let restartedProgress = FixturePixelMask(image: remountedFrame.image, color: .magenta)
        XCTAssertTrue(remountedFrame.didDrawHierarchy)
        XCTAssertGreaterThan(
            resumedProgress.indices.count,
            100,
            "A remounted label must continue from the original animation timeline."
        )
        XCTAssertTrue(
            restartedProgress.indices.isEmpty,
            "A remounted label must not render the animation's start value again."
        )
    }

    func test_publicEmptyView_animatedTitleCompletionSurvivesPlainReplacement() {
        let completion = expectation(description: "Nested title animation completes")
        let adapter = EmptyViewOutputSwiftUIAdapter()
        adapter.display(title: animatedNestedLabel(
            identifier: "empty.title",
            completion: { completion.fulfill() }
        ))
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIEmptyView(adapter: adapter)
                .frame(width: 240, height: 120),
            size: CGSize(width: 240, height: 120)
        )

        adapter.display(title: replacementNestedLabel(identifier: "empty.title"))

        wait(for: [completion], timeout: 0.5)
        assertNestedLabelFinished(in: host, identifier: "empty.title")
    }

    func test_publicKeyValueField_animatedKeyCompletionSurvivesPlainReplacement() {
        let completion = expectation(description: "Nested key animation completes")
        let adapter = KeyValueFieldViewOutputSwiftUIAdapter()
        adapter.display(keyTitle: animatedNestedLabel(
            identifier: "key-value.key",
            completion: { completion.fulfill() }
        ))
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIHKeyValueFieldView(adapter: adapter)
                .frame(width: 240, height: 80),
            size: CGSize(width: 240, height: 80)
        )

        adapter.display(keyTitle: replacementNestedLabel(identifier: "key-value.key"))

        wait(for: [completion], timeout: 0.5)
        assertNestedLabelFinished(in: host, identifier: "key-value.key")
    }

    func test_publicCard_animatedSubtitleCompletionSurvivesPlainReplacement() {
        let completion = expectation(description: "Nested subtitle animation completes")
        let adapter = CardViewOutputSwiftUIAdapter()
        adapter.display(subTitle: animatedNestedLabel(
            identifier: "card.subtitle",
            completion: { completion.fulfill() }
        ))
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUICardView(adapter: adapter)
                .frame(width: 240, height: 120),
            size: CGSize(width: 240, height: 120)
        )

        adapter.display(subTitle: replacementNestedLabel(identifier: "card.subtitle"))

        wait(for: [completion], timeout: 0.5)
        assertNestedLabelFinished(in: host, identifier: "card.subtitle")
    }

    func test_publicNavigationBar_animatedCenterValueCompletionSurvivesPlainReplacement() {
        let completion = expectation(description: "Nested center value animation completes")
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(centerView: .keyValue(.init(
            .text("Key"),
            animatedNestedLabel(
                identifier: "navigation.center.value",
                completion: { completion.fulfill() }
            )
        )))
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUINavigationBar(adapter: adapter)
                .frame(width: 320),
            size: CGSize(width: 320, height: 80)
        )

        adapter.display(centerView: .keyValue(.init(
            .text("Key"),
            replacementNestedLabel(identifier: "navigation.center.value")
        )))

        wait(for: [completion], timeout: 0.5)
        assertNestedLabelFinished(in: host, identifier: "navigation.center.value")
    }

    private func animatedNestedLabel(
        identifier: String,
        completion: @escaping () -> Void
    ) -> TextOutputPresentableModel {
        .init(
            accessibilityIdentifier: identifier,
            model: .animatedDecimal(
                from: 0,
                to: 1,
                mapToString: { .text($0.asString()) },
                animationStyle: .none,
                duration: 0.25,
                completion: completion
            )
        )
    }

    private func replacementNestedLabel(identifier: String) -> TextOutputPresentableModel {
        .init(
            accessibilityIdentifier: identifier,
            model: .text("Replacement")
        )
    }

    private func assertNestedLabelFinished(
        in host: SwiftUIAccessibilityTestHost,
        identifier: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        host.settle()
        XCTAssertNotNil(
            host.element(withLabel: "1"),
            "The rendered \(identifier) did not apply the animation's final value.",
            file: file,
            line: line
        )
        XCTAssertNil(
            host.element(withLabel: "Replacement"),
            "The rendered \(identifier) stayed on the interim replacement.",
            file: file,
            line: line
        )
    }

    private func animationProgressColor(
        _ progress: Decimal
    ) -> TextOutputPresentableModel.TextModel {
        .textStyled(
            text: .text(" "),
            cornerStyle: .fixed(0),
            height: 40,
            backgroundColor: progress < 0.25 ? .magenta : .cyan
        )
    }

    private func maximumSymmetricDifference(in masks: [FixturePixelMask]) -> Int {
        guard masks.count > 1 else { return 0 }
        return zip(masks, masks.dropFirst())
            .map { $0.indices.symmetricDifference($1.indices).count }
            .max() ?? 0
    }

    private func horizontalCentroidRange(in masks: [FixturePixelMask]) -> CGFloat {
        let centroids = masks.compactMap(\.horizontalCentroid)
        guard let minimum = centroids.min(), let maximum = centroids.max() else { return 0 }
        return maximum - minimum
    }
}

@available(iOS 17.0, *)
private struct ButtonAnimationFixture: View {
    let buttonAdapter: ButtonOutputSwiftUIAdapter
    let loadingAdapter: LoadingOutputSwiftUIAdapter

    var body: some View {
        ZStack {
            SwiftUIColor.white
            SUIButton(adapter: buttonAdapter, loadingAdapter: loadingAdapter)
        }
        .frame(width: 200, height: 100)
    }
}

@available(iOS 17.0, *)
private final class ReduceMotionControl: ObservableObject {
    @Published var isEnabled = true
}

@available(iOS 17.0, *)
private struct DynamicReduceMotionButtonFixture: View {
    let buttonAdapter: ButtonOutputSwiftUIAdapter
    let loadingAdapter: LoadingOutputSwiftUIAdapter
    @ObservedObject var reduceMotion: ReduceMotionControl

    var body: some View {
        ButtonAnimationFixture(
            buttonAdapter: buttonAdapter,
            loadingAdapter: loadingAdapter
        )
        .environment(\._accessibilityReduceMotion, reduceMotion.isEnabled)
    }
}

@available(iOS 17.0, *)
private struct SwitchAnimationFixture: View {
    let adapter: SwitchCotrolOutputSwiftUIAdapter

    var body: some View {
        ZStack {
            SwiftUIColor.white
            SUISwitchControl(adapter: adapter)
                .fixedSize()
        }
        .frame(width: 120, height: 80)
    }
}

@available(iOS 17.0, *)
private struct ShimmerAnimationFixture: View {
    let highlightColor: UIColor

    var body: some View {
        SUIShimmerView(style: .init(
            backgroundColor: .black,
            gradientColorOne: .black,
            gradientColorTwo: highlightColor,
            cornerRadius: 8
        ))
        .frame(width: 140, height: 40)
    }
}

@available(iOS 17.0, *)
private struct LabelAnimationFixture: View {
    let adapter: TextOutputSwiftUIAdapter

    var body: some View {
        ZStack {
            SwiftUIColor.white
            SUILabel(adapter: adapter)
                .frame(width: 100, height: 40)
        }
        .frame(width: 120, height: 60)
    }
}

@available(iOS 17.0, *)
private final class LabelRemountControl: ObservableObject {
    @Published var revision = 0
}

@available(iOS 17.0, *)
private struct RemountingLabelAnimationFixture: View {
    let adapter: TextOutputSwiftUIAdapter
    @ObservedObject var remount: LabelRemountControl

    var body: some View {
        ZStack {
            SwiftUIColor.white
            SUILabel(adapter: adapter)
                .id(remount.revision)
                .frame(width: 100, height: 40)
        }
        .frame(width: 120, height: 60)
    }
}

@available(iOS 17.0, *)
private final class LiveSwiftUIAnimationHost<Content: View> {
    struct Frame {
        let image: UIImage
        let didDrawHierarchy: Bool
    }

    private let hostingController: UIHostingController<Content>
    private let window: UIWindow
    private weak var previousKeyWindow: UIWindow?

    init(rootView: Content, size: CGSize) {
        hostingController = UIHostingController(rootView: rootView)

        let foregroundScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        if let foregroundScene {
            previousKeyWindow = foregroundScene.windows.first(where: \.isKeyWindow)
            window = UIWindow(windowScene: foregroundScene)
            window.frame = CGRect(origin: .zero, size: size)
        } else {
            window = UIWindow(frame: CGRect(origin: .zero, size: size))
        }

        window.backgroundColor = .white
        window.rootViewController = hostingController
        hostingController.view.frame = window.bounds
        hostingController.view.backgroundColor = .white
        window.makeKeyAndVisible()
        settle(for: 0.08)
    }

    deinit {
        window.isHidden = true
        previousKeyWindow?.makeKeyAndVisible()
    }

    func sampleFrames(count: Int, interval: TimeInterval) -> [Frame] {
        precondition(count > 0)
        return (0..<count).map { index in
            if index > 0 {
                RunLoop.main.run(until: Date().addingTimeInterval(interval))
            }
            return captureFrame()
        }
    }

    private func settle(for interval: TimeInterval) {
        window.setNeedsLayout()
        window.layoutIfNeeded()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(interval))
        window.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
    }

    private func captureFrame() -> Frame {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        format.preferredRange = .standard

        var didDrawHierarchy = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
            didDrawHierarchy = window.drawHierarchy(
                in: window.bounds,
                afterScreenUpdates: true
            )
        }
        return Frame(image: image, didDrawHierarchy: didDrawHierarchy)
    }
}

private struct FixturePixelMask {
    enum FixtureColor {
        case cyan
        case magenta
        case yellow

        func matches(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> Bool {
            guard alpha > 80 else { return false }
            switch self {
            case .cyan:
                return red < 120 && green > 130 && blue > 130
            case .magenta:
                return red > 130 && green < 120 && blue > 130
            case .yellow:
                return red > 130 && green > 130 && blue < 120
            }
        }
    }

    let indices: Set<Int>
    let horizontalCentroid: CGFloat?

    init(image: UIImage, color: FixtureColor) {
        guard let cgImage = image.cgImage else {
            indices = []
            horizontalCentroid = nil
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var rgba = [UInt8](repeating: 0, count: bytesPerRow * height)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: &rgba,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            indices = []
            horizontalCentroid = nil
            return
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var matchedIndices = Set<Int>()
        var xTotal = 0
        for pixelIndex in 0..<(width * height) {
            let byteIndex = pixelIndex * 4
            if color.matches(
                red: rgba[byteIndex],
                green: rgba[byteIndex + 1],
                blue: rgba[byteIndex + 2],
                alpha: rgba[byteIndex + 3]
            ) {
                matchedIndices.insert(pixelIndex)
                xTotal += pixelIndex % width
            }
        }

        indices = matchedIndices
        horizontalCentroid = matchedIndices.isEmpty
            ? nil
            : CGFloat(xTotal) / CGFloat(matchedIndices.count)
    }
}
#endif
