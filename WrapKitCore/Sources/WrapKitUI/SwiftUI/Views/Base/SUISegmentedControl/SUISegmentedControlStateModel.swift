//
//  SUISegmentedControlStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import Combine

public final class SUISegmentedControlStateModel: ObservableObject {
    @Published var segments: [SegmentControlModel] = []
    @Published var appearance: SegmentedControlAppearance? = nil
    @Published var selectedIndex: Int = 0
    
    private let adapter: SegmentedControlOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: SegmentedControlOutputSwiftUIAdapter) {
        self.adapter = adapter
        
        adapter.$displaySegmentsState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.segments = value.segments
                self?.selectedIndex = 0
            }
            .store(in: &cancellables)
        
        adapter.$displayAppearenceState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.appearance = value.appearence
            }
            .store(in: &cancellables)
    }
}
