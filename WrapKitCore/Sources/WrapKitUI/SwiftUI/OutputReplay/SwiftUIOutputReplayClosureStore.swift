import Foundation

final class SwiftUIOutputReplayConsumableValue<Value> {
    private let lock = NSLock()
    private var value: Value?

    init(_ value: Value) {
        self.value = value
    }

    func take() -> Value? {
        lock.lock()
        let value = value
        self.value = nil
        lock.unlock()
        return value
    }
}

struct SwiftUIOutputReplayPreparedTextInput {
    let retainedModel: TextInputPresentableModel
    let consumableModel: SwiftUIOutputReplayConsumableValue<TextInputPresentableModel>
}

/// Keeps closure-bearing output values safe to retain in generated SwiftUI adapter state.
///
/// Persistent actions with the same semantic path share a revocable slot. Replacing an
/// action therefore also makes copies retained by an older output event inert. One-shot
/// completions keep a shared gate so rebuilding a SwiftUI view cannot invoke them twice.
final class SwiftUIOutputReplayClosureStore {
    private var slots: [String: SwiftUIOutputReplayRevocableClosure] = [:]
    private var latestMutationGenerationByGroup: [String: UInt64] = [:]
    private var nextMutationGeneration: UInt64 = 0
    private var textInputCandidates: [UInt64: SwiftUIOutputReplayDeferredCandidate] = [:]

    func sanitize<Value>(_ value: Value, path _: String) -> Value {
        value
    }

    func sanitizePersistentAction(_ action: (() -> Void)?, path: String) -> (() -> Void)? {
        beginImmediateReplacement(of: path)
        guard let action else { return nil }
        let box = SwiftUIOutputReplayPersistentClosureBox<Void> { _ in action() }
        slots[path] = box
        return { box.call(()) }
    }

    func sanitizePersistentAction<Input>(
        _ action: ((Input) -> Void)?,
        path: String
    ) -> ((Input) -> Void)? {
        replacePersistent(action, at: path)
    }

    func sanitizeOnce(_ completion: (() -> Void)?, path: String) -> (() -> Void)? {
        beginImmediateReplacement(of: path)
        guard let completion else { return nil }
        let box = SwiftUIOutputReplayOneShotClosureBox<Void> { _ in completion() }
        slots[path] = box
        return { box.call(()) }
    }

    func sanitizeOnce<Input>(
        _ completion: ((Input) -> Void)?,
        path: String
    ) -> ((Input) -> Void)? {
        replaceOneShot(completion, at: path)
    }

    func invalidate(path: String) {
        beginImmediateReplacement(of: path)
    }

    func invalidate(prefix: String) {
        beginImmediateReplacement(of: prefix, includingChildren: true)
    }

    private func replacePersistent<Input>(
        _ action: ((Input) -> Void)?,
        at path: String
    ) -> ((Input) -> Void)? {
        guard let action else {
            beginImmediateReplacement(of: path)
            return nil
        }
        return replacePersistentAction(action, at: path)
    }

    private func replacePersistentAction<Input>(
        _ action: @escaping (Input) -> Void,
        at path: String
    ) -> (Input) -> Void {
        beginImmediateReplacement(of: path)
        let box = SwiftUIOutputReplayPersistentClosureBox(action)
        slots[path] = box
        return { input in box.call(input) }
    }

    private func replaceOneShot<Input>(
        _ completion: ((Input) -> Void)?,
        at path: String
    ) -> ((Input) -> Void)? {
        beginImmediateReplacement(of: path)
        guard let completion else { return nil }

        let box = SwiftUIOutputReplayOneShotClosureBox(completion)
        slots[path] = box
        return { input in box.call(input) }
    }

    func sanitizePersistentProvider<Output>(
        _ provider: (() -> Output)?,
        path: String,
        fallback: @escaping () -> Output
    ) -> (() -> Output)? {
        beginImmediateReplacement(of: path)
        guard let provider else { return nil }
        let box = SwiftUIOutputReplayTransformClosureBox<Void, Output>(
            action: { _ in provider() },
            fallback: { _ in fallback() }
        )
        slots[path] = box
        return { box.call(()) }
    }

    func sanitizePersistentProvider<Input, Output>(
        _ provider: ((Input) -> Output)?,
        path: String,
        fallback: @escaping (Input) -> Output
    ) -> ((Input) -> Output)? {
        beginImmediateReplacement(of: path)
        guard let provider else { return nil }
        let box = SwiftUIOutputReplayTransformClosureBox(
            action: provider,
            fallback: fallback
        )
        slots[path] = box
        return { input in box.call(input) }
    }

    private func beginImmediateReplacement(
        of group: String,
        includingChildren: Bool = false
    ) {
        nextMutationGeneration &+= 1
        latestMutationGenerationByGroup[group] = nextMutationGeneration
        discardPendingCandidateGroups(named: group)
        revokeSlots(in: group, includingChildren: includingChildren)
    }

    private func revokeSlots(in path: String, includingChildren: Bool) {
        let matchingKeys = slots.keys.filter {
            $0 == path || (includingChildren && $0.hasPrefix("\(path)."))
        }
        matchingKeys.forEach { key in
            slots.removeValue(forKey: key)?.revoke()
        }
    }

    private func discardPendingCandidateGroups(named group: String) {
        for sequence in Array(textInputCandidates.keys) {
            guard let candidate = textInputCandidates[sequence] else { continue }
            candidate.removeGroup(named: group)?.revoke()
            if candidate.isEmpty {
                textInputCandidates.removeValue(forKey: sequence)
            }
        }
    }
}

private protocol SwiftUIOutputReplayRevocableClosure: AnyObject {
    func activate()
    func revoke()
}

