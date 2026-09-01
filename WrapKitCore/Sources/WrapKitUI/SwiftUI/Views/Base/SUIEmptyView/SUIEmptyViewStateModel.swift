//
//  SUIEmptyViewStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/5/26.
//

import Combine
import SwiftUI

public final class SUIEmptyViewStateModel: ObservableObject {
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

    private let adapter: EmptyViewOutputSwiftUIAdapter
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

        adapter.$displayModelState
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

        adapter.$displayTitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyTitle(
                    value.title,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.$displaySubtitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applySubtitle(
                    value.subtitle,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.$displayButtonModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyButton(
                    value.buttonModel,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.$displayImageState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyImage(
                    value.image,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyVisibility(
                    isHidden: value.isHidden,
                    animationConfig: .default,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
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
    }

    private func applyTitle(
        _ title: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestTitleOutputSequence else { return }
        latestTitleOutputSequence = outputSequence
        self.title = title
        isTitleHidden = title == nil
    }

    private func applySubtitle(
        _ subtitle: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestSubtitleOutputSequence else { return }
        latestSubtitleOutputSequence = outputSequence
        self.subtitle = subtitle
        isSubtitleHidden = subtitle == nil
    }

    private func applyButton(
        _ buttonModel: ButtonPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestButtonOutputSequence else { return }
        latestButtonOutputSequence = outputSequence
        setButtonModel(buttonModel)
        isButtonHidden = buttonModel == nil
    }

    private func applyImage(
        _ image: ImageViewPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestImageOutputSequence else { return }
        latestImageOutputSequence = outputSequence
        setImageModel(image)
        isImageHidden = image == nil
    }

    private func setButtonModel(_ model: ButtonPresentableModel?) {
        guard let model else {
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
}
