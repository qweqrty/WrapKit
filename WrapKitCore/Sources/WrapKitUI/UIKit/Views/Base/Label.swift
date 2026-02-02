//
//  Label.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public enum CornerStyle {
    case automatic        // height / 2
    case fixed(CGFloat)
    case none
}

public enum LabelAnimationStyle {
    case none
    case circle(lineColor: Color)
}

public protocol TextOutput: HiddableOutput {
    func display(model: TextOutputPresentableModel?)
    func display(text: String?)
    func display(attributes: [TextAttributes])
    func display(htmlString: String?, font: Font, color: Color)
    func display(
        id: String?,
        from startAmount: Decimal,
        to endAmount: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    )
    func display(isHidden: Bool)
}

public struct TextOutputPresentableModel: HashableWithReflection {
    public indirect enum TextModel: HashableWithReflection {
        case text(String?)
        case attributes([TextAttributes])
        case attributedString(String?, Font, Color)
        case animatedDecimal(
            id: String? = nil,
            from: Decimal,
            to: Decimal,
            mapToString: ((Decimal) -> TextModel)?,
            animationStyle: LabelAnimationStyle,
            duration: TimeInterval,
            completion: (() -> Void)?
        )
        @available(*, deprecated, message: "Animated double is going to be deprecated. Use animatedDecimal instead")
        case animated(
            id: String? = nil,
            Double,
            Double,
            mapToString: ((Double) -> TextModel)?,
            animationStyle: LabelAnimationStyle,
            duration: TimeInterval,
            completion: (() -> Void)?
        )
        case textStyled(
            text: TextModel,
            cornerStyle: CornerStyle? = nil,
            insets: EdgeInsets = .zero,
            height: CGFloat? = nil,
            backgroundColor: Color? = nil
        )
        
        public var text: String? {
            switch self {
            case .text(let text):
                return text
            case .attributes(let attributes):
                return attributes.compactMap((\.text)).joined()
            case .attributedString(let text, _, _):
                return text
            case .animatedDecimal(_, _, let to, let mapToString, _, _, _):
                return to.asString()
            case .animated(_, _, let to, let mapToString, _, _, _):
                return to.asString()
            case .textStyled(let model, _, _, _, _):
                return model.text
            }
        }
    }
    public let accessibilityIdentifier: String?
    public let model: TextModel?
    
