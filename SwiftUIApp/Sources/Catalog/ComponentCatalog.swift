import SwiftUI
import WrapKit

struct CatalogOutputItem: Identifiable, Hashable {
    let id: String
    let title: String
    let destination: CatalogOutputDestination

    init(title: String, destination: CatalogOutputDestination) {
        id = destination.id
        self.title = title
        self.destination = destination
    }

    static func == (lhs: CatalogOutputItem, rhs: CatalogOutputItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum CatalogOutputDestination: CaseIterable {
    case textOutput
    case imageViewOutput
    case cardViewOutput
    case expandableCardViewOutput
    case titledOutput
    case emptyViewOutput
    case buttonOutput
    case switchControlOutput
    case segmentedControlOutput
    case progressBarOutput
    case loadingOutput
    case lottieViewOutput
    case refreshControlOutput
    case commonToastOutput
    case searchBarOutput
    case textInputOutput
    case datePickerViewOutput
    case pickerViewOutput
    case stackViewOutput
    case tableOutput
    case keyValueFieldViewOutput
    case headerOutput
    case selectionFlow

    var id: String {
        switch self {
        case .textOutput: return "content.textOutput"
        case .imageViewOutput: return "content.image"
        case .cardViewOutput: return "content.card"
        case .expandableCardViewOutput: return "content.expandableCard"
        case .titledOutput: return "content.titled"
        case .emptyViewOutput: return "content.empty"
        case .buttonOutput: return "controls.button"
        case .switchControlOutput: return "controls.switchControl"
        case .segmentedControlOutput: return "controls.segmentedControl"
        case .progressBarOutput: return "controls.progressBar"
        case .loadingOutput: return "controls.loading"
        case .lottieViewOutput: return "controls.lottie"
        case .refreshControlOutput: return "controls.refresh"
        case .commonToastOutput: return "controls.toast"
        case .searchBarOutput: return "input.searchBar"
        case .textInputOutput: return "input.textInput"
        case .datePickerViewOutput: return "input.datePicker"
        case .pickerViewOutput: return "input.picker"
        case .stackViewOutput: return "layout.stackViewOutput"
        case .tableOutput: return "layout.tableOutput"
        case .keyValueFieldViewOutput: return "layout.keyValueFieldViewOutput"
        case .headerOutput: return "navigation.header"
        case .selectionFlow: return "flow.selection"
        }
    }

    var title: String {
        switch self {
        case .textOutput: return "TextOutput"
        case .imageViewOutput: return "ImageViewOutput"
        case .cardViewOutput: return "CardViewOutput"
        case .expandableCardViewOutput: return "ExpandableCardViewOutput"
        case .titledOutput: return "TitledOutput"
        case .emptyViewOutput: return "EmptyViewOutput"
        case .buttonOutput: return "ButtonOutput"
        case .switchControlOutput: return "SwitchControlOutput"
        case .segmentedControlOutput: return "SegmentedControlOutput"
        case .progressBarOutput: return "ProgressBarOutput"
        case .loadingOutput: return "LoadingOutput"
        case .lottieViewOutput: return "LottieViewOutput"
        case .refreshControlOutput: return "RefreshControlOutput"
        case .commonToastOutput: return "CommonToastOutput"
        case .searchBarOutput: return "SearchBarOutput"
        case .textInputOutput: return "TextInputOutput"
        case .datePickerViewOutput: return "DatePickerViewOutput"
        case .pickerViewOutput: return "PickerViewOutput"
        case .stackViewOutput: return "StackViewOutput"
        case .tableOutput: return "TableOutput"
        case .keyValueFieldViewOutput: return "KeyValueFieldViewOutput"
        case .headerOutput: return "HeaderOutput"
        case .selectionFlow: return "SelectionFlow"
        }
    }

    init?(launchValue: String) {
        guard let destination = Self.allCases.first(where: {
            $0.id.caseInsensitiveCompare(launchValue) == .orderedSame
                || $0.title.caseInsensitiveCompare(launchValue) == .orderedSame
        }) else { return nil }
        self = destination
    }
}

private enum CatalogOutputData {
    static let outputs = CatalogOutputDestination.allCases.map { destination in
        CatalogOutputItem(title: destination.title, destination: destination)
    }
}

private final class ComponentCatalogAdapters {
    let header = HeaderOutputSwiftUIAdapter()
    let table = TableOutputSwiftUIAdapter<CatalogOutputItem, Void, Void>()
    let buttons: [String: ButtonOutputSwiftUIAdapter]

    init(outputs: [CatalogOutputItem]) {
        buttons = Dictionary(
            uniqueKeysWithValues: outputs.map { output in
                (output.id, ButtonOutputSwiftUIAdapter())
            }
        )
    }

    func button(for output: CatalogOutputItem) -> ButtonOutputSwiftUIAdapter {
        guard let adapter = buttons[output.id] else {
            preconditionFailure("Missing button adapter for \(output.id)")
        }
        return adapter
    }
}

protocol ComponentCatalogPresenterRouting: AnyObject {
    func show(_ destination: CatalogOutputDestination)
}

final class ComponentCatalogFlow: ObservableObject, ComponentCatalogPresenterRouting {
    @Published private(set) var selectedDestination: CatalogOutputDestination?

    private(set) var selectedScene: AnyView?
    private let factory: ComponentCatalogSceneFactory

    init(factory: ComponentCatalogSceneFactory) {
        self.factory = factory
    }

    func show(_ destination: CatalogOutputDestination) {
        selectedScene = factory.makeScene(
            for: destination,
            onBack: { [weak self] in self?.navigateBack() }
        )
        selectedDestination = destination
    }

    func navigateBack() {
        selectedScene = nil
        selectedDestination = nil
    }
}

private final class ComponentCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var tableOutput: (any TableOutput<Void, CatalogOutputItem, Void>)?
    var buttonOutputs: [String: ButtonOutput] = [:]

    private weak var flow: ComponentCatalogPresenterRouting?
    private let outputs: [CatalogOutputItem]
    private var hasLoaded = false

    init(
        outputs: [CatalogOutputItem],
        flow: ComponentCatalogPresenterRouting
    ) {
        self.outputs = outputs
        self.flow = flow
    }

    func viewDidLoad() {
        guard !hasLoaded else { return }
        hasLoaded = true

        headerOutput?.display(model: CatalogAppearance.header(title: "WrapKit Design System"))
        tableOutput?.display(sections: [
            .init(cells: outputs.map { output in
                .init(
                    accessibilityIdentifier: "catalog.output.\(output.id)",
                    cell: output
                )
            })
        ])

        outputs.forEach { output in
            buttonOutputs[output.id]?.display(model: CatalogAppearance.actionButton(
                id: "catalog.output.button.\(output.id)",
                title: output.title,
                style: CatalogAppearance.primaryButton,
                onPress: { [weak self] in
                    self?.flow?.show(output.destination)
                }
            ))
        }
    }
}

struct ComponentCatalogSceneFactory {
    let selectionFlow: any SelectionFlow

