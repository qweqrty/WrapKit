import Foundation

public struct AlertAction {
    public enum Style {
        case `default`
        case cancel
        case destructive
    }

    public let title: String
    public let style: Style
    public let handler: (() -> Void)?
    
    public init(title: String, style: Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
