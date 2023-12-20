//
//  UIColor+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init?(hexaRGB: String, alpha: CGFloat = 1) {
        var chars = Array(hexaRGB.hasPrefix("#") ? hexaRGB.dropFirst() : hexaRGB[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  alpha: alpha)
    }
    
    var overlayColor: UIColor {
        var brightness: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        
        return brightness > 0.5 ? UIColor.black.withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.5)
    }
    
    
    static func readableBackground(for textColor: UIColor) -> UIColor {
        let potentialBackgroundColors: [UIColor] = [
            .orange,
            .green,
            .blue,
            .yellow,
            .purple,
            .brown,
            .magenta
        ]
        
        let textComponents = textColor.cgColor.components ?? [0, 0, 0]
        let textLuminance = 0.2126 * textComponents[0] + 0.7152 * textComponents[1] + 0.0722 * textComponents[2]
        
        let contrastingColors = potentialBackgroundColors.filter { bgColor in
            let bgComponents = bgColor.cgColor.components ?? [0, 0, 0]
            let bgLuminance = 0.2126 * bgComponents[0] + 0.7152 * bgComponents[1] + 0.0722 * bgComponents[2]
            
            let contrastRatio = (max(textLuminance, bgLuminance) + 0.05) / (min(textLuminance, bgLuminance) + 0.05)
            
            return contrastRatio >= 4.5
        }
        
        return contrastingColors.randomElement() ?? .black
    }
    
    static var random: UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255
        let green = CGFloat(arc4random_uniform(256)) / 255
        let blue = CGFloat(arc4random_uniform(256)) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    
}
#endif
