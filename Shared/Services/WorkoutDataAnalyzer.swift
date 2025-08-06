//
//  File.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/22/25.
//

import Foundation

@MainActor
final class WorkoutDataAnalyzer: WorkoutDataAnalyzerProtocol {
    var dataDelegate: DataDelegate
    
    init(dataDelate: DataDelegate) {
        self.dataDelegate = dataDelate
    }
    
    func weightTrendFor(
        exerciseOfName exerciseName: String,
        aggregateUsing method: WeightAggregationMethod = .all,
        limitTo numOfWeightValues: Int
    ) -> [Weight] {
        // The weight unit that all weights in the returned array will share.
        // It equals the most recently used weightUnit for that exercise.
        var weightUnit: Weight.WeightUnit?
        
        // The returned weights
        var weights = [Weight]()
        
        // The n most recent completed/historical workouts
        let historicalWorkouts = dataDelegate.historicalWorkouts.prefix(numOfWeightValues)
        
        for workout in historicalWorkouts {
            // Order may change spontaneously and unpredictably. Sorted for a stable and
            // consistent ordering.
            let sortedExercises = workout.exercises.sorted { $0.dateAdded < $1.dateAdded }
            
            // Determine if an exercise with the specified name exists in the workout
            if let exerciseIndex = sortedExercises.firstIndex(where: { $0.name == exerciseName }) {
                let exercise = sortedExercises[exerciseIndex]
                let completedSetDetails = exercise.setDetails.prefix(exercise.setsDone)
                let count = completedSetDetails.count
                
                switch method {
                
                case .all:
                    // Only go through the first `exercise.setsDone` sets.
                    // Sets after that have nil weightUsed values
                    for setDetail in completedSetDetails {
                        var weightUsed = setDetail.weightUsed!
                        if let weightUnit {
                            if weightUsed.unit != weightUnit { // Convert if necessary
                                weightUsed = weightUsed.convert(to: unitMassEquivalent(of: weightUnit))
                            }
                        } else {
                            weightUnit = weightUsed.unit
                        }
                        weights.append(weightUsed)
                    }
                    
                case .median:
                    let sortedCompletedSetDetails = completedSetDetails.sorted {
                        $0.weightUsed!.measurement < $1.weightUsed!.measurement
                    }
                    
                    // Determine the median
                    let median: Weight
                    if count % 2 == 0 { // even size
                        // This formula works even if the size is odd, but I've used if
                        // statements to keep intent clear.
                        let summedCenterWeight = (
                            sortedCompletedSetDetails[count / 2].weightUsed!
                            + sortedCompletedSetDetails[(count - 1) / 2].weightUsed!
                        )
                        median = Weight(summedCenterWeight.value / 2, in: summedCenterWeight.unit)
                    } else { // odd size
                        median = sortedCompletedSetDetails[count / 2].weightUsed!
                    }
                    weights.append(median)
                    
                case .average:
                    var sum: Weight = .zero
                    for setDetail in completedSetDetails { sum += setDetail.weightUsed! }
                    weights.append(Weight(sum.value / Double(count), in: sum.unit))
                    
                case .max:
                    // The set containing the maximum weight
                    let maxSetDetail = completedSetDetails.max { $0.weightUsed! > $1.weightUsed! }
                    if let maxWeight = maxSetDetail?.weightUsed {
                        weights.append(maxWeight)
                    }
                    
                case .min:
                    // The set containing the minimum weight
                    let minSetDetail = completedSetDetails.max { $0.weightUsed! < $1.weightUsed! }
                    if let minWeight = minSetDetail?.weightUsed {
                        weights.append(minWeight)
                    }
                    
                    
                }
            }
            if weightUnit == nil { assertionFailure("WeightUnit should not be nil by this point.") }
        }
        return weights
    }
}
