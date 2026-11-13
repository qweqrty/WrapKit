import SwiftUI
import UIKit
@testable import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUIShimmerViewSnapshotTests: XCTestCase {
    func test_shimmerView_initial_state() {
        assertSnapshots(
            basicShimmer(style: nil),
            named: "SHIMMERVIEW_INITIAL_STATE"
        )
    }

    func test_shimmerView_with_background_color() {
        assertSnapshots(
            basicShimmer(style: style(backgroundColor: .systemGray6)),
            named: "SHIMMERVIEW_WITH_BACKGROUND"
        )
    }

    func test_fail_shimmerView_with_background_color() {
        assertFailSnapshots(
            basicShimmer(style: style(backgroundColor: .systemGray5)),
            named: "SHIMMERVIEW_WITH_BACKGROUND"
        )
    }

    func test_shimmerView_custom_gradient_colors() {
        assertSnapshots(
            basicShimmer(
                style: style(
                    backgroundColor: .systemBlue.withAlphaComponent(0.3),
                    gradientColorTwo: .white.withAlphaComponent(0.8)
                )
            ),
            named: "SHIMMERVIEW_CUSTOM_GRADIENT_COLORS"
        )
    }

    func test_fail_shimmerView_custom_gradient_colors() {
        assertFailSnapshots(
            basicShimmer(
                style: style(
                    backgroundColor: .blue.withAlphaComponent(0.3),
                    gradientColorTwo: .white.withAlphaComponent(0.8)
                )
            ),
            named: "SHIMMERVIEW_CUSTOM_GRADIENT_COLORS"
        )
    }

    func test_shimmerView_colored_gradient() {
        assertSnapshots(
            basicShimmer(
                style: style(
                    backgroundColor: .systemPurple.withAlphaComponent(0.2),
                    gradientColorTwo: .systemPurple.withAlphaComponent(0.6)
                )
            ),
            named: "SHIMMERVIEW_COLORED_GRADIENT"
        )
    }

    func test_fail_shimmerView_colored_gradient() {
        assertFailSnapshots(
            basicShimmer(
                style: style(
                    backgroundColor: .purple.withAlphaComponent(0.2),
                    gradientColorTwo: .systemPurple.withAlphaComponent(0.6)
                )
            ),
            named: "SHIMMERVIEW_COLORED_GRADIENT"
        )
    }

    func test_shimmerView_with_style() {
        assertSnapshots(
            basicShimmer(
                style: style(
                    backgroundColor: .systemPink,
                    gradientColorTwo: .white.withAlphaComponent(0.9),
                    cornerRadius: 12
                )
            ),
            named: "SHIMMERVIEW_WITH_STYLE"
        )
    }

    func test_fail_shimmerView_with_style() {
        assertFailSnapshots(
            basicShimmer(
                style: style(
                    backgroundColor: .red,
                    gradientColorTwo: .white.withAlphaComponent(0.9),
                    cornerRadius: 12
                )
            ),
            named: "SHIMMERVIEW_WITH_STYLE"
        )
    }

    func test_shimmerView_pill_shape() {
        assertSnapshots(
            basicShimmer(
                style: style(backgroundColor: .systemGray6, cornerRadius: 50)
            ),
            named: "SHIMMERVIEW_PILL_SHAPE"
        )
    }

    func test_fail_shimmerView_pill_shape() {
        assertFailSnapshots(
            basicShimmer(
                style: style(backgroundColor: .systemGray6, cornerRadius: 0)
            ),
            named: "SHIMMERVIEW_PILL_SHAPE"
        )
    }

    func test_shimmerView_skeleton_card() {
        assertSnapshots(
            skeletonCard(shimmerBackgroundColor: .systemGray6),
            named: "SHIMMERVIEW_SKELETON_CARD"
        )
    }

    func test_fail_shimmerView_skeleton_card() {
        assertFailSnapshots(
            skeletonCard(shimmerBackgroundColor: .systemGray5),
            named: "SHIMMERVIEW_SKELETON_CARD"
        )
    }

}

@available(iOS 17.0, *)
private extension SUIShimmerViewSnapshotTests {
    func basicShimmer(style: ShimmerStyle?) -> AnyView {
        AnyView(
            SUIShimmerView(style: style)
                .frame(width: 390, height: 100)
        )
    }

    func skeletonCard(shimmerBackgroundColor: UIColor) -> AnyView {
        let shimmerStyle = style(backgroundColor: shimmerBackgroundColor, cornerRadius: 4)
        let avatarStyle = style(backgroundColor: shimmerBackgroundColor, cornerRadius: 30)

        return AnyView(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(SwiftUIColor.white)
                    .frame(width: 350, height: 120)
                    .shadow(
                        color: SwiftUIColor.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
                    .offset(x: 20, y: 20)

                SUIShimmerView(style: avatarStyle)
                    .frame(width: 60, height: 60)
                    .offset(x: 36, y: 50)

                SUIShimmerView(style: shimmerStyle)
                    .frame(width: 242, height: 16)
                    .offset(x: 112, y: 50)

                SUIShimmerView(style: shimmerStyle)
                    .frame(width: 150, height: 12)
                    .offset(x: 112, y: 78)
            }
            .frame(width: 390, height: 300, alignment: .topLeading)
        )
    }

    func style(
        backgroundColor: UIColor,
        gradientColorTwo: UIColor = UIColor(white: 0.95, alpha: 0.6),
        cornerRadius: CGFloat = 0
    ) -> ShimmerStyle {
        ShimmerStyle(
            backgroundColor: backgroundColor,
            gradientColorOne: .clear,
            gradientColorTwo: gradientColorTwo,
            cornerRadius: cornerRadius
        )
    }

    func assertSnapshots(
        _ content: AnyView,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        SnapshotAppearance.allCases.forEach { appearance in
            assert(
                snapshot: makeSnapshot(content, appearance: appearance),
                named: snapshotName(name, appearance: appearance),
                precision: SwiftUISnapshotPrecision.standard,
                file: file,
                line: line
            )
        }
    }

    func assertFailSnapshots(
        _ content: AnyView,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        SnapshotAppearance.allCases.forEach { appearance in
            assertFail(
                snapshot: makeSnapshot(content, appearance: appearance),
                named: snapshotName(name, appearance: appearance),
                precision: SwiftUISnapshotPrecision.fail,
                file: file,
                line: line
            )
        }
    }

    func makeSnapshot(
        _ content: AnyView,
        appearance: SnapshotAppearance
    ) -> UIImage {
        let configuration = SUISnapshotConfiguration.iPhone(style: appearance.colorScheme)
        let rootView = SnapshotShimmerContainer(content: content)
            .snapshotEnvironment(configuration: configuration)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    func snapshotName(
        _ name: String,
        appearance: SnapshotAppearance
    ) -> String {
        let runtime = SnapshotRuntime.currentBaselinePrefix ?? "UNSUPPORTED_RUNTIME"
        let appearanceSuffix = appearance == .light ? "LIGHT" : "DARK"
        return "SwiftUI_\(runtime)_\(name)_\(appearanceSuffix)"
    }
}

@available(iOS 17.0, *)
private struct SnapshotShimmerContainer: View {
    let content: AnyView

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(width: 390, height: 300, alignment: .topLeading)
                .background(SwiftUIColor.white)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)
    }
}
