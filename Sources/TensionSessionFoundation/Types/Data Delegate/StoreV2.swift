//
//  StoreV2.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/25/26.
//

import SwiftData

/// Schema 2.0.0, before `UserInfo.useAutomaticRepDetection`.
nonisolated enum StoreV2: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            WorkoutManager.self,
            Workout.self,
            Exercise.self,
            UserInfo.self,
            Exercise.Catalog.self
        ]
    }
    
    @Model
    final class UserInfo {
        
        var restSeconds: Int
        
        var hasLearnedTimeKeeper: Bool
        
        var hasWatchCompletedInitialSync: Bool
        
        init(
            restSeconds: Int = 120,
            hasLearnedTimeKeeper: Bool = false,
            hasWatchCompletedInitialSync: Bool = false
        ) {
            self.restSeconds = restSeconds
            self.hasLearnedTimeKeeper = hasLearnedTimeKeeper
            self.hasWatchCompletedInitialSync = hasWatchCompletedInitialSync
        }
    }
}
