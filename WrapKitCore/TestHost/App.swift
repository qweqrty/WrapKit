import SwiftUI

@main
struct WrapKitTestHostApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *),
               let mode = GlassButtonScrollFixture.Mode(launchArguments: ProcessInfo.processInfo.arguments) {
                GlassButtonScrollFixture(mode: mode)
            } else if #available(iOS 16.0, *),
                      ProcessInfo.processInfo.arguments.contains("--header-after-pop") {
                HeaderAfterPopFixture().ignoresSafeArea()
            } else if #available(iOS 16.0, *),
                      let mode = KeyboardAccessoryFixture.Mode(launchArguments: ProcessInfo.processInfo.arguments) {
                KeyboardAccessoryFixture(mode: mode)
            } else {
                EmptyView()
            }
        }
    }
}
