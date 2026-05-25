import WrapKit
import WrapKitTestUtils
import SwiftUI
import UIKit

final class PairedLabelSnapshotSUT: NSObject {
    let uiKitLabel = Label()
    let adapter = TextOutputSwiftUIAdapter()
    private var currentModel: TextOutputPresentableModel?
    private var explicitTextInsets: UIEdgeInsets = .zero
    private var explicitBackgroundColor: UIColor?
    private var explicitCornerStyle: CornerStyle?
    private var swiftUIFont: UIFont = .systemFont(ofSize: 20)
    private var swiftUITextColor: UIColor = .label
    private var swiftUITextAlignment: NSTextAlignment = .natural

    override init() {
        super.init()
        swiftUIFont = uiKitLabel.font
        swiftUITextColor = uiKitLabel.textColor
        swiftUITextAlignment = uiKitLabel.textAlignment
    }
}

extension PairedLabelSnapshotSUT {
    var backgroundColor: UIColor? {
        get { uiKitLabel.backgroundColor }
        set {
            uiKitLabel.backgroundColor = newValue
            explicitBackgroundColor = newValue
            syncSwiftUIModel()
        }
    }

    var textInsets: UIEdgeInsets {
        get { uiKitLabel.textInsets }
        set {
            uiKitLabel.textInsets = newValue
            explicitTextInsets = newValue
            syncSwiftUIModel()
        }
    }

    var cornerStyle: CornerStyle? {
        get { uiKitLabel.cornerStyle }
        set {
            uiKitLabel.cornerStyle = newValue
            explicitCornerStyle = newValue
            syncSwiftUIModel()
        }
    }

    var textColor: UIColor! {
        get { uiKitLabel.textColor }
        set {
            uiKitLabel.textColor = newValue
            if let newValue {
                swiftUITextColor = newValue
            }
            syncSwiftUIModel()
        }
    }

    var font: UIFont! {
        get { uiKitLabel.font }
        set {
            uiKitLabel.font = newValue
            if let newValue {
                swiftUIFont = newValue
            }
            syncSwiftUIModel()
        }
    }

    var textAlignment: NSTextAlignment {
        get { uiKitLabel.textAlignment }
        set {
            uiKitLabel.textAlignment = newValue
            swiftUITextAlignment = newValue
            syncSwiftUIModel()
        }
    }
}

extension PairedLabelSnapshotSUT {
    func display(model: TextOutputPresentableModel?) {
        performDisplay(model) {
            uiKitLabel.display(model: model)
        }
    }

    func display(textModel: TextOutputPresentableModel.TextModel?) {
        let model = textModel.map { TextOutputPresentableModel(model: $0) }
        performDisplay(model) {
            uiKitLabel.display(textModel: textModel)
        }
    }

    func display(text: String?) {
        let model = TextOutputPresentableModel(model: .text(text))
        performDisplay(model) {
            uiKitLabel.display(text: text)
        }
    }

    func display(attributes: [TextAttributes]) {
        let model = TextOutputPresentableModel(model: .attributes(attributes))
        performDisplay(model) {
            uiKitLabel.display(attributes: attributes)
        }
    }

    func display(htmlString: String?, config: HTMLAttributedStringConfig?) {
        let model = TextOutputPresentableModel(model: .attributedString(htmlString, config: config))
        performDisplay(model) {
            uiKitLabel.display(htmlString: htmlString, config: config)
        }
    }

    func display(
        id: String? = nil,
        from startAmount: Decimal,
        to endAmount: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        let finalModel = mapToString?(endAmount) ?? .text(endAmount.asString())
        let wrappedCompletion = { [weak self] in
            self?.publish(model: .init(model: finalModel))
            completion?()
        }
        let animatedModel = TextOutputPresentableModel(
            model: .animatedDecimal(
                id: id,
                from: startAmount,
                to: endAmount,
                mapToString: mapToString,
                animationStyle: animationStyle,
                duration: duration,
                completion: wrappedCompletion
            )
        )
        currentModel = animatedModel
        uiKitLabel.display(
            id: id,
            from: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: wrappedCompletion
        )
        publish(model: animatedModel)
    }

