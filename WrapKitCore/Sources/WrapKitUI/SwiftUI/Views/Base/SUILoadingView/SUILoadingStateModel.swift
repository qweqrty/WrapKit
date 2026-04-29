//
//  SUILoadingStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 16/4/26.
//


import SwiftUI
import Combine

public final class SUILoadingStateModel: ObservableObject {
    @Published public var isLoading: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: LoadingOutputSwiftUIAdapter) {
        adapter.$displayIsLoadingState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value.isLoading
            }
            .store(in: &cancellables)
    }
}