    func makeScene(
        for output: CatalogOutputDestination,
        onBack: @escaping () -> Void
    ) -> AnyView {
        switch output {
        case .textOutput:
            return TextOutputCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .imageViewOutput: return ImageViewOutputCatalogSceneFactory.make(onBack: onBack)
        case .cardViewOutput: return CardViewOutputCatalogSceneFactory.make(onBack: onBack)
        case .expandableCardViewOutput: return ExpandableCardViewOutputCatalogSceneFactory.make(onBack: onBack)
        case .titledOutput: return TitledOutputCatalogSceneFactory.make(onBack: onBack)
        case .emptyViewOutput:
            return EmptyViewOutputCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .buttonOutput: return ButtonCatalogSceneFactory.make(onBack: onBack)
        case .switchControlOutput: return SwitchControlCatalogSceneFactory.make(onBack: onBack)
        case .segmentedControlOutput: return SegmentedControlCatalogSceneFactory.make(onBack: onBack)
        case .progressBarOutput: return ProgressBarCatalogSceneFactory.make(onBack: onBack)
        case .loadingOutput: return LoadingCatalogSceneFactory.make(onBack: onBack)
        case .lottieViewOutput:
            return LottieCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .refreshControlOutput: return RefreshControlCatalogSceneFactory.make(onBack: onBack)
        case .commonToastOutput:
            return CommonToastCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .searchBarOutput: return SearchBarCatalogSceneFactory.make(onBack: onBack)
        case .textInputOutput:
            return TextInputCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .datePickerViewOutput:
            return DatePickerCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .pickerViewOutput: return PickerCatalogSceneFactory.make(onBack: onBack)
        case .stackViewOutput:
            return StackViewCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        case .tableOutput: return TableCatalogSceneFactory.make(onBack: onBack)
        case .keyValueFieldViewOutput: return KeyValueFieldCatalogSceneFactory.make(onBack: onBack)
        case .headerOutput: return HeaderCatalogSceneFactory.make(onBack: onBack)
        case .selectionFlow:
            return SelectionFlowCatalogSceneFactory.make(
                onBack: onBack,
                selectionFlow: selectionFlow
            )
        }
    }
}

struct ComponentCatalogFactory {
    func makeCatalog(
        selectionFlow injectedSelectionFlow: SelectionFlowSwiftUI? = nil,
        initialDestination: CatalogOutputDestination? = nil
    ) -> AnyView {
        let outputs = CatalogOutputData.outputs
        let adapters = ComponentCatalogAdapters(outputs: outputs)
        let selectionFlow = injectedSelectionFlow ?? SelectionFlowSwiftUI()
        let flow = ComponentCatalogFlow(factory: ComponentCatalogSceneFactory(
            selectionFlow: selectionFlow.mainQueueDispatched
        ))
        let presenter = ComponentCatalogPresenter(outputs: outputs, flow: flow)

        presenter.headerOutput = adapters.header.weakReferenced.mainQueueDispatched
        presenter.tableOutput = MainQueueDispatchDecorator(
            decoratee: WeakRefVirtualProxy(adapters.table)
        )
        outputs.forEach { output in
            presenter.buttonOutputs[output.id] = adapters
                .button(for: output)
                .weakReferenced
                .mainQueueDispatched
        }
        if let initialDestination {
            flow.show(initialDestination)
        }

        return AnyView(
            ComponentCatalogView(
                presenter: presenter,
                flow: flow,
                adapters: adapters,
                selectionFlow: selectionFlow
            )
        )
    }
}

private struct ComponentCatalogView: View {
    private let presenter: ComponentCatalogPresenter
    private let adapters: ComponentCatalogAdapters
    @StateObject private var flow: ComponentCatalogFlow
    @StateObject private var selectionFlow: SelectionFlowSwiftUI

