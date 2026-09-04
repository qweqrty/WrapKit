import Foundation
import SwiftUI
import WrapKit

private enum HeaderCatalogSetting: String, CaseIterable, Hashable {
    case subtitle
    case titledImageCenter
    case leadingCard
    case primeTrailingImage
    case secondaryTrailingImage
    case tertiaryTrailingImage
    case compactStyle
    case hidden
    case nilModel

    var title: String {
        switch self {
        case .subtitle: return "Show subtitle"
        case .titledImageCenter: return "Use titled image center"
        case .leadingCard: return "Show back button"
        case .primeTrailingImage: return "Show the first trailing button"
        case .secondaryTrailingImage: return "Show the second trailing button"
        case .tertiaryTrailingImage: return "Show the third trailing button"
        case .compactStyle: return "Use compact style"
        case .hidden: return "Hide navigation bar"
        case .nilModel: return "Send display(model: nil)"
        }
    }

    var value: String {
        switch self {
        case .subtitle: return "Centered title"
        case .titledImageCenter: return "Image and title instead of key and value"
        case .leadingCard: return "Back"
        case .primeTrailingImage: return "Help"
        case .secondaryTrailingImage: return "Notifications"
        case .tertiaryTrailingImage: return "Profile"
        case .compactStyle: return "Tighter spacing and a gray background"
        case .hidden: return "Navigation bar visibility"
        case .nilModel: return "Nil model hides the rendered header"
        }
    }
}

private final class HeaderCatalogAdapters {
    let header = HeaderOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let help = TextOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: HeaderCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class HeaderCatalogPresenter: LifeCycleViewOutput {
    var screenHeaderOutput: HeaderOutput?
    var screenStackOutput: StackViewOutput?
    var headerOutput: HeaderOutput?
    var statusOutput: TextOutput?
    var helpOutput: TextOutput?
    var settingOutputs: [HeaderCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var isHelpVisible = false
    private var settingStates: [HeaderCatalogSetting: Bool] = [
        .subtitle: true,
        .leadingCard: true,
        .primeTrailingImage: true
    ]

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        screenHeaderOutput?.display(model: CatalogAppearance.header(
            title: "HeaderOutput",
            onBack: onBack
        ))
        screenStackOutput?.display(model: CatalogAppearance.verticalStack)
        configureHeader()
        configureSettings()
        renderState()
    }
}

private extension HeaderCatalogPresenter {
    func configureHeader() {
        headerOutput?.display(model: makeHeaderModel())
    }

