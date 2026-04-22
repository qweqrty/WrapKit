//
//  SUISegmentedControl.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import SwiftUI
import SwiftUIIntrospect

public struct SUISegmentedControl: View {
    @ObservedObject var stateModel: SUISegmentedControlStateModel

    public init(adapter: SegmentedControlOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }

    public var body: some View {
        SUISegmentedControlView(
            segments: stateModel.segments,
            selectedIndex: stateModel.selectedIndex,
            appearance: stateModel.appearance,
            onSelect: { [weak stateModel] index in
                stateModel?.selectedIndex = index
                guard let stateModel = stateModel else { return }
                if index < stateModel.segments.count {
                    stateModel.segments[index].onTap?(index)
                }
            }
        )
    }
}

public struct SUISegmentedControlView: View {
    let segments: [SegmentControlModel]
    let appearance: SegmentedControlAppearance?
    let onSelect: ((Int) -> Void)?

    @State private var selectedIndex: Int = 0

    public init(
        segments: [SegmentControlModel],
        selectedIndex: Int = 0,
        appearance: SegmentedControlAppearance? = nil,
        onSelect: ((Int) -> Void)? = nil
    ) {
        self.segments = segments
        self._selectedIndex = State(initialValue: selectedIndex)
        self.appearance = appearance
        self.onSelect = onSelect
    }

    public var body: some View {
        Picker("", selection: $selectedIndex) {
            ForEach(segments, id: \.index) { segment in
                Text(segment.title).tag(segment.index)
            }
        }
        .pickerStyle(.segmented)
        .introspect(.picker(style: .segmented), on: .iOS(.v15, .v26)) { segmentedControl in
            segmentedControl.backgroundColor = appearance?.colors.backgroundColor
            segmentedControl.selectedSegmentTintColor = appearance?.colors.selectedBackgroundColor
            segmentedControl.layer.cornerRadius = appearance?.cornerRadius ?? 8
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: appearance?.colors.textColor ?? UIColor.black,
                .font: appearance?.font ?? UIFont.systemFont(ofSize: 13)
            ]
            segmentedControl.setTitleTextAttributes(attributes, for: .normal)
            
            for (index, segment) in segments.enumerated() {
                guard let identifier = segment.accessibilityIdentifier else { continue }
                if #available(iOS 14.0, *) {
                    segmentedControl.actionForSegment(at: index)?.accessibilityIdentifier = identifier
                }
            }
        }
        .onChange(of: selectedIndex) { newIndex in
            onSelect?(newIndex)
            if newIndex < segments.count {
                segments[newIndex].onTap?(newIndex)
            }
        }
    }
}

#Preview {
    SUISegmentedControlView(segments: [.init(title: "1", index: 0), .init(title: "2", index: 1)])
}
