//
//  Label.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol TextOutput: AnyObject {
    func display(model: TextOutputPresentableModel?)
    func display(text: String?)
    func display(attributes: [TextAttributes])
}

public struct TextOutputPresentableModel {
    public let text: String?
    public let attributes: [TextAttributes]
    
    public init(text: String? = nil, attributes: [TextAttributes] = []) {
        self.text = text
        self.attributes = attributes
    }
}

#if canImport(UIKit)
import UIKit

open class Label: UILabel {
   
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
        isUserInteractionEnabled: Bool = true
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
    }

    public override var intrinsicContentSize: CGSize {
        if text == nil || text!.isEmpty {
            return CGSize(width: super.intrinsicContentSize.width, height: 0)
        } else {
            return super.intrinsicContentSize
        }
    }
    
    public override var text: String? {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private var attributes: [TextAttributes] = [] {
        didSet {
            guard !attributes.isEmpty else {
                attributedText = nil
                return
            }
            
            let combinedAttributedString = NSMutableAttributedString()
            
            for (index, (prev, current, _)) in attributes.withPreviousAndNext.enumerated() {
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
                let prevRange = prev?.range ?? .init(location: 0, length: 0)
                attributes[index].range = NSRange(location: prevRange.location + prevRange.length, length: current.text.count)
            }
            attributedText = combinedAttributedString
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isInsideLabel = super.point(inside: point, with: event)
        
        guard isInsideLabel else { return false }
        
        for attribute in attributes {
            guard let range = attribute.range else { continue }
            if UITapGestureRecognizer().didTapAttributedTextInLabel(label: self, textAlignment: attribute.textAlignment ?? textAlignment, inRange: range), let onTap = attribute.onTap {
                onTap()
                return false
             }
        }
        return isInsideLabel
    }
    
    private func aligmentOffset() -> CGFloat {
        switch textAlignment {
        case .left, .natural, .justified:
            return 0.0
        case .center:
            return 0.5
        case .right:
            return 1.0
        @unknown default:
            return 0.0
        }
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

extension Label: TextOutput {
    public func display(model: TextOutputPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        text = model.text
        attributes = model.attributes
    }
    
    public func display(text: String?) {
        self.text = text
    }
    
    public func display(attributes: [TextAttributes]) {
        self.attributes = attributes
    }
}
#endif
