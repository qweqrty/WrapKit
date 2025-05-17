
import Foundation
import GameKit
import SwiftUI

#if os(macOS)
typealias ViewController = NSViewController
typealias ViewControllerRepresentable = NSViewControllerRepresentable
#elseif os(iOS)
typealias ViewController = UIViewController
typealias ViewControllerRepresentable = UIViewControllerRepresentable
#endif

extension View {
    public func enableGameCenter() -> some View {
        self
            .modifier(EnableGameCenterModifier())
            .modifier(OpenGameCenterModifier())
    }

    @MainActor
    public func onGameCenterAuthenticated(_ perform: @escaping () -> ()) -> some View {
        GameKitAuthenticationController.shared.onAuthenticate = perform
        return self
    }
}

private struct EnableGameCenterModifier: ViewModifier {
    @ObservedObject var controller = GameKitAuthenticationController.shared

    func body(content: Content) -> some View {
        let content = content
            .environment(\.gameCenterIsAuthenticated, controller.isAuthenticated)
            .environmentObject(controller)
            .onAppear { controller.authenticate() }

        if let authenticationView = controller.authenticationView {
            content.overlay(authenticationView)
        } else {
            content
        }
    }
}

private struct GameCenterIsAuthenticatedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public internal(set) var gameCenterIsAuthenticated: Bool {
        get { self[GameCenterIsAuthenticatedKey.self] }
        set { self[GameCenterIsAuthenticatedKey.self] = newValue }
    }
}


private struct OpenGameCenterConfiguration: EnvironmentKey {
    static let defaultValue: () -> () = {}
}

extension EnvironmentValues {
    public internal(set) var openGameCenterConfiguration: () -> () {
        get { self[OpenGameCenterConfiguration.self] }
        set { self[OpenGameCenterConfiguration.self] = newValue }
    }
}

private struct OpenGameCenterModifier: ViewModifier {
    @Environment(\.openURL) var openURL
    @Environment(\.openGameCenterConfiguration) var openGameCenterConfiguration

    func body(content: Content) -> some View {
        content.environment(\.openGameCenterConfiguration, {
#if os(iOS)
            openURL(URL(string: UIApplication.openSettingsURLString)!)
#elseif os(macOS)
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/InternetAccounts.prefPane"))
#endif
        })
    }
}

private struct GameCenterAuthenticationView: ViewControllerRepresentable {

    typealias Coordinator = Void

    let viewController: ViewController

    func makeCoordinator() -> Coordinator { Void() }

#if os(iOS)
    func makeUIViewController(context: Context) -> ViewController { viewController }
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
#elseif os(macOS)
    func makeNSViewController(context: Context) -> ViewController { viewController }
    func updateNSViewController(_ nsViewController: ViewController, context: Context) {}
#endif
 }

@MainActor
private class GameKitAuthenticationController: ObservableObject {

    static let shared = GameKitAuthenticationController()

    var didTryAuthenticate = false
    var onAuthenticate: (() -> ())?

    @Published var isAuthenticated = false
    @Published var authenticationError: Error?
    @Published var authenticationView: GameCenterAuthenticationView?

    var isAuthenticatedObservation: NSKeyValueObservation?

    private init() {
        isAuthenticated = GKLocalPlayer.local.isAuthenticated

        isAuthenticatedObservation = GKLocalPlayer.local.observe(
            \.isAuthenticated,
             options: .new,
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }

                 // Skip when setting the same value again
                 guard self.isAuthenticated != GKLocalPlayer.local.isAuthenticated
                 else { return }

                 self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                 self.authenticationError = nil
                 self.authenticationView = nil

                 if self.isAuthenticated {
                     self.onAuthenticate?()
                     self.onAuthenticate = nil
                 }
             })
    }

    deinit {
        isAuthenticatedObservation?.invalidate()
    }

    func authenticate() {
        guard !didTryAuthenticate else { return }
        didTryAuthenticate = true

        GKLocalPlayer.local
            .authenticateHandler = { [weak self] viewController, error in
                guard let self = self else { return }

                self.authenticationError = error
                if let viewController = viewController {
                    self.authenticationView = GameCenterAuthenticationView(
                        viewController: viewController)
                }
            }
    }
}
