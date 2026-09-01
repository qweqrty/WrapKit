import Foundation
import SwiftUI
import WrapKit

enum DatePickerCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let adapters = DatePickerCatalogSceneAdapters()
        let presenter = DatePickerCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow
        )

        presenter.headerOutput = adapters.chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = adapters.chrome.stack.weakReferenced.mainQueueDispatched
        presenter.datePickerOutput = adapters.datePicker.weakReferenced.mainQueueDispatched
        presenter.modeOutput = adapters.mode.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.todayButtonOutput = adapters.todayButton.weakReferenced.mainQueueDispatched
        presenter.nextButtonOutput = adapters.nextButton.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched

        return AnyView(
            DatePickerCatalogView(presenter: presenter, adapters: adapters)
        )
    }
}

private final class DatePickerCatalogSceneAdapters {
    let chrome = CatalogChromeAdapters()
    let datePicker = DatePickerViewOutputSwiftUIAdapter()
    let mode = CardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: DatePickerCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let todayButton = ButtonOutputSwiftUIAdapter()
    let nextButton = ButtonOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
}

private final class DatePickerCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var datePickerOutput: DatePickerViewOutput?
    var modeOutput: CardViewOutput?
    var settingOutputs: [DatePickerCatalogSetting: CardViewOutput] = [:]
    var todayButtonOutput: ButtonOutput?
    var nextButtonOutput: ButtonOutput?
    var statusOutput: TextOutput?

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private var didLoad = false
    private var selectedDate = Date()
    private var selectedMode: DatePickerCatalogMode = .date
    private var settingStates: [DatePickerCatalogSetting: Bool] = [
        .limitedRange: true,
        .callbackEnabled: true
    ]

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

        headerOutput?.display(model: CatalogAppearance.header(
            title: "DatePickerViewOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureDatePicker()
        configureModeSelection()
        configureSettings()
        configureButtons()
        showStatus("Date: \(formatted(selectedDate))")
    }
}

private extension DatePickerCatalogPresenter {
    func configureDatePicker() {
        let hasLimitedRange = settingStates[.limitedRange] == true
        datePickerOutput?.display(
            model: .init(
                value: selectedDate,
                minimumDate: hasLimitedRange ? minimumDate : nil,
                maximumDate: hasLimitedRange ? maximumDate : nil,
                mode: selectedMode.value,
                dateChanged: settingStates[.callbackEnabled] == true
                    ? makeDateChangedCallback()
                    : nil
            )
        )
    }

    func configureModeSelection() {
        modeOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "catalog.input.date.mode",
            title: "Mode",
            value: selectedMode.title,
            onPress: { [weak self] in self?.showModeSelection() }
        ))
    }

    func showModeSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Choose a date picker mode",
            isMultipleSelectionEnabled: false,
            items: DatePickerCatalogMode.allCases.map { mode in
                .init(
                    id: mode.rawValue,
                    title: mode.title,
                    isSelected: mode == selectedMode,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard case let .singleSelection(item)? = result,
                      let mode = DatePickerCatalogMode(rawValue: item.id)
                else { return }
                self?.selectMode(mode)
            }
        ))
    }

    func selectMode(_ mode: DatePickerCatalogMode) {
        selectedMode = mode
        configureDatePicker()
        configureModeSelection()
        showStatus("Mode: \(mode.title)")
    }

    func configureSettings() {
        DatePickerCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "catalog.input.date.setting.\(setting.rawValue)",
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
        _ setting: DatePickerCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .limitedRange:
            configureDatePicker()
        case .callbackEnabled:
            datePickerOutput?.display(
                dateChanged: isOn ? makeDateChangedCallback() : nil
            )
        }
    }

    func makeDateChangedCallback() -> (Date) -> Void {
        { [weak self] date in
            guard let self else { return }
            selectedDate = date
            showStatus("Date: \(formatted(date))")
        }
    }

    func configureButtons() {
        todayButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.input.date.today",
            title: "Today without animation",
            onPress: { [weak self] in self?.selectToday() }
        ))
        nextButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.input.date.next",
            title: "+7 days with animation",
            onPress: { [weak self] in self?.selectNext() }
        ))
    }

    func selectToday() {
        selectedDate = minimumDate
        datePickerOutput?.display(date: selectedDate)
        showStatus("Set to today")
    }

    func selectNext() {
        let candidate = Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: selectedDate
        ) ?? selectedDate
        let nextDate = candidate > maximumDate ? minimumDate : candidate
        selectedDate = nextDate
        datePickerOutput?.display(setDate: nextDate, animated: true)
        showStatus("Date: \(formatted(nextDate))")
    }

    func showStatus(_ message: String) {
        displayInputCatalogStatus(message, on: statusOutput)
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var minimumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var maximumDate: Date {
        Calendar.current.date(byAdding: .day, value: 30, to: minimumDate) ?? .distantFuture
    }
}

private struct DatePickerCatalogView: View {
    let presenter: DatePickerCatalogPresenter
    let adapters: DatePickerCatalogSceneAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: adapters.chrome) {
                InputCatalogSurface {
                    SUIDatePicker(adapter: adapters.datePicker)
                        .frame(minHeight: 216)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    SUICardView(adapter: adapters.mode)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)

                    ForEach(DatePickerCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    SUIButton(adapter: adapters.todayButton, pressAnimations: [.shrink])
                    SUIButton(adapter: adapters.nextButton, pressAnimations: [.shrink])
                }

                InputCatalogStatus(adapter: adapters.status)
            }
        }
    }
}
