import Foundation
import SwiftUI
import WrapKit

enum SearchBarCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = SearchBarCatalogSceneAdapters()
        let presenter = SearchBarCatalogPresenter(onBack: onBack)

        presenter.headerOutput = adapters.chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = adapters.chrome.stack.weakReferenced.mainQueueDispatched
        presenter.searchBarOutput = adapters.searchBar.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched

        return AnyView(
            SearchBarCatalogView(
                presenter: presenter,
                adapters: adapters,
                configuration: .appleDefault
            )
        )
    }
}

private final class SearchBarCatalogSceneAdapters {
    let chrome = CatalogChromeAdapters()
    let searchBar = SearchBarOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: SearchBarCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let status = TextOutputSwiftUIAdapter()
}

private final class SearchBarCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var searchBarOutput: SearchBarOutput?
    var settingOutputs: [SearchBarCatalogSetting: CardViewOutput] = [:]
    var statusOutput: TextOutput?

    private let onBack: () -> Void
    private var didLoad = false
    private var query = ""
    private var settingStates = Dictionary(
        uniqueKeysWithValues: SearchBarCatalogSetting.allCases.map { ($0, false) }
    )

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "SearchBarOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        searchBarOutput?.display(model: makeModel())
        configureSettings()
        showStatus("Enter a query")
    }
}

private extension SearchBarCatalogPresenter {
    func makeModel() -> SearchBarPresentableModel {
        .init(
            textField: settingStates[.textFieldHidden] == true ? nil : makeTextField(),
            leftView: settingStates[.leftButtonHidden] == true ? nil : makeLeftButton(),
            rightView: settingStates[.rightButtonHidden] == true ? nil : makeRightButton(),
            placeholder: placeholder,
            backgroundColor: backgroundColor,
            spacing: spacing
        )
    }

    func makeLeftButton() -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.input.search.fill",
            accessibility: .init(label: "Insert an example query"),
            image: ImageFactory.systemImage(named: "magnifyingglass"),
            height: SearchBarCatalogMetrics.sideControlSize,
            width: SearchBarCatalogMetrics.sideControlSize,
            style: buttonStyle,
            onPress: { [weak self] in
                self?.toggleExample()
            }
        )
    }

    func makeRightButton() -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.input.search.clear",
            accessibility: .init(label: "Clear search"),
            image: ImageFactory.systemImage(named: "xmark.circle.fill"),
            height: SearchBarCatalogMetrics.sideControlSize,
            width: SearchBarCatalogMetrics.sideControlSize,
            style: buttonStyle,
            onPress: { [weak self] in
                self?.clear()
            }
        )
    }

    func makeTextField() -> TextInputPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.input.search",
            text: query,
            placeholder: placeholder,
            autocapitalizationType: .none,
            inputType: .webSearch,
            didChangeText: [ { [weak self] text in
                guard let self else { return }
                query = text ?? ""
                showStatus(query.isEmpty ? "Search cleared" : "Query: \(query)")
            }]
        )
    }

    func clear() {
        query = ""
        displayCurrentTextField()
        showStatus("Search cleared")
    }

    func toggleExample() {
        query = query.isEmpty ? "WrapKit" : ""
        displayCurrentTextField()
        showStatus(query.isEmpty ? "Example removed" : "Inserted the WrapKit query")
    }

    func displayCurrentTextField() {
        searchBarOutput?.display(
            textField: settingStates[.textFieldHidden] == true ? nil : makeTextField()
        )
    }

    func configureSettings() {
        SearchBarCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "catalog.input.search.setting.\(setting.rawValue)",
                    title: setting.title,
                    isOn: settingStates[setting] ?? false,
                    onToggle: { [weak self] output in
                        self?.toggle(setting, switchOutput: output)
                    }
                )
            )
        }
    }

    func toggle(
        _ setting: SearchBarCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .hidden:
            searchBarOutput?.display(model: isOn ? nil : makeModel())
        case .textFieldHidden:
            searchBarOutput?.display(textField: isOn ? nil : makeTextField())
        case .leftButtonHidden:
            searchBarOutput?.display(leftView: isOn ? nil : makeLeftButton())
        case .rightButtonHidden:
            searchBarOutput?.display(rightView: isOn ? nil : makeRightButton())
        case .shortPlaceholder:
            searchBarOutput?.display(placeholder: placeholder)
        case .blueBackground:
            searchBarOutput?.display(backgroundColor: backgroundColor)
        case .wideSpacing:
            searchBarOutput?.display(spacing: spacing)
        }
    }

    var placeholder: String {
        settingStates[.shortPlaceholder] == true ? "Search" : "Search components"
    }

    var backgroundColor: WrapKit.Color {
        settingStates[.blueBackground] == true
            ? .systemBlue.withAlphaComponent(0.16)
            : .secondarySystemBackground
    }

    var spacing: CGFloat {
        settingStates[.wideSpacing] == true
            ? 20
            : SearchBarCatalogMetrics.sideControlSpacing
    }

    var buttonStyle: WrapKit.ButtonStyle {
        .init(
            backgroundColor: .clear,
            titleColor: .secondaryLabel,
            cornerStyle: .automatic
        )
    }

    func showStatus(_ message: String) {
        displayInputCatalogStatus(message, on: statusOutput)
    }
}

private struct SearchBarCatalogView: View {
    let presenter: SearchBarCatalogPresenter
    let adapters: SearchBarCatalogSceneAdapters
    let configuration: InputCatalogViewConfiguration

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: adapters.chrome) {
                InputCatalogSurface {
                    SUISearchBar(
                        adapter: adapters.searchBar,
                        textFieldAppearance: configuration.searchAppearance,
                        spacing: SearchBarCatalogMetrics.sideControlSpacing,
                        cornerRadius: 10,
                        contentInsets: configuration.searchContentInsets
                    )
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(SearchBarCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                InputCatalogStatus(adapter: adapters.status)
            }
        }
    }
}

private enum SearchBarCatalogMetrics {
    static let sideControlSize: CGFloat = 44
    static let sideControlSpacing: CGFloat = 8
}
