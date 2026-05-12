import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

public struct SUIExpandableCardView: View {
    @StateObject private var stateModel: SUIExpandableCardViewStateModel
    private let stackSpacing: CGFloat
    private let primeCardHeight: CGFloat?
    private let secondaryCardHeight: CGFloat?

    public init(adapter: ExpandableCardViewOutputSwiftUIAdapter) {
        self.init(
            adapter: adapter,
            stackSpacing: 0,
            primeCardHeight: nil,
            secondaryCardHeight: nil
        )
    }

    public init(
        adapter: ExpandableCardViewOutputSwiftUIAdapter,
        stackSpacing: CGFloat,
        primeCardHeight: CGFloat?,
        secondaryCardHeight: CGFloat?
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.stackSpacing = stackSpacing
        self.primeCardHeight = primeCardHeight
        self.secondaryCardHeight = secondaryCardHeight
    }

    public var body: some View {
        if !stateModel.isHidden {
            VStack(spacing: stackSpacing) {
                cardView(
                    model: stateModel.primeModel,
                    adapter: stateModel.primeCardAdapter,
                    height: primeCardHeight
                )

                if stateModel.secondaryModel != nil {
                    cardView(
                        model: stateModel.secondaryModel,
                        adapter: stateModel.secondaryCardAdapter,
                        height: secondaryCardHeight
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private func cardView(
        model: CardViewPresentableModel?,
        adapter: CardViewOutputSwiftUIAdapter,
        height: CGFloat?
    ) -> some View {
        if model != nil {
            let card = SUICardView(adapter: adapter)
            if let height {
                card
                    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .top)
            } else {
                card
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}

private final class SUIExpandableCardViewStateModel: ObservableObject {
    @Published var primeModel: CardViewPresentableModel?
    @Published var secondaryModel: CardViewPresentableModel?
    @Published var isHidden: Bool = false

    let primeCardAdapter = CardViewOutputSwiftUIAdapter()
    let secondaryCardAdapter = CardViewOutputSwiftUIAdapter()

    private var cancellables: Set<AnyCancellable> = []

    init(adapter: ExpandableCardViewOutputSwiftUIAdapter) {
        adapter.$displayModelState
            .sink { [weak self] state in
                self?.apply(model: state?.model)
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .sink { [weak self] state in
                guard let state else { return }
                self?.isHidden = state.isHidden
            }
            .store(in: &cancellables)
    }

    private func apply(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>?) {
        guard let model else { return }

        primeModel = model.first
        secondaryModel = model.second

        primeCardAdapter.display(model: model.first)
        secondaryCardAdapter.display(model: model.second)
    }
}

#endif
