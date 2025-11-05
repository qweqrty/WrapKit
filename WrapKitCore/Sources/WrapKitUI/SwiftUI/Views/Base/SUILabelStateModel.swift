//
//  SUILabelViewModel.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/11/25.
//

import SwiftUI
import Combine

public final class SUILabelStateModel: ObservableObject {
    @Published var presentable: TextOutputPresentableModel = .text(nil)
    @Published var isHidden: Bool = false
    
    @Published private var adapter: TextOutputSwiftUIAdapter
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
        adapter.$displayModelState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.presentable = value.model
            }
            .store(in: &cancellables)
        adapter.$displayTextState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.presentable = .text(value.text)
            }
            .store(in: &cancellables)
        adapter.$displayAttributesState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.presentable = .attributes(value.attributes)
            }
            .store(in: &cancellables)
        adapter.$displayStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.presentable = .animated(value.startAmount, value.endAmount, mapToString: value.mapToString, animationStyle: value.animationStyle, duration: value.duration, completion: value.completion)
            }
            .store(in: &cancellables)
        adapter.$displayIsHiddenState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }
    
}
