import SwiftUI
import WrapKit

enum ProgressBarCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = ProgressBarCatalogAdapters()
        let presenter = ProgressBarCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.progressOutput = adapters.progress.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(ProgressBarCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class ProgressBarCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let progress = ProgressBarOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: ProgressCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class ProgressBarCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var progressOutput: ProgressBarOutput?
    var settingOutputs: [ProgressCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var progress: CGFloat = 24
    private var settingStates: [ProgressCatalogSetting: Bool] = [
        .model: true,
        .highProgress: false,
        .alternateStyle: false,
        .hidden: false
    ]

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "ProgressBarOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureProgress()
        showStatus("Ready")
    }
}

private extension ProgressBarCatalogPresenter {
    func configureProgress() {
        configureTargetProgress()

        ProgressCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.controls.progress.setting.\(setting.rawValue)",
                title: setting.title,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                }
            ))
        }
    }

    func configureTargetProgress() {
        guard settingStates[.model] == true else {
            progressOutput?.display(model: nil)
            return
        }

        progressOutput?.display(model: .init(
            progress: progress,
            style: ControlsCatalogAppearance.progressStyle(
                isAlternate: settingStates[.alternateStyle] == true
            )
        ))
        progressOutput?.display(isHidden: settingStates[.hidden] == true)
    }

    func toggleSetting(
        _ setting: ProgressCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .model:
            configureTargetProgress()
        case .highProgress:
            progress = isOn ? 80 : 24
            progressOutput?.display(progress: progress)
        case .alternateStyle:
            progressOutput?.display(
                style: isOn ? ControlsCatalogAppearance.progressStyle(isAlternate: true) : nil
            )
        case .hidden:
            if settingStates[.model] == true {
                progressOutput?.display(isHidden: isOn)
            } else {
                progressOutput?.display(model: nil)
            }
        }

        showStatus("\(setting.title): \(isOn ? "on" : "off")")
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct ProgressBarCatalogView: View {
    let presenter: ProgressBarCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: ProgressBarCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Live ProgressBarOutput")
                    SUIProgressBar(adaper: adapters.progress)
                        .frame(maxWidth: .infinity)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Settings")
                    ForEach(ProgressCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                ControlsCatalogStatusView(adapter: adapters.status)
            }
        }
    }
}
