import SwiftUI
import GoogleMobileAds

class RewardedAD: NSObject, ObservableObject, FullScreenContentDelegate {
    
    // Свойства
    @Published var rewardedAdLoaded: Bool = false
    @Published var userEarnedReward: Bool = false
    
    private var rewardedAd: RewardedAd?
    
    override init() {
        super.init()
    }
    
    // Загрузка рекламы с вознаграждением
    func loadRewardedAd() {
        RewardedAd.load(with: "ca-app-pub-3940256099942544/1712485313", request: Request()) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка загрузки рекламы с вознаграждением: \(error.localizedDescription)")
                self.rewardedAdLoaded = false
                return
            }
            print("Реклама с вознаграждением успешно загружена")
            self.rewardedAdLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    // Показ рекламы с вознаграждением
    func displayRewardedAd() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let root = windowScene?.windows.first?.rootViewController else {
            print("Не удалось получить rootViewController")
            return
        }
        
        if let ad = rewardedAd {
            ad.present(from: root, userDidEarnRewardHandler: { [weak self] in
                guard let self = self else { return }
                print("Пользователь получил вознаграждение")
                self.userEarnedReward = true
                self.rewardedAdLoaded = false
            })
        } else {
            print("Реклама с вознаграждением не готова")
            self.rewardedAdLoaded = false
            self.loadRewardedAd()
        }
    }
    
    // Ошибка показа рекламы
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ошибка показа рекламы с вознаграждением: \(error.localizedDescription)")
        self.rewardedAdLoaded = false
        self.loadRewardedAd()
    }
    
    // Уведомление о показе рекламы
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print(" Реклама с вознаграждением отображена")
    }
    
    // Уведомление о закрытии рекламы
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Реклама с вознаграждением закрыта")
        self.rewardedAdLoaded = false
        self.loadRewardedAd()
    }
}
