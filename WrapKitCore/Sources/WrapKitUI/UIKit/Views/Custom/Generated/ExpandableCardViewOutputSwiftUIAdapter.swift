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
#if canImport(Combine)
import Combine
#endif
public class ExpandableCardViewOutputSwiftUIAdapter: ObservableObject, ExpandableCardViewOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
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
        case .displayModel(let state):
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
        public let model: Pair<CardViewPresentableModel, CardViewPresentableModel?>
    }
    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
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
