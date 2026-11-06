#if canImport(SwiftUI)
import SwiftUI
import CoreText

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
struct SUIStrikethroughAttribute {
    let style: UnderlineStyle
    let color: SwiftUIColor
    let baselineOffset: CGFloat
    let thickness: CGFloat

    init(style: UnderlineStyle, font: Font, color: SwiftUIColor) {
        self.style = style
        self.color = color
        self.baselineOffset = font.xHeight / 2
        let ctFont = font as CTFont
        self.thickness = max(1, CTFontGetUnderlineThickness(ctFont))
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
enum SUIStrikethroughTextRenderer {
    static func draw(
        _ attribute: SUIStrikethroughAttribute,
        from minX: CGFloat,
        to maxX: CGFloat,
        baselineY: CGFloat,
        in context: inout GraphicsContext
    ) {
        guard maxX > minX else { return }
        let y = baselineY - attribute.baselineOffset
        let baseStyle = attribute.style.rawValue & 0x0F
        let width = attribute.thickness * (baseStyle == UnderlineStyle.thick.rawValue ? 2 : 1)
        let offsets: [CGFloat] = baseStyle == UnderlineStyle.double.rawValue
            ? [-attribute.thickness, attribute.thickness]
            : [0]
        var path = Path()
        for offset in offsets {
            path.move(to: CGPoint(x: minX, y: y + offset))
            path.addLine(to: CGPoint(x: maxX, y: y + offset))
        }
        context.stroke(path, with: .color(attribute.color), style: StrokeStyle(
            lineWidth: width,
            dash: dash(for: attribute.style, thickness: width)
        ))
    }

    private static func dash(for style: UnderlineStyle, thickness: CGFloat) -> [CGFloat] {
        switch style.rawValue & 0x0F00 {
        case UnderlineStyle.patternDot.rawValue:
            return [thickness, thickness]
        case UnderlineStyle.patternDash.rawValue:
            return [4 * thickness, 2 * thickness]
        case UnderlineStyle.patternDashDot.rawValue:
            return [4 * thickness, 2 * thickness, thickness, 2 * thickness]
        case UnderlineStyle.patternDashDotDot.rawValue:
            return [4 * thickness, 2 * thickness, thickness, 2 * thickness, thickness, 2 * thickness]
        default:
            return []
        }
    }
}
#endif
