//
//  GameState.swift
//  GameMenu
//
//  Created by sunflow on 10/5/25.
//

import Foundation

class GameState: ObservableObject {
    
    @Published var musicEnabled: Bool = true {
        didSet {
            updateMusic()
        }
    }
    
    @Published var soundEffectsEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var selectedLanguage: String = "English"
    @Published var isShowingSettings: Bool = false
    
    private func updateMusic() {
        if musicEnabled {
            AudioManager.shared.playMusic(named: "backgroundMusic.mp3")
        } else {
            AudioManager.shared.stopMusic()
        }
    }
}

