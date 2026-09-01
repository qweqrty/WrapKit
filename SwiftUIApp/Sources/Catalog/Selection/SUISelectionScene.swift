import Combine
import SwiftUI
import UIKit
import WrapKit

final class SUISelectionSceneAdapters {
    let selection = SelectionOutputSwiftUIAdapter()
    let header = HeaderOutputSwiftUIAdapter()
    let emptyView = EmptyViewOutputSwiftUIAdapter()
    let resetButton = ButtonOutputSwiftUIAdapter()
    let selectButton = ButtonOutputSwiftUIAdapter()
    let searchField = TextInputOutputSwiftUIAdapter()
    let refresh = RefreshControlOutputSwiftUIAdapter()
    let table = TableOutputSwiftUIAdapter<SelectionType.SelectionCellPresentableModel, Void, Void>()
}

private final class SUISelectionSceneStateModel: ObservableObject {
    @Published private(set) var shouldShowSearch = false

    private let input: any SelectionInput
    private let table: TableOutputSwiftUIAdapter<SelectionType.SelectionCellPresentableModel, Void, Void>
    private let emptyView: EmptyViewOutputSwiftUIAdapter
    private let selectButton: ButtonOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []

    init(
        input: any SelectionInput,
        adapters: SUISelectionSceneAdapters
    ) {
        self.input = input
        table = adapters.table
        emptyView = adapters.emptyView
        selectButton = adapters.selectButton

        adapters.selection.$displayShouldShowSearchBarState
            .compactMap { $0 }
            .map(\.shouldShowSearchBar)
            .removeDuplicates()
            .sink { [weak self] shouldShowSearch in
                self?.shouldShowSearch = shouldShowSearch
            }
            .store(in: &cancellables)

        adapters.selection.$displayItemsSelectedCountTitleState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(state)
            }
            .store(in: &cancellables)
    }

    private func apply(_ state: SelectionOutputSwiftUIAdapter.DisplayItemsSelectedCountTitleState) {
        table.display(sections: state.items)

        let cells = state.items.flatMap(\.cells)
        let selectedCount = input.items.filter { $0.isSelected.get() == true }.count
        let countSuffix = selectedCount == 0 ? "" : " (\(selectedCount))"
        selectButton.display(title: "\(state.selectedCountTitle)\(countSuffix)")
        emptyView.display(isHidden: !cells.isEmpty)
    }
}

struct SUISelectionScene: View {
    private let input: any SelectionInput
    private let lifeCycleOutput: LifeCycleViewOutput
    private let adapters: SUISelectionSceneAdapters
    private let configuration: SelectionFlow.Model
    private let isRefreshEnabled: Bool

    @StateObject private var stateModel: SUISelectionSceneStateModel

    init(
        input: any SelectionInput,
        lifeCycleOutput: LifeCycleViewOutput,
        adapters: SUISelectionSceneAdapters,
        configuration: SelectionFlow.Model,
        isRefreshEnabled: Bool = false
    ) {
        self.input = input
        self.lifeCycleOutput = lifeCycleOutput
        self.adapters = adapters
        self.configuration = configuration
        self.isRefreshEnabled = isRefreshEnabled
        _stateModel = StateObject(wrappedValue: SUISelectionSceneStateModel(
            input: input,
            adapters: adapters
        ))
    }

