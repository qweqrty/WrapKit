import Foundation
import SwiftUI
import WrapKit

enum PickerCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = PickerCatalogSceneAdapters()
        let presenter = PickerCatalogPresenter(onBack: onBack)

        presenter.headerOutput = adapters.chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = adapters.chrome.stack.weakReferenced.mainQueueDispatched
        presenter.pickerOutput = adapters.picker.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.firstButtonOutput = adapters.firstButton.weakReferenced.mainQueueDispatched
        presenter.nextButtonOutput = adapters.nextButton.weakReferenced.mainQueueDispatched
        presenter.nilSelectionButtonOutput = adapters.nilSelectionButton.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched

        return AnyView(
            PickerCatalogView(presenter: presenter, adapters: adapters)
        )
    }
}

private final class PickerCatalogSceneAdapters {
    let chrome = CatalogChromeAdapters()
    let picker = PickerViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: PickerCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let firstButton = ButtonOutputSwiftUIAdapter()
    let nextButton = ButtonOutputSwiftUIAdapter()
    let nilSelectionButton = ButtonOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
}

private final class PickerCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var pickerOutput: PickerViewOutput?
    var settingOutputs: [PickerCatalogSetting: CardViewOutput] = [:]
    var firstButtonOutput: ButtonOutput?
    var nextButtonOutput: ButtonOutput?
    var nilSelectionButtonOutput: ButtonOutput?
    var statusOutput: TextOutput?

    private let options = ["Small", "Medium", "Large", "Extra Large"]
    private let onBack: () -> Void
    private var didLoad = false
    private var selectedOptionIndex = 1
    private var settingStates: [PickerCatalogSetting: Bool] = [
        .hidden: false,
        .twoComponents: false,
        .shortList: false,
        .numberedTitles: false,
        .callbackEnabled: true
    ]

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "PickerViewOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        pickerOutput?.display(model: makeModel())
        configureSettings()
        configureButtons()
        showStatus("Selected: \(options[selectedOptionIndex])")
    }
}

private extension PickerCatalogPresenter {
    func makeModel() -> PickerViewPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.input.picker",
            componentsCount: { [weak self] in self?.componentsCount },
            rowsCount: { [weak self] in self?.rowsCount ?? 0 },
            titleForRowAt: { [weak self] index in self?.title(at: index) },
            didSelectAt: settingStates[.callbackEnabled] == true
                ? makeSelectionCallback()
                : nil,
            selectedRow: .init(
                row: selectedOptionIndex,
                selectedRowCompletion: { [weak self] row in
                    self?.showSelectedOption(at: row)
                }
            )
        )
    }

    func configureSettings() {
        PickerCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "catalog.input.picker.setting.\(setting.rawValue)",
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
        _ setting: PickerCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .hidden:
            pickerOutput?.display(model: isOn ? nil : makeModel())
        case .twoComponents:
            let componentsCount = componentsCount
            pickerOutput?.componentsCount = { componentsCount }
        case .shortList:
            updateRows()
            normalizeSelection()
        case .numberedTitles:
            updateRows()
        case .callbackEnabled:
            pickerOutput?.didSelectAt = isOn ? makeSelectionCallback() : nil
        }
    }

    func makeSelectionCallback() -> (Int) -> Void {
        { [weak self] index in
            guard let self, options.indices.contains(index) else { return }
            selectedOptionIndex = index
            showSelectedOption(at: index)
        }
    }

    func updateRows() {
        let rowsCount = rowsCount
        let titles = (0..<rowsCount).map { title(at: $0) }
        pickerOutput?.rowsCount = { rowsCount }
        pickerOutput?.titleForRowAt = { index in
            titles.indices.contains(index) ? titles[index] : nil
        }
    }

    func normalizeSelection() {
        guard selectedOptionIndex >= rowsCount else { return }
        selectedOptionIndex = 0
        pickerOutput?.display(selectedRow: .init(row: selectedOptionIndex, animated: false))
    }

    func configureButtons() {
        firstButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.input.picker.first",
            title: "Select first item",
            onPress: { [weak self] in self?.selectFirstOption() }
        ))
        nextButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.input.picker.next",
            title: "Select next item",
            onPress: { [weak self] in self?.selectNextOption() }
        ))
        nilSelectionButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.input.picker.selection.nil",
            title: "Call display(selectedRow: nil)",
            onPress: { [weak self] in self?.displayNilSelection() }
        ))
    }

    func selectFirstOption() {
        selectedOptionIndex = 0
        pickerOutput?.display(
            selectedRow: .init(
                row: selectedOptionIndex,
                animated: false,
                selectedRowCompletion: { [weak self] row in
                    self?.showSelectedOption(at: row)
                }
            )
        )
    }

    func selectNextOption() {
        selectedOptionIndex = (selectedOptionIndex + 1) % rowsCount
        pickerOutput?.display(
            selectedRow: .init(
                row: selectedOptionIndex,
                animated: false,
                selectedRowCompletion: { [weak self] row in
                    self?.showSelectedOption(at: row)
                }
            )
        )
    }

    func displayNilSelection() {
        pickerOutput?.display(selectedRow: nil)
        showStatus(
            "display(selectedRow: nil) is a no-op; selection remains \(options[selectedOptionIndex])"
        )
    }

    func showSelectedOption(at index: Int) {
        guard options.indices.contains(index) else { return }
        selectedOptionIndex = index
        showStatus("Selected: \(options[index])")
    }

    var componentsCount: Int {
        settingStates[.twoComponents] == true ? 2 : 1
    }

    var rowsCount: Int {
        settingStates[.shortList] == true ? 2 : options.count
    }

    func title(at index: Int) -> String? {
        guard options.indices.contains(index), index < rowsCount else { return nil }
        return settingStates[.numberedTitles] == true
            ? "\(index + 1). \(options[index])"
            : options[index]
    }

    func showStatus(_ message: String) {
        displayInputCatalogStatus(message, on: statusOutput)
    }
}

private struct PickerCatalogView: View {
    let presenter: PickerCatalogPresenter
    let adapters: PickerCatalogSceneAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: adapters.chrome) {
                InputCatalogSurface {
                    SUIPickerView(adapter: adapters.picker)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 180)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(PickerCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    SUIButton(adapter: adapters.firstButton, pressAnimations: [.shrink])
                    SUIButton(adapter: adapters.nextButton, pressAnimations: [.shrink])
                    SUIButton(adapter: adapters.nilSelectionButton, pressAnimations: [.shrink])
                }

                InputCatalogStatus(adapter: adapters.status)
            }
        }
    }
}
