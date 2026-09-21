import Foundation
import SwiftUI
import WrapKit

struct LayoutCatalogItem: Hashable, Identifiable {
    let id: Int
    let title: String
    let symbol: String
    var isSelected = false
}

struct LayoutCatalogHeader {
    let title: String
}

private enum LayoutCatalogData {
    static let items: [LayoutCatalogItem] = [
        .init(id: 1, title: "Home", symbol: "house.fill"),
        .init(id: 2, title: "Favorites", symbol: "star.fill"),
        .init(id: 3, title: "Recents", symbol: "clock.fill"),
        .init(id: 4, title: "Messages", symbol: "message.fill"),
        .init(id: 5, title: "Profile", symbol: "person.crop.circle.fill"),
        .init(id: 6, title: "Settings", symbol: "gearshape.fill")
    ]
}

private enum KeyValueCatalogAction: String, CaseIterable, Hashable {
    case model
    case keyTitle
    case valueTitle
    case bottomImage
    case clear

    var title: String {
        switch self {
        case .model: return "Update the full model"
        case .keyTitle: return "Change the key"
        case .valueTitle: return "Change the value"
        case .bottomImage: return "Toggle the bottom image"
        case .clear: return "Clear all content"
        }
    }
}

private enum StackCatalogSetting: String, CaseIterable, Hashable {
    case axis
    case spacing
    case margins
    case visibility

    var title: String {
        switch self {
        case .axis: return "Vertical axis"
        case .spacing: return "Wide spacing"
        case .margins: return "Wide margins"
        case .visibility: return "Hide stack"
        }
    }

    var value: String {
        switch self {
        case .axis: return "Horizontal or vertical"
        case .spacing: return "8 or 20 points"
        case .margins: return "8 or 20 points"
        case .visibility: return "Component visibility"
        }
    }
}

private enum StackDistributionPreset: String, CaseIterable, Hashable {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing
    case equalCentering

    var title: String {
        switch self {
        case .fill: return "Fill"
        case .fillEqually: return "Fill equally"
        case .fillProportionally: return "Fill proportionally"
        case .equalSpacing: return "Equal spacing"
        case .equalCentering: return "Equal centering"
        }
    }

    var value: StackViewDistribution {
        switch self {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .fillProportionally: return .fillProportionally
        case .equalSpacing: return .equalSpacing
        case .equalCentering: return .equalCentering
        }
    }
}

private enum StackAlignmentPreset: String, CaseIterable, Hashable {
    case fill
    case leading
    case top
    case firstBaseline
    case center
    case trailing
    case bottom
    case lastBaseline

    var title: String {
        switch self {
        case .fill: return "Fill"
        case .leading: return "Leading"
        case .top: return "Top"
        case .firstBaseline: return "First baseline"
        case .center: return "Center"
        case .trailing: return "Trailing"
        case .bottom: return "Bottom"
        case .lastBaseline: return "Last baseline"
        }
    }

    var value: StackViewAlignment {
        switch self {
        case .fill: return .fill
        case .leading: return .leading
        case .top: return .top
        case .firstBaseline: return .firstBaseline
        case .center: return .center
        case .trailing: return .trailing
        case .bottom: return .bottom
        case .lastBaseline: return .lastBaseline
        }
    }
}

private final class KeyValueFieldCatalogAdapters {
    let keyValue = KeyValueFieldViewOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let actions = Dictionary(
        uniqueKeysWithValues: KeyValueCatalogAction.allCases.map {
            ($0, ButtonOutputSwiftUIAdapter())
        }
    )
}