private final class SwiftUIOutputReplayPersistentClosureBox<Input>:
    SwiftUIOutputReplayRevocableClosure {
    private let lock = NSLock()
    private var action: ((Input) -> Void)?
    private var isActive: Bool

    init(_ action: @escaping (Input) -> Void, isActive: Bool = true) {
        self.action = action
        self.isActive = isActive
    }

    func call(_ input: Input) {
        lock.lock()
        let action = isActive ? action : nil
        lock.unlock()
        action?(input)
    }

    func activate() {
        lock.lock()
        isActive = true
        lock.unlock()
    }

    func revoke() {
        lock.lock()
        isActive = false
        action = nil
        lock.unlock()
    }
}

private final class SwiftUIOutputReplayOneShotClosureBox<Input>:
    SwiftUIOutputReplayRevocableClosure {
    private let lock = NSLock()
    private var completion: ((Input) -> Void)?
    private var isActive: Bool

    init(_ completion: @escaping (Input) -> Void, isActive: Bool = true) {
        self.completion = completion
        self.isActive = isActive
    }

    func call(_ input: Input) {
        lock.lock()
        let completion = isActive ? completion : nil
        if isActive {
            self.completion = nil
        }
        lock.unlock()
        completion?(input)
    }

    func activate() {
        lock.lock()
        isActive = true
        lock.unlock()
    }

    func revoke() {
        lock.lock()
        isActive = false
        completion = nil
        lock.unlock()
    }
}

private final class SwiftUIOutputReplayTransformClosureBox<Input, Output>:
    SwiftUIOutputReplayRevocableClosure {
    private let lock = NSLock()
    private var action: ((Input) -> Output)?
    private let fallback: (Input) -> Output
    private var isActive: Bool

    init(
        action: @escaping (Input) -> Output,
        fallback: @escaping (Input) -> Output,
        isActive: Bool = true
    ) {
        self.action = action
        self.fallback = fallback
        self.isActive = isActive
    }

    func call(_ input: Input) -> Output {
        lock.lock()
        let action = isActive ? action : nil
        lock.unlock()
        return action?(input) ?? fallback(input)
    }

    func activate() {
        lock.lock()
        isActive = true
        lock.unlock()
    }

    func revoke() {
        lock.lock()
        isActive = false
        action = nil
        lock.unlock()
    }
}

private final class SwiftUIOutputReplayDeferredCandidate {
    private var groups: [String: SwiftUIOutputReplayDeferredGroup] = [:]

    var isEmpty: Bool { groups.isEmpty }

    func existingGroup(named path: String) -> SwiftUIOutputReplayDeferredGroup? {
        groups[path]
    }

    func group(named path: String, generation: UInt64) -> SwiftUIOutputReplayDeferredGroup {
        if let group = groups[path] { return group }
        let group = SwiftUIOutputReplayDeferredGroup(generation: generation)
        groups[path] = group
        return group
    }

    func removeGroup(named path: String) -> SwiftUIOutputReplayDeferredGroup? {
        groups.removeValue(forKey: path)
    }

    func revoke() {
        groups.values.forEach { $0.revoke() }
        groups.removeAll()
    }
}

private final class SwiftUIOutputReplayDeferredGroup {
    let generation: UInt64
    private(set) var slots: [String: SwiftUIOutputReplayRevocableClosure] = [:]

    init(generation: UInt64) {
        self.generation = generation
    }

    func store(_ closure: SwiftUIOutputReplayRevocableClosure, at path: String) {
        slots[path] = closure
    }

    func activate() {
        slots.values.forEach { $0.activate() }
    }

    func revoke() {
        slots.values.forEach { $0.revoke() }
        slots.removeAll()
    }
}

extension SwiftUIOutputReplayClosureStore {
    func prepareTextInputModel(
        _ model: TextInputPresentableModel?,
        outputSequence: UInt64
    ) -> TextInputPresentableModel? {
        guard let model else { return nil }

        let inputView = prepareTextInputView(
            model.inputView,
            outputSequence: outputSequence,
            groupPath: "inputView",
            accessoryGroupPath: "inputAccessoryView"
        )
        let inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
        if case .date(let dateModel) = inputView {
            inputAccessoryView = dateModel.accessoryView
        } else {
            inputAccessoryView = prepareTextInputAccessoryView(
                model.inputAccessoryView,
                outputSequence: outputSequence,
                groupPath: "inputAccessoryView"
            )
        }

        return TextInputPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            text: model.text,
            mask: model.mask,
            isValid: model.isValid,
            isEnabledForEditing: model.isEnabledForEditing,
            isTextSelectionDisabled: model.isTextSelectionDisabled,
            placeholder: model.placeholder,
            isUserInteractionEnabled: model.isUserInteractionEnabled,
            isSecureTextEntry: model.isSecureTextEntry,
            inputView: inputView,
            inputAccessoryView: inputAccessoryView,
            trailingSymbol: model.trailingSymbol,
            autocapitalizationType: model.autocapitalizationType ?? .none,
            inputType: model.inputType,
            leadingViewOnPress: prepareTextInputAction(
                model.leadingViewOnPress,
                outputSequence: outputSequence,
                groupPath: "leadingViewOnPress"
            ),
            trailingViewOnPress: prepareTextInputAction(
                model.trailingViewOnPress,
                outputSequence: outputSequence,
                groupPath: "trailingViewOnPress"
            ),
            onPress: prepareTextInputAction(
                model.onPress,
                outputSequence: outputSequence,
                groupPath: "onPress"
            ),
            onPaste: prepareTextInputAction(
                model.onPaste,
                outputSequence: outputSequence,
                groupPath: "onPaste"
            ),
            onBecomeFirstResponder: prepareTextInputAction(
                model.onBecomeFirstResponder,
                outputSequence: outputSequence,
                groupPath: "onBecomeFirstResponder"
            ),
            onResignFirstResponder: prepareTextInputAction(
                model.onResignFirstResponder,
                outputSequence: outputSequence,
                groupPath: "onResignFirstResponder"
            ),
            onTapBackspace: prepareTextInputAction(
                model.onTapBackspace,
                outputSequence: outputSequence,
                groupPath: "onTapBackspace"
            ),
            didChangeText: model.didChangeText.map {
                prepareTextInputActions(
                    $0,
                    outputSequence: outputSequence,
                    groupPath: "didChangeText"
                )
            }
        )
    }

    func resolveTextInputModelCallbackGroup(
        outputSequence: UInt64,
        path: String,
        accepted: Bool
    ) {
        guard let candidate = textInputCandidates[outputSequence],
              let group = candidate.removeGroup(named: path) else { return }
        defer {
            if candidate.isEmpty {
                textInputCandidates.removeValue(forKey: outputSequence)
            }
        }

        guard accepted else {
            group.revoke()
            return
        }
        let latestGeneration = latestMutationGenerationByGroup[path] ?? 0
        guard latestGeneration <= group.generation else {
            group.revoke()
            return
        }

        revokeSlots(in: path, includingChildren: true)
        group.activate()
        latestMutationGenerationByGroup[path] = group.generation
        group.slots.forEach { slots[$0.key] = $0.value }
    }

    func discardTextInputModelCallbackCandidate(outputSequence: UInt64) {
        textInputCandidates.removeValue(forKey: outputSequence)?.revoke()
    }
}

