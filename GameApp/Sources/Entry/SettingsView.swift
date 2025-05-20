import SwiftUI
import WrapKitGame
import StoreKit

struct SettingsView: View {
    @Binding var musicEnabled: Bool
    @Binding var isPresented: Bool
    @Binding var soundEffectsEnabled: Bool
    @Binding var vibrationEnabled: Bool
    @Binding var selectedLanguage: String
    
    @EnvironmentObject var interstitialAd: InterstitialAD
    @EnvironmentObject var storeVM: StoreVM
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var rewardedAd: RewardedAD
    
    let styleConfig: SettingsStyleConfig
    
    @State private var showContent = false
    @State private var showBackground = false
    @State private var showPurchaseFailedAlert = false
    @State private var purchaseErrorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(showBackground ? 0.5 : 0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            if showContent {
                VStack(spacing: 8) {
                    Text("Settings")
                        .font(styleConfig.titleFont)
                        .foregroundColor(styleConfig.sectionHeaderColor)
                    
                    VStack {
                        GameToggle(
                            isOn: $musicEnabled,
                            onImage: "soundOn",
                            offImage: "soundoff",
                            size: CGSize(width: 50, height: 50),
                            backgroundColor: Color.black.opacity(0.3),
                            borderColor: .yellow,
                            borderWidth: 2,
                            cornerRadius: 20,
                            title: "Music",
                            font: styleConfig.titleFont,
                            action: {
                                playMusic()
                            }
                        )
                        
                        GameToggle(
                            isOn: $vibrationEnabled,
                            onImage: "soundOn",
                            offImage: "soundoff",
                            size: CGSize(width: 50, height: 50),
                            backgroundColor: Color.black.opacity(0.3),
                            borderColor: .yellow,
                            borderWidth: 2,
                            cornerRadius: 20,
                            title: "Vibration",
                            font: styleConfig.titleFont,
                            action: {
                                
                            }
                        )
                        
                        Text("Золото: \(gameState.gold)")
                            .font(.title)
                            .padding()
                        
                        
                        if storeVM.subscriptionGroupStatus != .purchased {
                            ForEach(storeVM.subscriptions) { product in
                                GameButton(title: "Buy", backgroundImageName: "menuItem") {
                                    Task {
                                        await buy(product: product)
                                    }
                                }
                            }
                        } else {
                            GameButton(title: "Subscribed", backgroundImageName: "menuItem")
                        }
                        GameButton(title: "Show add", backgroundImageName: "menuItem") {
                            interstitialAd.displayInterstitialAd()
                        }
                        GameButton(title: "Restore", backgroundImageName: "menuItem") {
                            Task {
                                await restore()
                            }
                        }
                        GameButton(title: "Close", backgroundImageName: "menuItem2") {
                            close()
                        }
                        
                        GameButton(title: "Get 100 gold", backgroundImageName: "menuItem2") {
                            rewardedAd.displayRewardedAd()
                        }
                        .disabled(!rewardedAd.rewardedAdLoaded)
                    }
                    
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(30)
                .shadow(radius: 20)
                .frame(maxWidth: 350)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                showBackground = true
                showContent = true
            }
        }
        .onChange(of: rewardedAd.userEarnedReward) { newValue in
            if newValue {
                gameState.addGold(amount: 100)
                rewardedAd.userEarnedReward = false
            }
        }
    }
    
    private func close() {
        withAnimation(.spring()) {
            showContent = false
            showBackground = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    func playMusic() {
        if gameState.soundEffectsEnabled {
            AudioManager.shared.playEffect(named: "clickSound.wav")
        }
    }
    
    private func buy(product: SKProduct) async {
        do {
            try await storeVM.purchase(product)
        } catch {
            // TODO: CHECK
            purchaseErrorMessage = error.localizedDescription
            showPurchaseFailedAlert = true
        }
    }
    
    private func restore() async {
        do {
            try await storeVM.restorePurchases()
        } catch {
            // TODO: CHECK
            purchaseErrorMessage = error.localizedDescription
            showPurchaseFailedAlert = true
        }
    }
}