private final class KeyValueFieldCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var screenStackOutput: StackViewOutput?
    var keyValueOutput: KeyValueFieldViewOutput?
    var statusOutput: TextOutput?
    var actionOutputs: [KeyValueCatalogAction: ButtonOutput] = [:]

    private let onBack: () -> Void
    private var revision = 1
    private var showsBottomImage = true
    private var didLoad = false

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true
        headerOutput?.display(model: CatalogAppearance.header(
            title: "KeyValueFieldViewOutput",
            onBack: onBack
        ))
        screenStackOutput?.display(model: CatalogAppearance.verticalStack)
        configureActions()
        displayModel()
    }

    private func configureActions() {
        KeyValueCatalogAction.allCases.forEach { action in
            actionOutputs[action]?.display(model: CatalogAppearance.actionButton(
                id: "catalog.keyValue.\(action.rawValue)",
                title: action.title,
                onPress: { [weak self] in self?.perform(action) }
            ))
        }
    }

    private func perform(_ action: KeyValueCatalogAction) {
        switch action {
        case .model:
            displayModel()
        case .keyTitle:
            revision += 1
            keyValueOutput?.display(keyTitle: .text("Section \(revision)"))
            showStatus("Key updated")
        case .valueTitle:
            let item = LayoutCatalogData.items[revision % LayoutCatalogData.items.count]
            revision += 1
            keyValueOutput?.display(valueTitle: .text(item.title))
            showStatus("Value updated")
        case .bottomImage:
            showsBottomImage.toggle()
            displayBottomImage()
            showStatus(showsBottomImage ? "Bottom image shown" : "Bottom image hidden")
        case .clear:
            showsBottomImage = false
            keyValueOutput?.display(model: nil)
            keyValueOutput?.display(bottomImage: nil)
            showStatus("All content cleared")
        }
    }

    private func displayModel() {
        guard let item = LayoutCatalogData.items.first else { return }
        keyValueOutput?.display(model: .init(
            .text("Primary section"),
            .text(item.title)
        ))
        showsBottomImage = true
        displayBottomImage()
        showStatus("Full model displayed")
    }

    private func displayBottomImage() {
        keyValueOutput?.display(bottomImage: showsBottomImage ? .systemSymbol(
            "checkmark.seal.fill",
            accessibilityIdentifier: "catalog.keyValue.icon",
            size: .init(width: 22, height: 22),
            contentModeIsFit: true
        ) : nil)
    }

    private func showStatus(_ text: String) {
        statusOutput?.display(model: .text(text))
    }
}

enum KeyValueFieldCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = KeyValueFieldCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = KeyValueFieldCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.screenStackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.keyValueOutput = adapters.keyValue.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.actionOutputs = adapters.actions.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(KeyValueFieldCatalogScene(
            presenter: presenter,
            adapters: adapters,
            chrome: chrome
        ))
    }
}

