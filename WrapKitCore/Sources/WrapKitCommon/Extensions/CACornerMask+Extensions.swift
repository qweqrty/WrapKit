import QuartzCore

public extension CACornerMask {
    static let allCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    static let topCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    static let bottomCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
}
