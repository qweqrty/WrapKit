import Foundation

public protocol HeaderOutput: HiddableOutput {
    func display(model: HeaderPresentableModel?)
    func display(style: HeaderPresentableModel.Style?)
    func display(centerView: HeaderPresentableModel.CenterView?)
    func display(leadingCard: CardViewPresentableModel?)
    func display(primeTrailingImage: ButtonPresentableModel?)
    func display(secondaryTrailingImage: ButtonPresentableModel?)
    func display(tertiaryTrailingImage: ButtonPresentableModel?)
    func display(isHidden: Bool)
}

public struct HeaderPresentableModel: HashableWithReflection {
    public struct Style {
        public let backgroundColor: Color
        public let horizontalSpacing: CGFloat
        public let primeFont: Font
        public let primeColor: Color
        public let secondaryFont: Font
        public let secondaryColor: Color
        public let numberOfLines: Int
        
        public init(
            backgroundColor: Color,
            horizontalSpacing: CGFloat,
            primeFont: Font,
            primeColor: Color,
            secondaryFont: Font,
            secondaryColor: Color,
            numberOfLines: Int = 1
        ) {
            self.backgroundColor = backgroundColor
            self.horizontalSpacing = horizontalSpacing
            self.primeFont = primeFont
            self.primeColor = primeColor
            self.secondaryFont = secondaryFont
            self.secondaryColor = secondaryColor
            self.numberOfLines = numberOfLines
        }
    }
    
    public enum CenterView {
        case keyValue(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case titledImage(Pair<ImageViewPresentableModel?, TextOutputPresentableModel?>)
    }
    
    public let style: Style?
    public let centerView: CenterView?
    public let leadingCard: CardViewPresentableModel?
    public let primeTrailingImage: ButtonPresentableModel?
    public let secondaryTrailingImage: ButtonPresentableModel?
    public let tertiaryTrailingImage: ButtonPresentableModel?
    
    public init(
        style: Style? = nil,
        centerView: CenterView? = nil,
        leadingCard: CardViewPresentableModel? = nil,
        primeTrailingImage: ButtonPresentableModel? = nil,
        secondaryTrailingImage: ButtonPresentableModel? = nil,
        tertiaryTrailingImage: ButtonPresentableModel? = nil
    ) {
        self.style = style
        self.centerView = centerView
        self.leadingCard = leadingCard
        self.primeTrailingImage = primeTrailingImage
        self.secondaryTrailingImage = secondaryTrailingImage
        self.tertiaryTrailingImage = tertiaryTrailingImage
    }
}

