import Foundation
import SwiftUI
import WrapKit

enum TextInputCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let adapters = TextInputCatalogSceneAdapters()
        let presenter = TextInputCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow
        )

        presenter.headerOutput = adapters.chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = adapters.chrome.stack.weakReferenced.mainQueueDispatched
        presenter.accountOutput = adapters.account.weakReferenced.mainQueueDispatched
        presenter.commentOutput = adapters.comment.weakReferenced.mainQueueDispatched
        presenter.codeOutput = adapters.code.weakReferenced.mainQueueDispatched
        presenter.maskSelectionOutput = adapters.maskSelection.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.accountLeadingImageOutput = adapters.accountLeadingImage.weakReferenced.mainQueueDispatched
        presenter.accountTrailingImageOutput = adapters.accountTrailingImage.weakReferenced.mainQueueDispatched
        presenter.accountTitleOutput = adapters.accountTitle.weakReferenced.mainQueueDispatched
        presenter.commentTitleOutput = adapters.commentTitle.weakReferenced.mainQueueDispatched
        presenter.codeTitleOutput = adapters.codeTitle.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched

        return AnyView(
            TextInputCatalogView(
                presenter: presenter,
                adapters: adapters,
                configuration: .appleDefault
            )
        )
    }
}

private final class TextInputCatalogSceneAdapters {
    let chrome = CatalogChromeAdapters()
    let account = TextInputOutputSwiftUIAdapter()
    let comment = TextInputOutputSwiftUIAdapter()
    let code = TextInputOutputSwiftUIAdapter()
    let maskSelection = CardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: TextInputCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let accountLeadingImage = ImageViewOutputSwiftUIAdapter()
    let accountTrailingImage = ImageViewOutputSwiftUIAdapter()
    let accountTitle = TextOutputSwiftUIAdapter()
    let commentTitle = TextOutputSwiftUIAdapter()
    let codeTitle = TextOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
}

private final class TextInputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var accountOutput: TextInputOutput?
    var commentOutput: TextInputOutput?
    var codeOutput: TextInputOutput?
    var maskSelectionOutput: CardViewOutput?
    var settingOutputs: [TextInputCatalogSetting: CardViewOutput] = [:]
    var accountLeadingImageOutput: ImageViewOutput?
    var accountTrailingImageOutput: ImageViewOutput?
    var accountTitleOutput: TextOutput?
    var commentTitleOutput: TextOutput?
    var codeTitleOutput: TextOutput?
    var statusOutput: TextOutput?

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private var didLoad = false
    private var settingStates = Dictionary(
        uniqueKeysWithValues: TextInputCatalogSetting.allCases.map { ($0, false) }
    )
    private var accountName = "555123456"
    private var comment = "Leave the package at the front desk."
    private var verificationCode = "24"
    private var inputDate = Date()
    private var accountTextBeforeDateInput: String?
    private var accountTextBeforeCustomPickerInput: String?
    private var customPickerSelectedRow = 1
    private var maskPreset: TextInputMaskPreset = .none

    private let customPickerOptions = [
        "Beginner",
        "Intermediate",
        "Advanced"
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
            title: "TextInputOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureTitles()
        configureAccountIcons()
        configureAccount()
        configureComment()
        configureCode()
        configureCallbacks()
        configureMaskSelection()
        configureSettings()
        showStatus("Inputs are ready")
    }
}

private extension TextInputCatalogPresenter {
    func configureTitles() {
        accountTitleOutput?.display(model: .text("Single-line input"))
        commentTitleOutput?.display(model: .text("Multiline input"))
        codeTitleOutput?.display(model: .text("Four-digit code"))
    }

    func configureAccountIcons() {
        accountLeadingImageOutput?.display(
            model: .systemSymbol(
                "person.crop.circle",
                accessibilityIdentifier: "catalog.input.account.leading",
                accessibility: .init(label: "Contact"),
                size: .init(width: 22, height: 22),
                contentModeIsFit: true
            )
        )
        accountTrailingImageOutput?.display(
            model: .systemSymbol(
                "xmark.circle.fill",
                accessibilityIdentifier: "catalog.input.account.clear",
                accessibility: .init(label: "Clear field"),
                size: .init(width: 22, height: 22),
                contentModeIsFit: true
            )
        )
    }