    public init(accessibilityIdentifier: String? = nil, model: TextModel?) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.model = model
    }
    
    // MARK: - Helpers
    public static func text(accessibilityIdentifier: String? = nil, _ string: String?) -> Self {
        return .init(accessibilityIdentifier: accessibilityIdentifier, model: .text(string))
    }
    
    public static func attributes(accessibilityIdentifier: String? = nil, _ attributes: [TextAttributes]) -> Self {
        return .init(accessibilityIdentifier: accessibilityIdentifier, model: .attributes(attributes))
    }
    
    public static func attributedString(accessibilityIdentifier: String? = nil, _ string: String?, _ font: Font, _ color: Color) -> Self {
        return .init(accessibilityIdentifier: accessibilityIdentifier, model: .attributedString(string, font, color))
    }
    
    public static func animatedDecimal(
        accessibilityIdentifier: String? = nil,
        id: String? = nil,
        from: Decimal,
        to: Decimal,
        mapToString: ((Decimal) -> TextModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    ) -> Self {
        return .init(accessibilityIdentifier: accessibilityIdentifier, model: .animatedDecimal(id: id, from: from, to: to, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
    }
    
    @available(*, deprecated, message: "Animated double is going to be deprecated. Use animatedDecimal instead")
    public static func animated(
        accessibilityIdentifier: String? = nil,
        id: String? = nil,
        _ from: Double,
        _ to: Double,
        mapToString: ((Double) -> TextModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    ) -> Self {
        return .init(accessibilityIdentifier: accessibilityIdentifier, model: .animated(id: id, from, to, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
    }
    
    public static func textStyled(
        accessibilityIdentifier: String? = nil,
        text: TextModel,
        cornerStyle: CornerStyle? = nil,
        insets: EdgeInsets = .zero,
        height: CGFloat? = nil,
        backgroundColor: Color? = nil
    ) -> Self {
        return .init(accessibilityIdentifier: accessibilityIdentifier, model: .textStyled(text: text, cornerStyle: cornerStyle, insets: insets, height: height, backgroundColor: backgroundColor))
    }
}

#if canImport(UIKit)
import UIKit

// MARK: - Adapter
extension Label: TextOutput {
    public func display(model: TextOutputPresentableModel?) {
        isHidden = model == nil
        if let accessibilityIdentifier = model?.accessibilityIdentifier {
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        guard let model = model?.model else { return }
        hideShimmer()

        switch model {
        case .text(let text):
            display(text: text)
        case .attributes(let attributes):
            display(attributes: attributes)
        case .animatedDecimal(let id, let startAmount, let endAmount, let mapToString, let animationStyle, let duration, let completion):
            display(id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        case .animated(let id, let startAmount, let endAmount, let mapToString, let animationStyle, let duration, let completion):
            let mapper: ((Decimal) -> TextOutputPresentableModel.TextModel)? = if let mapToString { { mapToString($0.doubleValue) } } else { nil }
            display(id: id, from: startAmount.asDecimal(), to: endAmount.asDecimal(), mapToString: mapper, animationStyle: animationStyle, duration: duration, completion: completion)
        case .textStyled(
            let text,
            let cornerStyle,
            let insets,
            _, // MARK: TODO ?
            let backgroundColor
        ):
            display(textModel: text)
            self.cornerStyle = cornerStyle
            self.textInsets = insets.asUIEdgeInsets
        case .attributedString(let htmlString, let font, let color):
            display(htmlString: htmlString, font: font, color: color)
            if let backgroundColor {
                self.backgroundColor = backgroundColor
            }
        }

        applyInteractivityAndAccessibility()
    }
    
    public func display(textModel: TextOutputPresentableModel.TextModel?) {
        display(model: .init(accessibilityIdentifier: accessibilityIdentifier, model: textModel))
    }

    public func display(text: String?) {
        isHidden = text.isEmpty
        self.text = text?.removingPercentEncoding ?? text ?? ""
        // If plain text, clear rich storage
        if textStorage.length > 0 {
            textStorage = NSTextStorage()
            textStorage.addLayoutManager(layoutManager)
        }
    }

    public func display(htmlString: String?, font: Font, color: Color) {
        isHidden = htmlString.isEmpty

        clearAnimationModel()

        let attr = htmlString?.asHtmlAttributedString
        self.attributedText = attr
        self.font = font
        self.textColor = color

        syncTextStorageFromCurrentRenderedText()
    }

    public func display(attributes: [TextAttributes]) {
        isHidden = attributes.isEmpty

        self.attributes = attributes.map { attribute in
            var updated = attribute
            updated.text = attribute.text.removingPercentEncoding ?? attribute.text
            return updated
        }

        syncTextStorageFromCurrentRenderedText()
    }

    public func display(
        id: String? = nil,
        from startAmount: Double,
        to endAmount: Double,
        mapToString: ((Double) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        let mapper: ((Decimal) -> TextOutputPresentableModel.TextModel)? = if let mapToString { { mapToString($0.doubleValue) } } else { nil }
        display(id: id, from: startAmount.asDecimal(), to: endAmount.asDecimal(), mapToString: mapper, animationStyle: animationStyle, duration: duration, completion: completion)
    }

    public func display(
        id: String? = nil,
        from startAmount: Decimal,
        to endAmount: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        if let id, id == currentAnimatedModelID, endAmount == currentAnimatedTarget {
            return
        }

        animation?.cancel()
        animation = CountingLabelAnimation(label: self)
        currentAnimatedTarget = endAmount

        animation?.startAnimation(
            fromValue: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: { [weak self] in
                completion?()
            }
        )

        applyInteractivityAndAccessibility()
    }

    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

// MARK: - Label
open class Label: UILabel {

    public var textInsets: UIEdgeInsets = .zero
    public var cornerStyle: CornerStyle?

    // TextKit
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: .zero)
    var textStorage = NSTextStorage()

    private var attributes: [TextAttributes] = [] {
        didSet {
            guard !attributes.isEmpty else {
                attributedText = nil
                syncTextStorageFromCurrentRenderedText()
                return
            }

            let combined = attributes.makeNSAttributedString(font: font, textColor: textColor, textAlignment: textAlignment)
            attributedText = combined

            textStorage = NSTextStorage(attributedString: combined)
            textStorage.addLayoutManager(layoutManager)
        }
    }

    private var animation: CountingLabelAnimation?
    private var currentAnimatedTarget: Decimal?
    private var currentAnimatedModelID: String?

    private enum A11yTapTarget: Equatable {
        case attribute(index: Int)
        case link(url: URL, title: String?)
    }
    private var a11yTargets: [A11yTapTarget] = []

    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        gesture.delegate = self
        return gesture
    }()

    public init(
        backgroundColor: UIColor? = .clear,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = false,
        font: UIFont? = nil,
        textColor: UIColor = .darkText,
        textAlignment: NSTextAlignment = .natural,
        numberOfLines: Int = 0,
        minimumScaleFactor: CGFloat = 0,
        adjustsFontSizeToFitWidth: Bool = false,
        isUserInteractionEnabled: Bool = true,
        cornerStyle: CornerStyle? = nil,
        textInsets: UIEdgeInsets = .zero
    ) {
        super.init(frame: .zero)

        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        if let font { self.font = font }
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.minimumScaleFactor = minimumScaleFactor
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        self.cornerStyle = cornerStyle
        self.textInsets = textInsets

        // Default can be interactive depending on content. We'll toggle in applyInteractivityAndAccessibility().
        self.isUserInteractionEnabled = isUserInteractionEnabled

        // TextKit init
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        layoutManager.addTextContainer(textContainer)

        syncTextStorageFromCurrentRenderedText()
        applyInteractivityAndAccessibility()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        font = .systemFont(ofSize: 20)
        numberOfLines = 0
        minimumScaleFactor = 0
        adjustsFontSizeToFitWidth = false

        // TextKit init
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        layoutManager.addTextContainer(textContainer)

        syncTextStorageFromCurrentRenderedText()
        applyInteractivityAndAccessibility()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        layoutManager.addTextContainer(textContainer)

        syncTextStorageFromCurrentRenderedText()
        applyInteractivityAndAccessibility()
    }

    deinit {
        animation?.invalidate()
        animation = nil
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if let cornerStyle {
            switch cornerStyle {
            case .automatic:
                layer.cornerRadius = min(bounds.height, bounds.width) / 2
            case .fixed(let radius):
                layer.cornerRadius = radius
            case .none:
                layer.cornerRadius = 0
            }
            clipsToBounds = true
        }

        textContainer.size = bounds.size
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    open override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        guard let t = text, !t.isEmpty || (attributedText?.length ?? 0) > 0 else {
            return CGSize(width: base.width, height: 0)
        }
        let width = max(animation?.animatedTextMaxWidth ?? 0, base.width)
        return CGSize(
            width: width + textInsets.left + textInsets.right,
            height: base.height + textInsets.top + textInsets.bottom
        )
    }

    public override var text: String? {
        didSet {
            invalidateIntrinsicContentSize()
            syncTextStorageFromCurrentRenderedText()
            applyInteractivityAndAccessibility()
        }
    }

    public override var attributedText: NSAttributedString? {
        didSet {
            invalidateIntrinsicContentSize()
            syncTextStorageFromCurrentRenderedText()
            applyInteractivityAndAccessibility()
        }
    }

    // MARK: - Public helpers
    @discardableResult
    public func append(_ attributedTexts: TextAttributes...) -> Self {
        attributedTexts.forEach { self.attributes.append($0) }
        applyInteractivityAndAccessibility()
        return self
    }

    public func removeAttributes() {
        attributes.removeAll()
        attributedText = nil
        syncTextStorageFromCurrentRenderedText()
        applyInteractivityAndAccessibility()
    }

    // MARK: - Internals
    private func clearAnimationModel() {
        animation?.resetAnimatedTextMaxWidth()
    }

    private func syncTextStorageFromCurrentRenderedText() {
        if let attributedText, attributedText.length > 0 {
            textStorage = NSTextStorage(attributedString: attributedText)
        } else {
            textStorage = NSTextStorage(string: text ?? "")
        }
        textStorage.addLayoutManager(layoutManager)
    }

    private func isTappableByTextAttributes() -> Bool {
        attributes.contains(where: { $0.onTap != nil && $0.range != nil })
    }

    private func linkTargetsFromTextStorage() -> [A11yTapTarget] {
        guard textStorage.length > 0 else { return [] }

        var result: [A11yTapTarget] = []
        let full = NSRange(location: 0, length: textStorage.length)

        textStorage.enumerateAttribute(.link, in: full) { value, range, _ in
            guard let value else { return }
            let url: URL? =
                (value as? URL) ??
                (value as? String).flatMap(URL.init(string:))

            guard let url else { return }

            let title = textStorage.attributedSubstring(from: range).string
                .trimmingCharacters(in: .whitespacesAndNewlines)

            result.append(.link(url: url, title: title.isEmpty ? nil : title))
        }

        // unique by url+title+range not доступно, но хотя бы уберём дубли по url+title
        var seen = Set<String>()
        return result.filter { t in
            let key: String = switch t {
            case .link(let url, let title): "\(url.absoluteString)|\(title ?? "")"
            default: UUID().uuidString
            }
            return seen.insert(key).inserted
        }
    }

    private func applyInteractivityAndAccessibility() {
        let hasAttrTaps = isTappableByTextAttributes()
        let linkTargets = linkTargetsFromTextStorage()
        let hasLinks = !linkTargets.isEmpty
        let tappable = hasAttrTaps || hasLinks

        isUserInteractionEnabled = tappable
        if tappable {
            if gestureRecognizers?.contains(tapGesture) != true {
                addGestureRecognizer(tapGesture)
            }
        } else {
            if gestureRecognizers?.contains(tapGesture) == true {
                removeGestureRecognizer(tapGesture)
            }
        }
        
        guard UIAccessibility.isVoiceOverRunning || ProcessInfo.isUITest else { return }
        isAccessibilityElement = true
        accessibilityLabel = nil
        accessibilityHint = nil

        if tappable {
            accessibilityTraits = [.button]

            a11yTargets = []

            for (idx, attr) in attributes.enumerated() {
                if attr.onTap != nil, attr.range != nil {
                    a11yTargets.append(.attribute(index: idx))
                }
            }
            a11yTargets.append(contentsOf: linkTargets)

            if a11yTargets.count > 1 {
                accessibilityCustomActions = a11yTargets.enumerated().map { i, target in
                    let name: String = {
                        switch target {
                        case .attribute(let idx):
                            // best-effort title from attribute text
                            let t = attributes[idx].text.trimmingCharacters(in: .whitespacesAndNewlines)
                            return t.isEmpty ? "Action \(i + 1)" : "Open: \(t)"
                        case .link(_, let title):
                            if let title, !title.isEmpty { return "Open link: \(title)" }
                            return "Open link \(i + 1)"
                        }
                    }()
                    return UIAccessibilityCustomAction(name: name, target: self, selector: #selector(handleA11yCustomAction(_:)))
                }
            } else {
                accessibilityCustomActions = nil
            }
        } else {
            accessibilityTraits = [.staticText]
            a11yTargets = []
            accessibilityCustomActions = nil
        }
    }

    @objc private func handleA11yCustomAction(_ action: UIAccessibilityCustomAction) -> Bool {
        guard let idx = accessibilityCustomActions?.firstIndex(of: action),
              idx >= 0, idx < a11yTargets.count
        else { return false }

        return performA11yTarget(a11yTargets[idx])
    }

    private func performA11yTarget(_ target: A11yTapTarget) -> Bool {
        switch target {
        case .attribute(let idx):
            guard idx < attributes.count else { return false }
            attributes[idx].onTap?()
            return true

        case .link(let url, _):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
    }

    open override func accessibilityActivate() -> Bool {
        if a11yTargets.count == 1, let only = a11yTargets.first {
            return performA11yTarget(only)
        }
        return super.accessibilityActivate()
    }

    private func performTapAtPoint(_ point: CGPoint) -> Bool {
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.size = self.bounds.size

        let adjustedPoint = CGPoint(x: point.x - textInsets.left, y: point.y - textInsets.top)

        let glyphIndex = layoutManager.glyphIndex(for: adjustedPoint, in: textContainer)

        let glyphRect = layoutManager.boundingRect(
            forGlyphRange: NSRange(location: glyphIndex, length: 1),
            in: textContainer
        )
        guard glyphRect.contains(adjustedPoint) else { return false }

        let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        guard charIndex >= 0, charIndex < textStorage.length else { return false }

        var best: (range: NSRange, onTap: (() -> Void))?
        for attr in attributes {
            guard let r = attr.range, let onTap = attr.onTap else { continue }
            guard NSLocationInRange(charIndex, r) else { continue }
            if let cur = best {
                if r.length < cur.range.length { best = (r, onTap) }
            } else {
                best = (r, onTap)
            }
        }
        if let best {
            best.onTap()
            return true
        }

        if let linkValue = textStorage.attribute(.link, at: charIndex, effectiveRange: nil) {
            let url: URL? =
                (linkValue as? URL) ??
                (linkValue as? String).flatMap(URL.init(string:))

            if let url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return true
            }
        }

        return false
    }
}

// MARK: - UIGestureRecognizerDelegate
extension Label: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == tapGesture else { return true }
        let point = gestureRecognizer.location(in: self)
        return performTapAtPoint(point)
    }
}

extension TextOutputPresentableModel.TextModel {
    func width(usingFont font: Font) -> CGFloat {
        let attributedString: NSAttributedString = switch self {
        case .attributes(var attributes):
            attributes.makeNSAttributedString(font: font)
        case .text(let text):
            NSAttributedString(string: text ?? "", attributes: [.font: font])
        default:
            NSAttributedString()
        }
        let size = attributedString.size()
        return ceil(size.width)
    }
}
#endif
