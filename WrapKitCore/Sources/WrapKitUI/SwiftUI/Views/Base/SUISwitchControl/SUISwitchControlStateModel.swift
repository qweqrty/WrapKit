//
//  SUISwitchControlStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/4/26.
//

import Combine

public final class SUISwitchControlStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let isHidden: Bool
        let isOn: Bool
        let isEnabled: Bool
        let isLoading: Bool
        let style: SwitchControlPresentableModel.Style?
        let onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?
        let accessibilityIdentifier: String?
    }

    @Published var isHidden: Bool = false
    @Published var isOn: Bool = false {
        didSet { persistReplayCheckpoint() }
    }
    @Published var isEnabled: Bool = true
    @Published var isLoading: Bool = false
    @Published var style: SwitchControlPresentableModel.Style? = nil
    @Published var onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)? = nil
    @Published var accessibilityIdentifier: String? = nil

    let adapter: SwitchCotrolOutputSwiftUIAdapter

    private var outputReplayConsumer: SwitchCotrolOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestIsOnOutputSequence: UInt64 = 0
    private var latestEnabledOutputSequence: UInt64 = 0
    private var latestStyleOutputSequence: UInt64 = 0
    private var latestOnPressOutputSequence: UInt64 = 0
    private var latestAccessibilityOutputSequence: UInt64 = 0
    
    public init(adapter: SwitchCotrolOutputSwiftUIAdapter) {
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
                self?.display(
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
                self?.display(
                    isHidden: value.isHidden,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayIsOnState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.display(
                    isOn: value.isOn,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayIsEnabledState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.display(
                    isEnabled: value.isEnabled,
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
                self?.display(
                    style: value.style,
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
                self?.display(
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

        adapter.activeOutputReplayPublisher(
            adapter.$isLoading,
            consumer: outputReplayConsumer,
            dropFirst: false
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value
                self?.persistReplayCheckpoint()
            }
            .store(in: &cancellables)

        persistReplayCheckpoint()
    }

}

private extension SUISwitchControlStateModel {
    func display(
        model: SwitchControlPresentableModel?,
        outputSequence: UInt64
    ) {
        display(
            isHidden: model == nil,
            outputSequence: outputSequence
        )
        display(
            onPress: model?.onPress,
            outputSequence: outputSequence
        )

        guard let model else { return }
        if let isOn = model.isOn {
            display(isOn: isOn, outputSequence: outputSequence)
        }
        if let isEnabled = model.isEnabled {
            display(isEnabled: isEnabled, outputSequence: outputSequence)
        }
        if let style = model.style {
            display(style: style, outputSequence: outputSequence)
        }
        if let accessibilityIdentifier = model.accessibilityIdentifier {
            display(
                accessibilityIdentifier: accessibilityIdentifier,
                outputSequence: outputSequence
            )
        }
    }

    func display(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    func display(isOn: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestIsOnOutputSequence else { return }
        latestIsOnOutputSequence = outputSequence
        self.isOn = isOn
        persistReplayCheckpoint()
    }

    func display(isEnabled: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestEnabledOutputSequence else { return }
        latestEnabledOutputSequence = outputSequence
        self.isEnabled = isEnabled
        persistReplayCheckpoint()
    }

    func display(
        style: SwitchControlPresentableModel.Style?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestStyleOutputSequence else { return }
        latestStyleOutputSequence = outputSequence
        self.style = style
        persistReplayCheckpoint()
    }

    func display(
        onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestOnPressOutputSequence else { return }
        latestOnPressOutputSequence = outputSequence
        self.onPress = onPress
        persistReplayCheckpoint()
    }

    func display(
        accessibilityIdentifier: String,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestAccessibilityOutputSequence else { return }
        latestAccessibilityOutputSequence = outputSequence
        self.accessibilityIdentifier = accessibilityIdentifier
        persistReplayCheckpoint()
    }

    func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            isHidden: isHidden,
            isOn: isOn,
            isEnabled: isEnabled,
            isLoading: isLoading,
            style: style,
            onPress: onPress,
            accessibilityIdentifier: accessibilityIdentifier
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isHidden = checkpoint.isHidden
        isOn = checkpoint.isOn
        isEnabled = checkpoint.isEnabled
        isLoading = checkpoint.isLoading
        style = checkpoint.style
        onPress = checkpoint.onPress
        accessibilityIdentifier = checkpoint.accessibilityIdentifier
    }
}