    func configureAccount() {
        accountOutput?.display(
            model: .init(
                accessibilityIdentifier: "catalog.input.account",
                text: accountName,
                isValid: true,
                isEnabledForEditing: true,
                isTextSelectionDisabled: false,
                placeholder: "Phone number",
                isUserInteractionEnabled: true,
                isSecureTextEntry: false,
                autocapitalizationType: .none,
                inputType: .default
            )
        )
        accountOutput?.display(leadingViewIsHidden: true)
        accountOutput?.display(trailingViewIsHidden: true)
        accountOutput?.display(isClearButtonActive: false)
    }

    func configureComment() {
        commentOutput?.display(
            model: .init(
                accessibilityIdentifier: "catalog.input.comment",
                text: comment,
                isValid: true,
                isEnabledForEditing: true,
                isTextSelectionDisabled: false,
                placeholder: "Delivery note",
                isUserInteractionEnabled: true,
                isSecureTextEntry: false,
                autocapitalizationType: .sentences,
                inputType: .default
            )
        )
    }

    func configureCode() {
        codeOutput?.display(
            model: .init(
                accessibilityIdentifier: "catalog.input.code",
                text: verificationCode,
                isValid: true,
                isEnabledForEditing: true,
                isTextSelectionDisabled: false,
                isUserInteractionEnabled: true,
                isSecureTextEntry: false,
                inputType: .numberPad
            )
        )
    }

    func configureCallbacks() {
        accountOutput?.display(leadingViewOnPress: { [weak self] in
            self?.showStatus("Contact action selected")
        })
        accountOutput?.display(trailingViewOnPress: { [weak self] in
            self?.accountName = ""
            self?.showStatus("Single-line input cleared")
        })

        configureCommonCallbacks(
            output: accountOutput,
            name: "Single-line input",
            onChange: { [weak self] text in
                guard let self else { return }
                accountName = text ?? ""
                showStatus("Phone: \(accountName.count) digits")
            }
        )
        accountOutput?.display(onTapBackspace: { [weak self] in
            self?.showStatus("Backspace pressed in single-line input")
        })
        accountOutput?.display(onPaste: { [weak self] text in
            self?.showStatus("Paste intercepted: \(text?.count ?? 0) characters")
        })
        configureCommonCallbacks(
            output: commentOutput,
            name: "Multiline input",
            onChange: { [weak self] text in
                guard let self else { return }
                comment = text ?? ""
                showStatus("Note: \(comment.count) characters")
            }
        )
        commentOutput?.display(onTapBackspace: { [weak self] in
            self?.showStatus("Backspace pressed in multiline input")
        })
        commentOutput?.display(onPaste: { [weak self] text in
            self?.showStatus("Multiline paste intercepted: \(text?.count ?? 0) characters")
        })
        configureCommonCallbacks(
            output: codeOutput,
            name: "Code",
            onChange: { [weak self] text in
                guard let self else { return }
                verificationCode = String((text ?? "").prefix(4))
                showStatus("Code: \(verificationCode.count)/4")
            }
        )
        codeOutput?.display(onTapBackspace: { [weak self] in
            self?.showStatus("Code digit deleted")
        })
    }

    func configureCommonCallbacks(
        output: TextInputOutput?,
        name: String,
        onChange: @escaping (String?) -> Void
    ) {
        output?.display(onPress: { [weak self] in
            self?.showStatus("Pressed: \(name.lowercased())")
        })
        output?.display(onBecomeFirstResponder: { [weak self] in
            self?.showStatus("Focused: \(name.lowercased())")
        })
        output?.display(onResignFirstResponder: { [weak self] in
            self?.showStatus("Focus ended: \(name.lowercased())")
        })
        output?.display(didChangeText: [onChange])
    }

    func configureSettings() {
        TextInputCatalogSetting.allCases.forEach { setting in
            configureSetting(setting)
        }
    }

