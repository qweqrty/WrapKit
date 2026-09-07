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
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
public class TitledOutputSwiftUIAdapter: ObservableObject, TitledOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
        case displayTitles(DisplayTitlesState)
        case displayBottomTitles(DisplayBottomTitlesState)
        case displayLeadingBottomTitle(DisplayLeadingBottomTitleState)
        case displayTrailingBottomTitle(DisplayTrailingBottomTitleState)
        case displayIsUserInteractionEnabled(DisplayIsUserInteractionEnabledState)
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
        case .displayTitles(let state):
            outputReplayStateDelivery.send(state)
        case .displayBottomTitles(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeadingBottomTitle(let state):
            outputReplayStateDelivery.send(state)
        case .displayTrailingBottomTitle(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsUserInteractionEnabled(let state):
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
        public let outputSequence: UInt64
        public let model: TitledViewPresentableModel?
    }
    public func display(model: TitledViewPresentableModel?) {
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
    @Published public var displayTitlesState: DisplayTitlesState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTitles(state))
        }
        didSet {
            guard displayTitlesState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTitlesState {
        public let outputSequence: UInt64
        public let titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        requireMainOutputReplayQueue()
        let titles = outputReplayClosureStore.sanitize(
            titles,
            path: "titles"
        )
        nextOutputSequence &+= 1
        displayTitlesState = .init(
            outputSequence: nextOutputSequence,
            titles: titles
        )
    }
    @Published public var displayBottomTitlesState: DisplayBottomTitlesState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBottomTitles(state))
        }
        didSet {
            guard displayBottomTitlesState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBottomTitlesState {
        public let outputSequence: UInt64
        public let bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        requireMainOutputReplayQueue()
        let bottomTitles = outputReplayClosureStore.sanitize(
            bottomTitles,
            path: "bottomTitles"
        )
        nextOutputSequence &+= 1
        displayBottomTitlesState = .init(
            outputSequence: nextOutputSequence,
            bottomTitles: bottomTitles
        )
    }
    @Published public var displayLeadingBottomTitleState: DisplayLeadingBottomTitleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeadingBottomTitle(state))
        }
        didSet {
            guard displayLeadingBottomTitleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeadingBottomTitleState {
        public let outputSequence: UInt64
        public let leadingBottomTitle: TextOutputPresentableModel?
    }
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        requireMainOutputReplayQueue()
        let leadingBottomTitle = outputReplayClosureStore.sanitize(
            leadingBottomTitle,
            path: "bottomTitles.first"
        )
        nextOutputSequence &+= 1
        displayLeadingBottomTitleState = .init(
            outputSequence: nextOutputSequence,
            leadingBottomTitle: leadingBottomTitle
        )
    }
    @Published public var displayTrailingBottomTitleState: DisplayTrailingBottomTitleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTrailingBottomTitle(state))
        }
        didSet {
            guard displayTrailingBottomTitleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTrailingBottomTitleState {
        public let outputSequence: UInt64
        public let trailingBottomTitle: TextOutputPresentableModel?
    }
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        requireMainOutputReplayQueue()
        let trailingBottomTitle = outputReplayClosureStore.sanitize(
            trailingBottomTitle,
            path: "bottomTitles.second"
        )
        nextOutputSequence &+= 1
        displayTrailingBottomTitleState = .init(
            outputSequence: nextOutputSequence,
            trailingBottomTitle: trailingBottomTitle
        )
    }
    @Published public var displayIsUserInteractionEnabledState: DisplayIsUserInteractionEnabledState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsUserInteractionEnabled(state))
        }
        didSet {
            guard displayIsUserInteractionEnabledState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsUserInteractionEnabledState {
        public let outputSequence: UInt64
        public let isUserInteractionEnabled: Bool
    }
    public func display(isUserInteractionEnabled: Bool) {
        requireMainOutputReplayQueue()
        let isUserInteractionEnabled = outputReplayClosureStore.sanitize(
            isUserInteractionEnabled,
            path: "isUserInteractionEnabled"
        )
        nextOutputSequence &+= 1
        displayIsUserInteractionEnabledState = .init(
            outputSequence: nextOutputSequence,
            isUserInteractionEnabled: isUserInteractionEnabled
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
        public let outputSequence: UInt64
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
