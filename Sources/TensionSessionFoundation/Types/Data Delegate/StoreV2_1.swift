//
//  StoreV2_1.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/25/26.
//

import SwiftData

/// Schema 2.0.1. `useAutomaticRepDetection` is optional so existing rows can migrate before it is filled in.
nonisolated enum StoreV2_1: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(2, 0, 1)
    
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
        
        var useAutomaticRepDetection: Bool?
        
        init(
            restSeconds: Int = 120,
            hasLearnedTimeKeeper: Bool = false,
            hasWatchCompletedInitialSync: Bool = false,
            useAutomaticRepDetection: Bool? = nil
        ) {
            self.restSeconds = restSeconds
            self.hasLearnedTimeKeeper = hasLearnedTimeKeeper
            self.hasWatchCompletedInitialSync = hasWatchCompletedInitialSync
            self.useAutomaticRepDetection = useAutomaticRepDetection
        }
    }
}
