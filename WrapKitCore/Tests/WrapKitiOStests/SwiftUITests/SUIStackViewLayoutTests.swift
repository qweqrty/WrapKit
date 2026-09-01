#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
final class SUIStackViewLayoutTests: XCTestCase {
    func test_fill_preservesIntrinsicLengthsAndStretchesLowestPriorityLastItem() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [20, 30, 10],
            priorities: [0, 1, 0],
            proposedLength: 100,
            distribution: .fill,
            spacing: 5
        )

        XCTAssertEqual(resolution.origins, [0, 25, 60])
        XCTAssertEqual(resolution.lengths, [20, 30, 40])
        XCTAssertEqual(resolution.containerLength, 100)
    }

    func test_fillEqually_usesLargestIntrinsicLengthWithoutProposal() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [20, 50, 30],
            proposedLength: nil,
            distribution: .fillEqually,
            spacing: 5
        )

        XCTAssertEqual(resolution.origins, [0, 55, 110])
        XCTAssertEqual(resolution.lengths, [50, 50, 50])
        XCTAssertEqual(resolution.containerLength, 160)
    }

    func test_fillEqually_splitsAvailableLengthAfterSpacing() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [20, 50, 30],
            proposedLength: 100,
            distribution: .fillEqually,
            spacing: 5
        )

        assertEqual(resolution.lengths, [30, 30, 30])
        assertEqual(resolution.origins, [0, 35, 70])
    }

    func test_fillProportionally_matchesUIKitSpacingContract() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [20, 60],
            proposedLength: 100,
            distribution: .fillProportionally,
            spacing: 10
        )

        assertEqual(resolution.lengths, [22.222, 67.778])
        assertEqual(resolution.origins, [0, 32.222])
    }

    func test_equalSpacing_usesEqualGapsNotSwiftUIDefaultSpacing() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [20, 20, 20],
            proposedLength: 100,
            distribution: .equalSpacing,
            spacing: 5
        )

        assertEqual(resolution.lengths, [20, 20, 20])
        assertEqual(resolution.origins, [0, 40, 80])
    }

    func test_equalCentering_keepsCentersEquidistantForDifferentItemLengths() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [10, 30, 20],
            proposedLength: 120,
            distribution: .equalCentering,
            spacing: 5
        )
        let centers = zip(resolution.origins, resolution.lengths).map { $0 + $1 / 2 }

        XCTAssertEqual(centers[1] - centers[0], centers[2] - centers[1], accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(resolution.origins[1] - 10, 5)
        XCTAssertGreaterThanOrEqual(resolution.origins[2] - 40, 5)
        XCTAssertEqual(resolution.origins[0], 0, accuracy: 0.001)
        XCTAssertEqual(resolution.origins[2] + resolution.lengths[2], 120, accuracy: 0.001)
    }

    func test_equalCentering_compressesInsteadOfOverlappingWhenProposalIsNarrow() {
        let resolution = StackMainAxisResolver.resolve(
            idealLengths: [10, 10, 100, 100],
            proposedLength: 160,
            distribution: .equalCentering,
            spacing: 8
        )

        for index in 1..<resolution.origins.count {
            let previousMaxX = resolution.origins[index - 1] + resolution.lengths[index - 1]
            XCTAssertGreaterThanOrEqual(resolution.origins[index] - previousMaxX, 7.999)
        }
        guard let lastOrigin = resolution.origins.last,
              let lastLength = resolution.lengths.last else {
            return XCTFail("Expected resolved items")
        }
        XCTAssertLessThanOrEqual(
            lastOrigin + lastLength,
            160.001
        )
    }

    func test_fillAlignment_stretchesEveryCrossAxisLength() {
        let horizontalCrossAxis = StackCrossAxisResolver.resolve(
            idealLengths: [12, 30, 18],
            proposedLength: 44,
            alignment: .fill
        )
        let verticalCrossAxis = StackCrossAxisResolver.resolve(
            idealLengths: [22, 14],
            proposedLength: 80,
            alignment: .fill
        )

        XCTAssertEqual(horizontalCrossAxis.origins, [0, 0, 0])
        XCTAssertEqual(horizontalCrossAxis.lengths, [44, 44, 44])
        XCTAssertEqual(verticalCrossAxis.origins, [0, 0])
        XCTAssertEqual(verticalCrossAxis.lengths, [80, 80])
    }

    func test_crossAxisAlignments_matchUIKitAliases() {
        let leading = StackCrossAxisResolver.resolve(
            idealLengths: [20],
            proposedLength: 50,
            alignment: .top
        )
        let center = StackCrossAxisResolver.resolve(
            idealLengths: [20],
            proposedLength: 50,
            alignment: .center
        )
        let trailing = StackCrossAxisResolver.resolve(
            idealLengths: [20],
            proposedLength: 50,
            alignment: .bottom
        )

        XCTAssertEqual(leading.origins, [0])
        XCTAssertEqual(center.origins, [15])
        XCTAssertEqual(trailing.origins, [30])
    }

    func test_mainAxisDistributions_matchUIKitHorizontally() {
        let idealLengths: [CGFloat] = [20, 40, 60]
        let distributions: [StackViewDistribution] = [
            .fill,
            .fillEqually,
            .fillProportionally,
            .equalSpacing,
            .equalCentering
        ]

        distributions.forEach { distribution in
            let diagnostic = "distribution=\(distribution), axis=horizontal"
            let expectedFrames = uiKitFrames(
                idealLengths: idealLengths,
                containerLength: 160,
                distribution: distribution,
                axis: .horizontal,
                spacing: 10
            )
            let actual = StackMainAxisResolver.resolve(
                idealLengths: idealLengths,
                priorities: [1, 1, 0],
                proposedLength: 160,
                distribution: distribution,
                spacing: 10
            )

            assertEqual(
                actual.origins,
                expectedFrames.map(\.minX),
                accuracy: 0.51,
                message: "\(diagnostic), value=origin"
            )
            assertEqual(
                actual.lengths,
                expectedFrames.map(\.width),
                accuracy: 0.51,
                message: "\(diagnostic), value=length"
            )
        }
    }

    func test_mainAxisDistributions_matchUIKitVertically() {
        let idealLengths: [CGFloat] = [12, 30, 48]
        let distributions: [StackViewDistribution] = [
            .fill,
            .fillEqually,
            .fillProportionally,
            .equalSpacing,
            .equalCentering
        ]

        distributions.forEach { distribution in
            let diagnostic = "distribution=\(distribution), axis=vertical"
            let expectedFrames = uiKitFrames(
                idealLengths: idealLengths,
                containerLength: 140,
                distribution: distribution,
                axis: .vertical,
                spacing: 7
            )
            let actual = StackMainAxisResolver.resolve(
                idealLengths: idealLengths,
                priorities: [1, 1, 0],
                proposedLength: 140,
                distribution: distribution,
                spacing: 7
            )

            assertEqual(
                actual.origins,
                expectedFrames.map(\.minY),
                accuracy: 0.51,
                message: "\(diagnostic), value=origin"
            )
            assertEqual(
                actual.lengths,
                expectedFrames.map(\.height),
                accuracy: 0.51,
                message: "\(diagnostic), value=length"
            )
        }
    }

    func test_horizontalStack_intrinsicHeightComesFromContent() {
        let view = SUIStackView(alignment: .top, axis: .horizontal, spacing: 7) {
            SwiftUI.Color.red.frame(width: 20, height: 12)
            SwiftUI.Color.blue.frame(width: 30, height: 25)
        }
        let size = sizeThatFits(view.fixedSize())

        XCTAssertEqual(size.width, 57, accuracy: 0.001)
        XCTAssertEqual(size.height, 25, accuracy: 0.001)
    }

    func test_verticalStack_intrinsicWidthComesFromContent() {
        let view = SUIStackView(alignment: .leading, axis: .vertical, spacing: 7) {
            SwiftUI.Color.red.frame(width: 20, height: 12)
            SwiftUI.Color.blue.frame(width: 30, height: 25)
        }
        let size = sizeThatFits(view.fixedSize())

        XCTAssertEqual(size.width, 30, accuracy: 0.001)
        XCTAssertEqual(size.height, 44, accuracy: 0.001)
    }
}

