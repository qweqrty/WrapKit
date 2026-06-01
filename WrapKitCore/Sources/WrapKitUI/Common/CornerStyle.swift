import Foundation

public enum CornerStyle {
    /// in SwiftUI is Capsule
    case automatic
    case fixed(CGFloat)
    case corners(Corners)
    case none
    
    public struct Corners {
        let topLeft, topRight, bottomLeft, bottomRight: CGFloat
        
        public init(
            topLeft: CGFloat = .zero,
            topRight: CGFloat = .zero,
            bottomLeft: CGFloat = .zero,
            bottomRight: CGFloat = .zero
        ) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }
        
        public init(all: CGFloat) {
            self.init(topLeft: all, topRight: all, bottomLeft: all, bottomRight: all)
        }
        
        public init(top: CGFloat = .zero, bottom: CGFloat = .zero) {
            self.init(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom)
        }
        
        public init(left: CGFloat = .zero, right: CGFloat = .zero) {
            self.init(topLeft: left, topRight: right, bottomLeft: left, bottomRight: right)
        }
        
        public var maximum: CGFloat {
            [topLeft, topRight, bottomLeft, bottomRight].max() ?? .zero
        }
    }
}

#if canImport(QuartzCore)
import QuartzCore
extension CornerStyle.Corners {
    public var maskedCorners: CACornerMask {
        var result: CACornerMask = []
        if topLeft > .zero { result.insert(.layerMinXMinYCorner) }
        if topRight > .zero { result.insert(.layerMaxXMinYCorner) }
        if bottomLeft > .zero { result.insert(.layerMinXMaxYCorner) }
        if bottomRight > .zero { result.insert(.layerMaxXMaxYCorner) }
        return result
    }
}
#endif
