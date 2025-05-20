import SwiftUI
import GoogleMobileAds

struct RewardedAdTest: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var rewardedAdsManager: RewardedAD
    
    var body: some View {
        VStack(spacing: 20) {
     
            Text("Золото: \(gameState.gold)")
                .font(.title)
                .padding()
            
            
            GameButton(title: "Get 100 gold", backgroundImageName: "menuItem") {
                rewardedAdsManager.displayRewardedAd()
            }
            .disabled(!rewardedAdsManager.rewardedAdLoaded)
            
            Spacer()
        }
        .padding()
        .onChange(of: rewardedAdsManager.userEarnedReward) { newValue in
            if newValue {
                gameState.addGold(amount: 100)
                rewardedAdsManager.userEarnedReward = false
            }
        }
    }
}
