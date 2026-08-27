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

    init(stateModel: SUISegmentControlViewStateModel) {
        _stateModel = .init(wrappedValue: stateModel)
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
                    segmentsView(containerWidth: proxy.size.width)
                }
            }
            .frame(minHeight: 32)
        }
    }

    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, *)
    private var nativeSegmentedControl: some View {
        nativeSegmentedPicker
            .background(SwiftUIColor(stateModel.appearance.colors.backgroundColor))
            .cornerStyle(.fixed(stateModel.appearance.cornerRadius))
            .frame(minHeight: 32)
    }

    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, *)
    private var nativeSegmentedPicker: some View {
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

    private func segmentsView(containerWidth: CGFloat) -> some View {
        let segmentWidth = segmentWidth(containerWidth: containerWidth)

        return HStack(spacing: 0) {
            ForEach(Array(stateModel.segments.enumerated()), id: \.offset) { index, segment in
                SwiftUI.Button {
                    stateModel.selectSegment(at: index)
                } label: {
                    segmentLabel(
                        title: segment.title,
                        segmentWidth: segmentWidth
                    )
                }
                .buttonStyle(.plain)
                .frame(width: segmentWidth)
                .frame(maxHeight: .infinity)
                .accessibilityIdentifier(segment.accessibilityIdentifier ?? "")
            }
        }
    }

    @ViewBuilder
    private func segmentLabel(
        title: String,
        segmentWidth: CGFloat
    ) -> some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            ViewThatFits(in: .horizontal) {
                ZStack {
                    segmentText(title)
                        .fixedSize(horizontal: true, vertical: false)
                        .hidden()
                    segmentText(title)
                        .frame(width: max(segmentWidth - segmentContentInsets * 2, 0))
                }
                segmentText(title)
                    .frame(width: segmentWidth)
            }
            .frame(maxHeight: .infinity)
        } else {
            segmentText(title)
                .frame(width: max(segmentWidth - segmentContentInsets * 2, 0))
                .frame(maxHeight: .infinity)
        }
    }

    private func segmentText(_ title: String) -> some View {
        SwiftUI.Text(title.removingPercentEncoding ?? title)
            .font(SwiftUIFont(stateModel.appearance.font))
            .foregroundColor(SwiftUIColor(stateModel.appearance.colors.textColor))
            .lineLimit(1)
            .truncationMode(.tail)
    }

    private var selectedSegmentInset: CGFloat {
        4
    }

    private var segmentContentInsets: CGFloat {
        9
    }

    private var selectedSegmentCornerRadius: CGFloat {
        max(stateModel.appearance.cornerRadius - selectedSegmentInset, 0)
    }

    private func selectedSegmentWidth(containerWidth: CGFloat) -> CGFloat {
        max(segmentWidth(containerWidth: containerWidth) - selectedSegmentInset * 2, 0)
    }

    private func segmentWidth(containerWidth: CGFloat) -> CGFloat {
        guard !stateModel.segments.isEmpty else { return 0 }
        return containerWidth / CGFloat(stateModel.segments.count)
    }

    private func selectedSegmentOffset(segmentWidth: CGFloat) -> CGFloat {
        CGFloat(stateModel.selectedIndex) * (segmentWidth + selectedSegmentInset * 2)
    }
}

#endif
