#if canImport(UIKit)
import UIKit

public final class AspectFitImageView: ImageView {
    private var ratioConstraint: NSLayoutConstraint?
    
    public override var image: UIImage? {
        didSet {
            updateAspectRatioConstraint()
        }
    }
    
    private func updateAspectRatioConstraint() {
        // Remove the old constraint to prevent conflicts
        if let oldConstraint = ratioConstraint {
            removeConstraint(oldConstraint)
            ratioConstraint = nil
        }
        
        // Ensure an image exists and has valid dimensions
        guard let imageSize = image?.size, imageSize.width > 0, imageSize.height > 0 else { return }
        
        // Calculate the ratio (Width / Height)
        let aspectRatio = imageSize.width / imageSize.height
        
        // Create and activate the new constraint
        ratioConstraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: aspectRatio)
        ratioConstraint?.isActive = true
    }
}

#endif
