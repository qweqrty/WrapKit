//
//  Label.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol TextOutput: AnyObject {
    func display(text: String?)
    func display(attributes: [TextAttributes])
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
        addGestureRecognizer(tapGestureRecognizer)
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
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        gesture.name = String(describing: TextAttributes.self)
        return gesture
    }()
    
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
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Convert touch point to attributed text coordinates
        guard let attributedText = attributedText, let labelText = text else { return super.hitTest(point, with: event) }
        let textRange = NSRange(location: 0, length: labelText.utf16.count)
        
        // Check if the touch is on any attribute with `onTap`
        for attribute in attributes {
            guard let range = attribute.range else { continue }
            
            if tapGestureRecognizer.didTapAttributedTextInLabel(label: self, inRange: range), attribute.onTap != nil {
                return self  // Forward touch to self to handle `onTap`
            }
        }
        
        // If no tappable attribute, pass the touch to the next responder
        return nil
    }
    
    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        for attribute in attributes {
            guard let range = attribute.range else { continue }
            if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                attribute.onTap?()
                return
            }
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
    public func display(text: String?) {
        self.text = text
    }
    
    public func display(attributes: [TextAttributes]) {
        self.attributes = attributes
    }
}
#endif
