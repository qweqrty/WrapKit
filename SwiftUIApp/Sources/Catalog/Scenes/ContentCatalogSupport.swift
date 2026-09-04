import SwiftUI
import WrapKit

enum TextOutputCatalogAction: String, CaseIterable, Hashable {
    case addLabelFragment
    case replayCountingAnimation

    var title: String {
        switch self {
        case .addLabelFragment: return "Add attributed fragment"
        case .replayCountingAnimation: return "Replay number animation"
        }
    }
}

enum ImageViewOutputCatalogAction: String, CaseIterable, Hashable {
    case systemImage
    case dataImage
    case invalidDataImage
    case lightOnlyRemoteImage
    case darkOnlyRemoteImage
    case lightDarkRemoteImage
    case clearOptionalValues

    var title: String {
        switch self {
        case .systemImage: return "Model: SF Symbol"
        case .dataImage: return "Image: valid PNG data"
        case .invalidDataImage: return "Image: invalid data"
        case .lightOnlyRemoteImage: return "Image: light-only URL"
        case .darkOnlyRemoteImage: return "Image: dark-only URL"
        case .lightDarkRemoteImage: return "Image: distinct light / dark URLs"
        case .clearOptionalValues: return "Send image and optional values as nil"
        }
    }
}

enum ExpandableCardViewOutputCatalogAction: String, CaseIterable, Hashable {
    case toggle

    var title: String { "Expand / collapse model" }
}

enum TextCatalogSetting: String, CaseIterable, Hashable {
    case model
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .hidden: return "Hide TextOutput"
        }
    }

    var subtitle: String {
        switch self {
        case .model: return "Off calls display(model: nil)"
        case .hidden: return "Component visibility"
        }
    }

    var initialIsOn: Bool {
        self == .model
    }
}

enum ImageCatalogSetting: String, CaseIterable, Hashable {
    case model
    case size
    case contentMode
    case borderWidth
    case borderColor
    case cornerRadius
    case alpha
    case onPress
    case onLongPress
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .size: return "Use large size"
        case .contentMode: return "Fill available bounds"
        case .borderWidth: return "Use thick border"
        case .borderColor: return "Use blue border"
        case .cornerRadius: return "Use round corners"
        case .alpha: return "Reduce opacity"
        case .onPress: return "Enable tap action"
        case .onLongPress: return "Enable long-press action"
        case .hidden: return "Hide ImageViewOutput"
        }
    }

    var subtitle: String {
        switch self {
        case .model: return "Off calls display(model: nil)"
        case .size: return "120 × 80 → 160 × 112"
        case .contentMode: return "Fit or fill the available bounds"
        case .borderWidth: return "2 pt → 6 pt"
        case .borderColor: return "separator → systemBlue"
        case .cornerRadius: return "16 pt → 52 pt"
        case .alpha: return "1.0 → 0.35"
        case .onPress: return "Tap updates the status"
        case .onLongPress: return "Long press updates the status"
        case .hidden: return "Component visibility"
        }
    }

    var initialIsOn: Bool {
        self == .model
    }
}

enum ExpandableCatalogSetting: String, CaseIterable, Hashable {
    case hidden

    var title: String { "Hide ExpandableCardViewOutput" }
    var subtitle: String { "Component visibility" }
}

enum TitledCatalogSetting: String, CaseIterable, Hashable {
    case model
    case validation
    case titles
    case bottomTitles
    case leadingBottomTitle
    case trailingBottomTitle
    case interaction
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .validation: return "Show validation error"
        case .titles: return "Show titles"
        case .bottomTitles: return "Show bottom titles"
        case .leadingBottomTitle: return "Use validation message"
        case .trailingBottomTitle: return "Use maximum character count"
        case .interaction: return "Enable interaction"
        case .hidden: return "Hide TitledOutput"
        }
    }

    var subtitle: String {
        switch self {
        case .model: return "Off calls display(model: nil)"
        case .validation: return "Switch between valid and invalid models"
        case .titles: return "Primary title group"
        case .bottomTitles: return "Supporting title group"
        case .leadingBottomTitle: return "Helper text → validation error"
        case .trailingBottomTitle: return "Current count → 40/40"
        case .interaction: return "Touch handling"
        case .hidden: return "Component visibility"
        }
    }

    var initialIsOn: Bool {
        switch self {
        case .model, .titles, .bottomTitles, .interaction: return true
        case .validation, .leadingBottomTitle, .trailingBottomTitle, .hidden: return false
        }
    }
}

enum EmptyCatalogSetting: String, CaseIterable, Hashable {
    case title
    case subtitle
    case button
    case image
    case hidden

    var title: String {
        switch self {
        case .title: return "Show title"
        case .subtitle: return "Show subtitle"
        case .button: return "Show action button"
        case .image: return "Show image"
        case .hidden: return "Hide EmptyViewOutput"
        }
    }

