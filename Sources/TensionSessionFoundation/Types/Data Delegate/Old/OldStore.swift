//
//  OldStore.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

import Foundation
import SwiftData

/// Persistent models from GymCoach v1.1.0.
nonisolated enum OldStore: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(1, 1, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            Workout.self,
            Exercise.self,
            UserInfo.self,
            SyncInstruction.self,
            ExerciseWeightsCache.self
        ]
    }
    
    @Model
    final class Workout {
        
        @Attribute(.unique)
        var id: UUID
        
        var name: String
        
        var isTemplate: Bool
        
        var dateAdded: Date
        
        var startTime: Date?
        
        var endTime: Date?
        
        @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
        var exercises: [Exercise]
        
        init(
            id: UUID,
            name: String,
            isTemplate: Bool,
            dateAdded: Date,
            startTime: Date?,
            endTime: Date?,
            exercises: [Exercise]
        ) {
            self.id = id
            self.name = name
            self.isTemplate = isTemplate
            self.dateAdded = dateAdded
            self.startTime = startTime
            self.endTime = endTime
            self.exercises = exercises
        }
    }
    
    @Model
    final class Exercise {
        
        var id: UUID
        
        var name: String
        
        @Relationship(inverse: nil)
        var workout: Workout?
        
        var setsPlanned: Int
        
        var setsDone: Int
        
        var setDetails: [SetDetail]
        
        var dateAdded: Date
        
        init(
            id: UUID,
            name: String,
            setsPlanned: Int,
            setsDone: Int,
            setDetails: [SetDetail],
            dateAdded: Date
        ) {
            self.id = id
            self.name = name
            self.setsPlanned = setsPlanned
            self.setsDone = setsDone
            self.setDetails = setDetails
            self.dateAdded = dateAdded
        }
    }
    
    struct SetDetail: Codable {
        
        var repsPlanned: Int
        
        var repsDone: Int?
        
        var weightPlanned: Weight
        
        var weightUsed: Weight?
    }
    
    struct Weight: Codable {
        
        var value: Double
        
        var unit: Unit
        
        enum Unit: String, Codable {
            
            case kilograms
            case pounds
        }
    }
    
    @Model
    final class UserInfo {
        
        var weightPreference: WeightPreference
        
        var wasWatchAppInstalled: Bool
        
        var weightAggregationMethod: WeightAggregationMethod
        
        enum WeightPreference: String, Codable {
            
            case system
            case kilograms
            case pounds
        }
        
        enum WeightAggregationMethod: String, Codable {
            
            case all
            case median
            case average
            case max
            case min
        }
        
        init(
            weightPreference: WeightPreference,
            wasWatchAppInstalled: Bool,
            weightAggregationMethod: WeightAggregationMethod
        ) {
            self.weightPreference = weightPreference
            self.wasWatchAppInstalled = wasWatchAppInstalled
            self.weightAggregationMethod = weightAggregationMethod
        }
    }
    
    @Model
    final class SyncInstruction {
        
        var id: UUID
        
        var operation: Operation
        
        var payloadData: Data
        
        enum Operation: String, Codable {
            
            case addTemplateWorkout
            case updateTemplateWorkout
            case deleteTemplateWorkout
            case deleteAllTemplateWorkouts
            case deleteAllHistoricalWorkouts
            case replyWithAllWorkouts
            case requestAllWorkouts
            case addHistoricalWorkout
            case updateExerciseWeightsCache
            case updateUserInfo
        }
        
        init(id: UUID, operation: Operation, payloadData: Data) {
            self.id = id
            self.operation = operation
            self.payloadData = payloadData
        }
    }
    
    @Model
    final class ExerciseWeightsCache {
        
        var id: UUID
        
        var name: String
        
        var weights: [Weight]
        
        init(id: UUID, name: String, weights: [Weight]) {
            self.id = id
            self.name = name
            self.weights = weights
        }
    }
}
