import SwiftUI
import WrapKit

enum SegmentedControlCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = SegmentedControlCatalogAdapters()
        let appearance = ControlsCatalogViewConfiguration.appleDefault.segmentAppearance
        let presenter = SegmentedControlCatalogPresenter(
            onBack: onBack,
            segmentAppearance: appearance
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.segmentOutput = adapters.segment.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(SegmentedControlCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters,
            appearance: appearance
        ))
    }
}

private final class SegmentedControlCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let segment = SegmentedControlOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: SegmentCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class SegmentedControlCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var segmentOutput: SegmentedControlOutput?
    var settingOutputs: [SegmentCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let segmentAppearance: SegmentedControlAppearance
    private var didLoad = false
    private var selectedModeIndex = 0
    private var settingStates: [SegmentCatalogSetting: Bool] = [
        .fourSegments: false,
        .purpleAppearance: false
    ]

    init(
        onBack: @escaping () -> Void,
        segmentAppearance: SegmentedControlAppearance
    ) {
        self.onBack = onBack
        self.segmentAppearance = segmentAppearance
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "SegmentedControlOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureSegment()
        showStatus("Ready")
    }
}

private extension SegmentedControlCatalogPresenter {
    func configureSegment() {
        segmentOutput?.display(appearence: segmentAppearance)
        displaySegmentModels(showFourth: false)

        SegmentCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.controls.segment.setting.\(setting.rawValue)",
                title: setting.title,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                }
            ))
        }
    }

    func displaySegmentModels(showFourth: Bool) {
        var segments: [SegmentControlModel] = [
            .init(
                accessibilityIdentifer: "catalog.controls.segment.ready",
                title: "Ready",
                index: 0,
                onTap: { [weak self] _ in self?.selectMode(at: 0) }
            ),
            .init(
                accessibilityIdentifer: "catalog.controls.segment.warning",
                title: "Review",
                index: 1,
                onTap: { [weak self] _ in self?.selectMode(at: 1) }
            ),
            .init(
                accessibilityIdentifer: "catalog.controls.segment.loading",
                title: "Loading",
                index: 2,
                onTap: { [weak self] _ in self?.selectMode(at: 2) }
            )
        ]

        if showFourth {
            segments.append(.init(
                accessibilityIdentifer: "catalog.controls.segment.done",
                title: "Complete",
                index: 3,
                onTap: { [weak self] _ in self?.selectMode(at: 3) }
            ))
        }

        segmentOutput?.display(segments: segments)
    }

    func toggleSetting(
        _ setting: SegmentCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .fourSegments:
            displaySegmentModels(showFourth: isOn)
        case .purpleAppearance:
            segmentOutput?.display(
                appearence: isOn
                    ? ControlsCatalogAppearance.purpleSegmentAppearance()
                    : segmentAppearance
            )
        }

        showStatus("\(setting.title): \(isOn ? "on" : "off")")
    }

    func selectMode(at index: Int) {
        selectedModeIndex = index
        switch selectedModeIndex {
        case 1:
            showStatus("Selected: review")
        case 2:
            showStatus("Selected: loading")
        case 3:
            showStatus("Selected: complete")
        default:
            showStatus("Selected: ready")
        }
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct SegmentedControlCatalogView: View {
    let presenter: SegmentedControlCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: SegmentedControlCatalogAdapters
    let appearance: SegmentedControlAppearance

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Live SegmentedControlOutput")
                    SUISegmentControlView(
                        adapter: adapters.segment,
                        appearance: appearance
                    )
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Settings")
                    ForEach(SegmentCatalogSetting.allCases, id: \.rawValue) { setting in
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