private struct KeyValueFieldCatalogScene: View {
    let presenter: KeyValueFieldCatalogPresenter
    let adapters: KeyValueFieldCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                keyValueConsumer(title: "Horizontal layout") {
                    SUIHKeyValueFieldView(
                        adapter: adapters.keyValue,
                        backgroundColor: .secondarySystemBackground,
                        keyTextColor: .secondaryLabel,
                        valueTextColor: .label,
                        spacing: 12,
                        contentInsets: .init(horizontal: 12, vertical: 10),
                        keyLineLimit: 2,
                        valueLineLimit: 2
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                keyValueConsumer(title: "Vertical layout") {
                    SUIVKeyValueFieldView(
                        adapter: adapters.keyValue,
                        keyTextColor: .secondaryLabel,
                        valueTextColor: .label,
                        keyNumberOfLines: 2,
                        valueNumberOfLines: 0,
                        spacing: 8,
                        contentInsets: .init(horizontal: 12, vertical: 10)
                    )
                    .background(
                        SwiftUI.Color(uiColor: .secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }

                CatalogActionButtons(actions: KeyValueCatalogAction.allCases, adapters: adapters.actions)
                CatalogStatusLabel(adapter: adapters.status)
            }
        }
    }

    private func keyValueConsumer<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        SUIStackView(axis: .vertical, spacing: 6) {
            SUILabelView(
                model: .text(title),
                font: .systemFont(ofSize: 13, weight: .semibold),
                textColor: .secondaryLabel
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            content()
        }
    }
}

private final class StackViewCatalogAdapters {
    let stack = StackViewOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let reset = ButtonOutputSwiftUIAdapter()
    let distribution = CardViewOutputSwiftUIAdapter()
    let alignment = CardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: StackCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class StackViewCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var screenStackOutput: StackViewOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var resetButtonOutput: ButtonOutput?
    var distributionOutput: CardViewOutput?
    var alignmentOutput: CardViewOutput?
    var settingOutputs: [StackCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private var usesVerticalAxis = false
    private var usesWideSpacing = false
    private var usesWideMargins = false
    private var isHidden = false
    private var distribution: StackDistributionPreset = .fillEqually
    private var alignment: StackAlignmentPreset = .center
    private var didLoad = false

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
            title: "StackViewOutput",
            onBack: onBack
        ))
        screenStackOutput?.display(model: CatalogAppearance.verticalStack)
        resetButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.stack.reset",
            title: "Reset configuration",
            onPress: { [weak self] in self?.displayModel() }
        ))
        displayModel()
    }

    private func configureSettings() {
        StackCatalogSetting.allCases.forEach(displaySetting)
        displayDistributionSelection()
        displayAlignmentSelection()
    }

    private func displaySetting(_ setting: StackCatalogSetting) {
        settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
            id: "catalog.stack.setting.\(setting.rawValue)",
            title: setting.title,
            value: setting.value,
            isOn: isSettingEnabled(setting),
            onToggle: { [weak self] _ in self?.toggle(setting) }
        ))
    }

    private func isSettingEnabled(_ setting: StackCatalogSetting) -> Bool {
        switch setting {
        case .axis: return usesVerticalAxis
        case .spacing: return usesWideSpacing
        case .margins: return usesWideMargins
        case .visibility: return isHidden
        }
    }

    private func toggle(_ setting: StackCatalogSetting) {
        switch setting {
        case .axis:
            usesVerticalAxis.toggle()
            stackOutput?.display(axis: usesVerticalAxis ? .vertical : .horizontal)
            showStatus(usesVerticalAxis ? "Axis: vertical" : "Axis: horizontal")
        case .spacing:
            usesWideSpacing.toggle()
            stackOutput?.display(spacing: usesWideSpacing ? 20 : 8)
            showStatus(usesWideSpacing ? "Spacing: 20" : "Spacing: 8")
        case .margins:
            usesWideMargins.toggle()
            let margin: CGFloat = usesWideMargins ? 20 : 8
            stackOutput?.display(layoutMargins: .init(all: margin))
            showStatus("Margins: \(Int(margin))")
        case .visibility:
            isHidden.toggle()
            stackOutput?.display(isHidden: isHidden)
            showStatus(isHidden ? "Stack hidden" : "Stack shown")
        }
        displaySetting(setting)
    }

    private func displayDistributionSelection() {
        distributionOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "catalog.stack.distribution",
            title: "Distribution",
            value: distribution.title,
            onPress: { [weak self] in self?.showDistributionSelection() }
        ))
    }

    private func displayAlignmentSelection() {
        alignmentOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "catalog.stack.alignment",
            title: "Alignment",
            value: alignment.title,
            onPress: { [weak self] in self?.showAlignmentSelection() }
        ))
    }

    private func showDistributionSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Choose distribution",
            isMultipleSelectionEnabled: false,
            items: StackDistributionPreset.allCases.map { preset in
                .init(
                    id: preset.rawValue,
                    title: preset.title,
                    isSelected: preset == distribution,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard case let .singleSelection(item)? = result,
                      let preset = StackDistributionPreset(rawValue: item.id) else { return }
                self?.distribution = preset
                self?.stackOutput?.display(distribution: preset.value)
                self?.displayDistributionSelection()
                self?.showStatus("Distribution: \(preset.title)")
            }
        ))
    }

    private func showAlignmentSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Choose alignment",
            isMultipleSelectionEnabled: false,
            items: StackAlignmentPreset.allCases.map { preset in
                .init(
                    id: preset.rawValue,
                    title: preset.title,
                    isSelected: preset == alignment,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard case let .singleSelection(item)? = result,
                      let preset = StackAlignmentPreset(rawValue: item.id) else { return }
                self?.alignment = preset
                self?.stackOutput?.display(alignment: preset.value)
                self?.displayAlignmentSelection()
                self?.showStatus("Alignment: \(preset.title)")
            }
        ))
    }

    private func displayModel() {
        usesVerticalAxis = false
        usesWideSpacing = false
        usesWideMargins = false
        isHidden = false
        distribution = .fillEqually
        alignment = .center
        stackOutput?.display(model: .init(
            axis: .horizontal,
            distribution: distribution.value,
            alignment: alignment.value,
            spacing: 8,
            layoutMargins: .init(all: 8)
        ))
        stackOutput?.display(isHidden: false)
        configureSettings()
        showStatus("Configuration reset")
    }

    private func showStatus(_ text: String) {
        statusOutput?.display(model: .text(text))
    }
}

enum StackViewCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let adapters = StackViewCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = StackViewCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.screenStackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.stackOutput = adapters.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.resetButtonOutput = adapters.reset.weakReferenced.mainQueueDispatched
        presenter.distributionOutput = adapters.distribution.weakReferenced.mainQueueDispatched
        presenter.alignmentOutput = adapters.alignment.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(StackViewCatalogScene(
            presenter: presenter,
            adapters: adapters,
            chrome: chrome
        ))
    }
}

private struct StackViewCatalogScene: View {
    let presenter: StackViewCatalogPresenter
    let adapters: StackViewCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(
                    adapter: adapters.stack,
                    backgroundColor: .secondarySystemBackground,
                    clipsToBounds: true
                ) {
                    ForEach(Array(LayoutCatalogData.items.prefix(3))) { item in
                        LayoutCatalogTile(item: item, color: .blue)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                SUIStackView(axis: .vertical, spacing: 8) {
                    SUICardView(adapter: adapters.distribution)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)

                    SUICardView(adapter: adapters.alignment)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)

                    ForEach(StackCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                SUIButton(adapter: adapters.reset, pressAnimations: [.shrink])
                CatalogStatusLabel(adapter: adapters.status)
            }
        }
    }
}

