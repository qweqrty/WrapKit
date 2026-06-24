import UIKit

public final class AspectFitImageView: ImageView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let image = image, image.size.height > 0 else {
            return super.intrinsicContentSize
        }
        let ratio = image.size.width / image.size.height
        if frame.height > 0 {
            return CGSize(width: (frame.height * ratio).rounded(), height: frame.height)
        } else if frame.width > 0 {
            return CGSize(width: frame.width, height: (frame.width / ratio).rounded())
        } else {
            return super.intrinsicContentSize
        }
    }
}