private extension SwiftUIOutputReplayClosureStore {
    func textInputCandidateGroup(
        outputSequence: UInt64,
        path: String
    ) -> SwiftUIOutputReplayDeferredGroup {
        if let group = textInputCandidates[outputSequence]?.existingGroup(named: path) {
            return group
        }

        nextMutationGeneration &+= 1
        let candidate = textInputCandidates[outputSequence] ?? SwiftUIOutputReplayDeferredCandidate()
        textInputCandidates[outputSequence] = candidate
        return candidate.group(named: path, generation: nextMutationGeneration)
    }

    func prepareTextInputAction(
        _ action: (() -> Void)?,
        outputSequence: UInt64,
        groupPath: String,
        slotPath: String? = nil
    ) -> (() -> Void)? {
        let group = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let action else { return nil }
        let box = SwiftUIOutputReplayPersistentClosureBox<Void>({ _ in action() }, isActive: false)
        group.store(box, at: slotPath ?? groupPath)
        return { box.call(()) }
    }

    func prepareTextInputAction<Input>(
        _ action: ((Input) -> Void)?,
        outputSequence: UInt64,
        groupPath: String,
        slotPath: String? = nil
    ) -> ((Input) -> Void)? {
        let group = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let action else { return nil }
        let box = SwiftUIOutputReplayPersistentClosureBox(action, isActive: false)
        group.store(box, at: slotPath ?? groupPath)
        return { input in box.call(input) }
    }

    func prepareTextInputActions(
        _ actions: [(String?) -> Void],
        outputSequence: UInt64,
        groupPath: String
    ) -> [(String?) -> Void] {
        let group = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        return actions.enumerated().map { index, action in
            let box = SwiftUIOutputReplayPersistentClosureBox(action, isActive: false)
            group.store(box, at: "\(groupPath).\(index)")
            return { input in box.call(input) }
        }
    }

    func prepareTextInputProvider<Output>(
        _ provider: (() -> Output)?,
        outputSequence: UInt64,
        groupPath: String,
        slotPath: String,
        fallback: @escaping () -> Output
    ) -> (() -> Output)? {
        let group = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let provider else { return nil }
        let box = SwiftUIOutputReplayTransformClosureBox<Void, Output>(
            action: { _ in provider() },
            fallback: { _ in fallback() },
            isActive: false
        )
        group.store(box, at: slotPath)
        return { box.call(()) }
    }

    func prepareTextInputProvider<Input, Output>(
        _ provider: ((Input) -> Output)?,
        outputSequence: UInt64,
        groupPath: String,
        slotPath: String,
        fallback: @escaping (Input) -> Output
    ) -> ((Input) -> Output)? {
        let group = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let provider else { return nil }
        let box = SwiftUIOutputReplayTransformClosureBox(
            action: provider,
            fallback: fallback,
            isActive: false
        )
        group.store(box, at: slotPath)
        return { input in box.call(input) }
    }

    func prepareTextInputSingleUse<Input>(
        _ completion: ((Input) -> Void)?,
        outputSequence: UInt64,
        groupPath: String,
        slotPath: String
    ) -> ((Input) -> Void)? {
        let group = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let completion else { return nil }
        let box = SwiftUIOutputReplayOneShotClosureBox(completion, isActive: false)
        group.store(box, at: slotPath)
        return { input in box.call(input) }
    }

    func prepareTextInputAccessoryView(
        _ model: TextInputPresentableModel.AccessoryViewPresentableModel?,
        outputSequence: UInt64,
        groupPath: String
    ) -> TextInputPresentableModel.AccessoryViewPresentableModel? {
        _ = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let model else { return nil }
        return .init(
            style: model.style,
            trailingButton: prepareTextInputButton(
                model.trailingButton,
                outputSequence: outputSequence,
                groupPath: groupPath,
                slotPath: "\(groupPath).trailingButton.onPress"
            )
        )
    }

