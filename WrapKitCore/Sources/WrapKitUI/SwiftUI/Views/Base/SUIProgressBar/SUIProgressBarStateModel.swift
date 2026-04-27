//
//  SUIProgressBarStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import Combine
import UIKit

public final class SUIProgressBarStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var progress: CGFloat = 0
    @Published var style: ProgressBarStyle? = nil
    
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
                self.progress = model.progress
                if let style = model.style { self.style = style }
            }
            .store(in: &cancellables)
        
        adapter.$displayProgressState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.progress = value.progress
            }
            .store(in: &cancellables)
        
        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.style = value.style
            }
            .store(in: &cancellables)
        
        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }
}
