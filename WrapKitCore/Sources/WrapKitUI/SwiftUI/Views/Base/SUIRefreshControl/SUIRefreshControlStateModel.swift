//
//  SUIRefreshControlStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 23/4/26.
//

import Combine

public final class SUIRefreshControlStateModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var tintColor: Color? = nil
    @Published var onRefreshCallbacks: [(() -> Void)?] = []
    
    private let adapter: RefreshControlOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: RefreshControlOutputSwiftUIAdapter) {
        self.adapter = adapter
        
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                if let style = value.model?.style {
                    self.tintColor = style.tintColor
                }
                if let onRefresh = value.model?.onRefresh {
                    self.onRefreshCallbacks = [onRefresh]
                }
                if let isLoading = value.model?.isLoading {
                    self.isLoading = isLoading
                }
            }
            .store(in: &cancellables)
        
        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.tintColor = value.style.tintColor
            }
            .store(in: &cancellables)
        
        adapter.$displayOnRefreshState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.onRefreshCallbacks = [value.onRefresh]
            }
            .store(in: &cancellables)
        
        adapter.$displayAppendingOnRefreshState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.onRefreshCallbacks.append(value.appendingOnRefresh)
            }
            .store(in: &cancellables)
        
        adapter.$displayIsLoadingState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value.isLoading
            }
            .store(in: &cancellables)
    }
    
    func triggerRefresh() {
        onRefreshCallbacks.forEach { $0?() }
    }
}
