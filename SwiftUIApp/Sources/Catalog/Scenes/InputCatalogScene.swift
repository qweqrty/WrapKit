import Foundation
import SwiftUI
import WrapKit

struct InputCatalogViewConfiguration {
    let fieldAppearance: TextfieldAppearance
    let codeAppearance: TextfieldAppearance
    let searchAppearance: TextfieldAppearance
    let searchContentInsets: WrapKit.EdgeInsets

    static var appleDefault: InputCatalogViewConfiguration {
        InputCatalogViewConfiguration(
            fieldAppearance: .init(
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
                    disabledBackgroundColor: .tertiarySystemFill
                ),
                font: .systemFont(ofSize: 17),
                border: .init(idleBorderWidth: 1, selectedBorderWidth: 2),
                placeholder: .init(
                    color: .placeholderText,
                    disabledColor: .tertiaryLabel,
                    font: .systemFont(ofSize: 17)
                )
            ),
            codeAppearance: .init(
                colors: .init(
                    textColor: .label,
                    selectedBorderColor: .systemBlue,
                    selectedBackgroundColor: .systemBlue.withAlphaComponent(0.08),
                    selectedErrorBorderColor: .systemRed,
                    errorBorderColor: .systemRed,
                    errorBackgroundColor: .systemRed.withAlphaComponent(0.08),
                    deselectedBorderColor: .separator,
                    deselectedBackgroundColor: .secondarySystemBackground,
                    disabledTextColor: .tertiaryLabel,
                    disabledBackgroundColor: .tertiarySystemFill
                ),
                font: .monospacedDigitSystemFont(ofSize: 22, weight: .semibold),
                border: .init(idleBorderWidth: 1, selectedBorderWidth: 2)
            ),
            searchAppearance: .init(
                colors: .init(
                    textColor: .label,
                    selectedBorderColor: .clear,
                    selectedBackgroundColor: .clear,
                    selectedErrorBorderColor: .systemRed,
                    errorBorderColor: .systemRed,
                    errorBackgroundColor: .clear,
                    deselectedBorderColor: .clear,
                    deselectedBackgroundColor: .clear,
                    disabledTextColor: .tertiaryLabel,
                    disabledBackgroundColor: .clear
                ),
                font: .systemFont(ofSize: 17),
                border: .init(idleBorderWidth: 0, selectedBorderWidth: 0),
                placeholder: .init(
                    color: .placeholderText,
                    disabledColor: .tertiaryLabel,
                    font: .systemFont(ofSize: 17)
                )
            ),
            searchContentInsets: .init(horizontal: 8, vertical: 0)
        )
    }
}

enum SearchBarCatalogSetting: String, CaseIterable, Hashable {
    case hidden
    case textFieldHidden
    case leftButtonHidden
    case rightButtonHidden
    case shortPlaceholder
    case blueBackground
    case wideSpacing

    var title: String {
        switch self {
        case .hidden: return "Hide search bar"
        case .textFieldHidden: return "Hide text field"
        case .leftButtonHidden: return "Hide leading button"
        case .rightButtonHidden: return "Hide trailing button"
        case .shortPlaceholder: return "Use a short placeholder"
        case .blueBackground: return "Use a blue background"
        case .wideSpacing: return "Increase spacing"
        }
    }

}

enum DatePickerCatalogSetting: String, CaseIterable, Hashable {
    case limitedRange
    case callbackEnabled

    var title: String {
        switch self {
        case .limitedRange: return "Limit to the next 30 days"
        case .callbackEnabled: return "Handle date changes"
        }
    }
}

enum DatePickerCatalogMode: String, CaseIterable, Hashable {
    case time
    case date
    case dateAndTime
    case countDownTimer

    var title: String {
        switch self {
        case .time: return "Time"
        case .date: return "Date"
        case .dateAndTime: return "Date and time"
        case .countDownTimer: return "Countdown timer"
        }
    }

