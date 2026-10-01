//
//  SUIButtonStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 15/4/26.
//

import Combine
import Foundation

public final class SUIButtonStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let presentable: ButtonPresentableModel
        let isHidden: Bool
        let isEnabled: Bool
    }

    @Published var presentable: ButtonPresentableModel = .init()
    @Published var isHidden: Bool = false
    @Published var isEnabled: Bool = true
    @Published var isLoading: Bool = false

    private let adapter: ButtonOutputSwiftUIAdapter

    private var outputReplayConsumer: ButtonOutputSwiftUIAdapter.OutputReplayConsumer?

    private var cancellables: Set<AnyCancellable> = []
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestEnabledOutputSequence: UInt64 = 0
    private var latestTitleOutputSequence: UInt64 = 0
    private var latestImageOutputSequence: UInt64 = 0
    private var latestStyleOutputSequence: UInt64 = 0
    private var latestSpacingOutputSequence: UInt64 = 0
    private var latestHeightOutputSequence: UInt64 = 0
    private var latestOnPressOutputSequence: UInt64 = 0
    
    public init(
        adapter: ButtonOutputSwiftUIAdapter,
        loadingAdapter: LoadingOutputSwiftUIAdapter? = nil
    ) {
        self.adapter = adapter
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
            .sink { [weak self] value in
                self?.apply(
                    model: value.model,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    isHidden: value.isHidden,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayEnabledState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    enabled: value.enabled,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayTitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    title: value.title,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayImageState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    image: value.image,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayStyleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let style = value.style else { return }
                self?.apply(
                    style: style,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displaySpacingState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    spacing: value.spacing,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayHeightState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    height: value.height,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayOnPressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    onPress: value.onPress,
                    outputSequence: value.outputSequence
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
        
        loadingAdapter?.$isLoading
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value
            }
            .store(in: &cancellables)
    }
}

private extension SUIButtonStateModel {
    func apply(
        model: ButtonPresentableModel?,
        outputSequence: UInt64
    ) {
        let current = presentable
        presentable = ButtonPresentableModel(
            accessibilityIdentifier: model?.accessibilityIdentifier,
            accessibility: model?.accessibility,
            title: current.title,
            image: current.image,
            spacing: current.spacing,
            height: current.height,
            width: model?.width ?? current.width,
            style: current.style,
            enabled: current.enabled,
            onPress: current.onPress
        )

        apply(isHidden: model == nil, outputSequence: outputSequence)
        apply(title: model?.title, outputSequence: outputSequence)
        apply(image: model?.image, outputSequence: outputSequence)
        apply(onPress: model?.onPress, outputSequence: outputSequence)

        if let spacing = model?.spacing {
            apply(spacing: spacing, outputSequence: outputSequence)
        }
        if let height = model?.height {
            apply(height: height, outputSequence: outputSequence)
        }
        if let style = model?.style {
            apply(style: style, outputSequence: outputSequence)
        }
        if let enabled = model?.enabled {
            apply(enabled: enabled, outputSequence: outputSequence)
        }
    }

    func apply(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    func apply(enabled: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestEnabledOutputSequence else { return }
        latestEnabledOutputSequence = outputSequence
        isEnabled = enabled
        presentable = presentable.merging(enabled: enabled)
        persistReplayCheckpoint()
    }

    func apply(title: String?, outputSequence: UInt64) {
        guard outputSequence >= latestTitleOutputSequence else { return }
        latestTitleOutputSequence = outputSequence
        presentable = presentable.merging(title: title)
        persistReplayCheckpoint()
    }

    func apply(image: Image?, outputSequence: UInt64) {
        guard outputSequence >= latestImageOutputSequence else { return }
        latestImageOutputSequence = outputSequence
        presentable = presentable.merging(image: image)
        persistReplayCheckpoint()
    }

    func apply(style: ButtonStyle, outputSequence: UInt64) {
        guard outputSequence >= latestStyleOutputSequence else { return }
        latestStyleOutputSequence = outputSequence
        presentable = presentable.merging(style: style)
        persistReplayCheckpoint()
    }

    func apply(spacing: CGFloat, outputSequence: UInt64) {
        guard outputSequence >= latestSpacingOutputSequence else { return }
        latestSpacingOutputSequence = outputSequence
        presentable = presentable.merging(spacing: spacing)
        persistReplayCheckpoint()
    }

    func apply(height: CGFloat, outputSequence: UInt64) {
        guard outputSequence >= latestHeightOutputSequence else { return }
        latestHeightOutputSequence = outputSequence
        presentable = presentable.merging(height: height)
        persistReplayCheckpoint()
    }

    func apply(onPress: (() -> Void)?, outputSequence: UInt64) {
        guard outputSequence >= latestOnPressOutputSequence else { return }
        latestOnPressOutputSequence = outputSequence
        presentable = presentable.merging(onPress: onPress)
        persistReplayCheckpoint()
    }

    func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            presentable: presentable.merging(enabled: isEnabled),
            isHidden: isHidden,
            isEnabled: isEnabled
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        presentable = checkpoint.presentable
        isHidden = checkpoint.isHidden
        isEnabled = checkpoint.isEnabled
    }
}

private extension ButtonPresentableModel {
    func merging(
        title: String?? = .none,
        image: Image?? = .none,
        style: ButtonStyle?? = .none,
        spacing: CGFloat? = nil,
        height: CGFloat? = nil,
        enabled: Bool? = nil,
        onPress: (() -> Void)?? = .none
    ) -> ButtonPresentableModel {
        ButtonPresentableModel(
            accessibilityIdentifier: self.accessibilityIdentifier,
            accessibility: self.accessibility,
            title: title ?? self.title,
            image: image ?? self.image,
            spacing: spacing ?? self.spacing,
            height: height ?? self.height,
            width: self.width,
            style: style ?? self.style,
            enabled: enabled ?? self.enabled,
            onPress: onPress ?? self.onPress
        )
    }
}
