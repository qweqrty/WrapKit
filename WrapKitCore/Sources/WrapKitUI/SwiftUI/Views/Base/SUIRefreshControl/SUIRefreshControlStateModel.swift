//
//  SUIRefreshControlStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 23/4/26.
//

import Combine
import Foundation

public final class SUIRefreshControlStateModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var tintColor: Color? = nil
    @Published var zPosition: CGFloat = -1
    @Published var onRefreshCallbacks: [(() -> Void)?] = []
    
    private let adapter: RefreshControlOutputSwiftUIAdapter
    private var latestStyleOutputSequence: UInt64 = 0
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: RefreshControlOutputSwiftUIAdapter) {
        self.adapter = adapter
        
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                if let style = value.model?.style,
                   value.outputSequence >= self.latestStyleOutputSequence {
                    self.latestStyleOutputSequence = value.outputSequence
                    self.tintColor = style.tintColor
                    self.zPosition = style.zPosition
                }
                if let isLoading = value.model?.isLoading {
                    self.isLoading = isLoading
                }
            }
            .store(in: &cancellables)
        
        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self,
                      value.outputSequence >= self.latestStyleOutputSequence else { return }
                self.latestStyleOutputSequence = value.outputSequence
                self.tintColor = value.style.tintColor
                self.zPosition = value.style.zPosition
            }
            .store(in: &cancellables)
        
        adapter.$displayIsLoadingState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value.isLoading
            }
            .store(in: &cancellables)

        adapter.$isLoading
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        if let directCallbacks = adapter.onRefresh {
            onRefreshCallbacks = directCallbacks
        }

        adapter.$onRefresh
            .dropFirst()
            .sink { [weak self] callbacks in
                self?.onRefreshCallbacks = callbacks ?? []
            }
            .store(in: &cancellables)
    }
    
    func triggerRefresh() {
        onRefreshCallbacks.forEach { $0?() }
    }

    func waitForLoadingToFinish(
        pollIntervalNanoseconds: UInt64 = 100_000_000,
        sleep: (UInt64) async throws -> Void = { nanoseconds in
            try await Task.sleep(nanoseconds: nanoseconds)
        }
    ) async {
        while isLoading {
            guard !Task.isCancelled else { return }
            do {
                try await sleep(pollIntervalNanoseconds)
            } catch {
                return
            }
        }
    }
}