    var value: DatePickerMode {
        switch self {
        case .time: return .time
        case .date: return .date
        case .dateAndTime: return .dateAndTime
        case .countDownTimer: return .countDownTimer
        }
    }
}

enum PickerCatalogSetting: String, CaseIterable, Hashable {
    case hidden
    case twoComponents
    case shortList
    case numberedTitles
    case callbackEnabled

    var title: String {
        switch self {
        case .hidden: return "Hide picker"
        case .twoComponents: return "Show two components"
        case .shortList: return "Show two items"
        case .numberedTitles: return "Number the options"
        case .callbackEnabled: return "Handle selection"
        }
    }
}

enum TextInputCatalogSetting: String, CaseIterable, Hashable {
    case modelHidden
    case invalid
    case editingLocked
    case interactionDisabled
    case secureEntry
    case selectionDisabled
    case emptyState
    case focus
    case leadingIcon
    case clearButton
    case trailingSymbol
    case dateInput
    case customPickerInput
    case hideTextView

    var title: String {
        switch self {
        case .modelHidden: return "Call display(model: nil)"
        case .invalid: return "Show validation error"
        case .editingLocked: return "Lock editing"
        case .interactionDisabled: return "Disable interaction"
        case .secureEntry: return "Use secure entry"
        case .selectionDisabled: return "Disable text selection"
        case .emptyState: return "Clear all values"
        case .focus: return "Focus the single-line field"
        case .leadingIcon: return "Show leading icon"
        case .clearButton: return "Show clear button while editing"
        case .trailingSymbol: return "Show trailing symbol"
        case .dateInput: return "Use a date input view"
        case .customPickerInput: return "Use a custom picker input"
        case .hideTextView: return "Hide the multiline field"
        }
    }

    var scope: String {
        switch self {
        case .modelHidden,
             .invalid,
             .editingLocked,
             .interactionDisabled,
             .secureEntry,
             .selectionDisabled,
             .emptyState:
            return "All inputs"
        case .focus,
             .leadingIcon,
             .clearButton,
             .trailingSymbol,
             .dateInput,
             .customPickerInput:
            return "Single-line"
        case .hideTextView:
            return "Multiline"
        }
    }
}

enum TextInputMaskPreset: String, CaseIterable, Hashable {
    case none
    case usPhone
    case paymentCard
    case amount

    var title: String {
        switch self {
        case .none: return "No mask"
        case .usPhone: return "US phone"
        case .paymentCard: return "Payment card"
        case .amount: return "Amount in USD"
        }
    }

    var example: String {
        switch self {
        case .none: return "Free text"
        case .usPhone: return "(555) 123-4567"
        case .paymentCard: return "4242 4242 4242 4242"
        case .amount: return "2490.50 USD"
        }
    }
}

struct InputCatalogSurface<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        SUIWrapperView(
            backgroundColor: SwiftUI.Color(uiColor: .secondarySystemGroupedBackground),
            cornerRadius: 16,
            padding: .init(all: 16)
        ) {
            content
        }
    }
}

struct InputCatalogSectionTitle: View {
    let adapter: TextOutputSwiftUIAdapter

    var body: some View {
        SUILabel(
            adapter: adapter,
            font: .systemFont(ofSize: 17, weight: .semibold),
            textColor: .label
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InputCatalogStatus: View {
    let adapter: TextOutputSwiftUIAdapter

    var body: some View {
        SUIWrapperView(
            backgroundColor: SwiftUI.Color(uiColor: .secondarySystemGroupedBackground),
            cornerRadius: 14,
            padding: .init(all: 14)
        ) {
            SUILabel(
                adapter: adapter,
                font: .systemFont(ofSize: 13),
                textColor: .secondaryLabel
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

func displayInputCatalogStatus(_ message: String, on output: TextOutput?) {
    output?.display(model: .text(
        accessibilityIdentifier: "catalog.input.lastEvent",
        accessibility: .init(label: "Result: \(message)"),
        message
    ))
}
