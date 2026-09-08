import SwiftUI
import WrapKit

enum CardViewOutputCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = CardViewOutputCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = CardViewOutputCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.output = adapters.output.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.enableAllOutput = adapters.enableAll.weakReferenced.mainQueueDispatched
        presenter.resetOutput = adapters.reset.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(
            CardViewOutputCatalogView(
                presenter: presenter,
                adapters: adapters,
                chrome: chrome
            )
        )
    }
}

private final class CardViewOutputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var output: CardViewOutput?
    var statusOutput: TextOutput?
    var enableAllOutput: ButtonOutput?
    var resetOutput: ButtonOutput?
    var settingOutputs: [CardCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var settingStates = Dictionary(
        uniqueKeysWithValues: CardCatalogSetting.allCases.map { ($0, $0.initialIsOn) }
    )
    private var isSelected = false
    private var isSwitchOn = false

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(
            model: CatalogAppearance.header(title: "CardViewOutput", onBack: onBack)
        )
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureActions()
        showPlayground()
    }

    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}

    private func configureActions() {
        enableAllOutput?.display(
            model: CatalogAppearance.actionButton(
                id: "catalog.content.card.enableAll",
                title: "Enable all",
                onPress: { [weak self] in self?.enableAll() }
            )
        )
        resetOutput?.display(
            model: CatalogAppearance.actionButton(
                id: "catalog.content.card.reset",
                title: "Reset",
                style: CatalogAppearance.destructiveButton,
                onPress: { [weak self] in self?.reset() }
            )
        )
    }

    private func showPlayground() {
        isSelected = false
        isSwitchOn = false
        settingStates = Dictionary(
            uniqueKeysWithValues: CardCatalogSetting.allCases.map { ($0, $0.initialIsOn) }
        )

        restoreCurrentModel()
        statusOutput?.display(text: "Card is ready")
        configureSettingRows()
    }

    private func restoreCurrentModel() {
        guard settingStates[.model] == true else {
            output?.display(model: nil)
            return
        }

        output?.display(
            model: .init(
                id: "card-playground",
                accessibilityIdentifier: "content.card.playground",
                accessibility: .init(
                    label: "Experimental card",
                    hint: "The settings are below"
                ),
                style: makeStyle(isChipStyle: false),
                title: .text("Primary card"),
                isUserInteractionEnabled: false,
                isGradientBorderEnabled: false
            )
        )

        CardCatalogSetting.allCases
            .filter { $0 != .model }
            .forEach { setting in
                apply(setting, isOn: settingStates[setting] ?? false)
            }
    }

    private func configureSettingRows() {
        CardCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "card.\(setting.rawValue)",
                    title: setting.title,
                    value: setting.subtitle,
                    isOn: settingStates[setting] ?? false,
                    onToggle: { [weak self] switchOutput in
                        self?.toggle(setting, switchOutput: switchOutput)
                    }
                )
            )
        }
    }

    private func toggle(
        _ setting: CardCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        apply(setting, isOn: isOn)
    }

    private func apply(_ setting: CardCatalogSetting, isOn: Bool) {

        switch setting {
        case .model:
            if isOn {
                restoreCurrentModel()
                statusOutput?.display(text: "Full CardViewOutput model restored")
            } else {
                output?.display(model: nil)
                statusOutput?.display(text: "display(model: nil) sent")
            }
        case .title:
            output?.display(title: isOn ? .text("Card") : nil)
        case .valueTitle:
            output?.display(valueTitle: isOn ? .text("$24") : nil)
        case .subTitle:
            output?.display(subTitle: isOn ? .text("Info") : nil)
        case .leadingImage:
            output?.display(
                leadingImage: isOn
                    ? .systemSymbol("creditcard.fill", size: .init(width: 28, height: 28))
                    : nil
            )
        case .secondaryLeadingImage:
            output?.display(
                secondaryLeadingImage: isOn
                    ? .systemSymbol("star.fill", size: .init(width: 20, height: 20))
                    : nil
            )
        case .trailingImage:
            output?.display(
                trailingImage: isOn
                    ? .systemSymbol("chevron.right", size: .init(width: 16, height: 16))
                    : nil
            )
        case .secondaryTrailingImage:
            output?.display(
                secondaryTrailingImage: isOn
                    ? .systemSymbol("bell.fill", size: .init(width: 20, height: 20))
                    : nil
            )
        case .leadingTitles:
            output?.display(
                leadingTitles: isOn
                    ? .init(.text("NEW"), .text("1"))
                    : nil
            )
        case .trailingTitles:
            output?.display(
                trailingTitles: isOn ? .init(.text("State"), .text("On")) : nil
            )
        case .switchControl:
            output?.display(switchControl: isOn ? makeSwitchModel() : nil)
            updateInteraction()
        case .bottomImage:
            output?.display(
                bottomImage: isOn
                    ? .systemSymbol(
                        "ellipsis.rectangle.fill",
                        size: .init(width: 120, height: 22),
                        contentModeIsFit: true
                    )
                    : nil
            )
        case .bottomSeparator:
            output?.display(
                bottomSeparator: isOn
                    ? .init(
                        color: .systemBlue,
                        padding: .init(horizontal: 12, vertical: 0),
                        height: 2
                    )
                    : nil
            )
        case .backgroundImage:
            output?.display(
                backgroundImage: isOn
                    ? .systemSymbol(
                        "circle.grid.2x2.fill",
                        size: .init(width: 220, height: 100),
                        contentModeIsFit: true,
                        alpha: 0.14
                    )
                    : nil
            )
        case .gradientBorder:
            output?.display(isGradientBorderEnabled: isOn)
        case .chipStyle:
            output?.display(isGradientBorderEnabled: false)
            output?.display(style: makeStyle(isChipStyle: isOn))
            if settingStates[.gradientBorder] == true {
                output?.display(isGradientBorderEnabled: true)
            }
        case .interaction:
            output?.display(onPress: isOn ? { [weak self] in self?.didPress() } : nil)
            output?.display(onLongPress: isOn ? { [weak self] in self?.didLongPress() } : nil)
            updateInteraction()
        case .hidden:
            if settingStates[.model] == true {
                output?.display(isHidden: isOn)
            } else {
                output?.display(model: nil)
            }
        }
    }

    private func enableAll() {
        isSelected = false
        isSwitchOn = false
        settingStates = Dictionary(
            uniqueKeysWithValues: CardCatalogSetting.allCases.map {
                ($0, $0 != .hidden)
            }
        )

        restoreCurrentModel()
        configureSettingRows()
        statusOutput?.display(text: "All card properties are enabled")
    }

    private func reset() {
        showPlayground()
        statusOutput?.display(text: "Card reset")
    }

    private func updateInteraction() {
        let isEnabled = settingStates[.interaction] == true
            || settingStates[.switchControl] == true
        output?.display(isUserInteractionEnabled: isEnabled)
    }

    private func didPress() {
        isSelected.toggle()
        statusOutput?.display(text: isSelected ? "Card selected" : "Selection cleared")
    }

    private func didLongPress() {
        isSelected = false
        statusOutput?.display(text: "Long press cleared the selection")
    }

    private func switchDidPress(_ switchOutput: SwitchCotrolOutput & LoadingOutput) {
        isSwitchOn.toggle()
        switchOutput.display(isOn: isSwitchOn)
    }

    private func makeStyle(isChipStyle: Bool) -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: isChipStyle ? .systemGray5 : .systemBackground,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: isChipStyle
                ? .init(horizontal: 10, vertical: 6)
                : .init(horizontal: 12, vertical: 10),
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: isChipStyle ? .secondaryLabel : .systemBlue,
            titleKeyTextColor: isChipStyle ? .secondaryLabel : .label,
            trailingTitleKeyTextColor: isChipStyle ? .secondaryLabel : .label,
            titleValueTextColor: isChipStyle ? .secondaryLabel : .systemBlue,
            subTitleTextColor: .secondaryLabel,
            leadingTitleKeyLabelFont: .systemFont(
                ofSize: isChipStyle ? 12 : 13,
                weight: .semibold
            ),
            titleKeyLabelFont: .systemFont(
                ofSize: isChipStyle ? 14 : 16,
                weight: .semibold
            ),
            trailingTitleKeyLabelFont: .systemFont(ofSize: isChipStyle ? 12 : 13),
            titleValueLabelFont: .systemFont(
                ofSize: isChipStyle ? 13 : 14,
                weight: .semibold
            ),
            subTitleLabelFont: .systemFont(ofSize: isChipStyle ? 12 : 13),
            subtitleNumberOfLines: 2,
            cornerStyle: isChipStyle ? .automatic : .fixed(14),
            stackSpace: 3,
            hStackViewSpacing: isChipStyle ? 6 : 8,
            titleKeyNumberOfLines: 2,
            titleValueNumberOfLines: 1,
            borderColor: isChipStyle ? .systemGray3 : .separator,
            borderWidth: isChipStyle ? 0.7 : 0.5,
            gradientBorderColors: [.systemBlue, .systemPurple, .systemPink],
            trailingImageLeadingSpacing: 6,
            secondaryTrailingImageLeadingSpacing: 6
        )
    }

    private func makeSwitchModel() -> SwitchControlPresentableModel {
        .init(
            accessibilityIdentifier: "content.card.target.switch",
            onPress: { [weak self] switchOutput in
                self?.switchDidPress(switchOutput)
            },
            isOn: isSwitchOn,
            isEnabled: true,
            style: CatalogAppearance.settingSwitch
        )
    }
}

private struct CardViewOutputCatalogView: View {
    let presenter: CardViewOutputCatalogPresenter
    let adapters: CardViewOutputCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUICardView(adapter: adapters.output)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)

                SUILabel(
                    adapter: adapters.status,
                    font: .systemFont(ofSize: 13),
                    textColor: .secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

                SUIStackView(distribution: .fillEqually, axis: .horizontal, spacing: 8) {
                    SUIButton(adapter: adapters.enableAll)
                    SUIButton(adapter: adapters.reset)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(CardCatalogSetting.allCases, id: \.rawValue) { setting in
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