private extension SUIStackViewLayoutTests {
    func assertEqual(
        _ values: [CGFloat],
        _ expected: [CGFloat],
        accuracy: CGFloat = 0.001,
        message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(values.count, expected.count, message, file: file, line: line)
        zip(values, expected).enumerated().forEach { index, values in
            XCTAssertEqual(
                values.0,
                values.1,
                accuracy: accuracy,
                "\(message), index=\(index)",
                file: file,
                line: line
            )
        }
    }

    func sizeThatFits(_ view: some View) -> CGSize {
        let host = UIHostingController(rootView: view)
        host.loadViewIfNeeded()
        return host.sizeThatFits(in: CGSize(width: 1_000, height: 1_000))
    }

    func uiKitFrames(
        idealLengths: [CGFloat],
        containerLength: CGFloat,
        distribution: StackViewDistribution,
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat
    ) -> [CGRect] {
        let views = idealLengths.map { length in
            StackIntrinsicView(size: axis == .horizontal
                ? .init(width: length, height: 20)
                : .init(width: 20, height: length))
        }
        views.enumerated().forEach { index, view in
            view.setContentHuggingPriority(
                .init(rawValue: index == views.count - 1 ? 249 : 251),
                for: axis
            )
        }
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = axis
        stack.alignment = .fill
        stack.distribution = uiKitDistribution(distribution)
        stack.spacing = spacing
        stack.frame = axis == .horizontal
            ? .init(x: 0, y: 0, width: containerLength, height: 40)
            : .init(x: 0, y: 0, width: 40, height: containerLength)
        stack.layoutIfNeeded()
        return views.map(\.frame)
    }

    func uiKitDistribution(_ distribution: StackViewDistribution) -> UIStackView.Distribution {
        switch distribution {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .fillProportionally: return .fillProportionally
        case .equalSpacing: return .equalSpacing
        case .equalCentering: return .equalCentering
        }
    }
}

private final class StackIntrinsicView: UIView {
    private let size: CGSize

    init(size: CGSize) {
        self.size = size
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize { size }
}
#endif
