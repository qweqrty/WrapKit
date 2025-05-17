import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var interstitialAd: InterstitialAdsManager
    //    @State private var navigationPath = NavigationPath()
    @State private var showFullScreen = false
    @State private var showSettings = false
    
    
    var body: some View {
        ZStack {
            GameMenu(
                title: "Game Menu",
                buttons: [
                    MenuButtonConfig(
                        title: "Start Game",
                        backgroundImageName: "menuItem2",
                        action: {
                            print("Starting game...")
                        }
                    ),
                    MenuButtonConfig(
                        title: "Settings",
                        backgroundImageName: "menuItem2",
                        action: {
                            //                            navigationPath.append("Settings")
                            showSettings = true
                        }
                    ),
                    MenuButtonConfig(
                        title: "Exit",
                        backgroundImageName: "menuItem2",
                        action: {
                            print("Exiting game...")
                        }
                    )
                ],
                backgroundImageName: "background1",
                backgroundAnimation: "cartoon"
            )
            
            if showSettings {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                SettingsView(
                    musicEnabled: $gameState.musicEnabled,
                    isPresented: $showSettings,
                    soundEffectsEnabled: $gameState.soundEffectsEnabled,
                    vibrationEnabled: $gameState.vibrationEnabled,
                    selectedLanguage: $gameState.selectedLanguage,
                    styleConfig: fantasyGameStyle
                )
                .transition(.scale)
                .zIndex(1)
                .environmentObject(interstitialAd)
            }
        }
        
    }
    
}
