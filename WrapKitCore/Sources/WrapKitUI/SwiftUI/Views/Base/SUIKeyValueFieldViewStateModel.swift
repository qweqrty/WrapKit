//
//  SUIKeyValueFieldViewStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

final class SUIKeyValueFieldViewStateModel: ObservableObject {
    @Published var keyTitle: TextOutputPresentableModel?
    @Published var valueTitle: TextOutputPresentableModel?
    @Published var bottomImage: ImageViewPresentableModel?
    @Published var isHidden: Bool
    @Published private(set) var isKeySlotHidden = false
    @Published private(set) var isValueSlotHidden = false
    @Published private(set) var isBottomImageSlotHidden = true

    let bottomImageAdapter = ImageViewOutputSwiftUIAdapter()

    private let displaysBottomImage: Bool
    private var cancellables: Set<AnyCancellable> = []

    init(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter,
        displaysBottomImage: Bool,
        isHidden: Bool
    ) {
        self.displaysBottomImage = displaysBottomImage
        self.isHidden = isHidden

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(model: state.model)
            }
            .store(in: &cancellables)

        adapter.$displayKeyTitleState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(keyTitle: state.keyTitle)
            }
            .store(in: &cancellables)

        adapter.$displayValueTitleState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(valueTitle: state.valueTitle)
            }
            .store(in: &cancellables)

        adapter.$displayBottomImageState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(bottomImage: state.bottomImage)
            }
            .store(in: &cancellables)
    }
}

private extension SUIKeyValueFieldViewStateModel {
    func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        keyTitle = model?.first
        valueTitle = model?.second
        isKeySlotHidden = model?.first == nil
        isValueSlotHidden = model?.second == nil
        updateVisibility()
    }

    func display(keyTitle: TextOutputPresentableModel?) {
        self.keyTitle = keyTitle
        isKeySlotHidden = keyTitle == nil
        updateVisibility()
    }

    func display(valueTitle: TextOutputPresentableModel?) {
        self.valueTitle = valueTitle
        isValueSlotHidden = valueTitle == nil
        updateVisibility()
    }

    func display(bottomImage: ImageViewPresentableModel?) {
        guard displaysBottomImage else { return }

        self.bottomImage = bottomImage
        isBottomImageSlotHidden = bottomImage == nil
        bottomImageAdapter.display(model: bottomImage)
    }

    func updateVisibility() {
        let bottomSlotIsHidden = !displaysBottomImage || isBottomImageSlotHidden
        isHidden = isKeySlotHidden && isValueSlotHidden && bottomSlotIsHidden
    }
}

#endif
