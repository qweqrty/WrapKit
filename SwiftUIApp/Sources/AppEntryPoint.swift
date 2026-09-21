import Foundation
import SwiftUI

@main
struct SwiftUIApp: App {
    @StateObject private var flow: EntrySwiftUIFlow

    init() {
        let initialDestination = ProcessInfo.processInfo.arguments
            .first(where: { $0.hasPrefix("--catalog-destination=") })
            .map { String($0.dropFirst("--catalog-destination=".count)) }
            .flatMap(CatalogOutputDestination.init(launchValue:))
        _flow = StateObject(wrappedValue: EntrySwiftUIFlow(
            factory: EntryViewSwiftUIFactory(initialDestination: initialDestination)
        ))
    }

    var body: some Scene {
        WindowGroup {
            EntryView()
                .environmentObject(flow)
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
            flow.showCatalog()
            hasAppeared = true
        }
    }
}