private struct TableCatalogRow: Hashable, Identifiable {
    let id: Int
    let title: String
    let symbol: String
    var isSelected = false
    var isFavorite = false
}

private struct TableCatalogSectionTitle {
    let title: String
}

private struct TableCatalogSectionNote {
    let text: String
}

private enum TableCatalogSetting: String, CaseIterable, Hashable {
    case leadingActions
    case trailingActions
    case editing
    case moving

    var title: String {
        switch self {
        case .leadingActions: return "Leading swipe actions"
        case .trailingActions: return "Trailing swipe actions"
        case .editing: return "Allow row editing"
        case .moving: return "Allow row reordering"
        }
    }

    var value: String {
        switch self {
        case .leadingActions: return "Favorite"
        case .trailingActions: return "Info and Delete"
        case .editing: return "canEdit + commitEditing"
        case .moving: return "canMove + move"
        }
    }
}

private enum TableCatalogCell: Hashable {
    case item(TableCatalogRow)
    case addItem
    case status
    case revealTrailingActions
    case hideRefreshControl
    case setting(TableCatalogSetting)
    case reset
}

private final class TableCatalogEditModeState: ObservableObject {
    @Published var editMode: EditMode = .inactive

    func display(isEditing: Bool) {
        editMode = isEditing ? .active : .inactive
    }
}

