import Foundation

#if canImport(SwiftUI)
import Combine

final class SUISegmentControlViewStateModel: ObservableObject {
    @Published var appearance: SegmentedControlAppearance
    @Published var segments: [SegmentControlModel] = []
    @Published var selectedIndex: Int = 0

    private var cancellables: Set<AnyCancellable> = []

    init(
        adapter: SegmentedControlOutputSwiftUIAdapter,
        appearance: SegmentedControlAppearance
    ) {
        self.appearance = appearance

        adapter.$displayAppearenceState
            .sink { [weak self] state in
                guard let state else { return }
                self?.appearance = state.appearence
            }
            .store(in: &cancellables)

        adapter.$displaySegmentsState
            .sink { [weak self] state in
                guard let state else { return }
                self?.segments = state.segments
                self?.selectedIndex = state.segments.isEmpty ? UISegmentControlConstants.noSegment : 0
            }
            .store(in: &cancellables)
    }

    func selectSegment(at index: Int) {
        guard segments.indices.contains(index) else { return }
        selectedIndex = index
        segments[index].onTap?(index)
    }
}

private enum UISegmentControlConstants {
    static let noSegment = -1
}

#endif
