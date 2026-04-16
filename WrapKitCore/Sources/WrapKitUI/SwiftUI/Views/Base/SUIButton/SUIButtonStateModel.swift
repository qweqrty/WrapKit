//
//  SUIButtonStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 15/4/26.
//

import Combine
import UIKit

public final class SUIButtonStateModel: ObservableObject {
    @Published var presentable: ButtonPresentableModel = .init()
    @Published var isHidden: Bool = false
    @Published var isEnabled: Bool = true
    
    @Published private var adapter: ButtonOutputSwiftUIAdapter
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: ButtonOutputSwiftUIAdapter) {
        self.adapter = adapter
        
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.presentable = value.model
                self.isHidden = false
                if let enabled = value.model.enabled {
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
                self?.isEnabled = value.enabled
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
                guard let self else { return }
                self.presentable = self.presentable.merging(style: value.style)
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
    }
}

private extension ButtonPresentableModel {
    func merging(
        title: String?? = .none,
        image: Image?? = .none,
        style: ButtonStyle?? = .none,
        spacing: CGFloat? = nil,
        height: CGFloat? = nil,
        onPress: (() -> Void)?? = .none
    ) -> ButtonPresentableModel {
        ButtonPresentableModel(
            accessibilityIdentifier: self.accessibilityIdentifier,
            title: title ?? self.title,
            image: image ?? self.image,
            spacing: spacing ?? self.spacing,
            contentInset: self.contentInset,
            height: height ?? self.height,
            width: self.width,
            style: style ?? self.style,
            enabled: self.enabled,
            onPress: onPress ?? self.onPress
        )
    }
}
