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
        public init(
            text: String,
            color: UIColor,
            font: UIFont,
            underlineStyle: NSUnderlineStyle? = nil,
            textAlignment: NSTextAlignment? = nil,
            leadingImage: UIImage? = nil,
            leadingImageBounds: CGRect = .zero,
            trailingImage: UIImage? = nil,
            trailingImageBounds: CGRect = .zero,
            onTap: (() -> Void)? = nil
        ) {
            self.text = text
            self.color = color
            self.font = font
            self.onTap = onTap
            self.range = nil
            self.underlineStyle = underlineStyle
            self.textAlignment = textAlignment
            self.leadingImage = leadingImage
            self.leadingImageBounds = leadingImageBounds
            self.trailingImage = trailingImage
            self.trailingImageBounds = trailingImageBounds
        }
        
        public let text: String
        public let color: UIColor
        public let underlineStyle: NSUnderlineStyle?
        public let font: UIFont
        public let textAlignment: NSTextAlignment?
        public let leadingImage: UIImage?
        public let leadingImageBounds: CGRect
        public let trailingImage: UIImage?
        public let trailingImageBounds: CGRect
        public let onTap: (() -> Void)?
        var range: NSRange?
    }
    
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
                combinedAttributedString.append(
                    NSAttributedString(
                        current.text,
                        font: current.font,
                        color: current.color,
                        lineSpacing: 4,
                        textAlignment: current.textAlignment ?? textAlignment,
                        leadingImage: current.leadingImage,
                        leadingImageBounds: current.leadingImageBounds,
                        trailingImage: current.trailingImage,
                        trailingImageBounds: current.trailingImageBounds
                    )
                )
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
        attributedTexts.forEach { link in
            self.links.append(link)
        }
        return self
    }
    
    func removeLinks() {
        self.links.removeAll()
        self.attributedText = nil
    }
}
#endif
