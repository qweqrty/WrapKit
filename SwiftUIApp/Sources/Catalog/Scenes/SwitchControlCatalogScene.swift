import SwiftUI
import WrapKit

enum SwitchControlCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = SwitchControlCatalogAdapters()
        let presenter = SwitchControlCatalogPresenter(
            onBack: onBack,
            switchStyle: ControlsCatalogViewConfiguration.appleDefault.switchStyle
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.switchOutput = adapters.switchControl.weakReferenced.mainQueueDispatched
        presenter.loadingOutput = adapters.switchControl.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(SwitchControlCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class SwitchControlCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let switchControl = SwitchCotrolOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: SwitchCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class SwitchControlCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var switchOutput: SwitchCotrolOutput?
    var loadingOutput: LoadingOutput?
    var settingOutputs: [SwitchCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let switchStyle: SwitchControlPresentableModel.Style
    private var didLoad = false
    private var isSwitchOn = true
    private var settingStates: [SwitchCatalogSetting: Bool] = [
        .model: true,
        .isOn: true,
        .enabled: true,
        .tintColor: false,
        .thumbTintColor: false,
        .backgroundColor: false,
        .cornerRadius: false,
        .loading: false,
        .action: true,
        .hidden: false
    ]

    init(
        onBack: @escaping () -> Void,
        switchStyle: SwitchControlPresentableModel.Style
    ) {
        self.onBack = onBack
        self.switchStyle = switchStyle
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "SwitchControlOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureSwitch()
        showStatus("Ready")
    }
}

private extension SwitchControlCatalogPresenter {
    func configureSwitch() {
        configureTargetSwitch()
        configureSettingRows()
    }

    func configureTargetSwitch() {
        guard settingStates[.model] == true else {
            switchOutput?.display(model: nil)
            return
        }

        switchOutput?.display(model: .init(
            accessibilityIdentifier: "catalog.controls.actionsSwitch",
            onPress: settingStates[.action] == true
                ? { [weak self] output in self?.targetSwitchDidPress(using: output) }
                : nil,
            isOn: isSwitchOn,
            isEnabled: settingStates[.enabled] == true,
            style: currentStyle
        ))
        switchOutput?.display(isHidden: settingStates[.hidden] == true)
        loadingOutput?.display(isLoading: settingStates[.loading] == true)
    }

    func configureSettingRows() {
        SwitchCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.controls.switch.setting.\(setting.rawValue)",
                title: setting.title,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                }
            ))
        }
    }

    func toggleSetting(
        _ setting: SwitchCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .model:
            configureTargetSwitch()
        case .isOn:
            isSwitchOn = isOn
            self.switchOutput?.display(isOn: isOn)
        case .enabled:
            self.switchOutput?.display(isEnabled: isOn)
        case .tintColor, .thumbTintColor, .backgroundColor, .cornerRadius:
            self.switchOutput?.display(style: currentStyle)
        case .loading:
            loadingOutput?.display(isLoading: isOn)
        case .action:
            if isOn {
                self.switchOutput?.display(isOn: isSwitchOn)
                self.switchOutput?.display(
                    onPress: { [weak self] output in self?.targetSwitchDidPress(using: output) }
                )
            } else {
                self.switchOutput?.display(onPress: nil)
            }
        case .hidden:
            if settingStates[.model] == true {
                self.switchOutput?.display(isHidden: isOn)
            } else {
                self.switchOutput?.display(model: nil)
            }
        }

        showStatus("\(setting.title): \(isOn ? "on" : "off")")
    }

    func targetSwitchDidPress(using output: SwitchCotrolOutput & LoadingOutput) {
        isSwitchOn.toggle()
        settingStates[.isOn] = isSwitchOn
        output.display(isOn: isSwitchOn)
        configureSettingRows()
        showStatus(isSwitchOn ? "Switch is on" : "Switch is off")
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }

    var currentStyle: SwitchControlPresentableModel.Style {
        .init(
            tintColor: settingStates[.tintColor] == true ? .systemPurple : switchStyle.tintColor,
            thumbTintColor: settingStates[.thumbTintColor] == true
                ? .systemYellow
                : switchStyle.thumbTintColor,
            backgroundColor: settingStates[.backgroundColor] == true
                ? .systemBlue.withAlphaComponent(0.24)
                : switchStyle.backgroundColor,
            cornerRadius: settingStates[.cornerRadius] == true ? 8 : switchStyle.cornerRadius,
            shimmerStyle: switchStyle.shimmerStyle
        )
    }
}

private struct SwitchControlCatalogView: View {
    let presenter: SwitchControlCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: SwitchControlCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Live SwitchControlOutput")
                    SUISwitchControl(adapter: adapters.switchControl)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Settings")
                    ForEach(SwitchCatalogSetting.allCases, id: \.rawValue) { setting in
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
