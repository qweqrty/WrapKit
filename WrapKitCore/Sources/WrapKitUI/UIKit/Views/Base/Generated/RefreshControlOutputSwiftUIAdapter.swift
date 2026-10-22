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
public class RefreshControlOutputSwiftUIAdapter: ObservableObject, RefreshControlOutput, LoadingOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()
    private var currentRefreshCallbacks: [(() -> Void)?] = []

    func refreshCallbacks(consumer: OutputReplayConsumer?) -> [(() -> Void)?] {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else { return [] }
        return currentRefreshCallbacks
    }

    func invokeRefreshCallbacks(consumer: OutputReplayConsumer?) {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else { return }
        // A handler may mutate the collection; UIKit finishes the current raw snapshot.
        let callbacks = onRefresh ?? []
        callbacks.forEach { $0?() }
    }
        @Published public var onRefresh: [(() -> Void)?]? = [] {
            willSet {
                dispatchPrecondition(condition: .onQueue(.main))
            }
            didSet {
                // Keep UIKit's raw mutable array separate from revocable UI/replay copies.
                currentRefreshCallbacks = outputReplayClosureStore.sanitizeRefreshActionsReplacement(
                    onRefresh ?? [],
                    path: "onRefresh"
                )
            }
        }

    @Published public var isLoading: Bool? = nil {
        willSet { dispatchPrecondition(condition: .onQueue(.main)) }
    }

    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
        case displayStyle(DisplayStyleState)
        case displayOnRefresh(DisplayOnRefreshState)
        case displayAppendingOnRefresh(DisplayAppendingOnRefreshState)
        case displayIsLoading(DisplayIsLoadingState)
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
        case .displayModel(let state):
            outputReplayStateDelivery.send(state)
        case .displayStyle(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnRefresh(let state):
            outputReplayStateDelivery.send(state)
        case .displayAppendingOnRefresh(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsLoading(let state):
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
        public let outputSequence: UInt64
        public let model: RefreshControlPresentableModel?
    }
    public func display(model: RefreshControlPresentableModel?) {
        requireMainOutputReplayQueue()
        if self.onRefresh != nil {
            self.onRefresh = [model?.onRefresh]
        }
        let model = model.map {
            RefreshControlPresentableModel(
                style: $0.style,
                onRefresh: currentRefreshCallbacks.first ?? nil,
                isLoading: $0.isLoading
            )
        }
        if let isLoading = model?.isLoading {
            self.isLoading = isLoading
        }
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
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
        public let outputSequence: UInt64
        public let style: RefreshControlPresentableModel.Style
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        requireMainOutputReplayQueue()
        nextOutputSequence &+= 1
        displayStyleState = .init(
            outputSequence: nextOutputSequence,
            style: style
        )
    }
    @Published public var displayOnRefreshState: DisplayOnRefreshState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnRefresh(state))
        }
        didSet {
            guard displayOnRefreshState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnRefreshState {
        let outputSequence: UInt64
        public let onRefresh: (() -> Void)?
    }
    public func display(onRefresh: (() -> Void)?) {
        requireMainOutputReplayQueue()
        if self.onRefresh != nil {
            self.onRefresh = [onRefresh]
        }
        let onRefresh = currentRefreshCallbacks.first ?? nil
        nextOutputSequence &+= 1
        displayOnRefreshState = .init(
            outputSequence: nextOutputSequence,
            onRefresh: onRefresh
        )
    }
    @Published public var displayAppendingOnRefreshState: DisplayAppendingOnRefreshState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayAppendingOnRefresh(state))
        }
        didSet {
            guard displayAppendingOnRefreshState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayAppendingOnRefreshState {
        let outputSequence: UInt64
        public let appendingOnRefresh: (() -> Void)?
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        requireMainOutputReplayQueue()
        self.onRefresh?.append(appendingOnRefresh)
        let appendingOnRefresh = currentRefreshCallbacks.last ?? nil
        nextOutputSequence &+= 1
        displayAppendingOnRefreshState = .init(
            outputSequence: nextOutputSequence,
            appendingOnRefresh: appendingOnRefresh
        )
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
}
