//
//  CachedExerciseWeights.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/6/25.
//

import Foundation
import SwiftData

@Model
final class ExerciseWeightsCache: Identifiable {
    enum Errors: Error {
        case mismatchedExercises
        case mismatchedExerciseWeightsCaches
    }
    
    var id: UUID
    var name: String
    var weights: [Weight]
    
    init(id: UUID = UUID(), name: String, weights: [Weight] = []) {
        self.id = id
        self.name = name
        self.weights = weights
    }
    
    init(id: UUID = UUID(), of exercise: Exercise) {
        self.id = id
        self.name = exercise.name
        self.weights = []
        self.weights = {
            var _weights = [Weight]()
            for i in 0..<exercise.setsDone {
                if let weightUsed = exercise.setDetails[i].weightUsed {
                    _weights.append(weightUsed)
                }
            }
            return _weights
        }()
        print("Created a new exercise weights cache, whose weights.count = \(weights.count)")
    }
    
    /// Adds all the weights from an exercise to this instance's weights list.
    func addWeightsFrom(_ exercise: Exercise) throws {
        guard exercise.name == self.name else {
            throw Errors.mismatchedExercises
        }
        
        for i in 0..<exercise.setsDone {
            guard let weightUsed = exercise.setDetails[i].weightUsed else {
                assertionFailure("Nil weight found where one was expected.")
                return
            }
            weights.append(weightUsed)
        }
    }
    
    func addWeightsFrom(_ partialCache: ExerciseWeightsCache) throws {
        guard partialCache.name == self.name else {
            throw Errors.mismatchedExerciseWeightsCaches
        }
        
        for weight in partialCache.weights {
            weights.append(weight)
        }
    }
}

extension ExerciseWeightsCache: WatchTransferrable {
    enum CodingKeys: String {
        case id
        case name
        case weights
    }
    
    var dictionaryForm: [String: Any] {
        [
            CodingKeys.id.rawValue: id.uuidString,
            CodingKeys.name.rawValue: name,
            CodingKeys.weights.rawValue: weights.map { $0.dictionaryForm }
        ]
    }
    
    convenience init?(from dictionaryForm: [String: Any]) {
        // Enforce that weights are present and that all correctly convert
        guard let rawID = dictionaryForm[CodingKeys.id.rawValue] as? String,
              let id = UUID(uuidString: rawID),
              let name = dictionaryForm[CodingKeys.name.rawValue] as? String,
              let rawWeights = dictionaryForm[CodingKeys.weights.rawValue] as? [[String: Any]],
              let weights: [Weight] = {
                  let _weights = rawWeights.compactMap { Weight(from: $0) }
                  if _weights.count == rawWeights.count { return _weights }
                  return nil
              }()
        else {
            return nil
        }
        
        self.init(id: id, name: name, weights: weights)
    }
}
