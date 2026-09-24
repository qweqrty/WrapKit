import Foundation
import WrapKit

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
            searchImage: ImageFactory.systemImage(named: "magnifyingglass") ?? WrapKit.Image(),
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
        selectedImage: .symbolName("largecircle.fill.circle"),
        notSelectedImage: .symbolName("circle"),
        lineColor: .separator,
        keyLabelNumberOfLines: 0
    )

    static let multipleCell = SelectionConfiguration.Cell(
        titleFont: .systemFont(ofSize: 17),
        trailingFont: .systemFont(ofSize: 13),
        titleColor: .label,
        selectedTitleColor: .systemBlue,
        trailingColor: .secondaryLabel,
        selectedImage: .symbolName("checkmark.square.fill"),
        notSelectedImage: .symbolName("square"),
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