    func prepareTextInputButton(
        _ model: ButtonPresentableModel?,
        outputSequence: UInt64,
        groupPath: String,
        slotPath: String
    ) -> ButtonPresentableModel? {
        guard let model else { return nil }
        return ButtonPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            title: model.title,
            image: model.image,
            spacing: model.spacing,
            height: model.height,
            width: model.width,
            style: model.style,
            enabled: model.enabled,
            onPress: prepareTextInputAction(
                model.onPress,
                outputSequence: outputSequence,
                groupPath: groupPath,
                slotPath: slotPath
            )
        )
    }

    func prepareTextInputView(
        _ inputView: TextInputPresentableModel.InputView?,
        outputSequence: UInt64,
        groupPath: String,
        accessoryGroupPath: String
    ) -> TextInputPresentableModel.InputView? {
        _ = textInputCandidateGroup(outputSequence: outputSequence, path: groupPath)
        guard let inputView else { return nil }

        switch inputView {
        case .date(let model):
            let accessoryView = prepareTextInputAccessoryView(
                model.accessoryView,
                outputSequence: outputSequence,
                groupPath: accessoryGroupPath
            )
            return .date(.init(
                minDate: model.minDate,
                maxDate: model.maxDate,
                mode: model.mode,
                value: model.value,
                accessoryView: accessoryView,
                onChange: prepareTextInputAction(
                    model.onChange,
                    outputSequence: outputSequence,
                    groupPath: groupPath,
                    slotPath: "\(groupPath).date.onChange"
                ),
                onDoneTapped: prepareTextInputAction(
                    accessoryView == nil ? nil : model.onDoneTapped,
                    outputSequence: outputSequence,
                    groupPath: accessoryGroupPath,
                    slotPath: "\(accessoryGroupPath).date.onDoneTapped"
                )
            ))
        case .custom(let model):
            let selectedRow = model.selectedRow.map {
                PickerViewPresentableModel.SelectedRow(
                    row: $0.row,
                    component: $0.component,
                    animated: $0.animated,
                    selectedRowCompletion: prepareTextInputSingleUse(
                        $0.selectedRowCompletion,
                        outputSequence: outputSequence,
                        groupPath: groupPath,
                        slotPath: "\(groupPath).custom.selectedRow.completion"
                    )
                )
            }
            return .custom(.init(
                accessibilityIdentifier: model.accessibilityIdentifier,
                componentsCount: prepareTextInputProvider(
                    model.componentsCount,
                    outputSequence: outputSequence,
                    groupPath: groupPath,
                    slotPath: "\(groupPath).custom.componentsCount",
                    fallback: { nil }
                ),
                rowsCount: prepareTextInputProvider(
                    model.rowsCount,
                    outputSequence: outputSequence,
                    groupPath: groupPath,
                    slotPath: "\(groupPath).custom.rowsCount",
                    fallback: { 0 }
                ),
                titleForRowAt: prepareTextInputProvider(
                    model.titleForRowAt,
                    outputSequence: outputSequence,
                    groupPath: groupPath,
                    slotPath: "\(groupPath).custom.titleForRowAt",
                    fallback: { _ in nil }
                ),
                didSelectAt: prepareTextInputAction(
                    model.didSelectAt,
                    outputSequence: outputSequence,
                    groupPath: groupPath,
                    slotPath: "\(groupPath).custom.didSelectAt"
                ),
                selectedRow: selectedRow
            ))
        }
    }
}

extension SwiftUIOutputReplayClosureStore {
    func sanitize(
        _ model: ButtonPresentableModel?,
        path: String
    ) -> ButtonPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else {
            _ = sanitizePersistentAction(
                Optional<() -> Void>.none,
                path: childPath("onPress", of: path)
            )
            return nil
        }

        return ButtonPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            title: model.title,
            image: model.image,
            spacing: model.spacing,
            height: model.height,
            width: model.width,
            style: model.style,
            enabled: model.enabled,
            onPress: sanitizePersistentAction(
                model.onPress,
                path: childPath("onPress", of: path)
            )
        )
    }

    func sanitize(
        _ model: ImageViewPresentableModel?,
        path: String
    ) -> ImageViewPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else {
            _ = sanitizePersistentAction(
                Optional<() -> Void>.none,
                path: childPath("onPress", of: path)
            )
            _ = sanitizePersistentAction(
                Optional<() -> Void>.none,
                path: childPath("onLongPress", of: path)
            )
            return nil
        }

        return ImageViewPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            size: model.size,
            image: model.image,
            onPress: sanitizePersistentAction(
                model.onPress,
                path: childPath("onPress", of: path)
            ),
            onLongPress: sanitizePersistentAction(
                model.onLongPress,
                path: childPath("onLongPress", of: path)
            ),
            contentModeIsFit: model.contentModeIsFit,
            borderWidth: model.borderWidth,
            borderColor: model.borderColor,
            cornerRadius: model.cornerRadius,
            alpha: model.alpha
        )
    }

    func sanitize(
        _ model: SwitchControlPresentableModel?,
        path: String
    ) -> SwitchControlPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else {
            let action: ((SwitchCotrolOutput & LoadingOutput) -> Void)? = nil
            _ = sanitizePersistentAction(action, path: childPath("onPress", of: path))
            return nil
        }

        return SwitchControlPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            onPress: sanitizePersistentAction(
                model.onPress,
                path: childPath("onPress", of: path)
            ),
            isOn: model.isOn,
            isEnabled: model.isEnabled,
            style: model.style
        )
    }

    func sanitize(
        _ model: DatePickerPresentableModel,
        path: String
    ) -> DatePickerPresentableModel {
        let path = normalizedModelPath(path)
        return DatePickerPresentableModel(
            value: model.value,
            minimumDate: model.minimumDate,
            maximumDate: model.maximumDate,
            mode: model.mode,
            dateChanged: sanitizePersistentAction(
                model.dateChanged,
                path: childPath("dateChanged", of: path)
            )
        )
    }
}

