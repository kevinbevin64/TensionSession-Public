//
//  SetDetail.swift
//  GymCoach
//
//  Created by Kevin Chen on 6/19/25.
//

import Foundation
import SwiftData

/// Represents the details of one set of an ``Exercise``
struct SetDetail: Codable {
    var repsPlanned: Int
    var repsDone: Int?
    var weightPlanned: Weight
    var weightUsed: Weight?
    
    var isCompleted: Bool {
        self.repsDone != nil && self.weightUsed != nil
    }

    init(reps: Int, weight: Weight) {
        repsPlanned = reps
        weightPlanned = weight
    }
    
    init(
        repsPlanned: Int,
        weightPlanned: Weight,
        repsDone: Int,
        weightUsed: Weight,
    ) {
        self.repsPlanned = repsPlanned
        self.weightPlanned = weightPlanned
        self.repsDone = repsDone
        self.weightUsed = weightUsed
    }
    
    mutating func fillIn(repsDone: Int, weightUsed: Weight) {
        self.repsDone = repsDone
        self.weightUsed = weightUsed
    }
}

// MARK: - For converting between an instance of SetDetail and a dictionary representation of it
extension SetDetail: WatchTransferrable {
    /// Creates a dictionary form of a Weight instance.
    var dictionaryForm: [String: Any] {
        var dictionaryForm: [String: Any] = [
            "repsPlanned": self.repsPlanned,
            "weightPlanned": self.weightPlanned.dictionaryForm,
        ]
        
        // Set optionals for repsDone and weightUsed if and only if both contain values
        if let repsDone = self.repsDone, let weightUsed = self.weightUsed {
            dictionaryForm["repsDone"] = repsDone
            dictionaryForm["weightUsed"] = weightUsed.dictionaryForm
        }

        return dictionaryForm
    }
    
    init?(from dictionary: [String: Any]) {
        guard
            // Requires non-optional repsPlanned and weightPlanned values
            let repsPlanned = dictionary["repsPlanned"] as? Int,
            let rawWeightPlanned = dictionary["weightPlanned"] as? [String: Any],
            let weightPlanned = Weight(from: rawWeightPlanned)
        else {
            print("Failed to create set detail from dictionary")
            return nil
        }
        
        // Set the non-optional values
        self.repsPlanned = repsPlanned
        self.weightPlanned = weightPlanned
        
        // Set the optional values
        if let repsDone = dictionary["repsDone"] as? Int,
           let rawWeightUsed = dictionary["weightUsed"] as? [String: Any],
           let weightUsed = Weight(from: rawWeightUsed) {
            self.repsDone = repsDone
            self.weightUsed = weightUsed
        }
    }
}

// MARK: - Hashable and Equatable
extension SetDetail: Hashable, Equatable {
//    /// The properties that create this instance's identity
//    var hashedProperties: [AnyHashable] {
//        return [
//            repsPlanned,
//            repsDone,
//            weightPlanned,
//            weightUsed
//        ]
//    }
//
//    static func == (lhs: SetDetail, rhs: SetDetail) -> Bool {
//        return lhs.hashedProperties == rhs.hashedProperties
//    }
//
//    func hash(into hasher: inout Hasher) {
//        for property in hashedProperties {
//            hasher.combine(property)
//        }
//    }
}
