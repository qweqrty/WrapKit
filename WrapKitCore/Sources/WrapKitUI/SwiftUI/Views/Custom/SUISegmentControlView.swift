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

    @ViewBuilder
    public var body: some View {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            nativeSegmentedControl
        } else {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    backgroundView
                    selectedSegmentView(containerWidth: proxy.size.width)
                    segmentsView
                }
            }
            .frame(minHeight: 32)
        }
    }

    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, *)
    private var nativeSegmentedControl: some View {
        Picker(
            "",
            selection: Binding(
                get: { stateModel.selectedIndex },
                set: { stateModel.selectSegment(at: $0) }
            )
        ) {
            ForEach(Array(stateModel.segments.enumerated()), id: \.offset) { index, segment in
                Text(segment.title.removingPercentEncoding ?? segment.title)
                    .font(SwiftUIFont(stateModel.appearance.font))
                    .foregroundColor(SwiftUIColor(stateModel.appearance.colors.textColor))
                    .lineLimit(1)
                    .tag(index)
                    .accessibilityIdentifier(segment.accessibilityIdentifier ?? "")
            }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .tint(SwiftUIColor(stateModel.appearance.colors.selectedBackgroundColor))
        .background(SwiftUIColor(stateModel.appearance.colors.backgroundColor))
        .cornerStyle(.fixed(stateModel.appearance.cornerRadius))
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
        4
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
