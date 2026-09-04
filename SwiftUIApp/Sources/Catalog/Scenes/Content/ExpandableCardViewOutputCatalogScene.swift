import SwiftUI
import WrapKit

enum ExpandableCardViewOutputCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = ExpandableCardViewOutputCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = ExpandableCardViewOutputCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.output = adapters.output.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.actionOutputs = adapters.actions.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(
            ExpandableCardViewOutputCatalogView(
                presenter: presenter,
                adapters: adapters,
                chrome: chrome
            )
        )
    }
}

private final class ExpandableCardViewOutputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var output: ExpandableCardViewOutput?
    var settingOutputs: [ExpandableCatalogSetting: CardViewOutput] = [:]
    var actionOutputs: [ExpandableCardViewOutputCatalogAction: ButtonOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var isExpanded = false
    private var isHidden = false

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(
            model: CatalogAppearance.header(title: "ExpandableCardViewOutput", onBack: onBack)
        )
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureActions()
        output?.display(isHidden: false)
        showCard()
        configureSettingRows()
    }

    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}

    private func configureActions() {
        ExpandableCardViewOutputCatalogAction.allCases.forEach { action in
            actionOutputs[action]?.display(
                model: CatalogAppearance.actionButton(
                    id: "catalog.content.expandable.\(action.rawValue)",
                    title: action.title,
                    onPress: { [weak self] in self?.toggleExpansion() }
                )
            )
        }
    }

    private func configureSettingRows() {
        ExpandableCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "expandable.\(setting.rawValue)",
                    title: setting.title,
                    value: setting.subtitle,
                    isOn: isHidden,
                    onToggle: { [weak self] switchOutput in
                        self?.toggle(setting, switchOutput: switchOutput)
                    }
                )
            )
        }
    }

    private func toggle(
        _ setting: ExpandableCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        switch setting {
        case .hidden:
            isHidden.toggle()
            switchOutput.display(isOn: isHidden)
            output?.display(isHidden: isHidden)
        }
    }

    private func toggleExpansion() {
        isExpanded.toggle()
        showCard()
    }

    private func showCard() {
        let prime = makeCard(
            id: "usage-summary",
            symbol: "chart.bar.fill",
            title: "Monthly spending",
            value: "$1,780",
            subtitle: isExpanded
                ? "Tap to collapse"
                : "Tap to view details",
            accentColor: .systemIndigo,
            accessibilityHint: isExpanded
                ? "Double-tap to collapse"
                : "Double-tap to expand",
            onPress: { [weak self] in self?.toggleExpansion() },
            onLongPress: { [weak self] in self?.toggleExpansion() }
        )

        let details = isExpanded
            ? makeCard(
                id: "usage-details",
                symbol: "network",
                title: "Groceries",
                value: "$860",
                subtitle: "Utilities and subscriptions: $920",
                accentColor: .systemTeal,
                accessibilityHint: "Double-tap to collapse details",
                onPress: { [weak self] in self?.toggleExpansion() },
                onLongPress: nil
            )
            : nil

        output?.display(model: .init(prime, details))
    }

    private func makeCard(
        id: String,
        symbol: String,
        title: String,
        value: String,
        subtitle: String,
        accentColor: WrapKit.Color,
        accessibilityHint: String,
        onPress: (() -> Void)?,
        onLongPress: (() -> Void)?
    ) -> CardViewPresentableModel {
        .init(
            id: id,
            accessibilityIdentifier: "content.card.\(id)",
            accessibility: .init(
                label: "\(title), \(value), \(subtitle)",
                hint: accessibilityHint
            ),
            style: makeStyle(accentColor: accentColor),
            title: .text(title),
            leadingImage: .systemSymbol(
                symbol,
                accessibility: .init(label: title),
                size: .init(width: 28, height: 28),
                contentModeIsFit: true
            ),
            subTitle: .text(subtitle),
            valueTitle: .text(value),
            onPress: onPress,
            onLongPress: onLongPress,
            isUserInteractionEnabled: true,
            isGradientBorderEnabled: false
        )
    }

    private func makeStyle(accentColor: WrapKit.Color) -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: .systemBackground,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .init(horizontal: 12, vertical: 10),
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: accentColor,
            titleKeyTextColor: .label,
            trailingTitleKeyTextColor: .label,
            titleValueTextColor: .label,
            subTitleTextColor: .secondaryLabel,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 15, weight: .semibold),
            titleKeyLabelFont: .systemFont(ofSize: 16, weight: .semibold),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 15),
            titleValueLabelFont: .systemFont(ofSize: 15, weight: .semibold),
            subTitleLabelFont: .systemFont(ofSize: 13),
            subtitleNumberOfLines: 2,
            cornerRadius: 14,
            stackSpace: 3,
            hStackViewSpacing: 10,
            titleKeyNumberOfLines: 2,
            titleValueNumberOfLines: 1,
            borderColor: .separator,
            borderWidth: 0.5,
            trailingImageLeadingSpacing: 8
        )
    }
}

private struct ExpandableCardViewOutputCatalogView: View {
    let presenter: ExpandableCardViewOutputCatalogPresenter
    let adapters: ExpandableCardViewOutputCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIExpandableCardView(adapter: adapters.output)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .top)

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(
                        ExpandableCardViewOutputCatalogAction.allCases,
                        id: \.rawValue
                    ) { action in
                        if let adapter = adapters.actions[action] {
                            SUIButton(adapter: adapter, pressAnimations: [.shrink])
                        }
                    }
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(ExpandableCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}
