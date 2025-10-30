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

public protocol TextOutput: AnyObject {
    func display(model: TextOutputPresentableModel?)
    func display(text: String?)
    func display(attributes: [TextAttributes])
    func display(from startAmount: Float, to endAmount: Float, mapToString: ((Float) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?)
    func display(isHidden: Bool)
}

public indirect enum TextOutputPresentableModel: HashableWithReflection {
    case text(String?)
    case attributes([TextAttributes])
    case animated(
        Float,
        Float,
        mapToString: ((Float) -> TextOutputPresentableModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    )
    case textStyled(
        text: TextOutputPresentableModel,
        cornerStyle: CornerStyle?,
        insets: EdgeInsets
    )
}

#if canImport(UIKit)
import UIKit

extension Label: TextOutput {
    public func display(model: TextOutputPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        clearAnimationModel()
        hideShimmer()
        switch model {
        case .text(let text):
            display(text: text)
        case .attributes(let attributes):
            display(attributes: attributes)
        case .animated(let startAmount, let endAmount, let mapToString, let animationStyle, let duration, let completion):
            display(from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        case .textStyled(let model, let style, let insets):
            display(model: model)
            self.cornerStyle = style
            self.textInsets = insets.asUIEdgeInsets
        }
    }
    
    public func display(text: String?) {
        isHidden = text.isEmpty
        clearAnimationModel()
        self.text = text?.removingPercentEncoding ?? text
        
    }
    
    public func display(attributes: [TextAttributes]) {
        isHidden = attributes.isEmpty
        clearAnimationModel()
        self.attributes = attributes.map { attribute in
            var updatedAttribute = attribute
            updatedAttribute.text = attribute.text.removingPercentEncoding ?? attribute.text
            return updatedAttribute
        }
    }
    
    public func display(from startAmount: Float, to endAmount: Float, mapToString: ((Float) -> TextOutputPresentableModel)?) {
        clearAnimationModel()
        display(from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: .none, duration: 1.0, completion: nil)
    }
    
    public func display(from startAmount: Float, to endAmount: Float, mapToString: ((Float) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle = .none, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        animation = .init(label: self)
        clearAnimationModel()
        animation?.startAnimation(fromValue: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
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
            layer.cornerRadius = bounds.height / 2
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
        return CGSize(
            width: animation?.animatedTextMaxWidth ?? base.width + textInsets.left + textInsets.right,
            height: base.height + textInsets.top + textInsets.bottom
        )
    }

    public override var text: String? {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private var animation: CountingLabelAnimation?
    
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
        if animation?.timer == nil {
            animation?.animatedTextMaxWidth = nil
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        animation?.timer?.invalidate()
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

extension TextOutputPresentableModel {
    func width(usingFont font: Font) -> CGFloat {
        var string: String?
        switch self {
        case .attributes(let attributes):
            string = attributes.map { $0.text }.joined()
        case .text(let text):
            string = text
        default:
            return 0
        }
        
        let attributedString = NSAttributedString(
            string: string ?? "",
            attributes: [.font: font]
        )
        
        let size = attributedString.size()
        return ceil(size.width)
    }
}
#endif
