//
//  SUIProgressBarStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import Combine
import Foundation

public final class SUIProgressBarStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var progress: CGFloat = 0
    @Published var style: ProgressBarStyle? = nil
    @Published var layoutHeight: CGFloat = 4
    @Published var animatesProgressChanges = false
    
    private let adapter: ProgressBarOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: ProgressBarOutputSwiftUIAdapter) {
        self.adapter = adapter
        
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isHidden = value.model == nil
                guard let model = value.model else { return }
                self.animatesProgressChanges = false
                self.progress = model.progress
                if let style = model.style {
                    self.style = style
                    self.updateLayoutHeight(from: style)
                }
            }
            .store(in: &cancellables)
        
        adapter.$displayProgressState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.animatesProgressChanges = true
                self?.progress = value.progress
            }
            .store(in: &cancellables)
        
        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.style = value.style
                self?.updateLayoutHeight(from: value.style)
            }
            .store(in: &cancellables)
        
        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }

    private func updateLayoutHeight(from style: ProgressBarStyle?) {
        guard let height = style?.height else { return }
        layoutHeight = height
    }
}