    func display(
        from startAmount: Decimal,
        to endAmount: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        display(
            id: nil,
            from: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: completion
        )
    }

    func display(isHidden: Bool) {
        uiKitLabel.display(isHidden: isHidden)
        adapter.display(isHidden: isHidden)
    }
}

private extension PairedLabelSnapshotSUT {
    func performDisplay(
        _ model: TextOutputPresentableModel?,
        action: () -> Void
    ) {
        currentModel = model
        action()
        publish(model: model)
    }

    func publish(model: TextOutputPresentableModel?) {
        adapter.display(model: swiftUIModel(from: model, traitStyle: nil))
    }

    private func syncSwiftUIModel() {
        guard currentModel != nil else { return }
        publish(model: currentModel)
    }

    private func swiftUIModel(
        from model: TextOutputPresentableModel?,
        traitStyle: UIUserInterfaceStyle?
    ) -> TextOutputPresentableModel? {
        guard let model else { return nil }
        return .init(
            accessibilityIdentifier: model.accessibilityIdentifier,
            model: swiftUITextModel(from: model.model, traitStyle: traitStyle)
        )
    }

    private func swiftUITextModel(
        from model: TextOutputPresentableModel.TextModel?,
        traitStyle: UIUserInterfaceStyle?
    ) -> TextOutputPresentableModel.TextModel? {
        guard let model else { return nil }
        let resolvedModel = resolve(textModel: model, traitStyle: traitStyle)

        guard shouldWrapTextModelInTextStyled(resolvedModel) else {
            return resolvedModel
        }

        return .textStyled(
            text: resolvedModel,
            cornerStyle: explicitCornerStyle,
            insets: EdgeInsets(
                top: explicitTextInsets.top,
                leading: explicitTextInsets.left,
                bottom: explicitTextInsets.bottom,
                trailing: explicitTextInsets.right
            ),
            backgroundColor: resolve(color: explicitBackgroundColor, traitStyle: traitStyle)
        )
    }

    private func shouldWrapTextModelInTextStyled(_ model: TextOutputPresentableModel.TextModel) -> Bool {
        let hasInsets = explicitTextInsets.top != 0 || explicitTextInsets.left != 0 || explicitTextInsets.bottom != 0 || explicitTextInsets.right != 0
        let hasDecoration = hasInsets || explicitCornerStyle != nil || explicitBackgroundColor != nil

        guard hasDecoration else { return false }

        switch model {
        case .text, .attributes, .attributedString, .textStyled:
            return true
        default:
            return false
        }
    }

    private func resolve(
        textModel: TextOutputPresentableModel.TextModel,
        traitStyle: UIUserInterfaceStyle?
    ) -> TextOutputPresentableModel.TextModel {
        guard let traitStyle else { return textModel }
        switch textModel {
        case .text:
            return textModel
        case .attributes(let attributes):
            return .attributes(attributes.map { resolve(attribute: $0, traitStyle: traitStyle) })
        case .attributedString(let html, let config):
            return .attributedString(html, config: resolve(config: config, traitStyle: traitStyle))
        case .animatedDecimal(let id, let from, let to, let mapToString, let animationStyle, let duration, let completion):
            return .animatedDecimal(
                id: id,
                from: from,
                to: to,
                mapToString: mapToString,
                animationStyle: animationStyle,
                duration: duration,
                completion: completion
            )
        case .animated(let id, let from, let to, let mapToString, let animationStyle, let duration, let completion):
            return .animated(
                id: id,
                from,
                to,
                mapToString: mapToString,
                animationStyle: animationStyle,
                duration: duration,
                completion: completion
            )
        case .textStyled(let text, let cornerStyle, let insets, let height, let backgroundColor):
            return .textStyled(
                text: resolve(textModel: text, traitStyle: traitStyle),
                cornerStyle: cornerStyle,
                insets: insets,
                height: height,
                backgroundColor: resolve(color: backgroundColor, traitStyle: traitStyle)
            )
        }
    }