    var subtitle: String {
        switch self {
        case .title: return "Primary message"
        case .subtitle: return "Supporting message"
        case .button: return "Action and accessibility"
        case .image: return "State illustration"
        case .hidden: return "Component visibility"
        }
    }

    var initialIsOn: Bool {
        self != .hidden
    }
}

enum CardCatalogSetting: String, CaseIterable, Hashable {
    case model
    case title
    case valueTitle
    case subTitle
    case leadingImage
    case secondaryLeadingImage
    case trailingImage
    case secondaryTrailingImage
    case leadingTitles
    case trailingTitles
    case switchControl
    case bottomImage
    case bottomSeparator
    case backgroundImage
    case gradientBorder
    case chipStyle
    case interaction
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .title: return "Show title"
        case .valueTitle: return "Show valueTitle"
        case .subTitle: return "Show subTitle"
        case .leadingImage: return "Show leadingImage"
        case .secondaryLeadingImage: return "Show secondaryLeadingImage"
        case .trailingImage: return "Show trailingImage"
        case .secondaryTrailingImage: return "Show secondaryTrailingImage"
        case .leadingTitles: return "Show leadingTitles"
        case .trailingTitles: return "Show trailingTitles"
        case .switchControl: return "Show switchControl"
        case .bottomImage: return "Show bottomImage"
        case .bottomSeparator: return "Show bottomSeparator"
        case .backgroundImage: return "Show backgroundImage"
        case .gradientBorder: return "Enable gradientBorder"
        case .chipStyle: return "Enable chip style"
        case .interaction: return "Enable tap and long press"
        case .hidden: return "Hide the card"
        }
    }

    var subtitle: String {
        switch self {
        case .model: return "Off calls display(model: nil)"
        case .title: return "Primary card text"
        case .valueTitle: return "Second line below title"
        case .subTitle: return "Description in a separate column"
        case .leadingImage: return "Icon before title"
        case .secondaryLeadingImage: return "Second leading icon"
        case .trailingImage: return "Trailing arrow"
        case .secondaryTrailingImage: return "Second trailing icon"
        case .leadingTitles: return "NEW / 1 before title"
        case .trailingTitles: return "State / On at the trailing edge"
        case .switchControl: return "Interactive switch"
        case .bottomImage: return "Image below the main card content"
        case .bottomSeparator: return "Separator along the bottom edge"
        case .backgroundImage: return "Background SF Symbol"
        case .gradientBorder: return "Animated gradient border"
        case .chipStyle: return "Gray background, compact padding, pill corners"
        case .interaction: return "Tap updates status; long press resets"
        case .hidden: return "Component visibility"
        }
    }

    var initialIsOn: Bool {
        self == .model || self == .title
    }
}

enum LabelCatalogMode: String, CaseIterable, Equatable {
    case model
    case textModel
    case plain
    case attributes
    case html
    case animatedDecimal

    var title: String {
        switch self {
        case .model: return "Presentable model"
        case .textModel: return "Text model"
        case .plain: return "Plain text"
        case .attributes: return "Attributed fragments"
        case .html: return "HTML"
        case .animatedDecimal: return "Animated number"
        }
    }
}

enum TitledCatalogPreset: Equatable {
    case valid
    case invalid
}

enum EmptyCatalogPreset: String, CaseIterable, Equatable {
    case noResults
    case error
    case success

    var title: String {
        switch self {
        case .noResults: return "No results"
        case .error: return "Loading error"
        case .success: return "Success"
        }
    }
}

final class TextOutputCatalogAdapters {
    let output = TextOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let mode = CardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: TextCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let actions = Dictionary(
        uniqueKeysWithValues: TextOutputCatalogAction.allCases.map {
            ($0, ButtonOutputSwiftUIAdapter())
        }
    )
}

final class ImageViewOutputCatalogAdapters {
    let output = ImageViewOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: ImageCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let actions = Dictionary(
        uniqueKeysWithValues: ImageViewOutputCatalogAction.allCases.map {
            ($0, ButtonOutputSwiftUIAdapter())
        }
    )
}

final class CardViewOutputCatalogAdapters {
    let output = CardViewOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let enableAll = ButtonOutputSwiftUIAdapter()
    let reset = ButtonOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: CardCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

final class ExpandableCardViewOutputCatalogAdapters {
    let output = ExpandableCardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: ExpandableCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
    let actions = Dictionary(
        uniqueKeysWithValues: ExpandableCardViewOutputCatalogAction.allCases.map {
            ($0, ButtonOutputSwiftUIAdapter())
        }
    )
}

final class TitledOutputCatalogAdapters {
    let output = TitledOutputSwiftUIAdapter()
    let content = ButtonOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: TitledCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

final class EmptyViewOutputCatalogAdapters {
    let output = EmptyViewOutputSwiftUIAdapter()
    let preset = CardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: EmptyCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}
