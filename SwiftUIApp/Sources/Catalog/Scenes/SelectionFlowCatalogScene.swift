import Combine
import SwiftUI
import WrapKit

private final class SelectionFlowCatalogAdapters {
    let chrome = CatalogChromeAdapters()
    let description = TextOutputSwiftUIAdapter()
    let result = TextOutputSwiftUIAdapter()
    let singleButton = ButtonOutputSwiftUIAdapter()
    let multipleButton = ButtonOutputSwiftUIAdapter()
    let servicedButton = ButtonOutputSwiftUIAdapter()
}

private final class SelectionFlowCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var descriptionOutput: TextOutput?
    var resultOutput: TextOutput?
    var singleButtonOutput: ButtonOutput?
    var multipleButtonOutput: ButtonOutput?
    var servicedButtonOutput: ButtonOutput?

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private var didLoad = false

    init(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) {
        self.onBack = onBack
        self.selectionFlow = selectionFlow
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "SelectionFlow",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        descriptionOutput?.display(model: .text(
            "Use the same selection flow for a single choice or a searchable list of multiple choices."
        ))
        resultOutput?.display(model: .text("No selection yet"))
        singleButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.selection.single",
            title: "Single selection",
            style: CatalogAppearance.primaryButton,
            onPress: { [weak self] in self?.showSingleSelection() }
        ))
        multipleButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.selection.multiple",
            title: "Multiple selection with search",
            style: CatalogAppearance.secondaryButton,
            onPress: { [weak self] in self?.showMultipleSelection() }
        ))
        servicedButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.selection.serviced",
            title: "Serviced selection with refresh",
            style: CatalogAppearance.secondaryButton,
            onPress: { [weak self] in self?.showServicedSelection() }
        ))
    }

    private func showSingleSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Layout density",
            isMultipleSelectionEnabled: false,
            items: [
                makeItem(id: "compact", title: "Compact", trailingTitle: "44 pt", selectionStyle: .radio),
                makeItem(id: "comfortable", title: "Comfortable", trailingTitle: "52 pt", isSelected: true, selectionStyle: .radio),
                makeItem(id: "spacious", title: "Spacious", trailingTitle: "60 pt", selectionStyle: .radio),
            ],
            callback: { [weak self] result in
                guard case let .singleSelection(item) = result else { return }
                self?.resultOutput?.display(model: .text("Selected: \(item.title)"))
            },
            emptyViewPresentableModel: emptyModel
        ))
    }

    private func showMultipleSelection() {
        let items = (1 ... 18).map { index in
            makeItem(
                id: "option-\(index)",
                title: "Option \(index)",
                trailingTitle: index.isMultiple(of: 3) ? "Recommended" : nil,
                isSelected: index == 2 || index == 5,
                selectionStyle: .checkbox
            )
        }
        selectionFlow.showSelection(model: .init(
            title: "Visible options",
            isMultipleSelectionEnabled: true,
            items: items,
            callback: { [weak self] result in
                guard case let .multipleSelection(items) = result else { return }
                let titles = items.map(\.title).joined(separator: ", ")
                self?.resultOutput?.display(model: .text(
                    titles.isEmpty ? "No options selected" : "Selected: \(titles)"
                ))
            },
            emptyViewPresentableModel: emptyModel
        ))
    }

    private func showServicedSelection() {
        let storage = InMemoryStorage<[SelectionType.SelectionCellPresentableModel]>()
        let service = CatalogSelectionOptionsService()
            .composed(secondaryStorage: storage)
        selectionFlow.showSelection(model: ServicedSelectionModel(
            model: .init(
                title: "Loaded options",
                isMultipleSelectionEnabled: true,
                items: [],
                callback: { [weak self] result in
                    guard case let .multipleSelection(items) = result else { return }
                    self?.resultOutput?.display(model: .text(
                        items.isEmpty
                            ? "No loaded options selected"
                            : "Loaded selection: \(items.map(\.title).joined(separator: ", "))"
                    ))
                },
                emptyViewPresentableModel: emptyModel
            ),
            service: service,
            storage: storage,
            request: { CatalogSelectionOptionsRequest() },
            response: { result in
                (try? result.get()) ?? []
            }
        ))
    }

    private var emptyModel: EmptyViewPresentableModel {
        .init(
            title: .text("No matching options"),
            subTitle: .text("Try a different search term."),
            image: .systemSymbol(
                "magnifyingglass",
                accessibility: .init(label: "Search"),
                size: .init(width: 44, height: 44),
                contentModeIsFit: true
            )
        )
    }

    private func makeItem(
        id: String,
        title: String,
        trailingTitle: String? = nil,
        isSelected: Bool = false,
        selectionStyle: SelectionIndicatorStyle
    ) -> SelectionType.SelectionCellPresentableModel {
        .init(
            id: id,
            title: title,
            isSelected: isSelected,
            trailingTitle: trailingTitle,
            configuration: selectionStyle == .radio
                ? CatalogSelectionAppearance.cell
                : CatalogSelectionAppearance.multipleCell
        )
    }
}

private enum SelectionIndicatorStyle: Equatable {
    case radio
    case checkbox
}

enum SelectionFlowCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let adapters = SelectionFlowCatalogAdapters()
        let presenter = SelectionFlowCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow
        )

        presenter.headerOutput = adapters.chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = adapters.chrome.stack.weakReferenced.mainQueueDispatched
        presenter.descriptionOutput = adapters.description.weakReferenced.mainQueueDispatched
        presenter.resultOutput = adapters.result.weakReferenced.mainQueueDispatched
        presenter.singleButtonOutput = adapters.singleButton.weakReferenced.mainQueueDispatched
        presenter.multipleButtonOutput = adapters.multipleButton.weakReferenced.mainQueueDispatched
        presenter.servicedButtonOutput = adapters.servicedButton.weakReferenced.mainQueueDispatched

        return AnyView(SelectionFlowCatalogScene(
            presenter: presenter,
            adapters: adapters
        ))
    }
}

private struct SelectionFlowCatalogScene: View {
    let presenter: SelectionFlowCatalogPresenter
    let adapters: SelectionFlowCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: adapters.chrome) {
                SUILabel(
                    adapter: adapters.description,
                    font: .systemFont(ofSize: 15),
                    textColor: .secondaryLabel,
                    textAlignment: .left
                )
                .fixedSize(horizontal: false, vertical: true)

                SUIButton(adapter: adapters.singleButton, pressAnimations: [.shrink])
                SUIButton(adapter: adapters.multipleButton, pressAnimations: [.shrink])
                SUIButton(adapter: adapters.servicedButton, pressAnimations: [.shrink])

                SUILabel(
                    adapter: adapters.result,
                    font: .systemFont(ofSize: 14, weight: .medium),
                    textColor: .secondaryLabel,
                    textAlignment: .left
                )
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct CatalogSelectionOptionsRequest {}

private final class CatalogSelectionOptionsService: Service {
    func make(
        request _: CatalogSelectionOptionsRequest
    ) -> AnyPublisher<[SelectionType.SelectionCellPresentableModel], ServiceError> {
        let items = (1 ... 20).map { index in
            SelectionType.SelectionCellPresentableModel(
                id: "loaded-option-\(index)",
                title: "Loaded option \(index)",
                isSelected: index == 3,
                trailingTitle: index.isMultiple(of: 4) ? "From service" : nil,
                configuration: CatalogSelectionAppearance.multipleCell
            )
        }

        return Just(items)
            .delay(for: .milliseconds(350), scheduler: DispatchQueue.main)
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
}
