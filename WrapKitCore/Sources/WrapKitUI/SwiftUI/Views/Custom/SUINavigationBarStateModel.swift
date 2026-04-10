#if canImport(Combine)
import Combine

public final class SUINavigationBarStateModel: ObservableObject {
    @Published var model: HeaderPresentableModel?
    @Published var style: HeaderPresentableModel.Style?
    @Published var centerView: HeaderPresentableModel.CenterView?
    @Published var leadingCard: CardViewPresentableModel?
    @Published var primeTrailingImage: ButtonPresentableModel?
    @Published var secondaryTrailingImage: ButtonPresentableModel?
    @Published var tertiaryTrailingImage: ButtonPresentableModel?
    @Published var isHidden = false

    @Published private var adapter: HeaderOutputSwiftUIAdapter

    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: HeaderOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .sink { [weak self] value in
                guard let self, let value else { return }
                apply(model: value.model)
            }
            .store(in: &cancellables)

        adapter.$displayStyleState
            .sink { [weak self] value in
                guard let self, let value else { return }
                style = value.style
            }
            .store(in: &cancellables)

        adapter.$displayCenterViewState
            .sink { [weak self] value in
                guard let self, let value else { return }
                centerView = value.centerView
            }
            .store(in: &cancellables)

        adapter.$displayLeadingCardState
            .sink { [weak self] value in
                guard let self, let value else { return }
                leadingCard = value.leadingCard
            }
            .store(in: &cancellables)

        adapter.$displayPrimeTrailingImageState
            .sink { [weak self] value in
                guard let self, let value else { return }
                primeTrailingImage = value.primeTrailingImage
            }
            .store(in: &cancellables)

        adapter.$displaySecondaryTrailingImageState
            .sink { [weak self] value in
                guard let self, let value else { return }
                secondaryTrailingImage = value.secondaryTrailingImage
            }
            .store(in: &cancellables)

        adapter.$displayTertiaryTrailingImageState
            .sink { [weak self] value in
                guard let self, let value else { return }
                tertiaryTrailingImage = value.tertiaryTrailingImage
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .sink { [weak self] value in
                guard let self, let value else { return }
                isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }

    private func apply(model: HeaderPresentableModel) {
        self.model = model
        style = model.style
        centerView = model.centerView
        leadingCard = model.leadingCard
        primeTrailingImage = model.primeTrailingImage
        secondaryTrailingImage = model.secondaryTrailingImage
        tertiaryTrailingImage = model.tertiaryTrailingImage
    }
}
#endif
