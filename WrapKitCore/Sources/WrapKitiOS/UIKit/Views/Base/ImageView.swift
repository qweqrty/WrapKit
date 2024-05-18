//
//  ImageView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ImageView: UIImageView {
    public var onPress: (() -> Void)? {
        didSet {
            isUserInteractionEnabled = onPress != nil
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            if let image = self.image {
                self.image = image.withRenderingMode(.alwaysTemplate)
                super.tintColor = tintColor
            }
        }
    }
    
    public init(
        image: UIImage? = nil,
        contentMode: UIImageView.ContentMode = .scaleAspectFit,
        cornerRadius: CGFloat = 0,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0,
        tintColor: UIColor? = nil,
        isHidden: Bool = false
    ) {
        super.init(image: nil)
        
        if let image = image {
            self.image = image
        }
        self.isHidden = isHidden
        self.contentMode = contentMode
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        self.cornerRadius = cornerRadius
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func onTap() {
      self.alpha = 1.0
      UIView.animate(withDuration: 0.4, delay: 0.0, options: .allowUserInteraction, animations: {
        self.alpha = 0.5
      }, completion: { finished in
        self.alpha = 1.0
      })
    onPress?()
  }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }
}
#endif
