import SwiftUI
import WrapKit

enum ButtonCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = ButtonCatalogAdapters()
        let presenter = ButtonCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.primaryButtonOutput = adapters.primaryButton.weakReferenced.mainQueueDispatched
        presenter.secondaryButtonOutput = adapters.secondaryButton.weakReferenced.mainQueueDispatched
        presenter.disabledButtonOutput = adapters.disabledButton.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(ButtonCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class ButtonCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let primaryButton = ButtonOutputSwiftUIAdapter()
    let secondaryButton = ButtonOutputSwiftUIAdapter()
    let disabledButton = ButtonOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: ButtonCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class ButtonCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var primaryButtonOutput: ButtonOutput?
    var secondaryButtonOutput: ButtonOutput?
    var disabledButtonOutput: ButtonOutput?
    var settingOutputs: [ButtonCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var primaryActionCount = 0
    private var settingStates: [ButtonCatalogSetting: Bool] = [
        .model: true,
        .enabled: true,
        .image: true,
        .destructiveStyle: false,
        .title: true,
        .spacing: true,
        .action: true,
        .largeHeight: true,
        .hidden: false
    ]

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(title: "ButtonOutput", onBack: onBack))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureButtons()
        showStatus("Ready")
    }
}

private extension ButtonCatalogPresenter {
    func configureButtons() {
        configurePrimaryButton()

        secondaryButtonOutput?.display(model: .init(
            accessibilityIdentifier: "catalog.controls.secondaryButton",
            accessibility: .init(label: "Secondary button"),
            title: "Secondary button",
            height: 48,
            style: ControlsCatalogAppearance.outlineButtonStyle(),
            enabled: true,
            onPress: { [weak self] in self?.showStatus("Secondary button pressed") }
        ))

        disabledButtonOutput?.display(model: .init(
            accessibilityIdentifier: "catalog.controls.disabledButton",
            accessibility: .init(label: "Disabled state", hint: "This button is disabled"),
            title: "Disabled state",
            height: 48,
            style: ControlsCatalogAppearance.primaryButtonStyle(),
            enabled: false
        ))

        configureSettingRows()
    }

    func configurePrimaryButton() {
        guard settingStates[.model] == true else {
            primaryButtonOutput?.display(model: nil)
            return
        }

        primaryButtonOutput?.display(model: .init(
            accessibilityIdentifier: "catalog.controls.primaryButton",
            accessibility: .init(
                label: "Interactive button",
                hint: "Use the settings below"
            ),
            title: settingStates[.title] == true ? "Interactive button" : nil,
            image: settingStates[.image] == true
                ? ImageFactory.systemImage(named: "checkmark.circle.fill")
                : nil,
            spacing: settingStates[.spacing] == true ? 12 : 0,
            height: settingStates[.largeHeight] == true ? 56 : 44,
            style: settingStates[.destructiveStyle] == true
                ? ControlsCatalogAppearance.destructiveButtonStyle()
                : ControlsCatalogAppearance.primaryButtonStyle(),
            enabled: settingStates[.enabled] == true,
            onPress: settingStates[.action] == true
                ? { [weak self] in self?.performPrimaryButtonAction() }
                : nil
        ))
        primaryButtonOutput?.display(isHidden: settingStates[.hidden] == true)
    }

    func configureSettingRows() {
        ButtonCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.controls.button.setting.\(setting.rawValue)",
                title: setting.title,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                }
            ))
        }
    }

    func toggleSetting(
        _ setting: ButtonCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .model:
            configurePrimaryButton()
        case .enabled:
            primaryButtonOutput?.display(enabled: isOn)
        case .image:
            primaryButtonOutput?.display(
                image: isOn ? ImageFactory.systemImage(named: "checkmark.circle.fill") : nil
            )
        case .destructiveStyle:
            if isOn {
                primaryButtonOutput?.display(
                    style: ControlsCatalogAppearance.destructiveButtonStyle()
                )
            } else {
                primaryButtonOutput?.display(style: nil)
                primaryButtonOutput?.display(style: ControlsCatalogAppearance.primaryButtonStyle())
            }
        case .title:
            primaryButtonOutput?.display(title: isOn ? "Interactive button" : nil)
        case .spacing:
            primaryButtonOutput?.display(spacing: isOn ? 12 : 0)
        case .action:
            primaryButtonOutput?.display(onPress: isOn ? { [weak self] in
                self?.performPrimaryButtonAction()
            } : nil)
        case .largeHeight:
            primaryButtonOutput?.display(height: isOn ? 56 : 44)
        case .hidden:
            if settingStates[.model] == true {
                primaryButtonOutput?.display(isHidden: isOn)
            } else {
                primaryButtonOutput?.display(model: nil)
            }
        }

        showStatus("\(setting.title): \(isOn ? "on" : "off")")
    }

    func performPrimaryButtonAction() {
        primaryActionCount += 1
        showStatus("Completed: \(primaryActionCount)")
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct ButtonCatalogView: View {
    let presenter: ButtonCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: ButtonCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Live variants")
                    SUIButton(adapter: adapters.primaryButton, pressAnimations: [.shrink])
                        .accentColor(.white)
                        .frame(maxWidth: .infinity)
                    SUIButton(adapter: adapters.secondaryButton, pressAnimations: [.shrink])
                        .frame(maxWidth: .infinity)
                    SUIButton(adapter: adapters.disabledButton)
                        .frame(maxWidth: .infinity)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Button settings")
                    ForEach(ButtonCatalogSetting.allCases, id: \.rawValue) { setting in
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
