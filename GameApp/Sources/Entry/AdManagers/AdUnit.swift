//
//  AdUnit.swift
//  GameApp
//
//  Created by sunflow on 19/5/25.
//

import Foundation

enum AdUnit {
    case gameRewarded
    case gameInterstitial
    case gameBanner
    case gameOpenAd
    
    var unitID: String {
        switch self {
        case .gameRewarded:
            return ""
        case .gameInterstitial:
            return "ca-app-pub-3940256099942544/4411468910"
        case .gameBanner:
            return ""
        case .gameOpenAd:
            return ""
        }
    }
}
