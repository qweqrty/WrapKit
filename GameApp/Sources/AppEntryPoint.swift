import SwiftUI
import WrapKitGame

@main
struct GameMenuApp: App {
    @StateObject private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
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
