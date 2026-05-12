//
//  SUIImageViewStateModel.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 30/4/26.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Kingfisher
import Combine

public final class SUIImageViewStateModel: ObservableObject {
    @Published private(set) var model: ImageViewPresentableModel = .init()
    @Published private(set) var isHidden = false
    @Published private(set) var reloadToken = UUID()

    private(set) var pendingCompletion: ((Image?) -> Void)?
    private let adapter: ImageViewOutputSwiftUIAdapter
    private var cancellables = Set<AnyCancellable>()

    init(adapter: ImageViewOutputSwiftUIAdapter) {
        self.adapter = adapter
        observeAdapter()
    }

    private func observeAdapter() {
        adapter.$displayModelState
            .compactMap { $0?.model }
            .sink { [weak self] adapterModel in
                guard let self else { return }
                self.isHidden = false
                self.model = adapterModel
                self.triggerReload(completion: nil)
            }
            .store(in: &cancellables)

        adapter.$displayModelCompletionState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                defer {
                    DispatchQueue.main.async { [weak adapter] in
                        adapter?.displayModelCompletionState = nil
                    }
                }
                guard let adapterModel = state.model else {
                    self.isHidden = true
                    state.completion?(nil)
                    return
                }
                self.isHidden = false
                self.model = adapterModel
                self.triggerReload(completion: state.completion)
            }
            .store(in: &cancellables)

        adapter.$displayImageState
            .compactMap { $0?.image }
            .sink { [weak self] image in
                guard let self else { return }
                self.model = self.model.updated(image: image)
                self.triggerReload(completion: nil)
            }
            .store(in: &cancellables)

        adapter.$displayImageCompletionState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                defer {
                    DispatchQueue.main.async { [weak adapter] in
                        adapter?.displayImageCompletionState = nil
                    }
                }
                self.model = self.model.updated(image: state.image)
                self.triggerReload(completion: state.completion)
            }
            .store(in: &cancellables)

        adapter.$displayAlphaState
            .compactMap { $0?.alpha }
            .sink { [weak self] alpha in
                self?.model = self?.model.updated(alpha: alpha) ?? .init()
            }
            .store(in: &cancellables)

        adapter.$displaySizeState
            .compactMap { $0?.size }
            .sink { [weak self] size in
                guard let self else { return }
                self.model = self.model.updated(size: size)
            }
            .store(in: &cancellables)

        adapter.$displayBorderColorState
            .compactMap { $0?.borderColor }
            .sink { [weak self] borderColor in
                guard let self else { return }
                self.model = self.model.updated(borderColor: borderColor)
            }
            .store(in: &cancellables)

        adapter.$displayBorderWidthState
            .compactMap { $0?.borderWidth }
            .sink { [weak self] borderWidth in
                guard let self else { return }
                self.model = self.model.updated(borderWidth: borderWidth)
            }
            .store(in: &cancellables)

        adapter.$displayCornerRadiusState
            .compactMap { $0?.cornerRadius }
            .sink { [weak self] cornerRadius in
                guard let self else { return }
                self.model = self.model.updated(cornerRadius: cornerRadius)
            }
            .store(in: &cancellables)

        adapter.$displayOnPressState
            .compactMap { $0?.onPress }
            .sink { [weak self] onPress in
                guard let self else { return }
                self.model = self.model.updated(onPress: onPress)
            }
            .store(in: &cancellables)

        adapter.$displayOnLongPressState
            .compactMap { $0?.onLongPress }
            .sink { [weak self] onLongPress in
                guard let self else { return }
                self.model = self.model.updated(onLongPress: onLongPress)
            }
            .store(in: &cancellables)

        adapter.$displayContentModeIsFitState
            .compactMap { $0?.contentModeIsFit }
            .sink { [weak self] isFit in
                guard let self else { return }
                self.model = self.model.updated(contentModeIsFit: isFit)
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0?.isHidden }
            .sink { [weak self] isHidden in
                self?.isHidden = isHidden
            }
            .store(in: &cancellables)
    }

    private func triggerReload(completion: ((Image?) -> Void)?) {
        pendingCompletion = completion
        reloadToken = UUID()
    }
}

#endif
