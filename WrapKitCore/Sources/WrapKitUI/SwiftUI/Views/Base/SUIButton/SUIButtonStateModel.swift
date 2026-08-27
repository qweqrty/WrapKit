//
//  SUIButtonStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 15/4/26.
//

import Combine
import Foundation

public final class SUIButtonStateModel: ObservableObject {
    @Published var presentable: ButtonPresentableModel = .init()
    @Published var isHidden: Bool = false
    @Published var isEnabled: Bool = true
    @Published var isLoading: Bool = false
    
    private let adapter: ButtonOutputSwiftUIAdapter
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        adapter: ButtonOutputSwiftUIAdapter,
        loadingAdapter: LoadingOutputSwiftUIAdapter? = nil
    ) {
        self.adapter = adapter
        
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                let current = self.presentable
                let model = value.model
                self.presentable = ButtonPresentableModel(
                    accessibilityIdentifier: model?.accessibilityIdentifier,
                    accessibility: model?.accessibility,
                    title: model?.title,
                    image: model?.image,
                    spacing: model?.spacing ?? current.spacing,
                    height: model?.height ?? current.height,
                    width: model?.width,
                    style: model?.style ?? current.style,
                    enabled: model?.enabled ?? current.enabled,
                    onPress: model?.onPress
                )
                self.isHidden = model == nil
                if let enabled = model?.enabled {
                    self.isEnabled = enabled
                }
            }
            .store(in: &cancellables)
        
        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isHidden = value.isHidden
            }
            .store(in: &cancellables)
        
        adapter.$displayEnabledState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isEnabled = value.enabled
                self.presentable = self.presentable.merging(enabled: value.enabled)
            }
            .store(in: &cancellables)
        
        adapter.$displayTitleState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.presentable = self.presentable.merging(title: value.title)
            }
            .store(in: &cancellables)
        
        adapter.$displayImageState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.presentable = self.presentable.merging(image: value.image)
            }
            .store(in: &cancellables)
        
        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, let style = value.style else { return }
                self.presentable = self.presentable.merging(style: style)
            }
            .store(in: &cancellables)
        
        adapter.$displaySpacingState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.presentable = self.presentable.merging(spacing: value.spacing)
            }
            .store(in: &cancellables)
        
        adapter.$displayHeightState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.presentable = self.presentable.merging(height: value.height)
            }
            .store(in: &cancellables)
        
        adapter.$displayOnPressState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.presentable = self.presentable.merging(onPress: value.onPress)
            }
            .store(in: &cancellables)
        
        loadingAdapter?.$isLoading
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value
            }
            .store(in: &cancellables)

        loadingAdapter?.$displayIsLoadingState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value.isLoading
            }
            .store(in: &cancellables)
    }
}

private extension ButtonPresentableModel {
    func merging(
        title: String?? = .none,
        image: Image?? = .none,
        style: ButtonStyle?? = .none,
        spacing: CGFloat? = nil,
        height: CGFloat? = nil,
        enabled: Bool? = nil,
        onPress: (() -> Void)?? = .none
    ) -> ButtonPresentableModel {
        ButtonPresentableModel(
            accessibilityIdentifier: self.accessibilityIdentifier,
            accessibility: self.accessibility,
            title: title ?? self.title,
            image: image ?? self.image,
            spacing: spacing ?? self.spacing,
            height: height ?? self.height,
            width: self.width,
            style: style ?? self.style,
            enabled: enabled ?? self.enabled,
            onPress: onPress ?? self.onPress
        )
    }
}