    func configureMaskSelection() {
        maskSelectionOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "catalog.input.mask-preset",
            title: "Mask preset",
            value: maskPreset.title,
            onPress: { [weak self] in self?.showMaskSelection() }
        ))
    }

    func showMaskSelection() {
        let items = TextInputMaskPreset.allCases.map { preset in
            SelectionType.SelectionCellPresentableModel(
                id: preset.rawValue,
                title: preset.title,
                isSelected: preset == maskPreset,
                trailingTitle: preset.example,
                configuration: CatalogSelectionAppearance.cell
            )
        }
        selectionFlow.showSelection(model: .init(
            title: "Choose a mask",
            isMultipleSelectionEnabled: false,
            items: items,
            callback: { [weak self] result in
                guard case let .singleSelection(item)? = result,
                      let preset = TextInputMaskPreset(rawValue: item.id) else { return }
                self?.selectMaskPreset(preset)
            }
        ))
    }

    func selectMaskPreset(_ preset: TextInputMaskPreset) {
        for setting in [TextInputCatalogSetting.dateInput, .customPickerInput]
        where settingStates[setting] == true {
            settingStates[setting] = false
            configureSetting(setting)
            apply(setting, isOn: false)
        }
        maskPreset = preset
        displayMaskPreset()
        configureMaskSelection()
        showStatus("Mask: \(preset.title)")
    }

    func configureSetting(_ setting: TextInputCatalogSetting) {
        settingOutputs[setting]?.display(
            model: CatalogAppearance.toggleSettingCard(
                id: "catalog.input.setting.\(setting.rawValue)",
                title: setting.title,
                value: setting.scope,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggle(setting, switchOutput: output)
                }
            )
        )
    }

    func toggle(
        _ setting: TextInputCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)
        if isOn {
            deactivateConflictingSetting(for: setting)
        }
        apply(setting, isOn: isOn)
        showStatus("\(setting.title): \(isOn ? "on" : "off")")
    }

    func deactivateConflictingSetting(for setting: TextInputCatalogSetting) {
        switch setting {
        case .dateInput, .customPickerInput:
            let conflictingSetting: TextInputCatalogSetting = setting == .dateInput
                ? .customPickerInput
                : .dateInput
            if settingStates[conflictingSetting] == true {
                settingStates[conflictingSetting] = false
                configureSetting(conflictingSetting)
                apply(conflictingSetting, isOn: false)
            }
            if maskPreset != .none {
                maskPreset = .none
                displayMaskPreset()
                configureMaskSelection()
            }
        default:
            break
        }
    }

    func apply(_ setting: TextInputCatalogSetting, isOn: Bool) {
        guard setting == .modelHidden || !isInputModelHidden else { return }

        switch setting {
        case .modelHidden:
            if isOn {
                outputs.forEach { $0.display(model: nil) }
            } else {
                restoreInputModels()
            }
        case .invalid:
            outputs.forEach { $0.display(isValid: !isOn) }
        case .editingLocked:
            outputs.forEach { $0.display(isEnabledForEditing: !isOn) }
            if isOn {
                outputs.forEach { $0.stopEditing() }
            }
        case .interactionDisabled:
            outputs.forEach { $0.display(isUserInteractionEnabled: !isOn) }
        case .secureEntry:
            outputs.forEach { $0.display(isSecureTextEntry: isOn) }
        case .selectionDisabled:
            outputs.forEach { $0.display(isTextSelectionDisabled: isOn) }
        case .emptyState:
            displayEmptyState(isOn)
        case .focus:
            if isOn {
                accountOutput?.startEditing()
            } else {
                accountOutput?.stopEditing()
            }
        case .leadingIcon:
            accountOutput?.display(leadingViewIsHidden: !isOn)
        case .clearButton:
            displayClearButton(isOn)
        case .trailingSymbol:
            displayTrailingSymbol()
        case .dateInput:
            displayDateInput(isOn)
        case .customPickerInput:
            displayCustomPickerInput(isOn)
        case .hideTextView:
            commentOutput?.display(isHidden: isOn)
        }
    }

    func restoreInputModels() {
        configureAccount()
        configureComment()
        configureCode()
        configureCallbacks()
        displayMaskPreset(shouldResetText: false)

        TextInputCatalogSetting.allCases
            .filter { $0 != .modelHidden && settingStates[$0] == true }
            .forEach { setting in
                if setting == .clearButton {
                    displayClearButton(true, shouldUpdateText: false)
                } else {
                    apply(setting, isOn: true)
                }
            }
    }

    func displayEmptyState(_ isOn: Bool) {
        accountOutput?.display(placeholder: "Phone number")
        commentOutput?.display(placeholder: "Delivery note")
        codeOutput?.display(placeholder: "Code")
        accountOutput?.display(text: isOn ? nil : accountName)
        commentOutput?.display(text: isOn ? nil : comment)
        codeOutput?.display(text: isOn ? nil : verificationCode)
    }

    func displayMaskPreset(shouldResetText: Bool = true) {
        switch maskPreset {
        case .none:
            if shouldResetText {
                accountName = "Sample input"
            }
        case .usPhone:
            if shouldResetText {
                accountName = "55512"
            }
        case .paymentCard:
            if shouldResetText {
                accountName = "42424242"
            }
        case .amount:
            if shouldResetText {
                accountName = "2490.50"
            }
        }

        guard !isInputModelHidden else { return }

        switch maskPreset {
        case .none:
            accountOutput?.display(mask: .init(
                mask: Mask(format: []),
                maskColor: .placeholderText
            ))
            accountOutput?.display(inputType: .default)
        case .usPhone:
            accountOutput?.display(mask: .init(
                mask: Mask(format: phoneMaskFormat),
                maskColor: .placeholderText
            ))
            accountOutput?.display(inputType: .phonePad)
        case .paymentCard:
            accountOutput?.display(mask: .init(
                mask: Mask(format: paymentCardMaskFormat),
                maskColor: .placeholderText
            ))
            accountOutput?.display(inputType: .numberPad)
        case .amount:
            accountOutput?.display(mask: .init(
                mask: AmountMask(maxIntegerDigits: 6, maxFractionDigits: 2),
                maskColor: .placeholderText
            ))
            accountOutput?.display(inputType: .decimalPad)
        }
        displayTrailingSymbol()
        accountOutput?.display(text: accountName)
    }

    func displayTrailingSymbol() {
        let presetSymbol = maskPreset == .amount ? " USD" : ""
        let verifiedSymbol = settingStates[.trailingSymbol] == true ? " · verified" : ""
        let symbol = presetSymbol + verifiedSymbol
        accountOutput?.display(trailingSymbol: symbol.isEmpty ? nil : symbol)
    }

    func displayClearButton(_ isOn: Bool, shouldUpdateText: Bool = true) {
        accountOutput?.display(isClearButtonActive: isOn)
        accountOutput?.display(trailingViewIsHidden: !isOn)
        if shouldUpdateText {
            accountOutput?.display(text: isOn ? nil : accountName)
        }
    }

    func displayDateInput(_ isOn: Bool) {
        guard isOn else {
            accountOutput?.stopEditing()
            accountOutput?.display(inputView: nil)
            accountOutput?.display(inputAccessoryView: nil)
            accountName = accountTextBeforeDateInput ?? accountName
            accountTextBeforeDateInput = nil
            accountOutput?.display(text: accountName)
            return
        }

        accountTextBeforeDateInput = accountName
        let accessory = TextInputPresentableModel.AccessoryViewPresentableModel(
            style: .init(height: 52, backgroundColor: .secondarySystemBackground),
            trailingButton: CatalogAppearance.actionButton(
                id: "catalog.input.date.done",
                title: "Done",
                onPress: { [weak self] in
                    self?.showStatus("Date confirmed")
                }
            )
        )
        accountOutput?.display(
            inputView: .date(
                .init(
                    minDate: minimumDate,
                    maxDate: maximumDate,
                    value: inputDate,
                    accessoryView: accessory,
                    onChange: { [weak self] date in
                        self?.inputDate = date
                    },
                    onDoneTapped: { [weak self] date in
                        guard let self else { return }
                        inputDate = date
                        accountOutput?.display(text: formatted(date))
                    }
                )
            )
        )
        accountOutput?.display(
            mask: .init(mask: Mask(format: []), maskColor: .placeholderText)
        )
        accountOutput?.display(text: formatted(inputDate))
        accountOutput?.startEditing()
    }

    func displayCustomPickerInput(_ isOn: Bool) {
        guard isOn else {
            accountOutput?.stopEditing()
            accountOutput?.display(inputView: nil)
            accountOutput?.display(inputAccessoryView: nil)
            accountName = accountTextBeforeCustomPickerInput ?? accountName
            accountTextBeforeCustomPickerInput = nil
            accountOutput?.display(text: accountName)
            return
        }

        accountTextBeforeCustomPickerInput = accountName
        let options = customPickerOptions
        let accessory = TextInputPresentableModel.AccessoryViewPresentableModel(
            style: .init(height: 52, backgroundColor: .secondarySystemBackground),
            trailingButton: CatalogAppearance.actionButton(
                id: "catalog.input.picker.done",
                title: "Done",
                onPress: { [weak self] in
                    self?.accountOutput?.stopEditing()
                    self?.showStatus("Picker value confirmed")
                }
            )
        )
        accountOutput?.display(inputAccessoryView: accessory)
        accountOutput?.display(inputView: .custom(.init(
            accessibilityIdentifier: "catalog.input.custom-picker",
            componentsCount: { 1 },
            rowsCount: { options.count },
            titleForRowAt: { row in
                options.indices.contains(row) ? options[row] : nil
            },
            didSelectAt: { [weak self] row in
                guard let self, options.indices.contains(row) else { return }
                customPickerSelectedRow = row
                accountOutput?.display(text: options[row])
                showStatus("Picker: \(options[row])")
            },
            selectedRow: .init(row: customPickerSelectedRow)
        )))
        accountOutput?.display(
            mask: .init(mask: Mask(format: []), maskColor: .placeholderText)
        )
        accountOutput?.display(text: options[customPickerSelectedRow])
        accountOutput?.startEditing()
    }

    var outputs: [TextInputOutput] {
        [accountOutput, commentOutput, codeOutput].compactMap { $0 }
    }

    var isInputModelHidden: Bool {
        settingStates[.modelHidden] == true
    }

    var phoneMaskFormat: [MaskedCharacter] {
        [.literal("(")] + digits(3) + [.literal(")"), .literal(" ")]
            + digits(3) + [.literal("-")] + digits(4)
    }

    var paymentCardMaskFormat: [MaskedCharacter] {
        digits(4) + [.literal(" ")] + digits(4) + [.literal(" ")]
            + digits(4) + [.literal(" ")] + digits(4)
    }

    func digits(_ count: Int) -> [MaskedCharacter] {
        Array(
            repeating: .specifier(
                placeholder: "X",
                allowedCharacters: .decimalDigits
            ),
            count: count
        )
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

private struct TextInputCatalogView: View {
    let presenter: TextInputCatalogPresenter
    let adapters: TextInputCatalogSceneAdapters
    let configuration: InputCatalogViewConfiguration

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: adapters.chrome) {
                InputCatalogSurface {
                    SUIStackView(axis: .vertical, spacing: 14) {
                        InputCatalogSectionTitle(adapter: adapters.accountTitle)
                        SUITextField(
                            adapter: adapters.account,
                            appearance: configuration.fieldAppearance,
                            leadingView: AnyView(
                                SUIImageView(adapter: adapters.accountLeadingImage)
                                    .frame(width: 22, height: 22)
                            ),
                            trailingView: AnyView(
                                SUIImageView(adapter: adapters.accountTrailingImage)
                                    .frame(width: 22, height: 22)
                            )
                        )

                        InputCatalogSectionTitle(adapter: adapters.commentTitle)
                        SUITextView(
                            adapter: adapters.comment,
                            appearance: configuration.fieldAppearance
                        )
                        .frame(height: 124)

                        InputCatalogSectionTitle(adapter: adapters.codeTitle)
                        SUIChunkedTextField(
                            adapter: adapters.code,
                            count: 4,
                            appearance: configuration.codeAppearance
                        )
                    }
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    SUICardView(adapter: adapters.maskSelection)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)

                    ForEach(TextInputCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                InputCatalogStatus(adapter: adapters.status)
            }
        }
    }
}