    func configureSettings() {
        HeaderCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.header.setting.\(setting.rawValue)",
                title: setting.title,
                value: setting.value,
                isOn: settingStates[setting] ?? false,
                onToggle: { [weak self] output in
                    self?.toggle(setting, using: output)
                }
            ))
        }
    }

    func toggle(
        _ setting: HeaderCatalogSetting,
        using switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .subtitle:
            headerOutput?.display(centerView: makeCenterView())
        case .titledImageCenter:
            headerOutput?.display(centerView: makeCenterView())
        case .leadingCard:
            headerOutput?.display(leadingCard: isOn ? makeLeadingCard() : nil)
        case .primeTrailingImage:
            headerOutput?.display(primeTrailingImage: isOn ? makeTrailingButton(
                id: "help",
                symbol: "questionmark.circle",
                label: "Help",
                onPress: { [weak self] in self?.toggleHelp() }
            ) : nil)
        case .secondaryTrailingImage:
            headerOutput?.display(secondaryTrailingImage: isOn ? makeTrailingButton(
                id: "notifications",
                symbol: "bell",
                label: "Notifications",
                onPress: { [weak self] in self?.showStatus("Notifications button pressed") }
            ) : nil)
        case .tertiaryTrailingImage:
            headerOutput?.display(tertiaryTrailingImage: isOn ? makeTrailingButton(
                id: "profile",
                symbol: "person.crop.circle",
                label: "Profile",
                onPress: { [weak self] in self?.showStatus("Profile button pressed") }
            ) : nil)
        case .compactStyle:
            headerOutput?.display(style: makeHeaderStyle(isCompact: isOn))
        case .hidden:
            headerOutput?.display(isHidden: isOn || settingStates[.nilModel] == true)
        case .nilModel:
            if isOn {
                headerOutput?.display(model: nil)
            } else {
                headerOutput?.display(model: makeHeaderModel())
                headerOutput?.display(isHidden: settingStates[.hidden] == true)
            }
        }
    }

    func toggleHelp() {
        isHelpVisible.toggle()
        renderState()
    }

    func renderState() {
        showStatus(isHelpVisible ? "Help is visible" : "Header is ready")
        helpOutput?.display(model: isHelpVisible
            ? .text("The leading control navigates back; the trailing control hides this help.")
            : nil
        )
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: .text(text))
    }

    func makeLeadingCard() -> CardViewPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.header.back",
            accessibility: .init(label: "Back"),
            leadingImage: .systemSymbol(
                "chevron.left",
                accessibility: .init(label: "Back"),
                size: .init(width: 24, height: 24)
            ),
            onPress: onBack,
            isUserInteractionEnabled: true
        )
    }

    func makeHeaderModel() -> HeaderPresentableModel {
        .init(
            style: makeHeaderStyle(isCompact: settingStates[.compactStyle] == true),
            centerView: makeCenterView(),
            leadingCard: settingStates[.leadingCard] == true ? makeLeadingCard() : nil,
            primeTrailingImage: settingStates[.primeTrailingImage] == true
                ? makeTrailingButton(
                    id: "help",
                    symbol: "questionmark.circle",
                    label: "Help",
                    onPress: { [weak self] in self?.toggleHelp() }
                )
                : nil,
            secondaryTrailingImage: settingStates[.secondaryTrailingImage] == true
                ? makeTrailingButton(
                    id: "notifications",
                    symbol: "bell",
                    label: "Notifications",
                    onPress: { [weak self] in self?.showStatus("Notifications button pressed") }
                )
                : nil,
            tertiaryTrailingImage: settingStates[.tertiaryTrailingImage] == true
                ? makeTrailingButton(
                    id: "profile",
                    symbol: "person.crop.circle",
                    label: "Profile",
                    onPress: { [weak self] in self?.showStatus("Profile button pressed") }
                )
                : nil
        )
    }

    func makeCenterView() -> HeaderPresentableModel.CenterView {
        if settingStates[.titledImageCenter] == true {
            return .titledImage(.init(
                .systemSymbol(
                    "star.fill",
                    accessibilityIdentifier: "catalog.header.center.image",
                    accessibility: .init(label: "Featured"),
                    size: .init(width: 20, height: 20)
                ),
                .text("Featured")
            ))
        }

        return .keyValue(.init(
            .text("Overview"),
            settingStates[.subtitle] == true ? .text("Online") : nil
        ))
    }

    func makeTrailingButton(
        id: String,
        symbol: String,
        label: String,
        onPress: @escaping () -> Void
    ) -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: "catalog.header.\(id)",
            accessibility: .init(label: label),
            image: ImageFactory.systemImage(named: symbol),
            height: 32,
            width: 32,
            onPress: onPress
        )
    }

    func makeHeaderStyle(isCompact: Bool) -> HeaderPresentableModel.Style {
        .init(
            backgroundColor: isCompact
                ? .secondarySystemGroupedBackground
                : .systemGroupedBackground,
            horizontalSpacing: isCompact ? 6 : 12,
            primeFont: .systemFont(ofSize: isCompact ? 15 : 17, weight: .semibold),
            primeColor: .label,
            secondaryFont: .systemFont(ofSize: 12),
            secondaryColor: .secondaryLabel,
            numberOfLines: 1
        )
    }
}

enum HeaderCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = HeaderCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = HeaderCatalogPresenter(onBack: onBack)

        presenter.screenHeaderOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.screenStackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.headerOutput = adapters.header.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.helpOutput = adapters.help.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(HeaderCatalogScene(
            presenter: presenter,
            adapters: adapters,
            chrome: chrome
        ))
    }
}

private struct HeaderCatalogScene: View {
    let presenter: HeaderCatalogPresenter
    let adapters: HeaderCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUINavigationBar(adapter: adapters.header)
                SUILabel(
                    adapter: adapters.status,
                    font: .systemFont(ofSize: 13),
                    textColor: .secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
                SUILabel(
                    adapter: adapters.help,
                    font: .systemFont(ofSize: 13),
                    textColor: .secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(HeaderCatalogSetting.allCases, id: \.rawValue) { setting in
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
