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
public class TextInputOutputSwiftUIAdapter: ObservableObject, TextInputOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
        case displayText(DisplayTextState)
        case startEditing(StartEditingState)
        case stopEditing(StopEditingState)
        case displayMask(DisplayMaskState)
        case displayIsValid(DisplayIsValidState)
        case displayIsEnabledForEditing(DisplayIsEnabledForEditingState)
        case displayIsTextSelectionDisabled(DisplayIsTextSelectionDisabledState)
        case displayPlaceholder(DisplayPlaceholderState)
        case displayIsUserInteractionEnabled(DisplayIsUserInteractionEnabledState)
        case displayIsSecureTextEntry(DisplayIsSecureTextEntryState)
        case displayLeadingViewOnPress(DisplayLeadingViewOnPressState)
        case displayTrailingViewOnPress(DisplayTrailingViewOnPressState)
        case displayOnPress(DisplayOnPressState)
        case displayOnPaste(DisplayOnPasteState)
        case displayOnBecomeFirstResponder(DisplayOnBecomeFirstResponderState)
        case displayOnResignFirstResponder(DisplayOnResignFirstResponderState)
        case displayOnTapBackspace(DisplayOnTapBackspaceState)
        case displayDidChangeText(DisplayDidChangeTextState)
        case displayTrailingViewIsHidden(DisplayTrailingViewIsHiddenState)
        case displayLeadingViewIsHidden(DisplayLeadingViewIsHiddenState)
        case displayIsHidden(DisplayIsHiddenState)
        case displayInputView(DisplayInputViewState)
        case displayInputType(DisplayInputTypeState)
        case displayTrailingSymbol(DisplayTrailingSymbolState)
        case displayInputAccessoryView(DisplayInputAccessoryViewState)
        case displayIsClearButtonActive(DisplayIsClearButtonActiveState)
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
        case .displayText(let state):
            outputReplayStateDelivery.send(state)
        case .startEditing(let state):
            outputReplayStateDelivery.send(state)
        case .stopEditing(let state):
            outputReplayStateDelivery.send(state)
        case .displayMask(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsValid(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsEnabledForEditing(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsTextSelectionDisabled(let state):
            outputReplayStateDelivery.send(state)
        case .displayPlaceholder(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsUserInteractionEnabled(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsSecureTextEntry(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeadingViewOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayTrailingViewOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnPaste(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnBecomeFirstResponder(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnResignFirstResponder(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnTapBackspace(let state):
            outputReplayStateDelivery.send(state)
        case .displayDidChangeText(let state):
            outputReplayStateDelivery.send(state)
        case .displayTrailingViewIsHidden(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeadingViewIsHidden(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsHidden(let state):
            outputReplayStateDelivery.send(state)
        case .displayInputView(let state):
            outputReplayStateDelivery.send(state)
        case .displayInputType(let state):
            outputReplayStateDelivery.send(state)
        case .displayTrailingSymbol(let state):
            outputReplayStateDelivery.send(state)
        case .displayInputAccessoryView(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsClearButtonActive(let state):
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

    func resolveTextInputModelCallbackGroup(
        outputSequence: UInt64,
        path: String,
        accepted: Bool
    ) {
        outputReplayClosureStore.resolveTextInputModelCallbackGroup(
            outputSequence: outputSequence,
            path: path,
            accepted: accepted
        )
    }

    func discardTextInputModelCallbackCandidate(outputSequence: UInt64) {
        outputReplayClosureStore.discardTextInputModelCallbackCandidate(
            outputSequence: outputSequence
        )
    }

    func invalidateTextInputModelCallback(path: String) {
        outputReplayClosureStore.invalidate(path: path)
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
        public let model: TextInputPresentableModel?
    }
    public func display(model: TextInputPresentableModel?) {
        requireMainOutputReplayQueue()
        nextOutputSequence &+= 1
        let outputSequence = nextOutputSequence
        let model = outputReplayClosureStore.prepareTextInputModel(
            model,
            outputSequence: outputSequence
        )
        displayModelState = .init(
            outputSequence: outputSequence,
            model: model
        )
    }
    @Published public var displayTextState: DisplayTextState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayText(state))
        }
        didSet {
            guard displayTextState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTextState {
        let outputSequence: UInt64
        public let text: String?
    }
    public func display(text: String?) {
        requireMainOutputReplayQueue()
        let text = outputReplayClosureStore.sanitize(
            text,
            path: "text"
        )
        nextOutputSequence &+= 1
        displayTextState = .init(
            outputSequence: nextOutputSequence,
            text: text
        )
    }
    @Published public var startEditingState: StartEditingState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.startEditing(state))
        }
        didSet {
            guard startEditingState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct StartEditingState {
        let outputSequence: UInt64
    }
    public func startEditing() {
        requireMainOutputReplayQueue()
        nextOutputSequence &+= 1
        startEditingState = .init(
            outputSequence: nextOutputSequence,
        )
    }
    @Published public var stopEditingState: StopEditingState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.stopEditing(state))
        }
        didSet {
            guard stopEditingState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct StopEditingState {
        let outputSequence: UInt64
    }
    public func stopEditing() {
        requireMainOutputReplayQueue()
        nextOutputSequence &+= 1
        stopEditingState = .init(
            outputSequence: nextOutputSequence,
        )
    }
    @Published public var displayMaskState: DisplayMaskState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayMask(state))
        }
        didSet {
            guard displayMaskState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayMaskState {
        let outputSequence: UInt64
        public let mask: TextInputPresentableModel.Mask
    }
    public func display(mask: TextInputPresentableModel.Mask) {
        requireMainOutputReplayQueue()
        let mask = outputReplayClosureStore.sanitize(
            mask,
            path: "mask"
        )
        nextOutputSequence &+= 1
        displayMaskState = .init(
            outputSequence: nextOutputSequence,
            mask: mask
        )
    }
    @Published public var displayIsValidState: DisplayIsValidState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsValid(state))
        }
        didSet {
            guard displayIsValidState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsValidState {
        let outputSequence: UInt64
        public let isValid: Bool
    }
    public func display(isValid: Bool) {
        requireMainOutputReplayQueue()
        let isValid = outputReplayClosureStore.sanitize(
            isValid,
            path: "isValid"
        )
        nextOutputSequence &+= 1
        displayIsValidState = .init(
            outputSequence: nextOutputSequence,
            isValid: isValid
        )
    }
    @Published public var displayIsEnabledForEditingState: DisplayIsEnabledForEditingState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsEnabledForEditing(state))
        }
        didSet {
            guard displayIsEnabledForEditingState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsEnabledForEditingState {
        let outputSequence: UInt64
        public let isEnabledForEditing: Bool
    }
    public func display(isEnabledForEditing: Bool) {
        requireMainOutputReplayQueue()
        let isEnabledForEditing = outputReplayClosureStore.sanitize(
            isEnabledForEditing,
            path: "isEnabledForEditing"
        )
        nextOutputSequence &+= 1
        displayIsEnabledForEditingState = .init(
            outputSequence: nextOutputSequence,
            isEnabledForEditing: isEnabledForEditing
        )
    }
    @Published public var displayIsTextSelectionDisabledState: DisplayIsTextSelectionDisabledState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsTextSelectionDisabled(state))
        }
        didSet {
            guard displayIsTextSelectionDisabledState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsTextSelectionDisabledState {
        let outputSequence: UInt64
        public let isTextSelectionDisabled: Bool
    }
    public func display(isTextSelectionDisabled: Bool) {
        requireMainOutputReplayQueue()
        let isTextSelectionDisabled = outputReplayClosureStore.sanitize(
            isTextSelectionDisabled,
            path: "isTextSelectionDisabled"
        )
        nextOutputSequence &+= 1
        displayIsTextSelectionDisabledState = .init(
            outputSequence: nextOutputSequence,
            isTextSelectionDisabled: isTextSelectionDisabled
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
        let outputSequence: UInt64
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
    @Published public var displayIsSecureTextEntryState: DisplayIsSecureTextEntryState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsSecureTextEntry(state))
        }
        didSet {
            guard displayIsSecureTextEntryState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsSecureTextEntryState {
        let outputSequence: UInt64
        public let isSecureTextEntry: Bool
    }
    public func display(isSecureTextEntry: Bool) {
        requireMainOutputReplayQueue()
        let isSecureTextEntry = outputReplayClosureStore.sanitize(
            isSecureTextEntry,
            path: "isSecureTextEntry"
        )
        nextOutputSequence &+= 1
        displayIsSecureTextEntryState = .init(
            outputSequence: nextOutputSequence,
            isSecureTextEntry: isSecureTextEntry
        )
    }
    @Published public var displayLeadingViewOnPressState: DisplayLeadingViewOnPressState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeadingViewOnPress(state))
        }
        didSet {
            guard displayLeadingViewOnPressState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeadingViewOnPressState {
        let outputSequence: UInt64
        public let leadingViewOnPress: (() -> Void)?
    }
    public func display(leadingViewOnPress: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let leadingViewOnPress = outputReplayClosureStore.sanitizePersistentAction(
            leadingViewOnPress,
            path: "leadingViewOnPress"
        )
        nextOutputSequence &+= 1
        displayLeadingViewOnPressState = .init(
            outputSequence: nextOutputSequence,
            leadingViewOnPress: leadingViewOnPress
        )
    }
    @Published public var displayTrailingViewOnPressState: DisplayTrailingViewOnPressState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTrailingViewOnPress(state))
        }
        didSet {
            guard displayTrailingViewOnPressState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTrailingViewOnPressState {
        let outputSequence: UInt64
        public let trailingViewOnPress: (() -> Void)?
    }
    public func display(trailingViewOnPress: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let trailingViewOnPress = outputReplayClosureStore.sanitizePersistentAction(
            trailingViewOnPress,
            path: "trailingViewOnPress"
        )
        nextOutputSequence &+= 1
        displayTrailingViewOnPressState = .init(
            outputSequence: nextOutputSequence,
            trailingViewOnPress: trailingViewOnPress
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
        public let onPress: (() -> Void)?
    }
    public func display(onPress: (() -> Void)?) {
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
    @Published public var displayOnPasteState: DisplayOnPasteState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnPaste(state))
        }
        didSet {
            guard displayOnPasteState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnPasteState {
        let outputSequence: UInt64
        public let onPaste: ((String?) -> Void)?
    }
    public func display(onPaste: ((String?) -> Void)?) {
        requireMainOutputReplayQueue()
        let onPaste = outputReplayClosureStore.sanitizePersistentAction(
            onPaste,
            path: "onPaste"
        )
        nextOutputSequence &+= 1
        displayOnPasteState = .init(
            outputSequence: nextOutputSequence,
            onPaste: onPaste
        )
    }
    @Published public var displayOnBecomeFirstResponderState: DisplayOnBecomeFirstResponderState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnBecomeFirstResponder(state))
        }
        didSet {
            guard displayOnBecomeFirstResponderState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnBecomeFirstResponderState {
        let outputSequence: UInt64
        public let onBecomeFirstResponder: (() -> Void)?
    }
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let onBecomeFirstResponder = outputReplayClosureStore.sanitizePersistentAction(
            onBecomeFirstResponder,
            path: "onBecomeFirstResponder"
        )
        nextOutputSequence &+= 1
        displayOnBecomeFirstResponderState = .init(
            outputSequence: nextOutputSequence,
            onBecomeFirstResponder: onBecomeFirstResponder
        )
    }
    @Published public var displayOnResignFirstResponderState: DisplayOnResignFirstResponderState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnResignFirstResponder(state))
        }
        didSet {
            guard displayOnResignFirstResponderState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnResignFirstResponderState {
        let outputSequence: UInt64
        public let onResignFirstResponder: (() -> Void)?
    }
    public func display(onResignFirstResponder: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let onResignFirstResponder = outputReplayClosureStore.sanitizePersistentAction(
            onResignFirstResponder,
            path: "onResignFirstResponder"
        )
        nextOutputSequence &+= 1
        displayOnResignFirstResponderState = .init(
            outputSequence: nextOutputSequence,
            onResignFirstResponder: onResignFirstResponder
        )
    }
    @Published public var displayOnTapBackspaceState: DisplayOnTapBackspaceState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnTapBackspace(state))
        }
        didSet {
            guard displayOnTapBackspaceState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnTapBackspaceState {
        let outputSequence: UInt64
        public let onTapBackspace: (() -> Void)?
    }
    public func display(onTapBackspace: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let onTapBackspace = outputReplayClosureStore.sanitizePersistentAction(
            onTapBackspace,
            path: "onTapBackspace"
        )
        nextOutputSequence &+= 1
        displayOnTapBackspaceState = .init(
            outputSequence: nextOutputSequence,
            onTapBackspace: onTapBackspace
        )
    }
    @Published public var displayDidChangeTextState: DisplayDidChangeTextState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayDidChangeText(state))
        }
        didSet {
            guard displayDidChangeTextState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayDidChangeTextState {
        let outputSequence: UInt64
        public let didChangeText: [((String?) -> Void)]
    }
    public func display(didChangeText: [((String?) -> Void)]) {
        requireMainOutputReplayQueue()
        let didChangeText = outputReplayClosureStore.sanitize(
            didChangeText,
            path: "didChangeText"
        )
        nextOutputSequence &+= 1
        displayDidChangeTextState = .init(
            outputSequence: nextOutputSequence,
            didChangeText: didChangeText
        )
    }
    @Published public var displayTrailingViewIsHiddenState: DisplayTrailingViewIsHiddenState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTrailingViewIsHidden(state))
        }
        didSet {
            guard displayTrailingViewIsHiddenState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTrailingViewIsHiddenState {
        let outputSequence: UInt64
        public let trailingViewIsHidden: Bool
    }
    public func display(trailingViewIsHidden: Bool) {
        requireMainOutputReplayQueue()
        let trailingViewIsHidden = outputReplayClosureStore.sanitize(
            trailingViewIsHidden,
            path: "trailingViewIsHidden"
        )
        nextOutputSequence &+= 1
        displayTrailingViewIsHiddenState = .init(
            outputSequence: nextOutputSequence,
            trailingViewIsHidden: trailingViewIsHidden
        )
    }
    @Published public var displayLeadingViewIsHiddenState: DisplayLeadingViewIsHiddenState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeadingViewIsHidden(state))
        }
        didSet {
            guard displayLeadingViewIsHiddenState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeadingViewIsHiddenState {
        let outputSequence: UInt64
        public let leadingViewIsHidden: Bool
    }
    public func display(leadingViewIsHidden: Bool) {
        requireMainOutputReplayQueue()
        let leadingViewIsHidden = outputReplayClosureStore.sanitize(
            leadingViewIsHidden,
            path: "leadingViewIsHidden"
        )
        nextOutputSequence &+= 1
        displayLeadingViewIsHiddenState = .init(
            outputSequence: nextOutputSequence,
            leadingViewIsHidden: leadingViewIsHidden
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
    @Published public var displayInputViewState: DisplayInputViewState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayInputView(state))
        }
        didSet {
            guard displayInputViewState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayInputViewState {
        let outputSequence: UInt64
        public let inputView: TextInputPresentableModel.InputView?
    }
    public func display(inputView: TextInputPresentableModel.InputView?) {
        requireMainOutputReplayQueue()
        let inputView = outputReplayClosureStore.sanitize(
            inputView,
            path: "inputView"
        )
        nextOutputSequence &+= 1
        displayInputViewState = .init(
            outputSequence: nextOutputSequence,
            inputView: inputView
        )
    }
    @Published public var displayInputTypeState: DisplayInputTypeState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayInputType(state))
        }
        didSet {
            guard displayInputTypeState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayInputTypeState {
        let outputSequence: UInt64
        public let inputType: KeyboardType
    }
    public func display(inputType: KeyboardType) {
        requireMainOutputReplayQueue()
        let inputType = outputReplayClosureStore.sanitize(
            inputType,
            path: "inputType"
        )
        nextOutputSequence &+= 1
        displayInputTypeState = .init(
            outputSequence: nextOutputSequence,
            inputType: inputType
        )
    }
    @Published public var displayTrailingSymbolState: DisplayTrailingSymbolState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTrailingSymbol(state))
        }
        didSet {
            guard displayTrailingSymbolState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTrailingSymbolState {
        let outputSequence: UInt64
        public let trailingSymbol: String?
    }
    public func display(trailingSymbol: String?) {
        requireMainOutputReplayQueue()
        let trailingSymbol = outputReplayClosureStore.sanitize(
            trailingSymbol,
            path: "trailingSymbol"
        )
        nextOutputSequence &+= 1
        displayTrailingSymbolState = .init(
            outputSequence: nextOutputSequence,
            trailingSymbol: trailingSymbol
        )
    }
    @Published public var displayInputAccessoryViewState: DisplayInputAccessoryViewState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayInputAccessoryView(state))
        }
        didSet {
            guard displayInputAccessoryViewState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayInputAccessoryViewState {
        let outputSequence: UInt64
        public let inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
    }
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let inputAccessoryView = outputReplayClosureStore.sanitize(
            inputAccessoryView,
            path: "inputAccessoryView"
        )
        nextOutputSequence &+= 1
        displayInputAccessoryViewState = .init(
            outputSequence: nextOutputSequence,
            inputAccessoryView: inputAccessoryView
        )
    }
    @Published public var displayIsClearButtonActiveState: DisplayIsClearButtonActiveState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsClearButtonActive(state))
        }
        didSet {
            guard displayIsClearButtonActiveState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsClearButtonActiveState {
        let outputSequence: UInt64
        public let isClearButtonActive: Bool
    }
    public func display(isClearButtonActive: Bool) {
        requireMainOutputReplayQueue()
        let isClearButtonActive = outputReplayClosureStore.sanitize(
            isClearButtonActive,
            path: "isClearButtonActive"
        )
        nextOutputSequence &+= 1
        displayIsClearButtonActiveState = .init(
            outputSequence: nextOutputSequence,
            isClearButtonActive: isClearButtonActive
        )
    }
}
