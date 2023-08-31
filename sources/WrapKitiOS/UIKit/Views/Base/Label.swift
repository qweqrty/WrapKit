//
//  Label.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class Label: UILabel {
    public struct Link {
        public init(text: String, color: UIColor, font: UIFont, underlineStyle: NSUnderlineStyle? = nil, onTap: (() -> Void)? = nil) {
            self.text = text
            self.color = color
            self.font = font
            self.onTap = onTap
            self.range = nil
            self.underlineStyle = underlineStyle
        }
        
        let text: String
        let color: UIColor
        let underlineStyle: NSUnderlineStyle?
        let font: UIFont
        let onTap: (() -> Void)?
        var range: NSRange?
    }
    
    public init(
        backgroundColor: UIColor? = .clear,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = false,
        font: UIFont = .systemFont(ofSize: 20),
        textColor: UIColor = .darkText,
        textAlignment: NSTextAlignment = .left,
        numberOfLines: Int = 0,
        minimumScaleFactor: CGFloat = 0,
        adjustsFontSizeToFitWidth: Bool = false,
        isUserInteractionEnabled: Bool = true
    ) {
        super.init(frame: .zero)

        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        self.font = font
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
    
    private var links: [Link] = [] {
        didSet {
            guard !links.isEmpty else {
                attributedText = nil
                if let attributedTextTapGesture = gestureRecognizers?.first(where: { $0.name == String(describing: Link.self) }) {
                    removeGestureRecognizer(attributedTextTapGesture)
                }
                return
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
            tapGestureRecognizer.name = String(describing: Link.self)
            addGestureRecognizer(tapGestureRecognizer)
            
            let combinedAttributedString = NSMutableAttributedString()
            
            for (index, (prev, current, _)) in links.withPreviousAndNext.enumerated() {
                combinedAttributedString.append(NSAttributedString(current.text, font: current.font, color: current.color, lineSpacing: 4, textAlignment: textAlignment))
                let prevRange = prev?.range ?? .init(location: 0, length: 0)
                links[index].range = NSRange(location: prevRange.location + prevRange.length, length: current.text.count)
            }
            attributedText = combinedAttributedString
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        for link in links {
            guard let range = link.range else { continue }
            if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                link.onTap?()
                return
            }
        }
    }
}

public extension Label {
    @discardableResult
    func append(_ attributedTexts: Link...) -> Self {
        self.links = (links + attributedTexts).withPreviousAndNext.map { (prev, current, _) -> Link in
            var currentWithRange = current
            let prevRange: NSRange = prev?.range ?? .init(location: 0, length: 0)
            currentWithRange.range = .init(location: prevRange.length + prevRange.location, length: current.text.count)
            return currentWithRange
        }
        return self
    }
    
    func removeLinks() {
        self.links.removeAll()
        self.attributedText = nil
    }
}
#endif
