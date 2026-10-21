#if canImport(SwiftUI)
import SwiftUI
import CoreText

/// Text.LineStyle has no thickness or by-word options. Carry those options to
/// the renderer without changing the text's native SwiftUI layout.
@available(iOS 18, macOS 15, tvOS 18, watchOS 11, *)
struct SUIStrikethroughAttribute: TextAttribute {
    let style: UnderlineStyle
    let color: SwiftUIColor
    let baselineOffset: CGFloat
    let thickness: CGFloat

    init(style: UnderlineStyle, font: Font, color: Color) {
        self.style = style
        self.color = SwiftUIColor(color)
        self.baselineOffset = font.xHeight / 2
        let ctFont = font as CTFont
        self.thickness = max(1, CTFontGetUnderlineThickness(ctFont))
    }
}

@available(iOS 18, macOS 15, tvOS 18, watchOS 11, *)
struct SUIStrikethroughTextRenderer: TextRenderer {
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                guard let attribute = run[SUIStrikethroughAttribute.self] else { continue }
                let bounds = run.typographicBounds
                guard bounds.width > 0 else { continue }
                let y = bounds.origin.y - attribute.baselineOffset
                let baseStyle = attribute.style.rawValue & 0x0F
                let width = attribute.thickness * (baseStyle == UnderlineStyle.thick.rawValue ? 2 : 1)
                let offsets: [CGFloat] = baseStyle == UnderlineStyle.double.rawValue
                    ? [-attribute.thickness, attribute.thickness]
                    : [0]
                var path = Path()
                for offset in offsets {
                    path.move(to: CGPoint(x: bounds.origin.x, y: y + offset))
                    path.addLine(to: CGPoint(x: bounds.origin.x + bounds.width, y: y + offset))
                }
                context.stroke(path, with: .color(attribute.color), style: StrokeStyle(
                    lineWidth: width,
                    dash: dash(for: attribute.style, thickness: width)
                ))
            }
        }
    }

    private func dash(for style: UnderlineStyle, thickness: CGFloat) -> [CGFloat] {
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
