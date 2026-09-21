// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(Dispatch)
import Dispatch
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
public class SwitchCotrolOutputSwiftUIAdapter: ObservableObject, SwitchCotrolOutput, LoadingOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()

    @Published public var isLoading: Bool? = nil {
        willSet { dispatchPrecondition(condition: .onQueue(.main)) }
    }

    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayIsLoading(DisplayIsLoadingState)
        case displayModel(DisplayModelState)
        case displayOnPress(DisplayOnPressState)
        case displayIsOn(DisplayIsOnState)
        case displayStyle(DisplayStyleState)
        case displayIsEnabled(DisplayIsEnabledState)
        case displayIsHidden(DisplayIsHiddenState)
    }

    private var bufferedOutputReplayEvents: [OutputReplayEvent] = []
    private var isBufferingOutputReplayEvents = true
    private var outputReplayCheckpointStorage: Any?
    private var pendingOutputReplayCheckpointStorage: Any?
    private var outputReplayDeliveryDepth = 0
    private var nextOutputReplayConsumerGeneration: UInt64 = 0
    private var activeOutputReplayConsumerGeneration: UInt64 = 0
    private let outputReplayCheckpointRequest = PassthroughSubject<Void, Never>()
    private let outputReplayStateDelivery = PassthroughSubject<Any, Never>()

    struct OutputReplayConsumer {
        fileprivate let generation: UInt64
    }

    func claimOutputReplayConsumer() -> OutputReplayConsumer {
        requireMainOutputReplayQueue()
        nextOutputReplayConsumerGeneration &+= 1
        activeOutputReplayConsumerGeneration = nextOutputReplayConsumerGeneration
        return OutputReplayConsumer(generation: activeOutputReplayConsumerGeneration)
    }

    func outputReplayPublisher<State>(
        _ publisher: Published<State?>.Publisher,
        consumer: OutputReplayConsumer
    ) -> AnyPublisher<State?, Never> {
        requireMainOutputReplayQueue()
        let livePublisher = publisher
            .dropFirst()
            .eraseToAnyPublisher()
        let replayPublisher = outputReplayStateDelivery
            .compactMap { $0 as? State }
            .map(Optional.some)
            .eraseToAnyPublisher()
        return Publishers.Merge(livePublisher, replayPublisher)
            .filter { [weak self] _ in
                self?.isActiveOutputReplayConsumer(consumer) == true
            }
            .eraseToAnyPublisher()
    }

    func activeOutputReplayPublisher<Value>(
        _ publisher: Published<Value>.Publisher,
        consumer: OutputReplayConsumer,
        dropFirst: Bool
    ) -> AnyPublisher<Value, Never> {
        requireMainOutputReplayQueue()
        let publisher = dropFirst
            ? publisher.dropFirst().eraseToAnyPublisher()
            : publisher.eraseToAnyPublisher()
        return publisher
            .filter { [weak self] _ in
                self?.isActiveOutputReplayConsumer(consumer) == true
            }
            .eraseToAnyPublisher()
    }

    func bufferedOutputReplayPublisher(
        consumer: OutputReplayConsumer
    ) -> AnyPublisher<OutputReplayEvent, Never> {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        guard isBufferingOutputReplayEvents else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        isBufferingOutputReplayEvents = false
        let events = bufferedOutputReplayEvents
        bufferedOutputReplayEvents.removeAll(keepingCapacity: false)
        return events.publisher.eraseToAnyPublisher()
    }

    func replayOutputEvent(
        _ event: OutputReplayEvent,
        consumer: OutputReplayConsumer
    ) {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else { return }
        beginOutputReplayDelivery(event)
        switch event {
        case .displayIsLoading(let state):
            outputReplayStateDelivery.send(state)
        case .displayModel(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsOn(let state):
            outputReplayStateDelivery.send(state)
        case .displayStyle(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsEnabled(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsHidden(let state):
            outputReplayStateDelivery.send(state)
        }
        finishOutputReplayDelivery()
    }

    private func bufferOutputReplayEvent(_ event: OutputReplayEvent) {
        guard isBufferingOutputReplayEvents else { return }
        bufferedOutputReplayEvents.append(event)
    }

    private func beginOutputReplayDelivery(_ event: OutputReplayEvent) {
        requireMainOutputReplayQueue()
        outputReplayDeliveryDepth += 1
        bufferOutputReplayEvent(event)
    }

    private func finishOutputReplayDelivery() {
        requireMainOutputReplayQueue()
        outputReplayCheckpointRequest.send(())
        outputReplayDeliveryDepth -= 1
        if outputReplayDeliveryDepth == 0,
           let checkpoint = pendingOutputReplayCheckpointStorage {
            pendingOutputReplayCheckpointStorage = nil
            commitOutputReplayCheckpoint(checkpoint)
        }
    }

    private func requireMainOutputReplayQueue() {
        dispatchPrecondition(condition: .onQueue(.main))
    }

    func isActiveOutputReplayConsumer(_ consumer: OutputReplayConsumer?) -> Bool {
        requireMainOutputReplayQueue()
        guard let consumer else { return false }
        return consumer.generation == activeOutputReplayConsumerGeneration
    }

    func outputReplayCheckpoint<Checkpoint>(
        as _: Checkpoint.Type,
        consumer: OutputReplayConsumer
    ) -> Checkpoint? {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else { return nil }
        return outputReplayCheckpointStorage as? Checkpoint
    }

    func updateOutputReplayCheckpoint<Checkpoint>(
        consumer: OutputReplayConsumer?,
        _ checkpoint: Checkpoint
    ) {
        requireMainOutputReplayQueue()
        guard let consumer, isActiveOutputReplayConsumer(consumer) else { return }
        if outputReplayDeliveryDepth > 0 {
            pendingOutputReplayCheckpointStorage = checkpoint
            return
        }
        commitOutputReplayCheckpoint(checkpoint)
    }

    private func commitOutputReplayCheckpoint(_ checkpoint: Any) {
        requireMainOutputReplayQueue()
        outputReplayCheckpointStorage = checkpoint
        bufferedOutputReplayEvents.removeAll(keepingCapacity: true)
        isBufferingOutputReplayEvents = true
    }

    func outputReplayCheckpointRequestPublisher(
        consumer: OutputReplayConsumer
    ) -> AnyPublisher<Void, Never> {
        requireMainOutputReplayQueue()
        return outputReplayCheckpointRequest
            .filter { [weak self] in
                self?.isActiveOutputReplayConsumer(consumer) == true
            }
            .eraseToAnyPublisher()
    }



    @Published public var displayIsLoadingState: DisplayIsLoadingState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsLoading(state))
        }
        didSet {
            guard displayIsLoadingState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsLoadingState {
        let outputSequence: UInt64
        public let isLoading: Bool
    }
    public func display(isLoading: Bool) {
        requireMainOutputReplayQueue()
        self.isLoading = isLoading
        nextOutputSequence &+= 1
        displayIsLoadingState = .init(
            outputSequence: nextOutputSequence,
            isLoading: isLoading
        )
    }

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayModel(state))
        }
        didSet {
            guard displayModelState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayModelState {
        let outputSequence: UInt64
        public let model: SwitchControlPresentableModel?
    }
    public func display(model: SwitchControlPresentableModel?) {
        requireMainOutputReplayQueue()
        let model = outputReplayClosureStore.sanitize(
            model,
            path: "model"
        )
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnPress(state))
        }
        didSet {
            guard displayOnPressState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnPressState {
        let outputSequence: UInt64
        public let onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?
    }
    public func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?) {
        requireMainOutputReplayQueue()
        let onPress = outputReplayClosureStore.sanitizePersistentAction(
            onPress,
            path: "onPress"
        )
        nextOutputSequence &+= 1
        displayOnPressState = .init(
            outputSequence: nextOutputSequence,
            onPress: onPress
        )
    }
    @Published public var displayIsOnState: DisplayIsOnState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsOn(state))
        }
        didSet {
            guard displayIsOnState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsOnState {
        let outputSequence: UInt64
        public let isOn: Bool
    }
    public func display(isOn: Bool) {
        requireMainOutputReplayQueue()
        let isOn = outputReplayClosureStore.sanitize(
            isOn,
            path: "isOn"
        )
        nextOutputSequence &+= 1
        displayIsOnState = .init(
            outputSequence: nextOutputSequence,
            isOn: isOn
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayStyle(state))
        }
        didSet {
            guard displayStyleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayStyleState {
        let outputSequence: UInt64
        public let style: SwitchControlPresentableModel.Style?
    }
    public func display(style: SwitchControlPresentableModel.Style?) {
        requireMainOutputReplayQueue()
        let style = outputReplayClosureStore.sanitize(
            style,
            path: "style"
        )
        nextOutputSequence &+= 1
        displayStyleState = .init(
            outputSequence: nextOutputSequence,
            style: style
        )
    }
    @Published public var displayIsEnabledState: DisplayIsEnabledState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsEnabled(state))
        }
        didSet {
            guard displayIsEnabledState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsEnabledState {
        let outputSequence: UInt64
        public let isEnabled: Bool
    }
    public func display(isEnabled: Bool) {
        requireMainOutputReplayQueue()
        let isEnabled = outputReplayClosureStore.sanitize(
            isEnabled,
            path: "isEnabled"
        )
        nextOutputSequence &+= 1
        displayIsEnabledState = .init(
            outputSequence: nextOutputSequence,
            isEnabled: isEnabled
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsHidden(state))
        }
        didSet {
            guard displayIsHiddenState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsHiddenState {
        let outputSequence: UInt64
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        requireMainOutputReplayQueue()
        let isHidden = outputReplayClosureStore.sanitize(
            isHidden,
            path: "isHidden"
        )
        nextOutputSequence &+= 1
        displayIsHiddenState = .init(
            outputSequence: nextOutputSequence,
            isHidden: isHidden
        )
    }
}