    init(
        presenter: ComponentCatalogPresenter,
        flow: ComponentCatalogFlow,
        adapters: ComponentCatalogAdapters,
        selectionFlow: SelectionFlowSwiftUI
    ) {
        self.presenter = presenter
        _flow = StateObject(wrappedValue: flow)
        _selectionFlow = StateObject(wrappedValue: selectionFlow)
        self.adapters = adapters
    }

    var body: some View {
        SUISelectionSheetHost(flow: selectionFlow) {
            LifeCycleView(lifeCycleOutput: presenter) {
                SUIStackView(axis: .vertical, spacing: 0) {
                    SUINavigationBar(adapter: adapters.header)

                    SUITableView(
                        adapter: adapters.table,
                        style: .lazyVStack(scrollable: true),
                        cellContent: { output, indexPath in
                            SUIButton(adapter: adapters.button(for: output))
                                .padding(.horizontal, 16)
                                .padding(.top, indexPath.row == 0 ? 12 : 0)
                                .padding(.bottom, 12)
                        },
                        headerContent: { _ in SwiftUI.EmptyView() },
                        footerContent: { _ in SwiftUI.EmptyView() }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(SwiftUI.Color(uiColor: .systemGroupedBackground))
                .background(navigationLink)
                .navigationBarHidden(true)
            }
        }
    }

    private var navigationLink: some View {
        NavigationLink(
            destination: selectedDestinationView,
            isActive: isDetailPresented
        ) {
            SwiftUI.EmptyView()
        }
        .frame(width: 0, height: 0)
        .hidden()
    }

    private var selectedDestinationView: AnyView {
        flow.selectedScene ?? AnyView(SwiftUI.EmptyView())
    }

    private var isDetailPresented: Binding<Bool> {
        Binding(
            get: { flow.selectedDestination != nil },
            set: { isPresented in
                if !isPresented {
                    flow.navigateBack()
                }
            }
        )
    }
}