extension SwiftUIOutputReplayClosureStore {
    func sanitizeTextOutputUpdate(
        _ model: TextOutputPresentableModel?,
        path: String
    ) -> TextOutputPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else { return nil }
        return TextOutputPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            model: model.model.map {
                sanitize($0, path: childPath("textModel", of: path))
            }
        )
    }

    func sanitize(
        _ model: TextOutputPresentableModel?,
        path: String
    ) -> TextOutputPresentableModel? {
        sanitizeTextOutputUpdate(model, path: path)
    }

    func sanitize(
        _ model: TextOutputPresentableModel.TextModel?,
        path: String
    ) -> TextOutputPresentableModel.TextModel? {
        replaceTextModel(model, path: path)
    }

    func sanitize(
        _ model: TextOutputPresentableModel.TextModel,
        path: String
    ) -> TextOutputPresentableModel.TextModel {
        replaceRequiredTextModel(model, path: path)
    }

    func sanitize(
        _ attributes: [TextAttributes],
        path: String
    ) -> [TextAttributes] {
        invalidate(prefix: path)
        return sanitizeTextAttributes(attributes, path: path)
    }

    func sanitizeTextMap<Input>(
        _ mapToString: ((Input) -> TextOutputPresentableModel.TextModel)?,
        path: String
    ) -> ((Input) -> TextOutputPresentableModel.TextModel)? {
        invalidate(prefix: path)
        guard let mapToString else { return nil }

        let box = SwiftUIOutputReplayTransformClosureBox<
            Input,
            TextOutputPresentableModel.TextModel
        >(
            action: { [weak self] (input: Input) -> TextOutputPresentableModel.TextModel in
                guard let self else { return .text(nil) }
                return self.replaceRequiredTextModel(
                    mapToString(input),
                    path: self.childPath("mappedResult", of: path)
                )
            },
            fallback: { (_: Input) -> TextOutputPresentableModel.TextModel in .text(nil) }
        )
        slots[path] = box
        return { input in box.call(input) }
    }

    private func replaceTextModel(
        _ model: TextOutputPresentableModel.TextModel?,
        path: String
    ) -> TextOutputPresentableModel.TextModel? {
        guard let model else {
            invalidate(prefix: path)
            return nil
        }
        return replaceRequiredTextModel(model, path: path)
    }

    private func replaceRequiredTextModel(
        _ model: TextOutputPresentableModel.TextModel,
        path: String
    ) -> TextOutputPresentableModel.TextModel {
        invalidate(prefix: path)
        return sanitizeTextModel(model, path: path)
    }

    private func sanitizeTextModel(
        _ model: TextOutputPresentableModel.TextModel,
        path: String
    ) -> TextOutputPresentableModel.TextModel {
        switch model {
        case .text(let text):
            return .text(text)
        case .attributes(let attributes):
            return .attributes(sanitizeTextAttributes(
                attributes,
                path: childPath("attributes", of: path)
            ))
        case .attributedString(let text, let config):
            return .attributedString(text, config: config)
        case let .animatedDecimal(
            id,
            from,
            to,
            mapToString,
            animationStyle,
            duration,
            completion
        ):
            let animationPath = textAnimationPath(for: path)
            return .animatedDecimal(
                id: id,
                from: from,
                to: to,
                mapToString: sanitizeTextMap(
                    mapToString,
                    path: childPath("mapToString", of: animationPath)
                ),
                animationStyle: animationStyle,
                duration: duration,
                completion: sanitizeOnce(
                    completion,
                    path: childPath("completion", of: animationPath)
                )
            )
        case let .animated(
            id,
            from,
            to,
            mapToString,
            animationStyle,
            duration,
            completion
        ):
            let animationPath = textAnimationPath(for: path)
            return .animated(
                id: id,
                from,
                to,
                mapToString: sanitizeTextMap(
                    mapToString,
                    path: childPath("mapToString", of: animationPath)
                ),
                animationStyle: animationStyle,
                duration: duration,
                completion: sanitizeOnce(
                    completion,
                    path: childPath("completion", of: animationPath)
                )
            )
        case let .textStyled(text, cornerStyle, insets, height, backgroundColor):
            return .textStyled(
                text: sanitizeTextModel(
                    text,
                    path: childPath("styledText", of: path)
                ),
                cornerStyle: cornerStyle,
                insets: insets,
                height: height,
                backgroundColor: backgroundColor
            )
        }
    }

    private func sanitizeTextAttributes(
        _ attributes: [TextAttributes],
        path: String
    ) -> [TextAttributes] {
        attributes.enumerated().map { index, attribute in
            TextAttributes(
                id: attribute.id,
                text: attribute.text,
                color: attribute.color,
                font: attribute.font,
                lineSpacing: attribute.lineSpacing,
                underlineStyle: attribute.underlineStyle,
                textAlignment: attribute.textAlignment,
                leadingImage: attribute.leadingImage,
                leadingImageBounds: attribute.leadingImageBounds,
                trailingImage: attribute.trailingImage,
                trailingImageBounds: attribute.trailingImageBounds,
                onTap: sanitizePersistentAction(
                    attribute.onTap,
                    path: "\(path).\(index).onTap"
                )
            )
        }
    }

    private func sanitizeTextPair(
        _ pair: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>,
        path: String
    ) -> Pair<TextOutputPresentableModel?, TextOutputPresentableModel?> {
        Pair(
            sanitizeTextOutputUpdate(pair.first, path: childPath("first", of: path)),
            sanitizeTextOutputUpdate(pair.second, path: childPath("second", of: path))
        )
    }

    func sanitize(
        _ pair: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>,
        path: String
    ) -> Pair<TextOutputPresentableModel?, TextOutputPresentableModel?> {
        sanitizeTextPair(pair, path: path)
    }

    func sanitize(
        _ pair: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?,
        path: String
    ) -> Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>? {
        let path = normalizedModelPath(path)
        guard let pair else { return nil }
        return sanitizeTextPair(pair, path: path)
    }
}

