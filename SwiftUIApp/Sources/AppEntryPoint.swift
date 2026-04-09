import SwiftUI

@main
struct SwiftUIApp: App {
    @StateObject private var flow = EntrySwiftUIFlow()

    var body: some Scene {
        WindowGroup {
            EntryView()
                .environmentObject(flow)
        }
    }
}

struct EntryView: View {
    @EnvironmentObject var flow: EntrySwiftUIFlow

    @ViewBuilder
    private var screen: some View {
        switch flow.currentScreen {
        case .splash:
            SplashScreen()
        }
    }

    var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            NavigationStack {
                screen
            }
        } else {
            NavigationView {
                screen
            }
        }
    }
}
