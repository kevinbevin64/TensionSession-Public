//
//  File.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/22/25.
//

import Foundation

@MainActor
@Observable
final class WorkoutDataAnalyzer: WorkoutDataAnalyzerProtocol {
    // Keyed by exercise's name
    // Valued by an array of tuples, each of which represents a workout session for which
    //     the exercise was done at least once.
    // The tuple is in the form (date, weights) where date is the date of the workout and weights
    //     represents the weights lifted for that exercise
    //
    // Sorted from least recent to most recent 
    var exerciseData: [String: [(date: Date, weights: [Weight])]]
    var exerciseWeights: [String: [Weight]] // Sorted from least recent to most recent

    enum Errors: Swift.Error {
        case noExerciseData
    }
    
    init() {
        self.exerciseData = [:]
        self.exerciseWeights = [:]
    }
    
    init(with dataDelegate: DataDelegate) {
        self.exerciseData = [:]
        self.exerciseWeights = [:]
        // From least to most recent
        for historicalWorkout in dataDelegate.historicalWorkouts.reversed() {
            addData(from: historicalWorkout)
        }
    }
    
    // Add data from a historical workout
    // Can be used for initial gathering and for adding during app lifecycle
    func addData(from historicalWorkout: Workout) {
        guard historicalWorkout.isTemplate == false, let date = historicalWorkout.startTime else {
            assertionFailure("Attempted to add a template workout to the analyzer.")
            return
        }
        
        for exercise in historicalWorkout.exercises {
            addData(from: exercise, date: date)
        }
    }
    
    // Add data from an exercise
    func addData(from exercise: Exercise, date: Date) {
        if exerciseData[exercise.name] == nil {
            exerciseData[exercise.name] = []
        }
        exerciseData[exercise.name]?.append(
            (
                date: date,
                weights: exercise.setDetails.compactMap { $0.weightUsed }
            )
        )
        for i in 0..<exercise.setsDone {
            guard let weightUsed = exercise.setDetails[i].weightUsed else {
                assertionFailure("Tried to access nil weight")
                return
            }
            if exerciseWeights[exercise.name] == nil {
                exerciseWeights[exercise.name] = []
            }
            exerciseWeights[exercise.name]?.append(weightUsed)
        }
    }
    
    func getLast(_ n: Int, weightsFor exerciseName: String) -> [Weight] {
//        if exerciseWeights[exerciseName] == nil {
//            guard var data = exerciseData[exerciseName] else {
//                return []
//            }
//            
//            // Sort the data from most recent to least recent
//            data.sort { $0.date > $1.date }
//            
//            // Then, we will get the first n, then reverse again so that the values
//            // go from least recent to most recent
//            
//            var weights = [Weight]()
//            
//            for datum in data {
//                for weight in datum.weights {
//                    weights.append(weight)
//                }
//            }
//            
//            weights.reverse()
//            
//            exerciseWeights[exerciseName] = weights
//        }
//        
        return exerciseWeights[exerciseName]?.suffix(n) ?? []
    }
}
