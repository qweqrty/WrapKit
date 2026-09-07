//
//  SUIEmptyViewStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/5/26.
//

import Combine
import SwiftUI

public final class SUIEmptyViewStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let isHidden: Bool
        let title: TextOutputPresentableModel?
        let subtitle: TextOutputPresentableModel?
        let buttonModel: ButtonPresentableModel?
        let image: ImageViewPresentableModel?
        let animationConfig: EmptyViewAnimationConfig
        let isTitleHidden: Bool
        let isSubtitleHidden: Bool
        let isButtonHidden: Bool
        let isImageHidden: Bool
        let retainedButtonModel: ButtonPresentableModel?
        let retainedImageModel: ImageViewPresentableModel
        let titleAdapter: TextOutputSwiftUIAdapter
        let subtitleAdapter: TextOutputSwiftUIAdapter
        let imageAdapter: ImageViewOutputSwiftUIAdapter
    }

    @Published var isHidden: Bool = false
    @Published var title: TextOutputPresentableModel? = nil
    @Published var subtitle: TextOutputPresentableModel? = nil
    @Published var buttonModel: ButtonPresentableModel? = nil
    @Published var image: ImageViewPresentableModel? = nil
    @Published var animationConfig: EmptyViewAnimationConfig = .default
    @Published var isTitleHidden = false
    @Published var isSubtitleHidden = false
    @Published var isButtonHidden = false
    @Published var isImageHidden = false

    let titleStateModel: SUILabelStateModel
    let subtitleStateModel: SUILabelStateModel
    let imageAdapter: ImageViewOutputSwiftUIAdapter

    private let adapter: EmptyViewOutputSwiftUIAdapter
    private let titleAdapter: TextOutputSwiftUIAdapter
    private let subtitleAdapter: TextOutputSwiftUIAdapter

    private var outputReplayConsumer: EmptyViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var retainedButtonModel: ButtonPresentableModel?
    private var retainedImageModel = ImageViewPresentableModel()
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestTitleOutputSequence: UInt64 = 0
    private var latestSubtitleOutputSequence: UInt64 = 0
    private var latestButtonOutputSequence: UInt64 = 0
    private var latestImageOutputSequence: UInt64 = 0

    public init(adapter: EmptyViewOutputSwiftUIAdapter) {
        self.adapter = adapter
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
        titleAdapter = outputReplayCheckpoint?.titleAdapter
            ?? TextOutputSwiftUIAdapter()
        subtitleAdapter = outputReplayCheckpoint?.subtitleAdapter
            ?? TextOutputSwiftUIAdapter()
        imageAdapter = outputReplayCheckpoint?.imageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        titleStateModel = SUILabelStateModel(adapter: titleAdapter)
        subtitleStateModel = SUILabelStateModel(adapter: subtitleAdapter)

        adapter.outputReplayPublisher(
            adapter.$displayModelState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.applyVisibility(
                    isHidden: value.model == nil,
                    animationConfig: value.model?.animationConfig
                        ?? EmptyViewAnimationConfig(isAnimated: true, duration: 0.3),
                    outputSequence: value.outputSequence
                )
                self.applyTitle(
                    value.model?.title,
                    outputSequence: value.outputSequence
                )
                self.applySubtitle(
                    value.model?.subTitle,
                    outputSequence: value.outputSequence
                )
                self.applyButton(
                    value.model?.button,
                    outputSequence: value.outputSequence
                )
                self.applyImage(
                    value.model?.image,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyTitle(
                    value.title,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySubtitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applySubtitle(
                    value.subtitle,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayButtonModelState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyButton(
                    value.buttonModel,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayImageState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyImage(
                    value.image,
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
                self?.applyVisibility(
                    isHidden: value.isHidden,
                    animationConfig: .default,
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

        persistReplayCheckpoint()
    }

    private func applyVisibility(
        isHidden: Bool,
        animationConfig: EmptyViewAnimationConfig,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.animationConfig = animationConfig
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    private func applyTitle(
        _ title: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestTitleOutputSequence else { return }
        latestTitleOutputSequence = outputSequence
        self.title = title
        isTitleHidden = title == nil
        titleAdapter.display(model: title)
        persistReplayCheckpoint()
    }

    private func applySubtitle(
        _ subtitle: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestSubtitleOutputSequence else { return }
        latestSubtitleOutputSequence = outputSequence
        self.subtitle = subtitle
        isSubtitleHidden = subtitle == nil
        subtitleAdapter.display(model: subtitle)
        persistReplayCheckpoint()
    }

    private func applyButton(
        _ buttonModel: ButtonPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestButtonOutputSequence else { return }
        latestButtonOutputSequence = outputSequence
        setButtonModel(buttonModel)
        isButtonHidden = buttonModel == nil
        persistReplayCheckpoint()
    }

    private func applyImage(
        _ image: ImageViewPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestImageOutputSequence else { return }
        latestImageOutputSequence = outputSequence
        setImageModel(image)
        isImageHidden = image == nil
        imageAdapter.display(model: self.image)
        persistReplayCheckpoint()
    }

    private func setButtonModel(_ model: ButtonPresentableModel?) {
        guard let model else {
            if let retainedButtonModel {
                self.retainedButtonModel = ButtonPresentableModel(
                    spacing: retainedButtonModel.spacing,
                    height: retainedButtonModel.height,
                    width: retainedButtonModel.width,
                    style: retainedButtonModel.style,
                    enabled: retainedButtonModel.enabled
                )
            }
            buttonModel = nil
            return
        }

        let merged = ButtonPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            title: model.title,
            image: model.image,
            spacing: model.spacing ?? retainedButtonModel?.spacing,
            height: model.height ?? retainedButtonModel?.height,
            width: model.width ?? retainedButtonModel?.width,
            style: model.style ?? retainedButtonModel?.style,
            enabled: model.enabled ?? retainedButtonModel?.enabled,
            onPress: model.onPress
        )
        retainedButtonModel = merged
        buttonModel = merged
    }

    private func setImageModel(_ model: ImageViewPresentableModel?) {
        guard let model else {
            retainedImageModel = retainedImageModel.clearingForNilModel()
            image = nil
            return
        }
        retainedImageModel = retainedImageModel.mergingFullModel(model)
        image = retainedImageModel
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            isHidden: isHidden,
            title: title,
            subtitle: subtitle,
            buttonModel: buttonModel,
            image: image,
            animationConfig: animationConfig,
            isTitleHidden: isTitleHidden,
            isSubtitleHidden: isSubtitleHidden,
            isButtonHidden: isButtonHidden,
            isImageHidden: isImageHidden,
            retainedButtonModel: retainedButtonModel,
            retainedImageModel: retainedImageModel,
            titleAdapter: titleAdapter,
            subtitleAdapter: subtitleAdapter,
            imageAdapter: imageAdapter
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isHidden = checkpoint.isHidden
        title = checkpoint.title
        subtitle = checkpoint.subtitle
        buttonModel = checkpoint.buttonModel
        image = checkpoint.image
        animationConfig = checkpoint.animationConfig
        isTitleHidden = checkpoint.isTitleHidden
        isSubtitleHidden = checkpoint.isSubtitleHidden
        isButtonHidden = checkpoint.isButtonHidden
        isImageHidden = checkpoint.isImageHidden
        retainedButtonModel = checkpoint.retainedButtonModel
        retainedImageModel = checkpoint.retainedImageModel
    }
}
