//
//  File.swift
//  
//
//  Created by Stanislav Li on 14/1/25.
//

import Foundation

public extension Locale {
    var currentLanguageCode: String {
        Locale.preferredLanguages.first.flatMap { Locale(identifier: $0).languageCode } ?? Locale.current.languageCode ?? "en"
    }
}
