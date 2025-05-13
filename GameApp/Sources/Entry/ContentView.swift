import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
//    @State private var navigationPath = NavigationPath()
    @State private var showFullScreen = false
    @State private var showSettings = false
    
    var body: some View {
//        NavigationStack(path: $navigationPath) {
            
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
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView(
                    musicEnabled: $gameState.musicEnabled,
                    soundEffectsEnabled: $gameState.soundEffectsEnabled,
                    vibrationEnabled: $gameState.vibrationEnabled,
                    selectedLanguage: $gameState.selectedLanguage,
                    styleConfig: spaceGameStyle
                )
                
            }
        }
    }
//}
