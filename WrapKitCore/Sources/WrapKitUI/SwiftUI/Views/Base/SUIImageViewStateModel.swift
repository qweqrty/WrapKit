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
    private struct OutputReplayCheckpoint {
        let model: ImageViewPresentableModel
        let isHidden: Bool
        let reloadToken: UUID
        let pendingCompletion: ((Image?) -> Void)?
    }

    @Published private(set) var model: ImageViewPresentableModel = .init()
    @Published private(set) var isHidden = false
    @Published private(set) var reloadToken = UUID()

    private(set) var pendingCompletion: ((Image?) -> Void)?
    private let adapter: ImageViewOutputSwiftUIAdapter?
    private var outputReplayConsumer: ImageViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables = Set<AnyCancellable>()
    private var latestAccessibilityOutputSequence: UInt64 = 0
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestImageOutputSequence: UInt64 = 0
    private var latestSizeOutputSequence: UInt64 = 0
    private var latestOnPressOutputSequence: UInt64 = 0
    private var latestOnLongPressOutputSequence: UInt64 = 0
    private var latestContentModeOutputSequence: UInt64 = 0
    private var latestBorderWidthOutputSequence: UInt64 = 0
    private var latestBorderColorOutputSequence: UInt64 = 0
    private var latestCornerRadiusOutputSequence: UInt64 = 0
    private var latestAlphaOutputSequence: UInt64 = 0
    private var latestInputRevision: UUID?

    init(adapter: ImageViewOutputSwiftUIAdapter) {
        self.adapter = adapter
        observeAdapter()
    }

    init(model: ImageViewPresentableModel) {
        self.adapter = nil
        apply(model: model)
    }

    func apply(model: ImageViewPresentableModel) {
        let previousImage = self.model.image
        isHidden = false
        self.model = self.model.mergingFullModel(model)
        if previousImage != self.model.image {
            triggerReload(completion: nil)
        } else {
            persistReplayCheckpoint()
        }
    }

    func apply(model: ImageViewPresentableModel, inputRevision: UUID) {
        guard latestInputRevision != inputRevision else { return }
        latestInputRevision = inputRevision
        apply(model: model)
    }

    func takePendingCompletion() -> ((Image?) -> Void)? {
        let completion = pendingCompletion
        pendingCompletion = nil
        persistReplayCheckpoint()
        return completion
    }

    func performPress() {
        model.onPress?()
    }

    func performLongPress() {
        model.onLongPress?()
    }

    private func observeAdapter() {
        guard let adapter else { return }
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)

        adapter.outputReplayPublisher(
            adapter.$displayModelState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    model: state.model,
                    completion: nil,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayModelCompletionState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                self.apply(
                    model: state.model,
                    completion: state.completion,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayImageState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    image: state.image,
                    completion: nil,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayImageCompletionState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                self.apply(
                    image: state.image,
                    completion: state.completion,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayAlphaState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let alpha = state.alpha else { return }
                self?.apply(alpha: alpha, outputSequence: state.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySizeState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let size = state.size else { return }
                self?.apply(size: size, outputSequence: state.outputSequence)
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBorderColorState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    borderColor: state.borderColor,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBorderWidthState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let borderWidth = state.borderWidth else { return }
                self?.apply(
                    borderWidth: borderWidth,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayCornerRadiusState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let cornerRadius = state.cornerRadius else { return }
                self?.apply(
                    cornerRadius: cornerRadius,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnPressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    onPress: state.onPress,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnLongPressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    onLongPress: state.onLongPress,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayContentModeIsFitState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    contentModeIsFit: state.contentModeIsFit,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(
                    isHidden: state.isHidden,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayCheckpointRequestPublisher(consumer: outputReplayConsumer)
            .sink { [weak self] in self?.persistReplayCheckpoint() }
            .store(in: &cancellables)

        if let outputReplayCheckpoint {
            restore(outputReplayCheckpoint)
        }

        bufferedOutputReplayPublisher
            .sink { [weak adapter] event in
                adapter?.replayOutputEvent(event, consumer: outputReplayConsumer)
            }
            .store(in: &cancellables)

        persistReplayCheckpoint()
    }

    private func apply(
        model: ImageViewPresentableModel?,
        completion: ((Image?) -> Void)?,
        outputSequence: UInt64
    ) {
        apply(isHidden: model == nil, outputSequence: outputSequence)
        apply(
            accessibilityIdentifier: model?.accessibilityIdentifier,
            accessibility: model?.accessibility,
            outputSequence: outputSequence
        )
        if let model {
            apply(
                image: model.image,
                completion: completion,
                outputSequence: outputSequence
            )
        } else if apply(
            image: nil,
            completion: nil,
            outputSequence: outputSequence
        ) {
            completion?(nil)
        }
        apply(onPress: model?.onPress, outputSequence: outputSequence)
        apply(onLongPress: model?.onLongPress, outputSequence: outputSequence)

        guard let model else { return }

        if let size = resolvedSize(for: model) {
            apply(size: size, outputSequence: outputSequence)
        }
        if let contentModeIsFit = model.contentModeIsFit {
            apply(
                contentModeIsFit: contentModeIsFit,
                outputSequence: outputSequence
            )
        }
        if let borderWidth = model.borderWidth {
            apply(borderWidth: borderWidth, outputSequence: outputSequence)
        }
        if let borderColor = model.borderColor {
            apply(borderColor: borderColor, outputSequence: outputSequence)
        }
        if let cornerRadius = model.cornerRadius {
            apply(cornerRadius: cornerRadius, outputSequence: outputSequence)
        }
        if let alpha = model.alpha {
            apply(alpha: alpha, outputSequence: outputSequence)
        }
    }

    private func apply(
        accessibilityIdentifier: String?,
        accessibility: Accessibility?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestAccessibilityOutputSequence else { return }
        latestAccessibilityOutputSequence = outputSequence
        model = ImageViewPresentableModel(
            accessibilityIdentifier: accessibilityIdentifier,
            accessibility: accessibility,
            size: model.size,
            image: model.image,
            onPress: model.onPress,
            onLongPress: model.onLongPress,
            contentModeIsFit: model.contentModeIsFit,
            borderWidth: model.borderWidth,
            borderColor: model.borderColor,
            cornerRadius: model.cornerRadius,
            alpha: model.alpha
        )
        persistReplayCheckpoint()
    }

    private func apply(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    @discardableResult
    private func apply(
        image: ImageEnum?,
        completion: ((Image?) -> Void)?,
        outputSequence: UInt64
    ) -> Bool {
        guard outputSequence >= latestImageOutputSequence else { return false }
        latestImageOutputSequence = outputSequence
        model = model.replacingImage(image)
        triggerReload(completion: completion)
        return true
    }

    private func apply(size: CGSize, outputSequence: UInt64) {
        guard outputSequence >= latestSizeOutputSequence else { return }
        latestSizeOutputSequence = outputSequence
        model = model.updated(size: size)
        persistReplayCheckpoint()
    }

    private func apply(onPress: (() -> Void)?, outputSequence: UInt64) {
        guard outputSequence >= latestOnPressOutputSequence else { return }
        latestOnPressOutputSequence = outputSequence
        model = model.replacingOnPress(onPress)
        persistReplayCheckpoint()
    }

    private func apply(onLongPress: (() -> Void)?, outputSequence: UInt64) {
        guard outputSequence >= latestOnLongPressOutputSequence else { return }
        latestOnLongPressOutputSequence = outputSequence
        model = model.replacingOnLongPress(onLongPress)
        persistReplayCheckpoint()
    }

    private func apply(contentModeIsFit: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestContentModeOutputSequence else { return }
        latestContentModeOutputSequence = outputSequence
        model = model.updated(contentModeIsFit: contentModeIsFit)
        persistReplayCheckpoint()
    }

    private func apply(borderWidth: CGFloat, outputSequence: UInt64) {
        guard outputSequence >= latestBorderWidthOutputSequence else { return }
        latestBorderWidthOutputSequence = outputSequence
        model = model.updated(borderWidth: borderWidth)
        persistReplayCheckpoint()
    }

    private func apply(borderColor: Color?, outputSequence: UInt64) {
        guard outputSequence >= latestBorderColorOutputSequence else { return }
        latestBorderColorOutputSequence = outputSequence
        model = model.replacingBorderColor(borderColor)
        persistReplayCheckpoint()
    }

    private func apply(cornerRadius: CGFloat, outputSequence: UInt64) {
        guard outputSequence >= latestCornerRadiusOutputSequence else { return }
        latestCornerRadiusOutputSequence = outputSequence
        model = model.updated(cornerRadius: cornerRadius)
        persistReplayCheckpoint()
    }

    private func apply(alpha: CGFloat, outputSequence: UInt64) {
        guard outputSequence >= latestAlphaOutputSequence else { return }
        latestAlphaOutputSequence = outputSequence
        model = model.updated(alpha: alpha)
        persistReplayCheckpoint()
    }

    private func resolvedSize(for model: ImageViewPresentableModel) -> CGSize? {
        if let size = model.size {
            return size
        }
        switch model.image {
        case .asset(let image):
            return image?.size
        case .symbolName(let name):
            return ImageFactory.systemImage(named: name)?.size
        case .data, .url, .urlString, nil:
            return nil
        }
    }

    private func triggerReload(completion: ((Image?) -> Void)?) {
        pendingCompletion = completion
        reloadToken = UUID()
        persistReplayCheckpoint()
    }

    private func persistReplayCheckpoint() {
        adapter?.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            model: model,
            isHidden: isHidden,
            reloadToken: reloadToken,
            pendingCompletion: pendingCompletion
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        model = checkpoint.model
        isHidden = checkpoint.isHidden
        reloadToken = checkpoint.reloadToken
        pendingCompletion = checkpoint.pendingCompletion
    }
}

#endif
