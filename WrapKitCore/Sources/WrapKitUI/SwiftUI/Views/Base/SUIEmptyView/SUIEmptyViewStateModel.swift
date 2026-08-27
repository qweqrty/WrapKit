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

    public init(adapter: EmptyViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isHidden = value.model == nil
                self.title = value.model?.title
                self.subtitle = value.model?.subTitle
                self.setButtonModel(value.model?.button)
                self.setImageModel(value.model?.image)
                self.isTitleHidden = value.model?.title == nil
                self.isSubtitleHidden = value.model?.subTitle == nil
                self.isButtonHidden = value.model?.button == nil
                self.isImageHidden = value.model?.image == nil
                self.animationConfig = value.model?.animationConfig
                    ?? EmptyViewAnimationConfig(isAnimated: true, duration: 0.3)
            }
            .store(in: &cancellables)

        adapter.$displayTitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.title = value.title
                self?.isTitleHidden = value.title == nil
            }
            .store(in: &cancellables)

        adapter.$displaySubtitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.subtitle = value.subtitle
                self?.isSubtitleHidden = value.subtitle == nil
            }
            .store(in: &cancellables)

        adapter.$displayButtonModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.setButtonModel(value.buttonModel)
                self?.isButtonHidden = value.buttonModel == nil
            }
            .store(in: &cancellables)

        adapter.$displayImageState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.setImageModel(value.image)
                self?.isImageHidden = value.image == nil
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.animationConfig = .default
                self?.isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }

    private func setButtonModel(_ model: ButtonPresentableModel?) {
        guard let model else {
            buttonModel = nil
            return
        }

        let merged = ButtonPresentableModel(
            accessibilityIdentifier: model.accessibilityIdentifier,
            title: model.title,
            spacing: model.spacing ?? retainedButtonModel?.spacing,
            style: model.style ?? retainedButtonModel?.style,
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