    var body: some View {
        LifeCycleView(lifeCycleOutput: lifeCycleOutput) {
            SUIStackView(axis: .vertical, spacing: 0) {
                SUINavigationBar(adapter: adapters.header)

                if stateModel.shouldShowSearch {
                    searchField
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }

                tableContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if input.isMultipleSelectionEnabled {
                    selectionButtons
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
            }
            .background(SwiftUI.Color(uiColor: configuration.content.backgroundColor))
        }
    }

    private var searchField: some View {
        SUITextField(
            adapter: adapters.searchField,
            appearance: configuration.searchBar.textfieldAppearence,
            leadingView: AnyView(
                SUIImageViewView(model: .init(
                    accessibility: .init(label: configuration.texts.searchTitle),
                    size: .init(width: 18, height: 18),
                    image: .asset(configuration.searchBar.searchImage),
                    contentModeIsFit: true
                ))
                .accentColor(SwiftUI.Color(uiColor: configuration.searchBar.tintColor))
            ),
            contentInsets: .init(top: 10, leading: 12, bottom: 10, trailing: 12),
            cornerStyle: .fixed(10)
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var tableContent: some View {
        ZStack {
            if isRefreshEnabled {
                selectionTable.refreshControl(adapter: adapters.refresh)
            } else {
                selectionTable
            }

            SUIEmptyView(adapter: adapters.emptyView)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var selectionTable: some View {
        SUITableView(
            adapter: adapters.table,
            style: .lazyVStack(scrollable: true),
            cellContent: { model, _ in
                SUISelectionCell(model: model)
                    .id(model.id)
            },
            headerContent: { _ in SwiftUI.EmptyView() },
            footerContent: { _ in SwiftUI.EmptyView() }
        )
        .padding(.horizontal, 12)
    }

    private var selectionButtons: some View {
        SUIStackView(axis: .horizontal, spacing: 12) {
            SUIButton(adapter: adapters.resetButton, pressAnimations: [.shrink])
                .frame(maxWidth: .infinity)
            SUIButton(adapter: adapters.selectButton, pressAnimations: [.shrink])
                .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SUISelectionCell: View {
    let model: SelectionType.SelectionCellPresentableModel
    @State private var selected: Bool

    init(model: SelectionType.SelectionCellPresentableModel) {
        self.model = model
        _selected = .init(initialValue: model.isSelected.get() == true)
    }

    private var isSelected: Bool {
        selected
    }

    private var selectionImage: ImageEnum? {
        isSelected
            ? model.configuration.selectedImage
            : model.configuration.notSelectedImage
    }

    var body: some View {
        SUIStackView(alignment: .center, axis: .horizontal, spacing: 8) {
            leadingView

            SUILabelView(
                model: .text(model.title),
                font: model.configuration.titleFont,
                textColor: isSelected
                    ? model.configuration.selectedTitleColor ?? model.configuration.titleColor
                    : model.configuration.titleColor
            )
            .lineLimit(model.configuration.keyLabelNumberOfLines == 0
                ? nil
                : model.configuration.keyLabelNumberOfLines)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let trailingTitle = model.trailingTitle {
                SUILabelView(
                    model: .text(trailingTitle),
                    font: model.configuration.trailingFont,
                    textColor: model.configuration.trailingColor,
                    textAlignment: .right
                )
                .fixedSize(horizontal: true, vertical: false)
            }

            if let selectionImage {
                SUIImageViewView(model: .init(
                    accessibility: .init(label: isSelected ? "Selected" : "Not selected"),
                    size: .init(width: 22, height: 22),
                    image: selectionImage,
                    contentModeIsFit: true
                ))
                .accentColor(.blue)
            }
        }
        .frame(minHeight: 56)
        .overlay(alignment: .bottom) {
            SwiftUI.Color(uiColor: model.configuration.lineColor)
                .frame(height: 1 / UIScreen.main.scale)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("selection.item.\(model.id)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onReceive(model.isSelected.publisher) { isSelected in
            let newValue = isSelected == true
            if selected != newValue {
                selected = newValue
            }
        }
    }

    @ViewBuilder
    private var leadingView: some View {
        if model.leadingImage != nil || model.circleColor != nil {
            SUIImageViewView(model: .init(
                size: .init(width: 24, height: 24),
                image: model.leadingImage,
                contentModeIsFit: true,
                cornerRadius: 12
            ))
            .background(
                SwiftUI.Color(uiColor: UIColor.catalogColor(hex: model.circleColor) ?? .clear),
                in: Circle()
            )
        }
    }
}

private extension UIColor {
    static func catalogColor(hex: String?) -> UIColor? {
        guard var hex else { return nil }
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        guard hex.count == 6, let value = UInt64(hex, radix: 16) else { return nil }
        return UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}

enum CatalogSelectionAppearance {
    static let configuration: SelectionConfiguration = .init(
        texts: .init(
            searchTitle: "Search",
            resetTitle: "Reset",
            selectTitle: "Select",
            selectedCountTitle: "Selected"
        ),
        content: .init(
            lineColor: .separator,
            backgroundColor: .systemBackground,
            refreshColor: .systemBlue,
            backButtonImage: ImageFactory.systemImage(named: "xmark"),
            navBarFont: .systemFont(ofSize: 17, weight: .semibold),
            navBarTextColor: .label,
            shadowBackgroundColor: .black.withAlphaComponent(0.2)
        ),
        navBar: .init(
            backgroundColor: .systemBackground,
            horizontalSpacing: 12,
            primeFont: .systemFont(ofSize: 17, weight: .semibold),
            primeColor: .label,
            secondaryFont: .systemFont(ofSize: 13),
            secondaryColor: .secondaryLabel,
            numberOfLines: 1
        ),
        resetButton: .init(
            labelFont: .systemFont(ofSize: 17, weight: .semibold),
            textColor: .systemBlue,
            backgroundColor: .secondarySystemBackground,
            borderColor: .separator
        ),
        searchButton: .init(
            labelFont: .systemFont(ofSize: 17, weight: .semibold),
            textColor: .white,
            backgroundColor: .systemBlue,
            borderColor: .clear
        ),
        searchBar: .init(
            textfieldAppearence: .catalogSelection,
            searchImage: UIImage(systemName: "magnifyingglass") ?? UIImage(),
            tintColor: .secondaryLabel
        ),
        resetButtonColors: .init(
            activeTitleColor: .systemBlue,
            activeBorderColor: .separator,
            activeBackgroundColor: .secondarySystemBackground,
            inactiveTitleColor: .tertiaryLabel,
            inactiveBorderColor: .separator,
            inactiveBackgroundColor: .secondarySystemBackground
        )
    )

    static let cell = SelectionConfiguration.Cell(
        titleFont: .systemFont(ofSize: 17),
        trailingFont: .systemFont(ofSize: 13),
        titleColor: .label,
        selectedTitleColor: .systemBlue,
        trailingColor: .secondaryLabel,
        selectedImage: .asset(ImageFactory.systemImage(named: "largecircle.fill.circle")),
        notSelectedImage: .asset(ImageFactory.systemImage(named: "circle")),
        lineColor: .separator,
        keyLabelNumberOfLines: 0
    )

    static let multipleCell = SelectionConfiguration.Cell(
        titleFont: .systemFont(ofSize: 17),
        trailingFont: .systemFont(ofSize: 13),
        titleColor: .label,
        selectedTitleColor: .systemBlue,
        trailingColor: .secondaryLabel,
        selectedImage: .asset(ImageFactory.systemImage(named: "checkmark.square.fill")),
        notSelectedImage: .asset(ImageFactory.systemImage(named: "square")),
        lineColor: .separator,
        keyLabelNumberOfLines: 0
    )
}

private extension TextfieldAppearance {
    static var catalogSelection: TextfieldAppearance {
        .init(
            colors: .init(
                textColor: .label,
                selectedBorderColor: .systemBlue,
                selectedBackgroundColor: .secondarySystemBackground,
                selectedErrorBorderColor: .systemRed,
                errorBorderColor: .systemRed,
                errorBackgroundColor: .systemRed.withAlphaComponent(0.08),
                deselectedBorderColor: .separator,
                deselectedBackgroundColor: .secondarySystemBackground,
                disabledTextColor: .tertiaryLabel,
                disabledBackgroundColor: .systemGray6
            ),
            font: .systemFont(ofSize: 17),
            border: .init(idleBorderWidth: 1, selectedBorderWidth: 1),
            placeholder: .init(
                color: .placeholderText,
                disabledColor: .tertiaryLabel,
                font: .systemFont(ofSize: 17),
                text: "Search"
            )
        )
    }
}
