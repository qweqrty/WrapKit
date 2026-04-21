//
//  SUISwitchControlStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/4/26.
//

import Combine
import UIKit

public final class SUISwitchControlStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var isOn: Bool = false
    @Published var isEnabled: Bool = true
    @Published var isLoading: Bool = false
    @Published var style: SwitchControlPresentableModel.Style? = nil
    @Published var onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)? = nil
    
    let adapter: SwitchCotrolOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: SwitchCotrolOutputSwiftUIAdapter) {
        self.adapter = adapter
        
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isHidden = value.model == nil
                guard let model = value.model else { return }
                if let isOn = model.isOn { self.isOn = isOn }
                if let isEnabled = model.isEnabled { self.isEnabled = isEnabled }
                if let style = model.style { self.style = style }
                if let onPress = model.onPress { self.onPress = onPress }
            }
            .store(in: &cancellables)
        
        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isHidden = value.isHidden
            }
            .store(in: &cancellables)
        
        adapter.$displayIsOnState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isOn = value.isOn
            }
            .store(in: &cancellables)
        
        adapter.$displayIsEnabledState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isEnabled = value.isEnabled
            }
            .store(in: &cancellables)
        
        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.style = value.style
            }
            .store(in: &cancellables)
        
        adapter.$displayOnPressState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.onPress = value.onPress
            }
            .store(in: &cancellables)
        
        adapter.$displayIsLoadingState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value.isLoading
            }
            .store(in: &cancellables)
    }
}
