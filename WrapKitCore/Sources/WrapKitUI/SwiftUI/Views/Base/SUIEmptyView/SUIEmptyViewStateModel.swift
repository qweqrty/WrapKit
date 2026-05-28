//
//  SUIEmptyViewStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/5/26.
//


import Combine
import SwiftUI

public final class SUIEmptyViewStateModel: ObservableObject {
    @Published var isHidden: Bool = true
    @Published var title: TextOutputPresentableModel? = nil
    @Published var subtitle: TextOutputPresentableModel? = nil
    @Published var buttonModel: ButtonPresentableModel? = nil
    @Published var image: ImageViewPresentableModel? = nil
    @Published var animationConfig: EmptyViewAnimationConfig = .default

    private let adapter: EmptyViewOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: EmptyViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isHidden = value.model == nil
                self.title = value.model?.title
                self.subtitle = value.model?.subTitle
                self.buttonModel = value.model?.button
                self.image = value.model?.image
                self.animationConfig = value.model?.animationConfig ?? .default
            }
            .store(in: &cancellables)

        adapter.$displayTitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.title = value.title
            }
            .store(in: &cancellables)

        adapter.$displaySubtitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.subtitle = value.subtitle
            }
            .store(in: &cancellables)

        adapter.$displayButtonModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.buttonModel = value.buttonModel
            }
            .store(in: &cancellables)

        adapter.$displayImageState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.image = value.image
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }
}