extension SwiftUIOutputReplayClosureStore {
    func prepareSearchBarModel(
        _ model: SearchBarPresentableModel?
    ) -> (
        retainedModel: SearchBarPresentableModel?,
        textField: SwiftUIOutputReplayPreparedTextInput?
    ) {
        guard let model else { return (nil, nil) }
        let textField = prepareSearchTextField(model.textField)
        return (
            SearchBarPresentableModel(
                textField: textField?.retainedModel,
                leftView: sanitize(model.leftView, path: "leftView"),
                rightView: sanitize(model.rightView, path: "rightView"),
                placeholder: model.placeholder,
                backgroundColor: model.backgroundColor,
                spacing: model.spacing
            ),
            textField
        )
    }

    func prepareSearchTextField(
        _ model: TextInputPresentableModel?
    ) -> SwiftUIOutputReplayPreparedTextInput? {
        guard let model else { return nil }
        return SwiftUIOutputReplayPreparedTextInput(
            retainedModel: removingCallbacks(from: model),
            consumableModel: SwiftUIOutputReplayConsumableValue(model)
        )
    }

    func sanitize(
        _ model: CardViewPresentableModel?,
        path: String
    ) -> CardViewPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else { return nil }
        return sanitizeCardModel(model, path: path)
    }

    private func sanitizeCardModel(
        _ model: CardViewPresentableModel,
        path: String
    ) -> CardViewPresentableModel {
        return CardViewPresentableModel(
            id: model.id,
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            style: model.style,
            backgroundImage: sanitize(
                model.backgroundImage,
                path: childPath("backgroundImage", of: path)
            ),
            title: sanitize(model.title, path: childPath("title", of: path)),
            leadingTitles: sanitize(
                model.leadingTitles,
                path: childPath("leadingTitles", of: path)
            ),
            trailingTitles: sanitize(
                model.trailingTitles,
                path: childPath("trailingTitles", of: path)
            ),
            leadingImage: sanitize(model.leadingImage, path: childPath("leadingImage", of: path)),
            secondaryLeadingImage: sanitize(
                model.secondaryLeadingImage,
                path: childPath("secondaryLeadingImage", of: path)
            ),
            trailingImage: sanitize(
                model.trailingImage,
                path: childPath("trailingImage", of: path)
            ),
            secondaryTrailingImage: sanitize(
                model.secondaryTrailingImage,
                path: childPath("secondaryTrailingImage", of: path)
            ),
            subTitle: sanitize(model.subTitle, path: childPath("subTitle", of: path)),
            valueTitle: sanitize(model.valueTitle, path: childPath("valueTitle", of: path)),
            bottomImage: sanitize(model.bottomImage, path: childPath("bottomImage", of: path)),
            bottomSeparator: model.bottomSeparator,
            switchControl: sanitize(
                model.switchControl,
                path: childPath("switchControl", of: path)
            ),
            onPress: sanitizePersistentAction(
                model.onPress,
                path: childPath("onPress", of: path)
            ),
            onLongPress: sanitizePersistentAction(
                model.onLongPress,
                path: childPath("onLongPress", of: path)
            ),
            isUserInteractionEnabled: model.isUserInteractionEnabled,
            isGradientBorderEnabled: model.isGradientBorderEnabled
        )
    }

    func sanitize(
        _ model: EmptyViewPresentableModel?,
        path: String
    ) -> EmptyViewPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else {
            _ = sanitize(
                Optional<TextOutputPresentableModel>.none,
                path: childPath("title", of: path)
            )
            _ = sanitize(
                Optional<TextOutputPresentableModel>.none,
                path: childPath("subtitle", of: path)
            )
            _ = sanitize(
                Optional<ButtonPresentableModel>.none,
                path: childPath("buttonModel", of: path)
            )
            _ = sanitize(
                Optional<ImageViewPresentableModel>.none,
                path: childPath("image", of: path)
            )
            return nil
        }

        return EmptyViewPresentableModel(
            title: sanitize(model.title, path: childPath("title", of: path)),
            subTitle: sanitize(model.subTitle, path: childPath("subtitle", of: path)),
            button: sanitize(model.button, path: childPath("buttonModel", of: path)),
            image: sanitize(model.image, path: childPath("image", of: path)),
            animationConfig: model.animationConfig
        )
    }

    func sanitize(
        _ model: TitledViewPresentableModel?,
        path: String
    ) -> TitledViewPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else {
            _ = sanitize(
                Optional<Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>>.none,
                path: childPath("titles", of: path)
            )
            _ = sanitize(
                Optional<Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>>.none,
                path: childPath("bottomTitles", of: path)
            )
            return nil
        }
        return TitledViewPresentableModel(
            titles: sanitize(model.titles, path: childPath("titles", of: path)),
            bottomTitles: sanitize(
                model.bottomTitles,
                path: childPath("bottomTitles", of: path)
            ),
            isUserInteractionEnabled: model.isUserInteractionEnabled
        )
    }

    func sanitize(
        _ centerView: HeaderPresentableModel.CenterView?,
        path: String
    ) -> HeaderPresentableModel.CenterView? {
        let path = normalizedModelPath(path)
        guard let centerView else {
            clearKeyValueCenterClosures(path: path)
            clearTitledImageCenterClosures(path: path)
            return nil
        }
        switch centerView {
        case .keyValue(let pair):
            clearTitledImageCenterClosures(path: path)
            return .keyValue(sanitize(pair, path: childPath("keyValue", of: path)))
        case .titledImage(let pair):
            clearKeyValueCenterClosures(path: path)
            return .titledImage(Pair(
                sanitize(pair.first, path: childPath("image", of: path)),
                sanitize(pair.second, path: childPath("title", of: path))
            ))
        }
    }

    private func clearKeyValueCenterClosures(path: String) {
        let keyValuePath = childPath("keyValue", of: path)
        clearTextOutputContentClosures(path: childPath("first", of: keyValuePath))
        clearTextOutputContentClosures(path: childPath("second", of: keyValuePath))
    }

    private func clearTitledImageCenterClosures(path: String) {
        _ = sanitize(
            Optional<ImageViewPresentableModel>.none,
            path: childPath("image", of: path)
        )
        clearTextOutputContentClosures(path: childPath("title", of: path))
    }

    private func clearTextOutputContentClosures(path: String) {
        invalidate(prefix: childPath("textModel", of: path))
    }

    func sanitize(
        _ model: HeaderPresentableModel?,
        path: String
    ) -> HeaderPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else { return nil }

        return HeaderPresentableModel(
            style: model.style,
            centerView: sanitize(model.centerView, path: childPath("centerView", of: path)),
            leadingCard: sanitize(
                model.leadingCard,
                path: childPath("leadingCard", of: path)
            ),
            primeTrailingImage: sanitize(
                model.primeTrailingImage,
                path: childPath("primeTrailingImage", of: path)
            ),
            secondaryTrailingImage: sanitize(
                model.secondaryTrailingImage,
                path: childPath("secondaryTrailingImage", of: path)
            ),
            tertiaryTrailingImage: sanitize(
                model.tertiaryTrailingImage,
                path: childPath("tertiaryTrailingImage", of: path)
            )
        )
    }

    func sanitize(
        _ pair: Pair<CardViewPresentableModel, CardViewPresentableModel?>,
        path: String
    ) -> Pair<CardViewPresentableModel, CardViewPresentableModel?> {
        let path = normalizedModelPath(path)
        return Pair(
            sanitizeCardModel(pair.first, path: childPath("first", of: path)),
            sanitize(pair.second, path: childPath("second", of: path))
        )
    }
}

