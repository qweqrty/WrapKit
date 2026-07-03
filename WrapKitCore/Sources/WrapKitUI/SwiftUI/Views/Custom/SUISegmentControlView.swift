import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUISegmentControlView: View {
    @StateObject private var stateModel: SUISegmentControlViewStateModel

    public init(
        adapter: SegmentedControlOutputSwiftUIAdapter,
        appearance: SegmentedControlAppearance
    ) {
        _stateModel = .init(wrappedValue: .init(
            adapter: adapter,
            appearance: appearance
        ))
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                backgroundView
                if #unavailable(iOS 26) {
                    selectedSegmentView(containerWidth: proxy.size.width)
                }
                segmentsView
            }
        }
        .frame(minHeight: 32)
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: stateModel.appearance.cornerRadius, style: .continuous)
            .fill(SwiftUIColor(stateModel.appearance.colors.backgroundColor))
    }

    @ViewBuilder
    private func selectedSegmentView(containerWidth: CGFloat) -> some View {
        let segmentWidth = selectedSegmentWidth(containerWidth: containerWidth)
        if segmentWidth > 0 {
            RoundedRectangle(cornerRadius: selectedSegmentCornerRadius, style: .continuous)
                .fill(SwiftUIColor(stateModel.appearance.colors.selectedBackgroundColor))
                .frame(width: segmentWidth)
                .padding(selectedSegmentInset)
                .offset(x: selectedSegmentOffset(segmentWidth: segmentWidth))
        }
    }

    private var segmentsView: some View {
        HStack(spacing: 0) {
            ForEach(Array(stateModel.segments.enumerated()), id: \.offset) { index, segment in
                SwiftUI.Button {
                    stateModel.selectSegment(at: index)
                } label: {
                    SwiftUI.Text(segment.title.removingPercentEncoding ?? segment.title)
                        .font(SwiftUIFont(stateModel.appearance.font))
                        .foregroundColor(SwiftUIColor(stateModel.appearance.colors.textColor))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(segment.accessibilityIdentifier ?? "")
            }
        }
    }

    private var selectedSegmentInset: CGFloat {
        2
    }

    private var selectedSegmentCornerRadius: CGFloat {
        max(stateModel.appearance.cornerRadius - selectedSegmentInset, 0)
    }

    private func selectedSegmentWidth(containerWidth: CGFloat) -> CGFloat {
        guard !stateModel.segments.isEmpty else { return 0 }
        return max(containerWidth / CGFloat(stateModel.segments.count) - selectedSegmentInset * 2, 0)
    }

    private func selectedSegmentOffset(segmentWidth: CGFloat) -> CGFloat {
        CGFloat(stateModel.selectedIndex) * (segmentWidth + selectedSegmentInset * 2)
    }
}

#endif
