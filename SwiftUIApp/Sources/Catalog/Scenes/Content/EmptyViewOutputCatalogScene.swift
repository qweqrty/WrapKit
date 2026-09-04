import Foundation
import SwiftUI
import WrapKit

enum EmptyViewOutputCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let adapters = EmptyViewOutputCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = EmptyViewOutputCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.output = adapters.output.weakReferenced.mainQueueDispatched
        presenter.presetOutput = adapters.preset.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(
            EmptyViewOutputCatalogView(
                presenter: presenter,
                adapters: adapters,
                chrome: chrome
            )
        )
    }
}

private final class EmptyViewOutputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var output: EmptyViewOutput?
    var presetOutput: CardViewOutput?
    var settingOutputs: [EmptyCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private var didLoad = false
    private var preset: EmptyCatalogPreset = .noResults
    private var settingStates = Dictionary(
        uniqueKeysWithValues: EmptyCatalogSetting.allCases.map { ($0, $0.initialIsOn) }
    )
    private var requestVersion = 0
    private var isModelPresented = false

    init(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) {
        self.onBack = onBack
        self.selectionFlow = selectionFlow
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(
            model: CatalogAppearance.header(title: "EmptyViewOutput", onBack: onBack)
        )
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        show(.noResults)
    }

    func viewWillAppear() {}
    func viewWillDisappear() {
        requestVersion += 1
    }
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}

    private func show(_ preset: EmptyCatalogPreset) {
        requestVersion += 1
        self.preset = preset
        resetSettings()
        displayCurrentModel()
    }

    private func configurePresetRow() {
        presetOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "empty.preset",
            title: "Example",
            value: preset.title,
            onPress: { [weak self] in self?.showPresetSelection() }
        ))
    }

    private func showPresetSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Empty state example",
            isMultipleSelectionEnabled: false,
            items: EmptyCatalogPreset.allCases.map { preset in
                .init(
                    id: preset.rawValue,
                    title: preset.title,
                    isSelected: preset == self.preset,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard case let .singleSelection(item) = result,
                      let preset = EmptyCatalogPreset(rawValue: item.id)
                else { return }
                self?.show(preset)
            },
            emptyViewPresentableModel: .init(
                title: .text("No examples"),
                subTitle: .text("EmptyViewOutput has no available presets.")
            )
        ))
    }

    private var currentTitle: TextOutputPresentableModel {
        switch preset {
        case .noResults: return .text("No results")
        case .error: return .text("Could not load data")
        case .success: return .text("Data loaded")
        }
    }

    private var currentSubtitle: TextOutputPresentableModel {
        switch preset {
        case .noResults: return .text("Change the query or reset the filters")
        case .error: return .text("Please try again")
        case .success: return .text("The retry completed successfully")
        }
    }

    private var currentImage: ImageViewPresentableModel {
        switch preset {
        case .noResults:
            return .systemSymbol("magnifyingglass", size: .init(width: 56, height: 56))
        case .error:
            return .systemSymbol(
                "exclamationmark.triangle.fill",
                size: .init(width: 56, height: 56)
            )
        case .success:
            return .systemSymbol("checkmark.circle.fill", size: .init(width: 56, height: 56))
        }
    }

    private var currentButton: ButtonPresentableModel {
        switch preset {
        case .noResults:
            return makeAction(
                title: "Hide message",
                symbol: "eye.slash",
                onPress: { [weak self] in self?.hideMessage() }
            )
        case .error:
            return makeAction(
                title: "Try again",
                symbol: "arrow.clockwise",
                onPress: { [weak self] in self?.retryLoading() }
            )
        case .success:
            return makeAction(
                title: "Restore empty state",
                symbol: "arrow.uturn.backward",
                onPress: { [weak self] in self?.show(.noResults) }
            )
        }
    }

    private func resetSettings() {
        settingStates = Dictionary(
            uniqueKeysWithValues: EmptyCatalogSetting.allCases.map { ($0, $0.initialIsOn) }
        )
    }

    private func displayCurrentModel() {
        isModelPresented = true
        output?.display(
            model: .init(
                title: currentTitle,
                subTitle: currentSubtitle,
                button: currentButton,
                image: currentImage,
                animationConfig: .init(isAnimated: true, duration: 0.25)
            )
        )
        displayEffectiveVisibility()
        configurePresetRow()
        configureSettingRows()
    }

    private func configureSettingRows() {
        EmptyCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "empty.\(setting.rawValue)",
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
        _ setting: EmptyCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .title:
            output?.display(title: isOn ? currentTitle : nil)
        case .subtitle:
            output?.display(subtitle: isOn ? currentSubtitle : nil)
        case .button:
            output?.display(buttonModel: isOn ? currentButton : nil)
        case .image:
            output?.display(image: isOn ? currentImage : nil)
        case .hidden:
            displayEffectiveVisibility()
        }
    }

    private func hideMessage() {
        requestVersion += 1
        isModelPresented = false
        output?.display(model: nil)
        displayEffectiveVisibility()
    }

    private func retryLoading() {
        requestVersion += 1
        let currentRequest = requestVersion
        isModelPresented = false
        output?.display(model: nil)
        displayEffectiveVisibility()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            guard requestVersion == currentRequest else { return }
            preset = .success
            resetSettings()
            displayCurrentModel()
        }
    }

    private func displayEffectiveVisibility() {
        let isHiddenBySetting = settingStates[.hidden] == true
        output?.display(isHidden: !isModelPresented || isHiddenBySetting)
    }

    private func makeAction(
        title: String,
        symbol: String,
        onPress: @escaping () -> Void
    ) -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: "content.empty.action",
            accessibility: .init(label: title),
            title: title,
            image: ImageFactory.systemImage(named: symbol),
            spacing: 8,
            height: 44,
            style: .init(
                backgroundColor: .systemBlue,
                titleColor: .white,
                pressedColor: .systemBlue.withAlphaComponent(0.7),
                pressedTintColor: .white,
                font: .systemFont(ofSize: 16, weight: .semibold),
                cornerRadius: 12,
                loadingIndicatorColor: .white
            ),
            enabled: true,
            onPress: onPress
        )
    }
}

private struct EmptyViewOutputCatalogView: View {
    let presenter: EmptyViewOutputCatalogPresenter
    let adapters: EmptyViewOutputCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIEmptyView(adapter: adapters.output)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)

                SUICardView(adapter: adapters.preset)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(EmptyCatalogSetting.allCases, id: \.rawValue) { setting in
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
