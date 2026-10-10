//
//  DataDelegate.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

import SwiftData

@MainActor
final public class DataDelegate {
    
    var container: ModelContainer
    
    var context: ModelContext
    
    public var workoutManager: WorkoutManager
    
    public var userInfo: UserInfo
    
    public var catalog: Exercise.Catalog
    
    public var companion: Companion
    
    public init(isStoredInMemoryOnly: Bool) {
        
        do {
            container = try ModelContainer(
                for: WorkoutManager.self,
                     Workout.self,
                     Exercise.self,
                     UserInfo.self,
                     Exercise.Catalog.self,
                migrationPlan: DataDelegateMigrationPlan.self,
                configurations: .init(isStoredInMemoryOnly: isStoredInMemoryOnly)
            )
            context = container.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // Workout Manager
        
        let workoutManagers: [WorkoutManager]
        
        do {
            workoutManagers = try context.fetch(
                DataDelegate.workoutManagerFetchDescriptor
            )
        } catch {
            fatalError("Could not fetch WorkoutManagers: \(error)")
        }
        
        if let workoutManager = workoutManagers.first {
            assert(workoutManagers.count == 1)
            self.workoutManager = workoutManager
        } else {
            workoutManager = WorkoutManager()
            context.insert(workoutManager)
            try? context.save()
        }
        
        // User Info
        
        let userInfos: [UserInfo]
        
        do {
            userInfos = try context.fetch(
                DataDelegate.userInfoFetchDescriptor
            )
        } catch {
            fatalError("Could not fetch UserInfos: \(error)")
        }
        
        if let userInfo = userInfos.first {
            assert(userInfos.count == 1)
            self.userInfo = userInfo
        } else {
            userInfo = UserInfo()
            context.insert(userInfo)
            try? context.save()
        }
        
        // Exercise catalog
        
        let catalogs: [Exercise.Catalog]
        
        do {
            catalogs = try context.fetch(
                DataDelegate.exerciseCatalogFetchDescriptor
            )
        } catch {
            fatalError("Could not fetch Exercise.Catalog: \(error)")
        }
        
        if let catalog = catalogs.first {
            assert(catalogs.count == 1)
            self.catalog = catalog
        } else {
            catalog = Exercise.Catalog()
            context.insert(catalog)
            try? context.save()
        }
        
        // Companion
        
        companion = Companion()
        companion.userInfo = self.userInfo
        companion.workoutManager = self.workoutManager
        companion.getExerciseCatalogDTO = {
            return self.catalog.getDTO()
        }
        #if os(watchOS)
        companion.editCatalog = { newCatalogDTO in
            self.catalog.all = newCatalogDTO.all
        }
        #endif
        companion.activate()
        
        // Savers
        
        self.workoutManager.save = {
            try? self.context.save()
        }
    }
}
