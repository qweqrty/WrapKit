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
public class SearchBarOutputSwiftUIAdapter: ObservableObject, SearchBarOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
        case displayTextField(DisplayTextFieldState)
        case displayLeftView(DisplayLeftViewState)
        case displayRightView(DisplayRightViewState)
        case displayPlaceholder(DisplayPlaceholderState)
        case displayBackgroundColor(DisplayBackgroundColorState)
        case displaySpacing(DisplaySpacingState)
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
        case .displayTextField(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeftView(let state):
            outputReplayStateDelivery.send(state)
        case .displayRightView(let state):
            outputReplayStateDelivery.send(state)
        case .displayPlaceholder(let state):
            outputReplayStateDelivery.send(state)
        case .displayBackgroundColor(let state):
            outputReplayStateDelivery.send(state)
        case .displaySpacing(let state):
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
        public let model: SearchBarPresentableModel?
        let textFieldReplayModel: SwiftUIOutputReplayConsumableValue<TextInputPresentableModel>?
    }
    public func display(model: SearchBarPresentableModel?) {
        requireMainOutputReplayQueue()
        let preparedModel = outputReplayClosureStore.prepareSearchBarModel(model)
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: preparedModel.retainedModel,
            textFieldReplayModel: preparedModel.textField?.consumableModel
        )
    }
    @Published public var displayTextFieldState: DisplayTextFieldState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTextField(state))
        }
        didSet {
            guard displayTextFieldState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTextFieldState {
        let outputSequence: UInt64
        public let textField: TextInputPresentableModel?
        let textFieldReplayModel: SwiftUIOutputReplayConsumableValue<TextInputPresentableModel>?
    }
    public func display(textField: TextInputPresentableModel?) {
        requireMainOutputReplayQueue()
        let preparedTextField = outputReplayClosureStore.prepareSearchTextField(textField)
        nextOutputSequence &+= 1
        displayTextFieldState = .init(
            outputSequence: nextOutputSequence,
            textField: preparedTextField?.retainedModel,
            textFieldReplayModel: preparedTextField?.consumableModel
        )
    }
    @Published public var displayLeftViewState: DisplayLeftViewState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeftView(state))
        }
        didSet {
            guard displayLeftViewState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeftViewState {
        let outputSequence: UInt64
        public let leftView: ButtonPresentableModel?
    }
    public func display(leftView: ButtonPresentableModel?) {
        requireMainOutputReplayQueue()
        let leftView = outputReplayClosureStore.sanitize(
            leftView,
            path: "leftView"
        )
        nextOutputSequence &+= 1
        displayLeftViewState = .init(
            outputSequence: nextOutputSequence,
            leftView: leftView
        )
    }
    @Published public var displayRightViewState: DisplayRightViewState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayRightView(state))
        }
        didSet {
            guard displayRightViewState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayRightViewState {
        let outputSequence: UInt64
        public let rightView: ButtonPresentableModel?
    }
    public func display(rightView: ButtonPresentableModel?) {
        requireMainOutputReplayQueue()
        let rightView = outputReplayClosureStore.sanitize(
            rightView,
            path: "rightView"
        )
        nextOutputSequence &+= 1
        displayRightViewState = .init(
            outputSequence: nextOutputSequence,
            rightView: rightView
        )
    }
    @Published public var displayPlaceholderState: DisplayPlaceholderState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayPlaceholder(state))
        }
        didSet {
            guard displayPlaceholderState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayPlaceholderState {
        let outputSequence: UInt64
        public let placeholder: String?
    }
    public func display(placeholder: String?) {
        requireMainOutputReplayQueue()
        let placeholder = outputReplayClosureStore.sanitize(
            placeholder,
            path: "placeholder"
        )
        nextOutputSequence &+= 1
        displayPlaceholderState = .init(
            outputSequence: nextOutputSequence,
            placeholder: placeholder
        )
    }
    @Published public var displayBackgroundColorState: DisplayBackgroundColorState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBackgroundColor(state))
        }
        didSet {
            guard displayBackgroundColorState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBackgroundColorState {
        let outputSequence: UInt64
        public let backgroundColor: Color?
    }
    public func display(backgroundColor: Color?) {
        requireMainOutputReplayQueue()
        let backgroundColor = outputReplayClosureStore.sanitize(
            backgroundColor,
            path: "backgroundColor"
        )
        nextOutputSequence &+= 1
        displayBackgroundColorState = .init(
            outputSequence: nextOutputSequence,
            backgroundColor: backgroundColor
        )
    }
    @Published public var displaySpacingState: DisplaySpacingState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySpacing(state))
        }
        didSet {
            guard displaySpacingState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySpacingState {
        let outputSequence: UInt64
        public let spacing: CGFloat
    }
    public func display(spacing: CGFloat) {
        requireMainOutputReplayQueue()
        let spacing = outputReplayClosureStore.sanitize(
            spacing,
            path: "spacing"
        )
        nextOutputSequence &+= 1
        displaySpacingState = .init(
            outputSequence: nextOutputSequence,
            spacing: spacing
        )
    }
}
