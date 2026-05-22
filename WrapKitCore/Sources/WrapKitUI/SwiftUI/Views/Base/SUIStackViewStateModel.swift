//
//  SUIStackViewStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

final class SUIStackViewStateModel: ObservableObject {
    @Published var axis: StackViewAxis
    @Published var distribution: StackViewDistribution
    @Published var alignment: StackViewAlignment
    @Published var spacing: CGFloat
    @Published var layoutMargins: EdgeInsets
    @Published var isHidden: Bool

    private var cancellables: Set<AnyCancellable> = []

    init(
        adapter: StackViewOutputSwiftUIAdapter,
        axis: StackViewAxis,
        distribution: StackViewDistribution,
        alignment: StackViewAlignment,
        spacing: CGFloat,
        layoutMargins: EdgeInsets,
        isHidden: Bool
    ) {
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        self.layoutMargins = layoutMargins
        self.isHidden = isHidden

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(model: state.model)
            }
            .store(in: &cancellables)

        adapter.$displaySpacingState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(spacing: state.spacing)
            }
            .store(in: &cancellables)

        adapter.$displayAxisState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.axis = state.axis
            }
            .store(in: &cancellables)

        adapter.$displayDistributionState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.distribution = state.distribution
            }
            .store(in: &cancellables)

        adapter.$displayAlignmentState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.alignment = state.alignment
            }
            .store(in: &cancellables)

        adapter.$displayLayoutMarginsState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.layoutMargins = state.layoutMargins
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

private extension SUIStackViewStateModel {
    func display(model: StackViewPresentableModel) {
        if let axis = model.axis {
            self.axis = axis
        }
        if let distribution = model.distribution {
            self.distribution = distribution
        }
        if let alignment = model.alignment {
            self.alignment = alignment
        }
        if let layoutMargins = model.layoutMargins {
            self.layoutMargins = layoutMargins
        }
        display(spacing: model.spacing)
    }

    func display(spacing: CGFloat?) {
        guard let spacing else { return }
        self.spacing = spacing
    }
}

#endif
