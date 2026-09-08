import SwiftUI
import WrapKit

// swiftlint:disable type_body_length

enum CommonToastCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = CommonToastCatalogAdapters()
        let presenter = CommonToastCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow,
            switchStyle: ControlsCatalogViewConfiguration.appleDefault.switchStyle
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.toastOutput = adapters.toast.weakReferenced.mainQueueDispatched
        presenter.kindOutput = adapters.kind.weakReferenced.mainQueueDispatched
        presenter.showActionOutput = adapters.showAction.weakReferenced.mainQueueDispatched
        presenter.hideActionOutput = adapters.hideAction.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(CommonToastCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class CommonToastCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let toast = CommonToastOutputSwiftUIAdapter()
    let kind = CardViewOutputSwiftUIAdapter()
    let showAction = ButtonOutputSwiftUIAdapter()
    let hideAction = ButtonOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: ToastCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class CommonToastCatalogPresenter: LifeCycleViewOutput {
    private enum ToastKind: String, CaseIterable {
        case success
        case warning
        case error
        case custom

        var title: String {
            switch self {
            case .success: return "Success"
            case .warning: return "Warning"
            case .error: return "Error"
            case .custom: return "Custom"
            }
        }
    }

    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var toastOutput: CommonToastOutput?
    var kindOutput: CardViewOutput?
    var showActionOutput: ButtonOutput?
    var hideActionOutput: ButtonOutput?
    var settingOutputs: [ToastCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private let switchStyle: SwitchControlPresentableModel.Style
    private var didLoad = false
    private var selectedKind: ToastKind = .success
    private var isToastSwitchOn = true
    private var settingStates: [ToastCatalogSetting: Bool] = [
        .positionTop: true,
        .bottomPadding: false,
        .shadow: true,
        .persistent: false,
        .tapAction: true,
        .valueTitle: true,
        .subTitle: false,
        .trailingImage: false,
        .switchControl: false,
        .bottomSeparator: false,
        .leadingTitles: false,
        .trailingTitles: false,
        .secondaryLeadingImage: false,
        .secondaryTrailingImage: false,
        .customImage: true,
        .customBackground: false,
        .customButtons: true
    ]

    init(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow,
        switchStyle: SwitchControlPresentableModel.Style
    ) {
        self.onBack = onBack
        self.selectionFlow = selectionFlow
        self.switchStyle = switchStyle
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "CommonToastOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureKindRow()
        configureActions()
        configureSettingRows()
        showStatus("Ready")
    }

    func viewWillDisappear() {
        toastOutput?.hide()
    }
}

private extension CommonToastCatalogPresenter {
    func configureKindRow() {
        kindOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "catalog.controls.toast.kind",
            title: "Toast type",
            value: selectedKind.title,
            onPress: { [weak self] in self?.showKindSelection() }
        ))
    }

    func configureActions() {
        showActionOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.toast.show",
            title: "Show toast",
            style: CatalogAppearance.primaryButton,
            onPress: { [weak self] in self?.showToast() }
        ))
        hideActionOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.toast.hide",
            title: "Hide toast",
            onPress: { [weak self] in self?.hideToast() }
        ))
    }

    func showKindSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Toast type",
            isMultipleSelectionEnabled: false,
            items: ToastKind.allCases.map { kind in
                .init(
                    id: kind.rawValue,
                    title: kind.title,
                    isSelected: kind == selectedKind,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard
                    case let .singleSelection(item) = result,
                    let kind = ToastKind(rawValue: item.id)
                else { return }
                self?.selectedKind = kind
                self?.configureKindRow()
                self?.showStatus("Toast type: \(kind.title)")
            },
            emptyViewPresentableModel: .init(
                title: .text("No toast types"),
                subTitle: .text("There are no available display variants.")
            )
        ))
    }

    func configureSettingRows() {
        ToastCatalogSetting.allCases.forEach(configureSettingRow)
    }

    func configureSettingRow(_ setting: ToastCatalogSetting) {
        let isEnabled = setting != .bottomPadding || !isSettingOn(.positionTop)
        settingOutputs[setting]?.display(model: .init(
            id: "catalog.controls.toast.setting.\(setting.rawValue)",
            accessibilityIdentifier: "catalog.controls.toast.setting.\(setting.rawValue)",
            accessibility: .init(label: setting.title),
            style: CatalogAppearance.settingCard,
            title: .text(setting.title),
            valueTitle: setting.valueDescription.map { .text($0) },
            switchControl: .init(
                accessibilityIdentifier: "catalog.controls.toast.setting.\(setting.rawValue).switch",
                onPress: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                },
                isOn: settingStates[setting] ?? false,
                isEnabled: isEnabled,
                style: CatalogAppearance.settingSwitch
            ),
            isUserInteractionEnabled: true
        ))
    }

    func toggleSetting(
        _ setting: ToastCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        if setting == .positionTop {
            if isOn {
                settingStates[.bottomPadding] = false
            }
            configureSettingRow(.bottomPadding)
        }

        showStatus("\(setting.title): \(isOn ? "On" : "Off")")
    }

    func showToast() {
        showStatus("Showing \(selectedKind.title.lowercased()) toast")
        displayToast(kind: selectedKind)
    }

    func hideToast() {
        toastOutput?.hide()
        showStatus("Toast hidden")
    }

    private func displayToast(kind: ToastKind) {
        let content = toastContent(for: kind)
        let toast = CommonToast.Toast(
            cardViewModel: .init(
                accessibility: .init(label: "\(content.title). \(content.message)"),
                style: ControlsCatalogAppearance.toastStyle(accentColor: accentColor(for: kind)),
                title: .text(content.title),
                leadingTitles: isSettingOn(.leadingTitles)
                    ? .init(.text("Before"), .text("01"))
                    : nil,
                trailingTitles: isSettingOn(.trailingTitles)
                    ? .init(.text("After"), .text("02"))
                    : nil,
                secondaryLeadingImage: isSettingOn(.secondaryLeadingImage)
                    ? .systemSymbol("star.fill", size: .init(width: 18, height: 18))
                    : nil,
                trailingImage: isSettingOn(.trailingImage)
                    ? .systemSymbol("chevron.right", size: .init(width: 16, height: 16))
                    : nil,
                secondaryTrailingImage: isSettingOn(.secondaryTrailingImage)
                    ? .systemSymbol("bell.fill", size: .init(width: 18, height: 18))
                    : nil,
                subTitle: isSettingOn(.subTitle)
                    ? .text("Additional details")
                    : nil,
                valueTitle: isSettingOn(.valueTitle)
                    ? .text(content.message)
                    : nil,
                bottomSeparator: isSettingOn(.bottomSeparator)
                    ? .init(color: accentColor(for: kind), height: 2)
                    : nil,
                switchControl: isSettingOn(.switchControl)
                    ? makeToastSwitchModel()
                    : nil,
                isUserInteractionEnabled: isSettingOn(.switchControl)
            ),
            position: toastPosition,
            shadowColor: isSettingOn(.shadow) ? .black : nil,
            duration: isSettingOn(.persistent) ? nil : 3,
            onPress: isSettingOn(.tapAction) ? { [weak self] in
                self?.showStatus("Toast pressed")
            } : nil
        )

        switch kind {
        case .success:
            toastOutput?.display(.success(toast))
        case .warning:
            toastOutput?.display(.warning(toast))
        case .error:
            toastOutput?.display(.error(toast))
        case .custom:
            toastOutput?.display(.custom(.init(
                common: toast,
                image: isSettingOn(.customImage)
                    ? .symbolName("sparkles")
                    : nil,
                backgroundColor: isSettingOn(.customBackground)
                    ? .systemPurple.withAlphaComponent(0.12)
                    : nil,
                buttons: customButtons
            )))
        }
    }

    var customButtons: [CommonToast.CustomToast.Button]? {
        guard isSettingOn(.customButtons) else { return nil }
        return [
            .init(title: "Details", onPress: { [weak self] in
                self?.showStatus("Custom action: Details")
            }),
            .init(title: "Dismiss", onPress: { [weak self] in
                self?.hideToast()
            })
        ]
    }

    private func toastContent(for kind: ToastKind) -> (title: String, message: String) {
        switch kind {
        case .success:
            return ("Changes saved", "Your data is up to date")
        case .warning:
            return ("Review required", "Check the details before continuing")
        case .error:
            return ("Update failed", "Try again in a moment")
        case .custom:
            return ("Custom toast", "Image, background, and actions are configurable")
        }
    }

    var toastPosition: CommonToast.Position {
        guard !isSettingOn(.positionTop) else { return .top }
        let padding: CGFloat = isSettingOn(.bottomPadding) ? 40 : 0
        return .bottom(additionalBottomPadding: padding)
    }

    func isSettingOn(_ setting: ToastCatalogSetting) -> Bool {
        settingStates[setting] == true
    }

    func makeToastSwitchModel() -> SwitchControlPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.controls.toast.content.switch",
            onPress: { [weak self] output in
                guard let self else { return }
                self.isToastSwitchOn.toggle()
                output.display(isOn: self.isToastSwitchOn)
                self.showStatus(self.isToastSwitchOn ? "Toast switch: On" : "Toast switch: Off")
            },
            isOn: isToastSwitchOn,
            isEnabled: true,
            style: switchStyle
        )
    }

    private func accentColor(for kind: ToastKind) -> WrapKit.Color {
        switch kind {
        case .success: return .systemGreen
        case .warning: return .systemOrange
        case .error: return .systemRed
        case .custom: return .systemPurple
        }
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct CommonToastCatalogView: View {
    let presenter: CommonToastCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: CommonToastCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Preview")
                    SUICardView(adapter: adapters.kind)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                    SUIButton(adapter: adapters.showAction, pressAnimations: [.shrink])
                        .frame(maxWidth: .infinity)
                    SUIButton(adapter: adapters.hideAction, pressAnimations: [.shrink])
                        .frame(maxWidth: .infinity)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Next toast configuration")
                    ForEach(ToastCatalogSetting.allCases, id: \.rawValue) { setting in
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
        .toastView(adapter: adapters.toast)
    }
}

private extension ToastCatalogSetting {
    var valueDescription: String? {
        switch self {
        case .bottomPadding: return "Available at the bottom"
        case .customImage, .customBackground, .customButtons: return "Custom only"
        default: return nil
        }
    }
}

// swiftlint:enable type_body_length
