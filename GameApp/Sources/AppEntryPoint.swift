import SwiftUI
import GoogleMobileAds
import WrapKitGame

class AppDelegate:NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MobileAds.shared.start()
        return true
    }
}

@main
struct GameMenuApp: App {
    @StateObject private var gameState = GameState()
    @StateObject var interstitialManager = InterstitialAdsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(interstitialManager)
                .onAppear {
                    interstitialManager.loadInterstitialAd()
                }
        }
    }
}

struct EntryView: View {
    @EnvironmentObject var flow: EntrySwiftUIFlow
    @State private var hasAppeared = false

    var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            NavigationStack {
                flow.currentView
            }
            .onAppear {
                onAppear()
            }
        } else {
            NavigationView {
                flow.currentView
            }
            .onAppear {
                onAppear()
            }
        }
    }
    
    private func onAppear() {
        if !hasAppeared {
            flow.showSplash()
            hasAppeared = true
        }
    }
}