extension SwiftUIOutputReplayClosureStore {
    func sanitize(
        _ model: RefreshControlPresentableModel?,
        path _: String
    ) -> RefreshControlPresentableModel? {
        let callbacks = sanitizeRefreshActionsReplacement([model?.onRefresh], path: "onRefresh")
        guard let model else { return nil }
        return RefreshControlPresentableModel(
            style: model.style,
            onRefresh: callbacks[0],
            isLoading: model.isLoading
        )
    }

    func sanitizeRefreshActionsReplacement(
        _ callbacks: [(() -> Void)?],
        path: String
    ) -> [(() -> Void)?] {
        invalidate(prefix: path)
        return callbacks.enumerated().map { index, callback in
            sanitizePersistentAction(callback, path: "\(path).\(index)")
        }
    }

    func sanitizeRefreshAppendingAction(
        _ callback: (() -> Void)?,
        path: String,
        index: Int
    ) -> (() -> Void)? {
        sanitizePersistentAction(callback, path: "\(path).\(index)")
    }

    func sanitize(
        _ model: PickerViewPresentableModel?,
        path: String
    ) -> PickerViewPresentableModel? {
        let path = normalizedModelPath(path)
        guard let model else {
            _ = sanitizePersistentProvider(
                Optional<() -> Int?>.none,
                path: childPath("componentsCount", of: path),
                fallback: { nil }
            )
            _ = sanitizePersistentProvider(
                Optional<() -> Int>.none,
                path: childPath("rowsCount", of: path),
                fallback: { 0 }
            )
            _ = sanitizePersistentProvider(
                Optional<(Int) -> String?>.none,
                path: childPath("titleForRowAt", of: path),
                fallback: { _ in nil }
            )
            _ = sanitizePersistentAction(
                Optional<(Int) -> Void>.none,
                path: childPath("didSelectAt", of: path)
            )
            invalidate(path: childPath("selectedRow.completion", of: path))
            return nil
        }
        return sanitizePickerModel(model, path: path)
    }

