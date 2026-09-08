import Foundation
import SwiftUI
import WrapKit

enum RefreshControlCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = RefreshControlCatalogAdapters()
        let presenter = RefreshControlCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.refreshOutput = adapters.refresh.weakReferenced.mainQueueDispatched
        presenter.clearModelButtonOutput = adapters.clearModelButton.weakReferenced.mainQueueDispatched
        presenter.restoreModelButtonOutput = adapters.restoreModelButton.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(RefreshControlCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class RefreshControlCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let refresh = RefreshControlOutputSwiftUIAdapter()
    let clearModelButton = ButtonOutputSwiftUIAdapter()
    let restoreModelButton = ButtonOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: RefreshCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class RefreshControlCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var refreshOutput: RefreshControlOutput?
    var clearModelButtonOutput: ButtonOutput?
    var restoreModelButtonOutput: ButtonOutput?
    var settingOutputs: [RefreshCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var refreshRequestVersion = 0
    private var refreshAppendCount = 0
    private var settingStates: [RefreshCatalogSetting: Bool] = [
        .purpleTint: true,
        .behindContent: false,
        .directCallbacks: false,
        .primaryCallback: true,
        .appendedCallback: false
    ]

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "RefreshControlOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureRefresh()
        configureButtons()
        showStatus("Ready")
    }

    func viewWillDisappear() {
        refreshRequestVersion += 1
        refreshOutput?.display(isLoading: false)
    }
}

private extension RefreshControlCatalogPresenter {
    func configureRefresh() {
        refreshOutput?.display(model: .init(
            style: currentStyle,
            onRefresh: nil,
            isLoading: false
        ))
        configureRefreshCallbacks()

        RefreshCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.controls.refresh.setting.\(setting.rawValue)",
                title: setting.title,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                }
            ))
        }
    }

    func toggleSetting(
        _ setting: RefreshCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .purpleTint, .behindContent:
            refreshOutput?.display(style: currentStyle)
        case .directCallbacks, .primaryCallback, .appendedCallback:
            configureRefreshCallbacks()
        }

        showStatus("\(setting.title) — \(isOn ? "on" : "off")")
    }

    func configureRefreshCallbacks() {
        if settingStates[.directCallbacks] == true {
            var callbacks: [(() -> Void)?] = []
            if settingStates[.primaryCallback] == true {
                callbacks.append({ [weak self] in self?.refreshContent() })
            }
            if settingStates[.appendedCallback] == true {
                callbacks.append({ [weak self] in self?.appendedRefreshDidRun() })
            }
            refreshOutput?.onRefresh = callbacks
            return
        }

        refreshOutput?.onRefresh = nil
        refreshOutput?.display(onRefresh: settingStates[.primaryCallback] == true
            ? { [weak self] in self?.refreshContent() }
            : nil
        )

        if settingStates[.appendedCallback] == true {
            refreshOutput?.display(appendingOnRefresh: { [weak self] in
                self?.appendedRefreshDidRun()
            })
        }
    }

    var currentStyle: RefreshControlPresentableModel.Style {
        .init(
            tintColor: settingStates[.purpleTint] == true ? .systemPurple : .systemBlue,
            zPosition: settingStates[.behindContent] == true ? -1 : 0
        )
    }

    func configureButtons() {
        clearModelButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.refresh.model.nil",
            title: "Call display(model: nil)",
            onPress: { [weak self] in self?.clearRefreshModel() }
        ))
        restoreModelButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.refresh.model.restore",
            title: "Restore the configured model",
            onPress: { [weak self] in self?.restoreRefreshModel() }
        ))
    }

    func clearRefreshModel() {
        refreshRequestVersion += 1
        refreshOutput?.display(isLoading: false)
        refreshOutput?.display(model: nil)
        showStatus("display(model: nil) cleared refresh actions; the current tint is retained")
    }

    func restoreRefreshModel() {
        configureRefresh()
        showStatus("Refresh model restored with the current settings")
    }

    func refreshContent() {
        refreshRequestVersion += 1
        let version = refreshRequestVersion
        refreshOutput?.display(isLoading: true)
        showStatus("Refreshing…")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self, self.refreshRequestVersion == version else { return }
            self.refreshOutput?.display(isLoading: false)
            self.showStatus("Updated")
        }
    }

    func appendedRefreshDidRun() {
        refreshAppendCount += 1
        showStatus("Additional refresh actions: \(refreshAppendCount)")
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct RefreshControlCatalogView: View {
    let presenter: RefreshControlCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: RefreshControlCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Live RefreshControlOutput")
                    SUILabelView(
                        model: .text("Pull down to refresh"),
                        font: .systemFont(ofSize: 15, weight: .medium),
                        textColor: .label
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Next pull-to-refresh settings")
                    ForEach(RefreshCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    SUIButton(adapter: adapters.clearModelButton, pressAnimations: [.shrink])
                    SUIButton(adapter: adapters.restoreModelButton, pressAnimations: [.shrink])
                }

                ControlsCatalogStatusView(adapter: adapters.status)
            }
            .refreshControl(adapter: adapters.refresh)
        }
    }
}
