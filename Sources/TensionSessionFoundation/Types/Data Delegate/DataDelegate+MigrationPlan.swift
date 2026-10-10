//
//  DataDelegate+MigrationPlan.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

import SwiftData

enum CurrentStore: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(2, 1, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            WorkoutManager.self,
            Workout.self,
            Exercise.self,
            UserInfo.self,
            Exercise.Catalog.self
        ]
    }
}

enum DataDelegateMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [
            OldStore.self,
            StoreV2.self,
            CurrentStore.self
        ]
    }
    
    static var stages: [MigrationStage] {
        [
            oldStoreToStoreV2,
            storeV2ToCurrentStore
        ]
    }
    
    static let oldStoreToStoreV2 = MigrationStage.custom(
        fromVersion: OldStore.self,
        toVersion: StoreV2.self,
        willMigrate: { context in
            try OldStoreMigration.prepare(context)
        },
        didMigrate: { context in
            try OldStoreMigration.finish(context)
        }
    )
    
    static let storeV2ToCurrentStore = MigrationStage.custom(
        fromVersion: StoreV2.self,
        toVersion: CurrentStore.self,
        willMigrate: nil,
        didMigrate: { context in
            let userInfos = try context.fetch(FetchDescriptor<UserInfo>())
            for userInfo in userInfos {
                userInfo.useAutomaticRepDetection = true
            }
            try context.save()
        }
    )
}
