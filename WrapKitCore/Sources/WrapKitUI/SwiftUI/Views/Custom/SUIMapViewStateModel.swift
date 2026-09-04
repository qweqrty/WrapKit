import Foundation

#if canImport(SwiftUI)
import SwiftUI

public enum SUIMapViewContent {
    case color(Color)
    case gradient([Color])
    case image(Image)
    case pins(backgroundColor: Color, alpha: CGFloat)
}

public struct SUIMapViewButtonState {
    public var backgroundColor: Color
    public var borderColor: Color?
    public var borderWidth: CGFloat
    public var isHidden: Bool

    public init(
        backgroundColor: Color = .white,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        isHidden: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.isHidden = isHidden
    }
}

public final class SUIMapViewStateModel: ObservableObject {
    @Published public var content: SUIMapViewContent = .color(.clear)
    @Published public var locationButton = SUIMapViewButtonState()
    @Published public var plusButton = SUIMapViewButtonState()
    @Published public var minusButton = SUIMapViewButtonState()
    @Published public var actionsBackgroundColor: Color = .clear
    @Published public var separatorColor: Color = .lightGray
    @Published public var isActionsHidden: Bool = false
    @Published public var isSeparatorHidden: Bool = false

    public init() {}
}
#endif
