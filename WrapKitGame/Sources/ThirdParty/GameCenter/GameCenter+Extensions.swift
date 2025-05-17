
import Foundation
import GameKit
import SwiftUI

public enum GameCenterLaunchOption {
    case `default`
    case leaderboards
    case achievements
    case challenges
    case localPlayerProfile
    case dashboard
    case localPlayerFriendsList
    case leaderBoardID(id: String, playerScope: GKLeaderboard.PlayerScope, timeScope: GKLeaderboard.TimeScope)
    case leaderBoard(leaderboard: GKLeaderboard, playerScope: GKLeaderboard.PlayerScope)
    case achievementID(String)
}

extension View {
    public func gameCenter(
        isPresented: Binding<Bool>,
        launchOption: GameCenterLaunchOption = .default
    ) -> some View {
        modifier(GameCenterModifier(
            isPresented: isPresented,
            launchOption: launchOption))
    }
}

private struct GameCenterModifier: ViewModifier {
    @Binding var isPresented: Bool
    let launchOption: GameCenterLaunchOption

    @StateObject var controller = GameCenterController()

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            if isPresented {
                GameCenterController.shared.present(launchOption: launchOption)
                GameCenterController.shared.onDidFinish = onDidFinish
            }
        }
    }

    func onDidFinish() {
        isPresented = false
    }
}

private class GameCenterController:
    NSObject,
    GKGameCenterControllerDelegate,
    ObservableObject
{
    static let shared = GameCenterController()
    var onDidFinish: (() -> ())?
    var gamecenter: GKGameCenterViewController?

    func present(launchOption: GameCenterLaunchOption) {
        let gamecenter = createGameCenter(launchOption: launchOption)
        self.gamecenter = gamecenter
        gamecenter.gameCenterDelegate = self
        GameCenterController.shared.onDidFinish = onDidFinish
#if os(iOS)
        UIApplication.shared
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .present(gamecenter, animated: true)
#elseif os(macOS)
        NSApplication.shared
            .keyWindow?
            .contentViewController?
            .presentAsSheet(gamecenter)
#endif
    }

    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
#if os(iOS)
        let rootvc = UIApplication.shared
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController

        rootvc?.dismiss(animated: true)
#elseif os(macOS)
        NSApplication.shared
            .keyWindow?
            .contentViewController?
            .dismiss(gamecenter)
#endif

        onDidFinish?()
    }

    func createGameCenter(launchOption: GameCenterLaunchOption) -> GKGameCenterViewController {
        switch launchOption {
        case .default: return GKGameCenterViewController(state: .default)
        case .leaderboards: return GKGameCenterViewController(state: .leaderboards)
        case .achievements: return GKGameCenterViewController(state: .achievements)
        case .challenges: return GKGameCenterViewController(state: .challenges)
        case .localPlayerProfile: return GKGameCenterViewController(state: .localPlayerProfile)
        case .dashboard: return GKGameCenterViewController(state: .dashboard)
        case .localPlayerFriendsList: return GKGameCenterViewController(state: .localPlayerFriendsList)
        case .leaderBoardID(let id, let playerScope, let timeScope):
            return GKGameCenterViewController(leaderboardID: id, playerScope: playerScope, timeScope: timeScope)
        case .leaderBoard(let leaderboard, let playerScope):
            return GKGameCenterViewController(leaderboard: leaderboard, playerScope: playerScope)
        case .achievementID(let id):
            return GKGameCenterViewController(achievementID: id)
        }
    }
}
