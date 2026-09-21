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
#if canImport(SwiftUI)
import SwiftUI
#endif
public class HeaderOutputSwiftUIAdapter: ObservableObject, HeaderOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelReplayState)
        case displayStyle(DisplayStyleState)
        case displayCenterView(DisplayCenterViewState)
        case displayLeadingCard(DisplayLeadingCardState)
        case displayPrimeTrailingImage(DisplayPrimeTrailingImageState)
        case displaySecondaryTrailingImage(DisplaySecondaryTrailingImageState)
        case displayTertiaryTrailingImage(DisplayTertiaryTrailingImageState)
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
        case .displayStyle(let state):
            outputReplayStateDelivery.send(state)
        case .displayCenterView(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeadingCard(let state):
            outputReplayStateDelivery.send(state)
        case .displayPrimeTrailingImage(let state):
            outputReplayStateDelivery.send(state)
        case .displaySecondaryTrailingImage(let state):
            outputReplayStateDelivery.send(state)
        case .displayTertiaryTrailingImage(let state):
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
        willSet { dispatchPrecondition(condition: .onQueue(.main)) }
    }
    public struct DisplayModelState {
        let outputSequence: UInt64
        public let model: HeaderPresentableModel
    }
    struct DisplayModelReplayState {
        let outputSequence: UInt64
        let model: HeaderPresentableModel?
    }
    @Published var displayModelReplayState: DisplayModelReplayState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayModel(state))
        }
        didSet {
            guard displayModelReplayState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public func display(model: HeaderPresentableModel?) {
        requireMainOutputReplayQueue()
        let model = outputReplayClosureStore.sanitize(
            model,
            path: "model"
        )
        display(isHidden: model == nil)
        nextOutputSequence &+= 1
        let outputSequence = nextOutputSequence
        displayModelReplayState = .init(
            outputSequence: outputSequence,
            model: model
        )
        guard let model else { return }
        displayModelState = .init(
            outputSequence: outputSequence,
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
        let outputSequence: UInt64
        public let style: HeaderPresentableModel.Style?
    }
    public func display(style: HeaderPresentableModel.Style?) {
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
    @Published public var displayCenterViewState: DisplayCenterViewState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayCenterView(state))
        }
        didSet {
            guard displayCenterViewState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayCenterViewState {
        let outputSequence: UInt64
        public let centerView: HeaderPresentableModel.CenterView?
    }
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        requireMainOutputReplayQueue()
        let centerView = outputReplayClosureStore.sanitize(
            centerView,
            path: "centerView"
        )
        nextOutputSequence &+= 1
        displayCenterViewState = .init(
            outputSequence: nextOutputSequence,
            centerView: centerView
        )
    }
    @Published public var displayLeadingCardState: DisplayLeadingCardState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeadingCard(state))
        }
        didSet {
            guard displayLeadingCardState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeadingCardState {
        let outputSequence: UInt64
        public let leadingCard: CardViewPresentableModel?
    }
    public func display(leadingCard: CardViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let leadingCard = outputReplayClosureStore.sanitize(
            leadingCard,
            path: "leadingCard"
        )
        nextOutputSequence &+= 1
        displayLeadingCardState = .init(
            outputSequence: nextOutputSequence,
            leadingCard: leadingCard
        )
    }
    @Published public var displayPrimeTrailingImageState: DisplayPrimeTrailingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayPrimeTrailingImage(state))
        }
        didSet {
            guard displayPrimeTrailingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayPrimeTrailingImageState {
        let outputSequence: UInt64
        public let primeTrailingImage: ButtonPresentableModel?
    }
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        requireMainOutputReplayQueue()
        let primeTrailingImage = outputReplayClosureStore.sanitize(
            primeTrailingImage,
            path: "primeTrailingImage"
        )
        nextOutputSequence &+= 1
        displayPrimeTrailingImageState = .init(
            outputSequence: nextOutputSequence,
            primeTrailingImage: primeTrailingImage
        )
    }
    @Published public var displaySecondaryTrailingImageState: DisplaySecondaryTrailingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySecondaryTrailingImage(state))
        }
        didSet {
            guard displaySecondaryTrailingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySecondaryTrailingImageState {
        let outputSequence: UInt64
        public let secondaryTrailingImage: ButtonPresentableModel?
    }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        requireMainOutputReplayQueue()
        let secondaryTrailingImage = outputReplayClosureStore.sanitize(
            secondaryTrailingImage,
            path: "secondaryTrailingImage"
        )
        nextOutputSequence &+= 1
        displaySecondaryTrailingImageState = .init(
            outputSequence: nextOutputSequence,
            secondaryTrailingImage: secondaryTrailingImage
        )
    }
    @Published public var displayTertiaryTrailingImageState: DisplayTertiaryTrailingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTertiaryTrailingImage(state))
        }
        didSet {
            guard displayTertiaryTrailingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTertiaryTrailingImageState {
        let outputSequence: UInt64
        public let tertiaryTrailingImage: ButtonPresentableModel?
    }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        requireMainOutputReplayQueue()
        let tertiaryTrailingImage = outputReplayClosureStore.sanitize(
            tertiaryTrailingImage,
            path: "tertiaryTrailingImage"
        )
        nextOutputSequence &+= 1
        displayTertiaryTrailingImageState = .init(
            outputSequence: nextOutputSequence,
            tertiaryTrailingImage: tertiaryTrailingImage
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
