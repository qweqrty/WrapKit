import SwiftUI
import WrapKit

enum TitledOutputCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = TitledOutputCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = TitledOutputCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.output = adapters.output.weakReferenced.mainQueueDispatched
        presenter.contentOutput = adapters.content.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(
            TitledOutputCatalogView(
                presenter: presenter,
                adapters: adapters,
                chrome: chrome
            )
        )
    }
}

private final class TitledOutputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var output: TitledOutput?
    var contentOutput: ButtonOutput?
    var settingOutputs: [TitledCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var preset: TitledCatalogPreset = .valid
    private var settingStates = Dictionary(
        uniqueKeysWithValues: TitledCatalogSetting.allCases.map { ($0, $0.initialIsOn) }
    )

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(
            model: CatalogAppearance.header(title: "TitledOutput", onBack: onBack)
        )
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        displayCurrentModel()
    }

    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}

    private var currentTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?> {
        switch preset {
        case .valid:
            return .init(.text("Display name"), .text("Optional"))
        case .invalid:
            return .init(
                .text("Display name"),
                .attributes([
                    .init(
                        text: "Required",
                        color: .systemRed,
                        font: .systemFont(ofSize: 13)
                    )
                ])
            )
        }
    }

    private var currentBottomTitles: Pair<
        TextOutputPresentableModel?,
        TextOutputPresentableModel?
    > {
        switch preset {
        case .valid:
            return .init(.text("Shown in your profile"), .text("12/40"))
        case .invalid:
            return .init(
                .attributes([
                    .init(
                        text: "Enter at least 3 characters",
                        color: .systemRed,
                        font: .systemFont(ofSize: 13)
                    )
                ]),
                .text("0/40")
            )
        }
    }

    private func displayCurrentModel() {
        let showsTitles = settingStates[.titles] == true
        let showsBottomTitles = settingStates[.bottomTitles] == true
        let isInteractive = settingStates[.interaction] == true

        if settingStates[.model] == true {
            output?.display(
                model: .init(
                    titles: showsTitles ? currentTitles : nil,
                    bottomTitles: showsBottomTitles ? currentBottomTitles : nil,
                    isUserInteractionEnabled: isInteractive
                )
            )
        } else {
            output?.display(model: nil)
        }
        if settingStates[.leadingBottomTitle] == true {
            output?.display(leadingBottomTitle: validationMessage)
        }
        if settingStates[.trailingBottomTitle] == true {
            output?.display(trailingBottomTitle: .text("40/40"))
        }
        if settingStates[.model] == true {
            output?.display(isHidden: settingStates[.hidden] == true)
        } else {
            output?.display(model: nil)
        }

        contentOutput?.display(
            model: CatalogAppearance.actionButton(
                id: preset == .valid ? "content.titled.value" : "content.titled.error",
                title: preset == .valid ? "Clear value" : "Fix value",
                style: preset == .valid
                    ? CatalogAppearance.secondaryButton
                    : CatalogAppearance.destructiveButton,
                onPress: { [weak self] in
                    guard let self else { return }
                    if preset == .valid {
                        settingStates[.validation] = true
                        preset = .invalid
                    } else {
                        settingStates[.validation] = false
                        preset = .valid
                    }
                    displayCurrentModel()
                }
            )
        )
        contentOutput?.display(enabled: isInteractive)
        configureSettingRows()
    }

    private var validationMessage: TextOutputPresentableModel {
        .attributes([
            .init(
                text: "Check this value",
                color: .systemRed,
                font: .systemFont(ofSize: 13, weight: .semibold)
            )
        ])
    }

    private func configureSettingRows() {
        TitledCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "titled.\(setting.rawValue)",
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
        _ setting: TitledCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .model:
            displayCurrentModel()
        case .validation:
            preset = isOn ? .invalid : .valid
            displayCurrentModel()
        case .titles:
            output?.display(titles: isOn ? currentTitles : .init(nil, nil))
        case .bottomTitles:
            output?.display(bottomTitles: isOn ? currentBottomTitles : .init(nil, nil))
            if settingStates[.leadingBottomTitle] == true {
                output?.display(leadingBottomTitle: validationMessage)
            }
            if settingStates[.trailingBottomTitle] == true {
                output?.display(trailingBottomTitle: .text("40/40"))
            }
        case .leadingBottomTitle:
            output?.display(leadingBottomTitle: isOn
                ? validationMessage
                : settingStates[.bottomTitles] == true ? currentBottomTitles.first : nil)
        case .trailingBottomTitle:
            output?.display(trailingBottomTitle: isOn
                ? .text("40/40")
                : settingStates[.bottomTitles] == true ? currentBottomTitles.second : nil)
        case .interaction:
            output?.display(isUserInteractionEnabled: isOn)
            contentOutput?.display(enabled: isOn)
        case .hidden:
            if settingStates[.model] == true {
                output?.display(isHidden: isOn)
            } else {
                output?.display(model: nil)
            }
        }
    }
}

private struct TitledOutputCatalogView: View {
    let presenter: TitledOutputCatalogPresenter
    let adapters: TitledOutputCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUITitledView(adapter: adapters.output, spacing: 6) {
                    SUIButton(adapter: adapters.content, pressAnimations: [.shrink])
                        .frame(maxWidth: .infinity)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(TitledCatalogSetting.allCases, id: \.rawValue) { setting in
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