private final class TableCatalogAdapters {
    let table = TableOutputSwiftUIAdapter<
        TableCatalogCell,
        TableCatalogSectionNote,
        TableCatalogSectionTitle
    >()
    let status = TextOutputSwiftUIAdapter()
    let refresh = RefreshControlOutputSwiftUIAdapter()
    let revealTrailingActions = ButtonOutputSwiftUIAdapter()
    let hideRefreshControl = ButtonOutputSwiftUIAdapter()
    let editMode = ButtonOutputSwiftUIAdapter()
    let reset = ButtonOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: TableCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class TableCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var tableOutput: (any TableOutput<TableCatalogSectionTitle, TableCatalogCell, TableCatalogSectionNote>)?
    var statusOutput: TextOutput?
    var refreshOutput: RefreshControlOutput?
    var revealTrailingActionsButtonOutput: ButtonOutput?
    var hideRefreshControlButtonOutput: ButtonOutput?
    var editModeButtonOutput: ButtonOutput?
    var resetButtonOutput: ButtonOutput?
    var settingOutputs: [TableCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let onEditModeChange: (Bool) -> Void
    private var rowGroups = TableCatalogPresenter.defaultRowGroups
    private var nextRowID = TableCatalogPresenter.firstInsertedRowID
    private var showsLeadingActions = true
    private var showsTrailingActions = true
    private var allowsEditing = true
    private var allowsMoving = true
    private var isEditing = false
    private var refreshControlWasRemoved = false
    private var refreshRequestVersion = 0
    private var refreshCount = 0
    private var didLoad = false

    private static let groupTitles = ["Priority", "Later"]
    private static let defaultRowGroups: [[TableCatalogRow]] = [
        [
            .init(id: 1, title: "Inbox", symbol: "tray.fill"),
            .init(id: 2, title: "Favorites", symbol: "star.fill")
        ],
        [
            .init(id: 3, title: "Archive", symbol: "archivebox.fill"),
            .init(id: 4, title: "Downloads", symbol: "arrow.down.circle.fill")
        ]
    ]
    private static let firstInsertedRowID = (
        defaultRowGroups.flatMap { $0 }.map(\.id).max() ?? 0
    ) + 1

    init(
        onBack: @escaping () -> Void,
        onEditModeChange: @escaping (Bool) -> Void
    ) {
        self.onBack = onBack
        self.onEditModeChange = onEditModeChange
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true
        headerOutput?.display(model: CatalogAppearance.header(
            title: "TableOutput",
            onBack: onBack
        ))
        configureButtons()
        configureSettings()
        configureTableBehaviors()
        configureRefreshControl()
        displayTable()
        showStatus("Tap or swipe a row, or start editing to insert, delete, and move rows within or between groups.")
    }

    func viewWillDisappear() {
        refreshRequestVersion += 1
        refreshOutput?.display(isLoading: false)
    }

    private func configureButtons() {
        displayEditModeButton()
        revealTrailingActionsButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.table.revealTrailingActions",
            title: "Reveal first row actions",
            onPress: { [weak self] in self?.revealFirstRowActions() }
        ))
        hideRefreshControlButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.table.hideRefreshControl",
            title: "Remove pull to refresh",
            style: CatalogAppearance.destructiveButton,
            onPress: { [weak self] in self?.hideRefreshControl() }
        ))
        resetButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.table.reset",
            title: "Restore sample rows",
            onPress: { [weak self] in self?.resetRows() }
        ))
    }

    private func configureRefreshControl() {
        refreshOutput?.display(model: .init(
            style: .init(tintColor: .systemPurple),
            onRefresh: { [weak self] in self?.refreshTable() },
            isLoading: false
        ))
    }

    private func revealFirstRowActions() {
        guard let firstRowIndexPath else {
            showStatus("Restore a sample row before revealing its actions.")
            return
        }
        guard allowsEditing, showsTrailingActions else {
            showStatus("Enable row editing and trailing swipe actions first.")
            return
        }
        tableOutput?.display(expandTrailingActionsAt: firstRowIndexPath)
        showStatus("Trailing actions revealed on the first row.")
    }

    private func hideRefreshControl() {
        guard !refreshControlWasRemoved else { return }
        refreshControlWasRemoved = true
        refreshRequestVersion += 1
        refreshOutput?.display(isLoading: false)
        tableOutput?.displayHideRefreshControl()
        hideRefreshControlButtonOutput?.display(enabled: false)
        showStatus("Pull to refresh removed. Reopen this screen to restore it.")
    }

    private func refreshTable() {
        guard !refreshControlWasRemoved else { return }
        refreshRequestVersion += 1
        let version = refreshRequestVersion
        refreshCount += 1
        refreshOutput?.display(isLoading: true)
        showStatus("Refreshing sample rows…")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self,
                  !self.refreshControlWasRemoved,
                  self.refreshRequestVersion == version else { return }
            self.refreshOutput?.display(isLoading: false)
            self.showStatus("Refresh completed (\(self.refreshCount)).")
        }
    }

    private func configureSettings() {
        TableCatalogSetting.allCases.forEach(displaySetting)
    }

    private func displaySetting(_ setting: TableCatalogSetting) {
        settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
            id: "catalog.table.setting.\(setting.rawValue)",
            title: setting.title,
            value: setting.value,
            isOn: isSettingEnabled(setting),
            onToggle: { [weak self] _ in self?.toggle(setting) }
        ))
    }

    private func isSettingEnabled(_ setting: TableCatalogSetting) -> Bool {
        switch setting {
        case .leadingActions: return showsLeadingActions
        case .trailingActions: return showsTrailingActions
        case .editing: return allowsEditing
        case .moving: return allowsMoving
        }
    }

    private func toggle(_ setting: TableCatalogSetting) {
        switch setting {
        case .leadingActions:
            showsLeadingActions.toggle()
        case .trailingActions:
            showsTrailingActions.toggle()
        case .editing:
            allowsEditing.toggle()
            if !allowsEditing && !allowsMoving {
                setEditing(false)
            }
        case .moving:
            allowsMoving.toggle()
            if !allowsEditing && !allowsMoving {
                setEditing(false)
            }
        }
        displaySetting(setting)
        configureTableBehaviors()
        showStatus("\(setting.title): \(isSettingEnabled(setting) ? "on" : "off")")
    }

    private func configureTableBehaviors() {
        tableOutput?.display(leadingSwipeActionsForIndexPath: showsLeadingActions ? { [weak self] indexPath in
            self?.leadingActions(at: indexPath) ?? []
        } : nil)
        tableOutput?.display(trailingSwipeActionsForIndexPath: showsTrailingActions ? { [weak self] indexPath in
            self?.trailingActions(at: indexPath) ?? []
        } : nil)
        tableOutput?.display(canEdit: { [weak self] indexPath in
            guard let self, self.allowsEditing else { return false }
            return self.isItem(at: indexPath) || self.isAddItem(at: indexPath)
        })
        tableOutput?.display(commitEditing: { [weak self] style, indexPath in
            self?.commitEditing(style, at: indexPath)
        })
        tableOutput?.display(canMove: allowsMoving ? { [weak self] indexPath in
            self?.isItem(at: indexPath) == true
        } : nil)
        tableOutput?.display(move: allowsMoving ? { [weak self] source, destination in
            self?.moveRow(from: source, to: destination)
        } : nil)
    }

    private func leadingActions(at indexPath: IndexPath) -> [TableContextualAction<TableCatalogCell>] {
        guard let row = row(at: indexPath) else { return [] }
        return [
            .init(
                backgroundColor: .systemOrange,
                image: ImageFactory.systemImage(named: row.isFavorite ? "star.slash.fill" : "star.fill"),
                title: row.isFavorite ? "Unfavorite" : "Favorite",
                onPress: { [weak self] _ in self?.toggleFavorite(row.id) }
            )
        ]
    }

    private func trailingActions(at indexPath: IndexPath) -> [TableContextualAction<TableCatalogCell>] {
        guard let row = row(at: indexPath) else { return [] }
        return [
            .init(
                style: .destructive,
                backgroundColor: .systemRed,
                image: ImageFactory.systemImage(named: "trash.fill"),
                title: "Delete",
                onPress: { [weak self] _ in self?.deleteRow(id: row.id, source: "trailing action") }
            ),
            .init(
                backgroundColor: .systemBlue,
                image: ImageFactory.systemImage(named: "info.circle.fill"),
                title: "Info",
                onPress: { [weak self] _ in self?.showStatus("Info action: \(row.title)") }
            )
        ]
    }

    private func didSelect(_ row: TableCatalogRow) {
        rowGroups = rowGroups.map { rows in
            rows.map { current in
                var current = current
                current.isSelected = current.id == row.id
                return current
            }
        }
        displayTable()
        showStatus("Selected: \(row.title)")
    }

    private func toggleFavorite(_ id: TableCatalogRow.ID) {
        guard let location = rowLocation(id: id) else { return }
        rowGroups[location.section][location.row].isFavorite.toggle()
        let row = rowGroups[location.section][location.row]
        displayTable()
        showStatus("\(row.title) \(row.isFavorite ? "added to" : "removed from") favorites.")
    }

    private func commitEditing(_ style: TableEditingStyle, at indexPath: IndexPath) {
        switch style {
        case .delete:
            guard let row = row(at: indexPath) else { return }
            deleteRow(id: row.id, source: "commitEditing")
        case .insert:
            insertRow(at: indexPath)
        case .none:
            showStatus("commitEditing received the .none style.")
        }
    }

    private func deleteRow(id: TableCatalogRow.ID, source: String) {
        guard let location = rowLocation(id: id) else { return }
        let removed = rowGroups[location.section].remove(at: location.row)
        displayTable()
        showStatus("Deleted \(removed.title) through \(source).")
    }

    private func insertRow(at indexPath: IndexPath) {
        guard isAddItem(at: indexPath) else { return }
        let id = nextRowID
        nextRowID += 1
        let row = TableCatalogRow(
            id: id,
            title: "Sample row \(id)",
            symbol: "square.stack.3d.up.fill"
        )
        rowGroups[0].append(row)
        displayTable()
        showStatus("Inserted \(row.title) through commitEditing.")
    }

    private func moveRow(from source: IndexPath, to destination: IndexPath) {
        guard rowGroups.indices.contains(source.section),
              rowGroups.indices.contains(destination.section),
              rowGroups[source.section].indices.contains(source.row) else { return }
        let moved = rowGroups[source.section].remove(at: source.row)
        let destinationRow = min(
            max(destination.row, 0),
            rowGroups[destination.section].count
        )
        rowGroups[destination.section].insert(moved, at: destinationRow)
        displayTable()
        showStatus(
            "Moved \(moved.title) to \(groupTitle(at: destination.section)), row \(destinationRow + 1)."
        )
    }

    private func resetRows() {
        rowGroups = Self.defaultRowGroups
        nextRowID = Self.firstInsertedRowID
        setEditing(false)
        showStatus("Sample rows restored.")
    }

    private func toggleEditing() {
        setEditing(!isEditing)
        showStatus(
            isEditing
                ? "Editing is active. Use native reorder handles within a group, or long-press a row to move it between groups."
                : "Editing finished."
        )
    }

    private func setEditing(_ isEditing: Bool) {
        self.isEditing = isEditing && (allowsEditing || allowsMoving)
        onEditModeChange(self.isEditing)
        displayEditModeButton()
        displayTable()
    }

    private func displayEditModeButton() {
        editModeButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.table.editMode",
            title: isEditing ? "Finish editing" : "Start editing",
            style: isEditing ? CatalogAppearance.primaryButton : CatalogAppearance.secondaryButton,
            onPress: { [weak self] in self?.toggleEditing() }
        ))
    }

    private func displayTable() {
        let movableSections: [TableSection<
            TableCatalogSectionTitle,
            TableCatalogCell,
            TableCatalogSectionNote
        >] = rowGroups.enumerated().map { groupIndex, rows in
            var cells = rows.map { row in
                CellModel(
                    accessibilityIdentifier: "catalog.table.item.\(row.id)",
                    cell: TableCatalogCell.item(row),
                    onTap: { [weak self] _, cell in
                        guard case .item(let selectedRow) = cell else { return }
                        self?.didSelect(selectedRow)
                    }
                )
            }
            if groupIndex == 0 {
                cells.append(.init(
                    accessibilityIdentifier: "catalog.table.addItem",
                    cell: .addItem,
                    editingStyle: .insert
                ))
            }
            return .init(
                header: .init(title: groupTitle(at: groupIndex)),
                cells: cells,
                footer: .init(text: groupIndex == 0
                    ? "Start editing, then use the native reorder handle inside this group or long-press a row and drop it in either group."
                    : "Cross-group drops work before or after a row, at the end, and when this group is empty."
                )
            )
        }

        let configurationSection = TableSection<
            TableCatalogSectionTitle,
            TableCatalogCell,
            TableCatalogSectionNote
        >(
            header: .init(title: "Configuration"),
            cells: [
                .init(accessibilityIdentifier: "catalog.table.status", cell: .status),
                .init(
                    accessibilityIdentifier: "catalog.table.revealTrailingActions",
                    cell: .revealTrailingActions
                ),
                .init(
                    accessibilityIdentifier: "catalog.table.hideRefreshControl",
                    cell: .hideRefreshControl
                )
            ] + TableCatalogSetting.allCases.map {
                .init(
                    accessibilityIdentifier: "catalog.table.setting.\($0.rawValue)",
                    cell: .setting($0)
                )
            } + [
                .init(accessibilityIdentifier: "catalog.table.reset", cell: .reset)
            ],
            footer: .init(text: "Configuration stays outside the movable groups. The reveal command uses a public SwiftUI action strip while native manual swipe remains available. The remove command disables the nearest WrapKit pull-to-refresh modifier for this screen instance.")
        )

        tableOutput?.display(
            sections: isEditing ? movableSections : movableSections + [configurationSection]
        )
    }

    private func isItem(at indexPath: IndexPath) -> Bool {
        row(at: indexPath) != nil
    }

    private func isAddItem(at indexPath: IndexPath) -> Bool {
        indexPath.section == 0 && indexPath.row == rowGroups[0].count
    }

    private func row(at indexPath: IndexPath) -> TableCatalogRow? {
        guard rowGroups.indices.contains(indexPath.section),
              rowGroups[indexPath.section].indices.contains(indexPath.row) else { return nil }
        return rowGroups[indexPath.section][indexPath.row]
    }

    private var firstRowIndexPath: IndexPath? {
        rowGroups.enumerated().first(where: { !$0.element.isEmpty }).map {
            IndexPath(row: 0, section: $0.offset)
        }
    }

    private func rowLocation(id: TableCatalogRow.ID) -> IndexPath? {
        for (section, rows) in rowGroups.enumerated() {
            if let row = rows.firstIndex(where: { $0.id == id }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }

    private func groupTitle(at section: Int) -> String {
        guard Self.groupTitles.indices.contains(section) else { return "Group" }
        return Self.groupTitles[section]
    }

    private func showStatus(_ text: String) {
        statusOutput?.display(model: .text(text))
    }
}

enum TableCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = TableCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let editModeState = TableCatalogEditModeState()
        let presenter = TableCatalogPresenter(
            onBack: onBack,
            onEditModeChange: editModeState.display
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.tableOutput = MainQueueDispatchDecorator(
            decoratee: WeakRefVirtualProxy(adapters.table)
        )
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.refreshOutput = adapters.refresh.weakReferenced.mainQueueDispatched
        presenter.revealTrailingActionsButtonOutput = adapters.revealTrailingActions
            .weakReferenced
            .mainQueueDispatched
        presenter.hideRefreshControlButtonOutput = adapters.hideRefreshControl
            .weakReferenced
            .mainQueueDispatched
        presenter.editModeButtonOutput = adapters.editMode.weakReferenced.mainQueueDispatched
        presenter.resetButtonOutput = adapters.reset.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(TableCatalogScene(
            presenter: presenter,
            adapters: adapters,
            chrome: chrome,
            editModeState: editModeState
        ))
    }
}

