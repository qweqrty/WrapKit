//
//  GameServices.swift
//  WrapKitGame
//
//  Created by Stanislav Li on 10/5/25.
//

import Foundation
import WrapKit
import GameKit
import Combine

public class GameServices {
    public let shared = GameServices()
    private let leaderboardId: String
    
    private init(leaderboardId: String? = nil) {
        self.leaderboardId = leaderboardId ?? Bundle.main.bundleIdentifier ?? ""
    }
    
    public func getMyProfileService() -> any Service<GetMyScoreService.Request, GetMyScoreService.Response> {
        GetMyScoreService(leaderboardId: leaderboardId)
    }
    
    public func setMyScoreService() -> any Service<SetMyScoreService.Request, SetMyScoreService.Response> {
        SetMyScoreService(leaderboardId: leaderboardId)
    }
    
    public func getTopProfilesService() -> any Service<TopScoresService.Request, TopScoresService.Response> {
        TopScoresService(leaderboardId: leaderboardId)
    }
}

open class SetMyScoreService: Service {
    public typealias Request = Int64
    public typealias Response = Void
    
    private let leaderboardId: String
    
    public init(leaderboardId: String = Bundle.main.bundleIdentifier ?? "") {
        self.leaderboardId = leaderboardId
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        return Future { [weak self] promise in
            guard let self else { return }
            GKLeaderboard.submitScore(
                Int(request),
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [self.leaderboardId]
            ) { error in
                if error != nil {
                    promise(.failure(.internal))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

open class GetMyScoreService: Service {
    public typealias Request = Void
    public typealias Response = GKLeaderboard.Entry
    
    private let leaderboardId: String
    
    public init(leaderboardId: String = Bundle.main.bundleIdentifier ?? "") {
        self.leaderboardId = leaderboardId
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        return Future { [weak self] promise in
            guard let self else { return }
            GKLeaderboard.loadLeaderboards(IDs: [self.leaderboardId]) { [weak self] leaderboards, error in
                guard let leaderboard = leaderboards?.first(where: { $0.baseLeaderboardID == self?.leaderboardId }), error == nil else {
                    promise(.failure(.internal))
                    return
                }
                
                leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime) { localPlayerEntry, _, _ in
                    guard let localPlayerEntry else { return }
                    promise(.success(localPlayerEntry))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

open class TopScoresService: Service {
    public typealias Request = Void
    public typealias Response = [GKLeaderboard.Entry]
    
    private let leaderboardId: String
    
    public init(leaderboardId: String = Bundle.main.bundleIdentifier ?? "") {
        self.leaderboardId = leaderboardId
    }
    
    public func make(request: Request) -> AnyPublisher<Response, ServiceError> {
        return Future { [weak self] promise in
            guard let self else { return }
            GKLeaderboard.loadLeaderboards(IDs: [self.leaderboardId]) { [weak self] leaderboards, error in
                guard let leaderboard = leaderboards?.first(where: { $0.baseLeaderboardID == self?.leaderboardId }), error == nil else {
                    promise(.failure(.internal))
                    return
                }
                
                leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 100)) { _, entries, _, error  in
                    if error != nil {
                        promise(.failure(.internal))
                    } else {
                        promise(.success(entries ?? []))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
