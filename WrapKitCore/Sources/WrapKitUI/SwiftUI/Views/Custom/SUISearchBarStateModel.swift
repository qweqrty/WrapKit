import Foundation

#if canImport(SwiftUI)
    import Combine
    import SwiftUI

    final class SUISearchBarStateModel: ObservableObject {
        @Published var isHidden: Bool = false
        @Published var textField: TextInputPresentableModel?
        @Published var leftView: ButtonPresentableModel?
        @Published var rightView: ButtonPresentableModel?
        @Published var placeholder: String?
        @Published var backgroundColor: Color?
        @Published var isTextFieldHidden: Bool = false
        @Published var spacing: CGFloat

        let appearance: TextfieldAppearance
        let cornerRadius: CGFloat
        let padding: SwiftUI.EdgeInsets
        let textFieldAdapter: TextInputOutputSwiftUIAdapter
        let leftButtonAdapter: ButtonOutputSwiftUIAdapter
        let rightButtonAdapter: ButtonOutputSwiftUIAdapter
        let leftButtonStateModel: SUIButtonStateModel
        let rightButtonStateModel: SUIButtonStateModel

        private let adapter: SearchBarOutputSwiftUIAdapter

        private var outputReplayConsumer: SearchBarOutputSwiftUIAdapter.OutputReplayConsumer?
        private var cancellables: Set<AnyCancellable> = []
        private var latestVisibilityOutputSequence: UInt64 = 0
        private var latestTextFieldOutputSequence: UInt64 = 0
        private var latestLeftViewOutputSequence: UInt64 = 0
        private var latestRightViewOutputSequence: UInt64 = 0
        private var latestPlaceholderOutputSequence: UInt64 = 0
        private var latestBackgroundColorOutputSequence: UInt64 = 0
        private var latestSpacingOutputSequence: UInt64 = 0

        private struct OutputReplayCheckpoint {
            let isHidden: Bool
            let textField: TextInputPresentableModel?
            let leftView: ButtonPresentableModel?
            let rightView: ButtonPresentableModel?
            let placeholder: String?
            let backgroundColor: Color?
            let isTextFieldHidden: Bool
            let spacing: CGFloat
            let latestVisibilityOutputSequence: UInt64
            let latestTextFieldOutputSequence: UInt64
            let latestLeftViewOutputSequence: UInt64
            let latestRightViewOutputSequence: UInt64
            let latestPlaceholderOutputSequence: UInt64
            let latestBackgroundColorOutputSequence: UInt64
            let latestSpacingOutputSequence: UInt64
            let textFieldAdapter: TextInputOutputSwiftUIAdapter
            let leftButtonAdapter: ButtonOutputSwiftUIAdapter
            let rightButtonAdapter: ButtonOutputSwiftUIAdapter
        }

        init(
            adapter: SearchBarOutputSwiftUIAdapter,
            appearance: TextfieldAppearance,
            spacing: CGFloat,
            cornerRadius: CGFloat,
            padding: SwiftUI.EdgeInsets
        ) {
            let outputReplayConsumer = adapter.claimOutputReplayConsumer()
            self.outputReplayConsumer = outputReplayConsumer
            let replayCheckpoint = adapter.outputReplayCheckpoint(as: OutputReplayCheckpoint.self, consumer: outputReplayConsumer)
            let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
            let textFieldAdapter = replayCheckpoint?.textFieldAdapter
                ?? TextInputOutputSwiftUIAdapter()
            let leftButtonAdapter = replayCheckpoint?.leftButtonAdapter
                ?? ButtonOutputSwiftUIAdapter()
            let rightButtonAdapter = replayCheckpoint?.rightButtonAdapter
                ?? ButtonOutputSwiftUIAdapter()

            self.adapter = adapter
            self.appearance = appearance
            self.spacing = spacing
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.textFieldAdapter = textFieldAdapter
            self.leftButtonAdapter = leftButtonAdapter
            self.rightButtonAdapter = rightButtonAdapter
            leftButtonStateModel = SUIButtonStateModel(adapter: leftButtonAdapter)
            rightButtonStateModel = SUIButtonStateModel(adapter: rightButtonAdapter)

            adapter.outputReplayPublisher(
                adapter.$displayModelState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(
                        model: state.model,
                        textFieldReplayModel: state.textFieldReplayModel,
                        outputSequence: state.outputSequence
                    )
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayTextFieldState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(
                        textField: state.textField,
                        replayModel: state.textFieldReplayModel,
                        outputSequence: state.outputSequence
                    )
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayLeftViewState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(leftView: state.leftView, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayRightViewState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(rightView: state.rightView, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayPlaceholderState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(placeholder: state.placeholder, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayBackgroundColorState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(backgroundColor: state.backgroundColor, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displaySpacingState,
                consumer: outputReplayConsumer
            )
                .sink { [weak self] state in
                    guard let state else { return }
                    self?.apply(spacing: state.spacing, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayCheckpointRequestPublisher(consumer: outputReplayConsumer)
                .sink { [weak self] in self?.persistReplayCheckpoint() }
                .store(in: &cancellables)

            if let replayCheckpoint {
                restore(replayCheckpoint)
            }

            bufferedOutputReplayPublisher
                .sink { [weak adapter] event in
                    adapter?.replayOutputEvent(event, consumer: outputReplayConsumer)
                }
                .store(in: &cancellables)

            persistReplayCheckpoint()
        }

        private func apply(
            model: SearchBarPresentableModel?,
            textFieldReplayModel: SwiftUIOutputReplayConsumableValue<TextInputPresentableModel>?,
            outputSequence: UInt64
        ) {
            defer { persistReplayCheckpoint() }
            apply(isHidden: model == nil, outputSequence: outputSequence)
            guard let model else { return }

            apply(
                textField: model.textField,
                replayModel: textFieldReplayModel,
                outputSequence: outputSequence
            )
            apply(leftView: model.leftView, outputSequence: outputSequence)
            apply(rightView: model.rightView, outputSequence: outputSequence)
            apply(placeholder: model.placeholder, outputSequence: outputSequence)
            if let backgroundColor = model.backgroundColor {
                apply(backgroundColor: backgroundColor, outputSequence: outputSequence)
            }
            if let spacing = model.spacing {
                apply(spacing: spacing, outputSequence: outputSequence)
            }
        }

        private func apply(isHidden: Bool, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestVisibilityOutputSequence else { return }
            latestVisibilityOutputSequence = outputSequence
            self.isHidden = isHidden
        }

        private func apply(
            textField: TextInputPresentableModel?,
            replayModel: SwiftUIOutputReplayConsumableValue<TextInputPresentableModel>? = nil,
            outputSequence: UInt64
        ) {
            let consumedReplayModel = replayModel?.take()
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestTextFieldOutputSequence else { return }
            latestTextFieldOutputSequence = outputSequence
            self.textField = textField
            isTextFieldHidden = textField == nil
            if let textField, outputSequence >= latestPlaceholderOutputSequence {
                latestPlaceholderOutputSequence = outputSequence
                placeholder = textField.placeholder
            }
            if replayModel != nil {
                guard let model = consumedReplayModel else { return }
                textFieldAdapter.display(model: model)
            } else {
                textFieldAdapter.display(model: textField)
            }
        }

        private func apply(leftView: ButtonPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestLeftViewOutputSequence else { return }
            latestLeftViewOutputSequence = outputSequence
            self.leftView = leftView
            leftButtonAdapter.display(model: leftView)
        }

        private func apply(rightView: ButtonPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestRightViewOutputSequence else { return }
            latestRightViewOutputSequence = outputSequence
            self.rightView = rightView
            rightButtonAdapter.display(model: rightView)
        }

        private func apply(placeholder: String?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestPlaceholderOutputSequence else { return }
            latestPlaceholderOutputSequence = outputSequence
            self.placeholder = placeholder
            textFieldAdapter.display(placeholder: placeholder)
        }

        private func apply(backgroundColor: Color?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard let backgroundColor else { return }
            guard outputSequence >= latestBackgroundColorOutputSequence else { return }
            latestBackgroundColorOutputSequence = outputSequence
            self.backgroundColor = backgroundColor
        }

        private func apply(spacing: CGFloat, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestSpacingOutputSequence else { return }
            latestSpacingOutputSequence = outputSequence
            self.spacing = spacing
        }

        private func restore(_ checkpoint: OutputReplayCheckpoint) {
            isHidden = checkpoint.isHidden
            textField = checkpoint.textField
            leftView = checkpoint.leftView
            rightView = checkpoint.rightView
            placeholder = checkpoint.placeholder
            backgroundColor = checkpoint.backgroundColor
            isTextFieldHidden = checkpoint.isTextFieldHidden
            spacing = checkpoint.spacing
            latestVisibilityOutputSequence = checkpoint.latestVisibilityOutputSequence
            latestTextFieldOutputSequence = checkpoint.latestTextFieldOutputSequence
            latestLeftViewOutputSequence = checkpoint.latestLeftViewOutputSequence
            latestRightViewOutputSequence = checkpoint.latestRightViewOutputSequence
            latestPlaceholderOutputSequence = checkpoint.latestPlaceholderOutputSequence
            latestBackgroundColorOutputSequence = checkpoint.latestBackgroundColorOutputSequence
            latestSpacingOutputSequence = checkpoint.latestSpacingOutputSequence
        }

        private func persistReplayCheckpoint() {
            adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer,
                OutputReplayCheckpoint(
                    isHidden: isHidden,
                    textField: textField,
                    leftView: leftView,
                    rightView: rightView,
                    placeholder: placeholder,
                    backgroundColor: backgroundColor,
                    isTextFieldHidden: isTextFieldHidden,
                    spacing: spacing,
                    latestVisibilityOutputSequence: latestVisibilityOutputSequence,
                    latestTextFieldOutputSequence: latestTextFieldOutputSequence,
                    latestLeftViewOutputSequence: latestLeftViewOutputSequence,
                    latestRightViewOutputSequence: latestRightViewOutputSequence,
                    latestPlaceholderOutputSequence: latestPlaceholderOutputSequence,
                    latestBackgroundColorOutputSequence: latestBackgroundColorOutputSequence,
                    latestSpacingOutputSequence: latestSpacingOutputSequence,
                    textFieldAdapter: textFieldAdapter,
                    leftButtonAdapter: leftButtonAdapter,
                    rightButtonAdapter: rightButtonAdapter
                )
            )
        }
    }
#endif
