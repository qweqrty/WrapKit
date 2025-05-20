import SwiftUI
import WrapKitGame
import GoogleMobileAds

struct ContentView: View {
    @EnvironmentObject var storeVM: StoreVM
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var interstitialAd: InterstitialAD
    @EnvironmentObject var rewardedAd: RewardedAD
    //    @State private var navigationPath = NavigationPath()
    @State private var showFullScreen = false
    @State private var showSettings = false
    @State private var showAlert = false
    @State private var alertMessage = false
    
    
    
    var body: some View {
        ZStack {
            VStack {
                
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
                        ),
                    ],
                    backgroundImageName: "background1",
                    backgroundAnimation: "cartoon"
                )
                
                
                //adSizeBanner, adSizeLargeBanner, kGADAdSizeMediumRectangle, kGADAdSizeLeaderboard
                BannerAd(adSize: AdSizeBanner)
                    .frame(width: AdSizeBanner.size.width, height: AdSizeBanner.size.height)
            }
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
                .environmentObject(storeVM)
                .environmentObject(rewardedAd)
                .environmentObject(gameState)
            }
            
        }

        
    }
    
}
