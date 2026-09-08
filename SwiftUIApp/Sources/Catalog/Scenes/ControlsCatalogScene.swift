import SwiftUI
import WrapKit

enum ButtonCatalogSetting: String, CaseIterable, Hashable {
    case model
    case enabled
    case image
    case destructiveStyle
    case title
    case spacing
    case action
    case largeHeight
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .enabled: return "Enabled (off → disabled)"
        case .image: return "Show image"
        case .destructiveStyle: return "Destructive style (off → primary)"
        case .title: return "Show title"
        case .spacing: return "Spacing 12 (off → 0)"
        case .action: return "Handle taps"
        case .largeHeight: return "Height 56 (off → 44)"
        case .hidden: return "Hide button"
        }
    }
}

enum SwitchCatalogSetting: String, CaseIterable, Hashable {
    case model
    case isOn
    case enabled
    case tintColor
    case thumbTintColor
    case backgroundColor
    case cornerRadius
    case loading
    case action
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .isOn: return "isOn state"
        case .enabled: return "Enabled (off → disabled)"
        case .tintColor: return "Use a purple onTintColor"
        case .thumbTintColor: return "Use a yellow thumbTintColor"
        case .backgroundColor: return "Use a blue backgroundColor"
        case .cornerRadius: return "Use an 8 pt cornerRadius"
        case .loading: return "Show the configured shimmer"
        case .action: return "Handle value changes"
        case .hidden: return "Hide switch"
        }
    }
}

enum SegmentCatalogSetting: String, CaseIterable, Hashable {
    case fourSegments
    case purpleAppearance

    var title: String {
        switch self {
        case .fourSegments: return "Four segments (off → three)"
        case .purpleAppearance: return "Purple appearance"
        }
    }
}

enum ProgressCatalogSetting: String, CaseIterable, Hashable {
    case model
    case highProgress
    case alternateStyle
    case hidden

    var title: String {
        switch self {
        case .model: return "Show full model"
        case .highProgress: return "Progress 80% (off → 24%)"
        case .alternateStyle: return "Thick purple style (off → style nil)"
        case .hidden: return "Hide progress bar"
        }
    }
}

enum RefreshCatalogSetting: String, CaseIterable, Hashable {
    case purpleTint
    case behindContent
    case directCallbacks
    case primaryCallback
    case appendedCallback

    var title: String {
        switch self {
        case .purpleTint: return "Use a purple tint"
        case .behindContent: return "Place the indicator behind scroll content"
        case .directCallbacks: return "Configure actions through public onRefresh"
        case .primaryCallback: return "Run the primary refresh action"
        case .appendedCallback: return "Run an additional refresh action"
        }
    }
}

enum ToastCatalogSetting: String, CaseIterable, Hashable {
    case positionTop
    case bottomPadding
    case shadow
    case persistent
    case tapAction
    case valueTitle
    case subTitle
    case trailingImage
    case switchControl
    case bottomSeparator
    case leadingTitles
    case trailingTitles
    case secondaryLeadingImage
    case secondaryTrailingImage
    case customImage
    case customBackground
    case customButtons

    var title: String {
        switch self {
        case .positionTop: return "Position: top (off → bottom)"
        case .bottomPadding: return "Add 40 pt bottom padding"
        case .shadow: return "Show shadowColor"
        case .persistent: return "Keep visible (duration: nil)"
        case .tapAction: return "Handle toast taps"
        case .valueTitle: return "Show valueTitle"
        case .subTitle: return "Show subTitle"
        case .trailingImage: return "Show trailingImage"
        case .switchControl: return "Show switchControl"
        case .bottomSeparator: return "Show bottomSeparator"
        case .leadingTitles: return "Show leadingTitles"
        case .trailingTitles: return "Show trailingTitles"
        case .secondaryLeadingImage: return "Show secondaryLeadingImage"
        case .secondaryTrailingImage: return "Show secondaryTrailingImage"
        case .customImage: return "Show custom image"
        case .customBackground: return "Show custom backgroundColor"
        case .customButtons: return "Show custom action buttons"
        }
    }
}

struct ControlsCatalogViewConfiguration {
    let segmentAppearance: SegmentedControlAppearance
    let switchStyle: SwitchControlPresentableModel.Style

    static var appleDefault: ControlsCatalogViewConfiguration {
        let shimmerStyle = ShimmerStyle(
            backgroundColor: .systemGray5,
            gradientColorOne: .systemGray5,
            gradientColorTwo: .systemGray3,
            cornerRadius: 10
        )

        return .init(
            segmentAppearance: .init(
                colors: .init(
                    textColor: .label,
                    backgroundColor: .tertiarySystemGroupedBackground,
                    selectedBackgroundColor: .secondarySystemGroupedBackground
                ),
                font: .systemFont(ofSize: 14, weight: .medium),
                cornerRadius: 9
            ),
            switchStyle: .init(
                tintColor: .systemGreen,
                thumbTintColor: .white,
                backgroundColor: .systemGray5,
                cornerRadius: 16,
                shimmerStyle: shimmerStyle
            )
        )
    }
}

