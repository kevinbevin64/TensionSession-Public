//
//  OldStore+Migration.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

import Foundation
import SwiftData
import Synchronization

nonisolated enum OldStoreMigration {
    
    private static let storedWorkouts = Mutex<[WorkoutSnapshot]?>(nil)
    
    static func prepare(_ context: ModelContext) throws {
        
        let snapshots = try snapshot(from: context)
        storedWorkouts.withLock { $0 = snapshots }
        try deleteEverything(in: context)
        try context.save()
    }
    
    static func finish(_ context: ModelContext) throws {
        
        let workouts = storedWorkouts.withLock { stored in
            let workouts = stored ?? []
            stored = nil
            return workouts
        }
        try apply(workouts, to: context)
        try context.save()
    }
    
    private struct WorkoutSnapshot: Sendable {
        
        var id: UUID
        
        var name: String
        
        var dateAdded: Date
        
        var isTemplate: Bool
        
        var startTime: Date?
        
        var exercises: [ExerciseSnapshot]
    }
    
    private struct ExerciseSnapshot: Sendable {
        
        var id: UUID
        
        var name: String
        
        var setsPlanned: Int
        
        var repsPlanned: Int
        
        var weightPlanned: Weight
        
        var completedSets: [SetDetail]
    }
    
    private static func snapshot(from context: ModelContext) throws -> [WorkoutSnapshot] {
        
        let workouts = try context.fetch(FetchDescriptor<OldStore.Workout>())
        
        return workouts.compactMap { workout in
            
            if workout.startTime != nil, workout.endTime == nil {
                return nil
            }
            
            if workout.isTemplate {
                guard workout.startTime == nil else { return nil }
            } else {
                guard workout.startTime != nil, workout.endTime != nil else { return nil }
            }
            
            return WorkoutSnapshot(
                id: workout.id,
                name: workout.name,
                dateAdded: workout.dateAdded,
                isTemplate: workout.isTemplate,
                startTime: workout.startTime,
                exercises: workout.exercises.map(snapshot(of:))
            )
        }
    }
    
    private static func snapshot(of exercise: OldStore.Exercise) -> ExerciseSnapshot {
        
        let planned = exercise.setDetails.first
        
        return ExerciseSnapshot(
            id: exercise.id,
            name: exercise.name,
            setsPlanned: exercise.setsPlanned,
            repsPlanned: planned?.repsPlanned ?? 10,
            weightPlanned: weight(from: planned?.weightPlanned),
            completedSets: exercise.setDetails.compactMap { detail in
                guard let repsDone = detail.repsDone, let weightUsed = detail.weightUsed else {
                    return nil
                }
                return SetDetail(repsDone: repsDone, weightUsed: weight(from: weightUsed))
            }
        )
    }
    
    private static func weight(from old: OldStore.Weight?) -> Weight {
        
        guard let old else { return Weight(0) }
        
        switch old.unit {
        case .kilograms:
            return Weight(old.value, .kilograms)
        case .pounds:
            return Weight(old.value, .pounds)
        }
    }
    
    private static func deleteEverything(in context: ModelContext) throws {
        
        for instruction in try context.fetch(FetchDescriptor<OldStore.SyncInstruction>()) {
            context.delete(instruction)
        }
        
        for cache in try context.fetch(FetchDescriptor<OldStore.ExerciseWeightsCache>()) {
            context.delete(cache)
        }
        
        for workout in try context.fetch(FetchDescriptor<OldStore.Workout>()) {
            context.delete(workout)
        }
        
        for exercise in try context.fetch(FetchDescriptor<OldStore.Exercise>()) {
            context.delete(exercise)
        }
        
        for userInfo in try context.fetch(FetchDescriptor<OldStore.UserInfo>()) {
            context.delete(userInfo)
        }
    }
    
    private static func apply(_ workouts: [WorkoutSnapshot], to context: ModelContext) throws {
        
        let catalog = Exercise.Catalog()
        let manager = WorkoutManager()
        
        let templates = workouts
            .filter(\.isTemplate)
            .sorted { $0.dateAdded < $1.dateAdded }
        
        let history = workouts
            .filter { $0.isTemplate == false }
            .sorted { ($0.startTime ?? .distantPast) < ($1.startTime ?? .distantPast) }
        
        manager.unsortedTemplates = templates.enumerated().map { index, workout in
            makeWorkout(workout, order: index, catalog: catalog, state: .unstarted, startInstant: nil)
        }
        
        manager.unsortedHistory = history.enumerated().map { index, workout in
            makeWorkout(
                workout,
                order: index,
                catalog: catalog,
                state: .ended,
                startInstant: workout.startTime
            )
        }
        
        context.insert(catalog)
        context.insert(manager)
        context.insert(StoreV2.UserInfo())
    }
    
    private static func makeWorkout(
        _ workout: WorkoutSnapshot,
        order: Int,
        catalog: Exercise.Catalog,
        state: Workout.State,
        startInstant: Date?
    ) -> Workout {
        
        let exercises = workout.exercises.enumerated().map { index, exercise in
            Exercise(
                id2: exercise.id,
                order: index,
                kind: kind(named: exercise.name, catalog: catalog),
                equipment: .barbell,
                setsPlanned: exercise.setsPlanned,
                repsPlanned: exercise.repsPlanned,
                weightPlanned: exercise.weightPlanned,
                setDetails: exercise.completedSets
            )
        }
        
        return Workout(
            id2: workout.id,
            order: order,
            name: workout.name,
            state: state,
            startInstant: startInstant,
            exercises: exercises
        )
    }
    
    private static func kind(named name: String, catalog: Exercise.Catalog) -> Exercise.Catalog.Kind {
        
        let neatened = Exercise.Catalog.Kind.trimmedAndNeatened(name)
        
        if let builtIn = catalog.all.first(where: { $0.isBuiltIn && $0.name == neatened }) {
            return builtIn
        }
        
        if Exercise.Catalog.Kind.isValid(neatened) {
            if catalog.all.contains(where: { $0.name == neatened }) == false {
                try? catalog.addCustom(trimmedAndNeatened: neatened)
            }
            return Exercise.Catalog.Kind(neatened, isBuiltIn: false)
        }
        
        return Exercise.Catalog.Kind(name, isBuiltIn: false)
    }
}
