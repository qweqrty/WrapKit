//
//  SUITitledViewStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

final class SUITitledViewStateModel: ObservableObject {
    @Published var isHidden = false
    @Published var isUserInteractionEnabled = true

    let titlesAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
    let bottomTitlesAdapter = KeyValueFieldViewOutputSwiftUIAdapter()

    private var titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    private var bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    private var cancellables: Set<AnyCancellable> = []

    init(adapter: TitledOutputSwiftUIAdapter) {
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(model: state.model)
            }
            .store(in: &cancellables)

        adapter.$displayTitlesState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(titles: state.titles)
            }
            .store(in: &cancellables)

        adapter.$displayBottomTitlesState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(bottomTitles: state.bottomTitles)
            }
            .store(in: &cancellables)

        adapter.$displayLeadingBottomTitleState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(leadingBottomTitle: state.leadingBottomTitle)
            }
            .store(in: &cancellables)

        adapter.$displayTrailingBottomTitleState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(trailingBottomTitle: state.trailingBottomTitle)
            }
            .store(in: &cancellables)

        adapter.$displayIsUserInteractionEnabledState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.isUserInteractionEnabled = state.isUserInteractionEnabled
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.isHidden = state.isHidden
            }
            .store(in: &cancellables)
    }
}

private extension SUITitledViewStateModel {
    func display(model: TitledViewPresentableModel?) {
        isHidden = model == nil
        guard let model else { return }

        if let titles = model.titles {
            display(titles: titles)
        }

        if let bottomTitles = model.bottomTitles {
            display(bottomTitles: bottomTitles)
        }

        isUserInteractionEnabled = model.isUserInteractionEnabled
    }

    func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        self.titles = titles
        titlesAdapter.display(model: titles)
    }

    func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        self.bottomTitles = bottomTitles
        bottomTitlesAdapter.display(model: bottomTitles)
    }

    func display(leadingBottomTitle: TextOutputPresentableModel?) {
        bottomTitles = .init(leadingBottomTitle, bottomTitles?.second)
        bottomTitlesAdapter.display(keyTitle: leadingBottomTitle)
    }

    func display(trailingBottomTitle: TextOutputPresentableModel?) {
        bottomTitles = .init(bottomTitles?.first, trailingBottomTitle)
        bottomTitlesAdapter.display(valueTitle: trailingBottomTitle)
    }
}

#endif
