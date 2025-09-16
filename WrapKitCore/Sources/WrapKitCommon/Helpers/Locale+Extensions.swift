//
//  File.swift
//  
//
//  Created by Stanislav Li on 14/1/25.
//

import Foundation

public extension Locale {
    enum KyrgyzLangCode {
        case ky
        case kg
    }

    static func currentLanguageCode(useCode kyrgyzLangCode: KyrgyzLangCode = .ky) -> String {
        let systemCode = Locale.preferredLanguages.first
            .flatMap { Locale(identifier: $0).languageCode }
        ?? Locale.current.languageCode
        ?? "en"
        
        if systemCode == "ky" || systemCode == "kg" {
            switch kyrgyzLangCode {
            case .ky: return "ky"
            case .kg: return "kg"
            }
        }
        
        return systemCode
    }
}
