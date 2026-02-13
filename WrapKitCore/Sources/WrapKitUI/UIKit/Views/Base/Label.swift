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
    func display(textModel: TextOutputPresentableModel.TextModel?)
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

extension Label: TextOutput {
    public func display(model: TextOutputPresentableModel?) {
        isHidden = model == nil
        if let accessibilityIdentifier = model?.accessibilityIdentifier {
            self.accessibilityIdentifier = model?.accessibilityIdentifier
        }
        guard let model = model?.model else { return }
        display(textModel: model)
        let tappable = attributes.contains(where: { $0.onTap != nil && $0.range != nil })
        isAccessibilityElement = true
        accessibilityTraits = tappable ? [.button] : [.staticText]
    }
    
    public func display(textModel: TextOutputPresentableModel.TextModel?) {
        isHidden = textModel == nil
        guard let model = textModel else {  return }
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
    }
    
    public func display(text: String?) {
        isHidden = text.isEmpty
        self.text = text?.removingPercentEncoding ?? text ?? ""
    }
    
    public func display(htmlString: String?, font: Font, color: Color) {
        isHidden = htmlString != nil
        clearAnimationModel()
        self.attributedText = htmlString?.asHtmlAttributedString
        self.font = font
        self.textColor = color
    }
    
    public func display(attributes: [TextAttributes]) {
        isHidden = attributes.isEmpty
        self.attributes = attributes.map { attribute in
            var updatedAttribute = attribute
            updatedAttribute.text = attribute.text.removingPercentEncoding ?? attribute.text
            return updatedAttribute
        }
    }
    
    public func display(id: String? = nil, from startAmount: Double, to endAmount: Double, mapToString: ((Double) -> TextOutputPresentableModel.TextModel)?, animationStyle: LabelAnimationStyle = .none, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        let mapper: ((Decimal) -> TextOutputPresentableModel.TextModel)? = if let mapToString { { mapToString($0.doubleValue) } } else { nil }
        display(id: id, from: startAmount.asDecimal(), to: endAmount.asDecimal(), mapToString: mapper, animationStyle: .none, duration: 1.0, completion: nil)
    }
    
    public func display(id: String? = nil, from startAmount: Decimal, to endAmount: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?, animationStyle: LabelAnimationStyle = .none, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        if let id, id == currentAnimatedModelID, endAmount == currentAnimatedTarget {
            return
        }
        
        animation?.cancel()
        animation = CountingLabelAnimation(label: self)
        currentAnimatedTarget = endAmount
        
        animation?.startAnimation(fromValue: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: { [weak self] in
            completion?()
        })
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

open class Label: UILabel {
    public var textInsets: UIEdgeInsets = .zero
    public var cornerStyle: CornerStyle?
    
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    var textStorage = NSTextStorage()

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
        if let font = font { self.font = font }
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.textAlignment = textAlignment
        self.minimumScaleFactor = minimumScaleFactor
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        self.cornerStyle = cornerStyle
        self.textInsets = textInsets
        
        addGestureRecognizer(tapGesture)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        layoutManager.addTextContainer(textContainer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.isHidden = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = .systemFont(ofSize: 20)
        self.numberOfLines = 0
        self.minimumScaleFactor = 0
        self.adjustsFontSizeToFitWidth = false
        self.isUserInteractionEnabled = true
        
        addGestureRecognizer(tapGesture)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        layoutManager.addTextContainer(textContainer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let cornerStyle = cornerStyle else { return }
        switch cornerStyle {
        case .automatic:
            layer.cornerRadius = min(bounds.height, bounds.width) / 2
        case .fixed(let radius):
            layer.cornerRadius = radius
        case .none:
            layer.cornerRadius = 0
        }
        clipsToBounds = true
        
        textContainer.size = bounds.size
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    open override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        guard let text = text, !text.isEmpty else {
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
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private var animation: CountingLabelAnimation?
    private var currentAnimatedTarget: Decimal?
    private var currentAnimatedModelID: String?
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        gesture.delegate = self
        return gesture
    }()
    
    private var attributes: [TextAttributes] = [] {
        didSet {
            guard !attributes.isEmpty else {
                attributedText = nil
                return
            }
            let combinedAttributedString = attributes.makeNSAttributedString(font: font, textColor: textColor, textAlignment: textAlignment)
            attributedText = combinedAttributedString
            self.textStorage = NSTextStorage(attributedString: combinedAttributedString)
            self.textStorage.addLayoutManager(layoutManager)
        }
    }
    
    private func clearAnimationModel() {
        animation?.resetAnimatedTextMaxWidth()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        animation?.invalidate()
        animation = nil
    }
}

public extension Label {
    @discardableResult
    func append(_ attributedTexts: TextAttributes...) -> Self {
        attributedTexts.forEach { attribute in
            self.attributes.append(attribute)
        }
        return self
    }
    
    func removeAttributes() {
        self.attributes.removeAll()
        self.attributedText = nil
    }
}

extension Label: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == tapGesture else { return true }
        
        // Configure the text container
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.size = self.bounds.size
        
        let point = gestureRecognizer.location(in: self)
        
        for attribute in attributes {
            guard let range = attribute.range else { continue }
            if NSLayoutManager.didTapAttributedTextInLabel(
                point: point,
                layoutManager: layoutManager,
                textStorage: textStorage,
                textContainer: textContainer,
                textAlignment: attribute.textAlignment ?? textAlignment,
                inRange: range
            ), let onTap = attribute.onTap {
                onTap()
                return true
            }
        }
        return false
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