    private func sanitizePickerModel(
        _ model: PickerViewPresentableModel,
        path: String
    ) -> PickerViewPresentableModel {
        let selectedRowIsValid = model.selectedRow.map {
            let componentsCount = max(model.componentsCount?() ?? 0, 0)
            let rowsCount = max(model.rowsCount?() ?? 0, 0)
            return $0.component >= 0 && $0.component < componentsCount
                && $0.row >= 0 && $0.row < rowsCount
        } ?? false
        if !selectedRowIsValid {
            invalidate(path: childPath("selectedRow.completion", of: path))
        }
        return PickerViewPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            componentsCount: sanitizePersistentProvider(
                model.componentsCount,
                path: childPath("componentsCount", of: path),
                fallback: { nil }
            ),
            rowsCount: sanitizePersistentProvider(
                model.rowsCount,
                path: childPath("rowsCount", of: path),
                fallback: { 0 }
            ),
            titleForRowAt: sanitizePersistentProvider(
                model.titleForRowAt,
                path: childPath("titleForRowAt", of: path),
                fallback: { _ in nil }
            ),
            didSelectAt: sanitizePersistentAction(
                model.didSelectAt,
                path: childPath("didSelectAt", of: path)
            ),
            selectedRow: model.selectedRow.map {
                PickerViewPresentableModel.SelectedRow(
                    row: $0.row,
                    component: $0.component,
                    animated: $0.animated,
                    selectedRowCompletion: selectedRowIsValid
                        ? sanitizeOnce(
                            $0.selectedRowCompletion,
                            path: childPath("selectedRow.completion", of: path)
                        )
                        : nil
                )
            }
        )
    }

    func sanitize(
        _ selectedRow: PickerViewPresentableModel.SelectedRow?,
        path: String
    ) -> PickerViewPresentableModel.SelectedRow? {
        guard let selectedRow else {
            invalidate(path: childPath("completion", of: path))
            return nil
        }
        return PickerViewPresentableModel.SelectedRow(
            row: selectedRow.row,
            component: selectedRow.component,
            animated: selectedRow.animated,
            selectedRowCompletion: sanitizeOnce(
                selectedRow.selectedRowCompletion,
                path: childPath("completion", of: path)
            )
        )
    }

    func sanitize(
        _ accessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?,
        path: String
    ) -> TextInputPresentableModel.AccessoryViewPresentableModel? {
        invalidate(prefix: path)
        guard let accessoryView else { return nil }
        return .init(
            style: accessoryView.style,
            trailingButton: sanitize(
                accessoryView.trailingButton,
                path: childPath("trailingButton", of: path)
            )
        )
    }

    func sanitize(
        _ inputView: TextInputPresentableModel.InputView?,
        path: String
    ) -> TextInputPresentableModel.InputView? {
        invalidate(prefix: path)
        guard let inputView else { return nil }
        switch inputView {
        case .date(let model):
            let accessoryPath = "inputAccessoryView"
            let accessoryView = sanitize(model.accessoryView, path: accessoryPath)
            return .date(.init(
                minDate: model.minDate,
                maxDate: model.maxDate,
                mode: model.mode,
                value: model.value,
                accessoryView: accessoryView,
                onChange: sanitizePersistentAction(
                    model.onChange,
                    path: childPath("date.onChange", of: path)
                ),
                onDoneTapped: sanitizePersistentAction(
                    accessoryView == nil ? nil : model.onDoneTapped,
                    path: childPath("date.onDoneTapped", of: accessoryPath)
                )
            ))
        case .custom(let model):
            return .custom(sanitizePickerModel(
                model,
                path: childPath("custom", of: path)
            ))
        }
    }

    func sanitize(
        _ actions: [(String?) -> Void],
        path: String
    ) -> [(String?) -> Void] {
        invalidate(prefix: path)
        return actions.enumerated().map { index, action in
            replacePersistentAction(action, at: "\(path).\(index)")
        }
    }

}

private extension SwiftUIOutputReplayClosureStore {
    func removingCallbacks(
        from model: TextInputPresentableModel
    ) -> TextInputPresentableModel {
        TextInputPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            text: model.text,
            mask: model.mask,
            isValid: model.isValid,
            isEnabledForEditing: model.isEnabledForEditing,
            isTextSelectionDisabled: model.isTextSelectionDisabled,
            placeholder: model.placeholder,
            isUserInteractionEnabled: model.isUserInteractionEnabled,
            isSecureTextEntry: model.isSecureTextEntry,
            inputView: removingCallbacks(from: model.inputView),
            inputAccessoryView: removingCallbacks(from: model.inputAccessoryView),
            trailingSymbol: model.trailingSymbol,
            autocapitalizationType: model.autocapitalizationType ?? .none,
            inputType: model.inputType
        )
    }

    func removingCallbacks(
        from inputView: TextInputPresentableModel.InputView?
    ) -> TextInputPresentableModel.InputView? {
        guard let inputView else { return nil }
        switch inputView {
        case .date(let model):
            return .date(.init(
                minDate: model.minDate,
                maxDate: model.maxDate,
                mode: model.mode,
                value: model.value,
                accessoryView: removingCallbacks(from: model.accessoryView)
            ))
        case .custom(let model):
            return .custom(.init(
                accessibilityIdentifier: model.accessibilityIdentifier,
                selectedRow: model.selectedRow.map {
                    .init(
                        row: $0.row,
                        component: $0.component,
                        animated: $0.animated
                    )
                }
            ))
        }
    }

    func removingCallbacks(
        from accessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
    ) -> TextInputPresentableModel.AccessoryViewPresentableModel? {
        guard let accessoryView else { return nil }
        return .init(
            style: accessoryView.style,
            trailingButton: removingCallbacks(from: accessoryView.trailingButton)
        )
    }

    func removingCallbacks(
        from button: ButtonPresentableModel?
    ) -> ButtonPresentableModel? {
        guard let button else { return nil }
        return ButtonPresentableModel(
            accessibilityIdentifier: button.accessibilityIdentifier,
            accessibility: button.accessibility,
            title: button.title,
            image: button.image,
            spacing: button.spacing,
            height: button.height,
            width: button.width,
            style: button.style,
            enabled: button.enabled
        )
    }

    func normalizedModelPath(_ path: String) -> String {
        path == "model" ? "" : path
    }

    func childPath(_ child: String, of parent: String) -> String {
        parent.isEmpty ? child : "\(parent).\(child)"
    }

    func textAnimationPath(for textModelPath: String) -> String {
        var components = textModelPath.split(separator: ".").map(String.init)
        guard let textModelIndex = components.firstIndex(of: "textModel") else {
            return childPath("textAnimation", of: textModelPath)
        }
        components.replaceSubrange(textModelIndex..., with: ["textAnimation"])
        return components.joined(separator: ".")
    }
}
