import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

final class SUINavigationBarStateModel: ObservableObject {
    static let defaultStyle: HeaderPresentableModel.Style = .init(
        backgroundColor: .clear,
        horizontalSpacing: 12,
        primeFont: .systemFont(ofSize: 18),
        primeColor: .label,
        secondaryFont: .systemFont(ofSize: 14),
        secondaryColor: .secondaryLabel,
        numberOfLines: 1
    )
    @Published var model: HeaderPresentableModel = .init(style: SUINavigationBarStateModel.defaultStyle)
    @Published var isHidden: Bool = false

    let leadingCardAdapter = CardViewOutputSwiftUIAdapter()

    private var cancellables: Set<AnyCancellable> = []

    init(adapter: HeaderOutputSwiftUIAdapter) {
        adapter.$displayModelState
            .sink { [weak self] state in
                self?.setModel(state?.model)
            }
            .store(in: &cancellables)

        adapter.$displayStyleState
            .sink { [weak self] state in
                guard let style = state?.style else { return }
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displayCenterViewState
            .sink { [weak self] state in
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: state?.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displayLeadingCardState
            .sink { [weak self] state in
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: state?.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displayPrimeTrailingImageState
            .sink { [weak self] state in
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: state?.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displaySecondaryTrailingImageState
            .sink { [weak self] state in
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: state?.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displayTertiaryTrailingImageState
            .sink { [weak self] state in
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: state?.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .sink { [weak self] state in
                guard let state else { return }
                self?.isHidden = state.isHidden
            }
            .store(in: &cancellables)

        syncLeadingCardAdapter()
    }

    private func setModel(_ model: HeaderPresentableModel?) {
        isHidden = model == nil
        guard let model else {
            self.model = .init(style: Self.defaultStyle)
            syncLeadingCardAdapter()
            return
        }
        self.model = .init(
            style: model.style ?? self.model.style ?? Self.defaultStyle,
            centerView: model.centerView ?? self.model.centerView,
            leadingCard: model.leadingCard ?? self.model.leadingCard,
            primeTrailingImage: model.primeTrailingImage ?? self.model.primeTrailingImage,
            secondaryTrailingImage: model.secondaryTrailingImage ?? self.model.secondaryTrailingImage,
            tertiaryTrailingImage: model.tertiaryTrailingImage ?? self.model.tertiaryTrailingImage
        )
        syncLeadingCardAdapter()
    }

    private func updateModel(_ transform: (HeaderPresentableModel) -> HeaderPresentableModel) {
        model = transform(model)
        syncLeadingCardAdapter()
    }

    private func syncLeadingCardAdapter() {
        leadingCardAdapter.display(model: model.leadingCard)
    }
}
#endif
