//
//  DataFetcher.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/18/25.
//

import Foundation
import SwiftData

@Observable
@MainActor final class DataDelegate: DataDelegateProtocol {
    private let context: ModelContext
    
    var templateWorkouts: [Workout]
    var historicalWorkouts: [Workout]
    var exerciseWeightsCaches: [ExerciseWeightsCache]
    var suggestedWorkout: Workout? { templateWorkouts.first }
    private(set) var userInfo: UserInfo
    var pendingSyncInstructions: [SyncInstruction]
    
    init(context: ModelContext) {
        self.context = context
        self.templateWorkouts = []
        self.historicalWorkouts = []
        self.pendingSyncInstructions = []
        self.exerciseWeightsCaches = []
        
        // Find a UserInfo object in memory; it one isn't found, create one and store it persistently
        self.userInfo = {
            let userInfos = try! context.fetch(FetchDescriptor<UserInfo>()) // All UserInfo objects
            if userInfos.isEmpty {
                // Create the UserInfo object for this device.
                #if os(iOS)
                
                let userInfo = UserInfo()
                context.insert(userInfo)
                return userInfo
                
                #elseif os(watchOS)
                
                let userInfo = UserInfo(
                    // False because having the UserInfo object created for the first time means
                    // there's no prior session for which the watch app was installed.
                    wasWatchAppInstalled: false
                )
                context.insert(userInfo)
                return userInfo
                
                #endif
            } else {
                assert(userInfos.count == 1)
                return userInfos[0]
            }
        }()
        
        self.templateWorkouts = fetchTemplateWorkouts()
        self.historicalWorkouts = fetchHistoricalWorkouts()
        self.pendingSyncInstructions = fetchPendingSyncInstructions()
        self.exerciseWeightsCaches = fetchExerciseWeightsCaches()
    }
    
    // MARK: Template workouts
    // Fetches template workouts from the ModelContext in ascending dataAdded order.
    // Oldest objects are first; youngest ones are last.
    func fetchTemplateWorkouts() -> [Workout] {
        return try! context.fetch(FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.isTemplate == true },
            sortBy: [SortDescriptor(\Workout.dateAdded, order: .forward)]
        ))
    }
    
    func addTemplateWorkout(_ workout: Workout) {
        assert(workout.isTemplate == true, "Attempted to add historical workout as template.")
        templateWorkouts.append(workout)
//        if !templateWorkouts.contains(where: { $0.id == workout.id}) {
//            templateWorkouts.append(workout)
//        } else {
//            devPrint("Attempted to add a template when it already existed")
//        }
        context.insert(workout)
        try? context.save()
    }
    
    func deleteTemplateWorkout(_ workout: Workout) {
        assert(workout.isTemplate == true, "Attempted to delete historical workout from templates.")
        templateWorkouts.removeAll { $0.id == workout.id }
        context.delete(workout)
        try? context.save()
    }
    
    func deleteAllTemplateWorkouts() {
        templateWorkouts.removeAll()
        let workouts = try! context.fetch(FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.isTemplate == true }
        ))
        for workout in workouts {
            context.delete(workout)
        }
    }
    
    // MARK: Historical workouts
    // Fetches historical workouts from the ModelContext in descending dataAdded order.
    // Youngest objects are first; oldest ones are last. This shows the most recently completed
    // workout first.
    func fetchHistoricalWorkouts() -> [Workout] {
        return try! context.fetch(FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.isTemplate == false },
            sortBy: [SortDescriptor(\Workout.dateAdded, order: .reverse)]
        ))
    }
    
    func addHistoricalWorkout(_ workout: Workout) {
        assert(workout.isTemplate == false, "Attempted to add template workout as historical.")
        historicalWorkouts.append(workout)
        context.insert(workout)
        try? context.save()
    }
    
    func deleteAllHistoricalWorkouts() {
        historicalWorkouts.removeAll()
        let workouts = try! context.fetch(FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { $0.isTemplate == false }
        ))
        for workout in workouts {
            context.delete(workout)
        }
    }
    
    // MARK: Sync instructions
    func fetchPendingSyncInstructions() -> [SyncInstruction] {
        return try! context.fetch(FetchDescriptor<SyncInstruction>())
    }
    
    func addPendingSyncInstruction(_ instruction: SyncInstruction) {
        pendingSyncInstructions.append(instruction)
        context.insert(instruction)
        try? context.save()
    }
    
    func deletePendingSyncInstruction(_ instruction: SyncInstruction) {
        pendingSyncInstructions.removeAll { $0 == instruction }
        context.delete(instruction)
        try? context.save()
    }
    
    // MARK: - Caches exercise weights
    func fetchExerciseWeightsCaches() -> [ExerciseWeightsCache] {
        return try! context.fetch(FetchDescriptor<ExerciseWeightsCache>(
            sortBy: [SortDescriptor(\ExerciseWeightsCache.name, order: .forward)]
        ))
    }
    
    func addExerciseWeightsCache(_ cache: ExerciseWeightsCache) {
        exerciseWeightsCaches.append(cache)
        context.insert(cache)
        try? context.save()
    }
}