    private func resolve(attribute: TextAttributes, traitStyle: UIUserInterfaceStyle) -> TextAttributes {
        TextAttributes(
            id: attribute.id,
            text: attribute.text,
            color: resolve(color: attribute.color, traitStyle: traitStyle),
            font: attribute.font,
            lineSpacing: attribute.lineSpacing,
            underlineStyle: attribute.underlineStyle,
            textAlignment: attribute.textAlignment,
            leadingImage: attribute.leadingImage,
            leadingImageBounds: attribute.leadingImageBounds,
            trailingImage: attribute.trailingImage,
            trailingImageBounds: attribute.trailingImageBounds,
            onTap: attribute.onTap
        )
    }

    private func resolve(config: HTMLAttributedStringConfig?, traitStyle: UIUserInterfaceStyle) -> HTMLAttributedStringConfig? {
        guard var config else { return nil }
        config.color = resolve(color: config.color, traitStyle: traitStyle)
        return config
    }

    private func resolve(color: UIColor?, traitStyle: UIUserInterfaceStyle?) -> UIColor? {
        guard
            let color,
            let traitStyle
        else { return color }
        return color.resolvedColor(with: UITraitCollection(userInterfaceStyle: traitStyle))
    }
}

@available(iOS 17, *)
extension PairedLabelSnapshotSUT {
    func swiftUISnapshot(for style: ColorScheme) -> UIImage {
        let traitStyle: UIUserInterfaceStyle = style == .dark ? .dark : .light
        let resolvedTextColor = swiftUITextColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: traitStyle))
        if let currentModel {
            adapter.display(model: swiftUIModel(from: currentModel, traitStyle: traitStyle))
        }

        return SnapshotMirroredLabelContainer(
            adapter: adapter,
            font: swiftUIFont,
            textColor: resolvedTextColor,
            textAlignment: swiftUITextAlignment
        )
        .snapshot(
            for: SUISnapshotConfiguration(
                size: SUISnapshotConfiguration.size,
                safeAreaInsets: EdgeInsets(),
                layoutMargins: EdgeInsets(),
                colorScheme: style
            ),
            background: .clear
        )
    }
}

@available(iOS 17, *)
final class PairedLabelSnapshotState: ObservableObject {
    @Published var font: UIFont = .systemFont(ofSize: 20)
    @Published var textColor: UIColor = .label
    @Published var textAlignment: NSTextAlignment = .natural
    @Published var textInsets: UIEdgeInsets = .zero
    @Published var backgroundColor: UIColor = .clear
    @Published var cornerStyle: CornerStyle?
    @Published var currentModel: TextOutputPresentableModel.TextModel?
    @Published var hasExplicitTextInsets = false
    @Published var hasExplicitBackgroundColor = false
    @Published var hasExplicitCornerStyle = false

    var shouldApplyDirectDecoration: Bool {
        guard !isTextStyledModel else { return false }
        return hasExplicitTextInsets || hasExplicitCornerStyle || hasExplicitBackgroundColor
    }

    private var isTextStyledModel: Bool {
        if case .textStyled = currentModel {
            return true
        }
        return false
    }
}

@available(iOS 17, *)
private struct SnapshotMirroredLabelContainer: View {
    let adapter: TextOutputSwiftUIAdapter
    let font: UIFont
    let textColor: UIColor
    let textAlignment: NSTextAlignment

    var body: some View {
        VStack(spacing: 0) {
            SUILabel(
                adapter: adapter,
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
            .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .topLeading)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SwiftUI.Color.clear)
    }
}
