//
//  WatchTransferrable.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/14/25.
//

import Foundation
import SwiftData

// MARK: Persisting data

@MainActor protocol DataDelegateProtocol: AnyObject {
    // Get template workouts from the persistent store
    func fetchTemplateWorkouts() -> [Workout]
    
    // Add a template workout to the persistent store
    func addTemplateWorkout(_ workout: Workout)
    
    // Delete a template workout from the persistent store
    func deleteTemplateWorkout(_ workout: Workout)
    
    // Delete all the template workouts from the persistent store
    func deleteAllTemplateWorkouts()
    
    // Get the historical workouts from the persistent store
    func fetchHistoricalWorkouts() -> [Workout]
    
    // Add a historical workout to the persistent store
    func addHistoricalWorkout(_ workout: Workout)
    
    // Delete all the historical workouts from the persistent store 
    func deleteAllHistoricalWorkouts()
    
    // Get pending SyncInstructions
    func fetchPendingSyncInstructions() -> [SyncInstruction]
    
    // Add a pending SyncInstruction
    func addPendingSyncInstruction(_ instruction: SyncInstruction)
    
    // Delete a SyncInstruction.
    // This happens when the WatchConnectivity session is active, meaning pending instructions
    // can exit the persistent store and enter the transmission pipeline.
    func deletePendingSyncInstruction(_ instruction: SyncInstruction)
    
    // Get the exerciseWeightsCache-s that are currently persistently stored 
    func fetchExerciseWeightsCaches() -> [ExerciseWeightsCache]
    
    // Add an exerciseWeightsCache to the persistent store
    func addExerciseWeightsCache(_ cache: ExerciseWeightsCache)
}

// MARK: Watch communication

protocol DictionaryEncodable {
    var dictionaryForm: [String: Any] { get }
}

protocol DictionaryDecodable {
    init?(from dictionaryForm: [String: Any])
}

typealias DictionaryCodable = DictionaryEncodable & DictionaryDecodable
typealias WatchTransferrable = DictionaryCodable

protocol CompanionProtocol: AnyObject {
    // Tells the companion to add the template workout
    func addTemplateWorkout(_ workout: Workout)
    
    // Tells the companion to update the template workout
    func updateTemplateWorkout(_ workout: Workout)
    
    // Tells the companion to delete the template workout
    func deleteTemplateWorkout(_ workout: Workout)
    
    // Tells the companion to delete all its template workouts
    func deleteAllTemplateWorkouts()
    
    // Tells the companion to add the historical workout
    func addHistoricalWorkout(_ workout: Workout)
    
    // Tells the companion to delete all historical workouts
    func deleteAllHistoricalWorkouts()
    
    // Tells the companion to update its user info
    func updateUserInfo(_ userInfo: UserInfo)
    
    // Removes all the workout objects from the companion. This is used to clear the data in the
    // context, allowing for a fresh rewrite.
    func deleteAllWorkouts()
    
    #if os(watchOS)
    // Sends a message to the phone, waking it and making it reachable. The phone should then
    // reply with all workouts
    func requestAllWorkouts()
    #endif
}

enum Operation: String, Codable {
    // iOS only (iOS -> watchOS)
    case addTemplateWorkout
    case updateTemplateWorkout
    case deleteTemplateWorkout
    case deleteAllTemplateWorkouts
    case deleteAllHistoricalWorkouts
    case replyWithAllWorkouts

    // watchOS only (watchOS -> iOS)
    case requestAllWorkouts // Used when watch app is first installed
    
    // Both iOS and watchOS
    case addHistoricalWorkout // Sends the historical workout to the counterpart
    case updateExerciseWeightsCache // Updates the cache of exercise weights for a particular exercise

    // Communication tools
    case updateUserInfo  // both iOS and watchOS
}

protocol SyncInstructionProtocol: WatchTransferrable where Self: PersistentModel {
    var operation: Operation { get }
    var payload: [String: Any] { get } // Any refers only to property-list types
    var dateAdded: Date { get }
}

// MARK: Analyzing workout data

// Methods by which the weight trend for exercises belonging to historical workouts are aggregated.
// For example, with `all`, each weight value from each set of an exercise is used.
// With 'average', the average of weight values across all sets is used.
enum WeightAggregationMethod: String, Codable {
    case all
    case median
    case average
    case max
    case min
}

@MainActor
protocol WorkoutDataAnalyzerProtocol {
    init(with dataDelegate: DataDelegate)
    
    func addData(from historicalWorkout: Workout)
    
    func addData(from exercise: Exercise, date: Date)
}

// MARK: Keeping time

enum TimeKeeperMode {
    case stopwatch
    case timer
}

protocol TimeKeeperProtocol {
    // The displayed time
    var timeDisplay: String { get }
    var isRunning: Bool { get }
    
    
    func resume()
    func pause()
    
    // Sets the value of time display depending on the mode.
    // If mode is stopwatch, `timeDisplay` becomes 0
    // If mode is timer, `timeDisplay` becomes `alertAfter`
    func reset()
}