enum ControlsCatalogAppearance {
    static func status(_ text: String) -> TextOutputPresentableModel {
        .textStyled(
            accessibilityIdentifier: "catalog.controls.status",
            text: .text(text),
            cornerStyle: .fixed(12),
            insets: .init(horizontal: 14, vertical: 12),
            backgroundColor: .systemBlue.withAlphaComponent(0.08)
        )
    }

    static func primaryButtonStyle() -> WrapKit.ButtonStyle {
        .init(
            backgroundColor: .systemBlue,
            titleColor: .white,
            pressedColor: .systemBlue.withAlphaComponent(0.72),
            pressedTintColor: .white,
            font: .systemFont(ofSize: 17, weight: .semibold),
            cornerRadius: 12,
            loadingIndicatorColor: .white
        )
    }

    static func outlineButtonStyle() -> WrapKit.ButtonStyle {
        .init(
            backgroundColor: .secondarySystemGroupedBackground,
            titleColor: .systemBlue,
            borderWidth: 1,
            borderColor: .systemBlue,
            pressedColor: .systemBlue.withAlphaComponent(0.1),
            pressedTintColor: .systemBlue,
            font: .systemFont(ofSize: 17, weight: .semibold),
            cornerRadius: 12,
            loadingIndicatorColor: .systemBlue
        )
    }

    static func destructiveButtonStyle() -> WrapKit.ButtonStyle {
        .init(
            backgroundColor: .systemRed,
            titleColor: .white,
            pressedColor: .systemRed.withAlphaComponent(0.72),
            pressedTintColor: .white,
            font: .systemFont(ofSize: 17, weight: .semibold),
            cornerRadius: 12,
            loadingIndicatorColor: .white
        )
    }

    static func purpleSwitchStyle() -> SwitchControlPresentableModel.Style {
        .init(
            tintColor: .systemPurple,
            thumbTintColor: .systemYellow,
            backgroundColor: .systemPurple.withAlphaComponent(0.12),
            cornerRadius: 16,
            shimmerStyle: .init(
                backgroundColor: .systemPurple.withAlphaComponent(0.12),
                gradientColorOne: .systemGray5,
                gradientColorTwo: .systemPurple.withAlphaComponent(0.28),
                cornerRadius: 16
            )
        )
    }

    static func purpleSegmentAppearance() -> SegmentedControlAppearance {
        .init(
            colors: .init(
                textColor: .label,
                backgroundColor: .systemPurple.withAlphaComponent(0.12),
                selectedBackgroundColor: .systemPurple.withAlphaComponent(0.3)
            ),
            font: .systemFont(ofSize: 13, weight: .semibold),
            cornerRadius: 14
        )
    }

    static func progressStyle(isAlternate: Bool) -> ProgressBarStyle {
        .init(
            backgroundColor: isAlternate
                ? .systemPurple.withAlphaComponent(0.14)
                : .systemGray5,
            progressBarColor: isAlternate ? .systemPurple : .systemBlue,
            height: isAlternate ? 18 : 10,
            trackHeight: isAlternate ? 10 : 6,
            cornerStyle: isAlternate ? .fixed(4) : .automatic
        )
    }

    static func toastStyle(accentColor: WrapKit.Color) -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: .secondarySystemGroupedBackground,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .init(horizontal: 14, vertical: 12),
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: accentColor,
            titleKeyTextColor: .label,
            trailingTitleKeyTextColor: .label,
            titleValueTextColor: .secondaryLabel,
            subTitleTextColor: .secondaryLabel,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 15, weight: .semibold),
            titleKeyLabelFont: .systemFont(ofSize: 16, weight: .semibold),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 13),
            cornerRadius: 16,
            stackSpace: 3,
            hStackViewSpacing: 10,
            titleKeyNumberOfLines: 1,
            titleValueNumberOfLines: 2,
            borderColor: accentColor,
            borderWidth: 1
        )
    }
}

struct ControlsCatalogSectionTitle: View {
    let title: String

    var body: some View {
        SUILabelView(
            model: .text(title),
            font: .systemFont(ofSize: 13, weight: .semibold),
            textColor: .secondaryLabel
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ControlsCatalogStatusView: View {
    let adapter: TextOutputSwiftUIAdapter

    var body: some View {
        SUILabel(
            adapter: adapter,
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .label
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
