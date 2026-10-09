import Foundation

public enum ColorStyle: HashableWithReflection {
    case solid(Color?)
    case gradient(Gradient)

    public struct Gradient: HashableWithReflection {
        public let colors: [Color]
        public let startPoint: CGPoint
        public let endPoint: CGPoint

        public init(
            colors: [Color],
            startPoint: CGPoint = .init(x: 0, y: 0.5),
            endPoint: CGPoint = .init(x: 1, y: 0.5)
        ) {
            self.colors = colors
            self.startPoint = startPoint
            self.endPoint = endPoint
        }
    }
}
