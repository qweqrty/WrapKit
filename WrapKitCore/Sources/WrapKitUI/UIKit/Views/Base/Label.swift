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

public protocol TextOutput: AnyObject {
    func display(model: TextOutputPresentableModel?)
    func display(text: String?)
    func display(attributes: [TextAttributes])
    func display(from startAmount: Float, to endAmount: Float, mapToString: ((Float) -> TextOutputPresentableModel)?)
    func display(isHidden: Bool)
}

public indirect enum TextOutputPresentableModel: HashableWithReflection {
    case text(String?)
    case attributes([TextAttributes])
    case counting(Float, Float, mapToString: ((Float) -> TextOutputPresentableModel)?)
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
        hideShimmer()
        switch model {
        case .text(let text):
            display(text: text)
        case .attributes(let attributes):
            display(attributes: attributes)
        case .counting(let startAmount, let endAmount, let mapToString):
            display(from: startAmount, to: endAmount, mapToString: mapToString)
        case .textStyled(let model, let style, let insets):
            display(model: model)
            self.cornerStyle = style
            self.textInsets = insets.asUIEdgeInsets
        }
    }
    
    public func display(text: String?) {
        isHidden = text.isEmpty
        self.text = text?.removingPercentEncoding ?? text
    }
    
    public func display(attributes: [TextAttributes]) {
        isHidden = attributes.isEmpty
        self.attributes = attributes.map { attribute in
            var updatedAttribute = attribute
            updatedAttribute.text = attribute.text.removingPercentEncoding ?? attribute.text
            return updatedAttribute
        }
    }
    
    public func display(from startAmount: Float, to endAmount: Float, mapToString: ((Float) -> TextOutputPresentableModel)?) {
        animation.startAnimation(fromValue: startAmount, to: endAmount, mapToString: mapToString)
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

open class Label: UILabel {
    public var textInsets: UIEdgeInsets = .zero
    public var cornerStyle: CornerStyle?

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
            width: (animation.mapToString == nil ? base.width : animation.getCurrentCounterValue().width(usingFont: font)) + textInsets.left + textInsets.right,
            height: base.height + textInsets.top + textInsets.bottom
        )
    }
    
    public override var text: String? {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    lazy var animation: CountingLabelAnimation = .init(label: self)
    
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
            
            let combinedAttributedString = NSMutableAttributedString()
            for (index, current) in attributes.enumerated() {
                combinedAttributedString.append(
                    NSAttributedString(
                        current.text,
                        font: current.font ?? font,
                        color: current.color ?? textColor,
                        lineSpacing: 4,
                        underlineStyle: current.underlineStyle ?? [],
                        textAlignment: current.textAlignment ?? textAlignment,
                        leadingImage: current.leadingImage,
                        leadingImageBounds: current.leadingImageBounds,
                        trailingImage: current.trailingImage,
                        trailingImageBounds: current.trailingImageBounds
                    )
                )
                let currentLocation = combinedAttributedString.length - current.text.count
                attributes[index].range = NSRange(location: currentLocation, length: current.text.count)
            }
            attributedText = combinedAttributedString
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        for attribute in attributes {
            guard let range = attribute.range else { continue }
            if tapGesture.didTapAttributedTextInLabel(label: self, textAlignment: attribute.textAlignment ?? textAlignment, inRange: range), let onTap = attribute.onTap {
                onTap()
                return true
            }
        }
        return false
    }
}

private extension String {
    func width(usingFont font: Font) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = self.size(withAttributes: attributes)
        return ceil(size.width) + 4
    }
}

private extension TextOutputPresentableModel {
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
        return ceil(size.width) + 4
    }
}
#endif