private struct TableCatalogScene: View {
    let presenter: TableCatalogPresenter
    let adapters: TableCatalogAdapters
    let chrome: CatalogChromeAdapters
    @StateObject private var editModeState: TableCatalogEditModeState

    init(
        presenter: TableCatalogPresenter,
        adapters: TableCatalogAdapters,
        chrome: CatalogChromeAdapters,
        editModeState: TableCatalogEditModeState
    ) {
        self.presenter = presenter
        self.adapters = adapters
        self.chrome = chrome
        _editModeState = StateObject(wrappedValue: editModeState)
    }

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            SUIStackView(axis: .vertical, spacing: 0) {
                SUINavigationBar(adapter: chrome.header)
                SUIButton(adapter: adapters.editMode, pressAnimations: [.shrink])
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                SUITableView(
                    adapter: adapters.table,
                    style: .list,
                    cellContent: tableCell,
                    headerContent: sectionHeader,
                    footerContent: sectionFooter
                )
                .environment(\.editMode, $editModeState.editMode)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .refreshControl(adapter: adapters.refresh)
            }
            .background(SwiftUI.Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func tableCell(_ cell: TableCatalogCell, _ indexPath: IndexPath) -> some View {
        switch cell {
        case .item(let row):
            SUIStackView(alignment: .center, axis: .horizontal, spacing: 12) {
                SUIImageViewView(model: .systemSymbol(
                    row.symbol,
                    accessibility: .init(label: row.title),
                    size: .init(width: 24, height: 24),
                    contentModeIsFit: true
                ))
                .accentColor(row.isFavorite ? .orange : .blue)
                SUILabelView(
                    model: .text(row.title),
                    font: .systemFont(ofSize: 16),
                    textColor: .label
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                if row.isFavorite {
                    SUIImageViewView(model: .systemSymbol(
                        "star.fill",
                        accessibility: .init(label: "Favorite"),
                        size: .init(width: 18, height: 18),
                        contentModeIsFit: true
                    ))
                    .accentColor(.orange)
                }
                SUIImageViewView(model: .systemSymbol(
                    row.isSelected ? "checkmark.circle.fill" : "circle",
                    accessibility: .init(label: row.isSelected ? "Selected" : "Not selected"),
                    size: .init(width: 20, height: 20),
                    contentModeIsFit: true
                ))
                .accentColor(row.isSelected ? .blue : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(SwiftUI.Color(uiColor: .secondarySystemGroupedBackground))
        case .addItem:
            SUILabelView(
                model: .text("Add sample row"),
                font: .systemFont(ofSize: 16, weight: .medium),
                textColor: .systemGreen
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(SwiftUI.Color(uiColor: .secondarySystemGroupedBackground))
        case .status:
            CatalogStatusLabel(adapter: adapters.status)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        case .revealTrailingActions:
            SUIButton(adapter: adapters.revealTrailingActions, pressAnimations: [.shrink])
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        case .hideRefreshControl:
            SUIButton(adapter: adapters.hideRefreshControl, pressAnimations: [.shrink])
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        case .setting(let setting):
            if let adapter = adapters.settings[setting] {
                SUICardView(adapter: adapter)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }
        case .reset:
            SUIButton(adapter: adapters.reset, pressAnimations: [.shrink])
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        }
    }

    private func sectionHeader(_ header: TableCatalogSectionTitle) -> some View {
        SUILabelView(
            model: .text(header.title),
            font: .systemFont(ofSize: 13, weight: .semibold),
            textColor: .secondaryLabel
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private func sectionFooter(_ footer: TableCatalogSectionNote) -> some View {
        SUILabelView(
            model: .text(footer.text),
            font: .systemFont(ofSize: 12),
            textColor: .secondaryLabel,
            textAlignment: .left
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }
}

private struct CatalogActionButtons<Action: Hashable>: View {
    let actions: [Action]
    let adapters: [Action: ButtonOutputSwiftUIAdapter]

    var body: some View {
        SUIStackView(axis: .vertical, spacing: 8) {
            ForEach(actions, id: \.self) { action in
                if let adapter = adapters[action] {
                    SUIButton(adapter: adapter, pressAnimations: [.shrink])
                }
            }
        }
    }
}

private struct CatalogStatusLabel: View {
    let adapter: TextOutputSwiftUIAdapter

    var body: some View {
        SUILabel(
            adapter: adapter,
            font: .systemFont(ofSize: 13),
            textColor: .secondaryLabel
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct LayoutCatalogTile: View {
    let item: LayoutCatalogItem
    let color: SwiftUI.Color

    var body: some View {
        SUIStackView(alignment: .center, axis: .vertical, spacing: 6) {
            SUIImageViewView(model: .systemSymbol(
                item.symbol,
                accessibility: .init(label: item.title),
                size: .init(width: 24, height: 24),
                contentModeIsFit: true
            ))
            .accentColor(.white)
            SUILabelView(
                model: .text(item.title),
                font: .systemFont(ofSize: 12, weight: .medium),
                textColor: .white,
                textAlignment: .center
            )
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
