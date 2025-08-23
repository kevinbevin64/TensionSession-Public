//
//  Exercise.swift
//  GymCoach
//
//  Created by Kevin Chen on 6/19/25.
//

import Foundation
import SwiftData

@Model
final class Exercise: Identifiable {
    var id: UUID
    var name: String
    var setsPlanned: Int
    var setsDone: Int
    var setDetails: [SetDetail] // Rep and weight details
    var dateAdded: Date // This value is not transferred in WatchTransferrable
    
    init(
        id: UUID = UUID(),
        name: String,
        sets setsPlanned: Int,
        reps repsPlanned: Int,
        weight weightPlanned: Weight,
        dateAdded: Date = Date()
    ) {
        assert(setsPlanned > 0, "Number of sets must be positive")
        self.id = id
        self.name = name
        self.setsPlanned = setsPlanned
        self.setsDone = 0
        self.setDetails = []
        self.dateAdded = dateAdded
        for _ in 1...setsPlanned {
            setDetails.append(SetDetail(reps: repsPlanned, weight: weightPlanned))
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        setsPlanned: Int,
        setsDone: Int = 0,
        setDetails: [SetDetail],
        dateAdded: Date = Date()
    ) {
        assert(setsPlanned > 0, "Number of sets must be positive")
        self.id = id
        self.name = name
        self.setsPlanned = setsPlanned
        self.setsDone = setsDone
        self.setDetails = setDetails
        self.dateAdded = dateAdded
    }
    
    init(cleanCopyOf exercise: Exercise) {
        // Re-used values
        self.name = exercise.name
        self.setsPlanned = exercise.setsPlanned
        self.dateAdded = exercise.dateAdded
        
        // Cleaned
        self.setDetails = exercise.setDetails.map { SetDetail(reps: $0.repsPlanned, weight: $0.weightPlanned) }
        
        // New
        self.id = UUID()
        self.setsDone = 0
    }
    
    func addSet(repsDone: Int, weightUsed: Weight) {
        // Add SetDetail instance if array is full
        if setsDone == setDetails.count {
            // Copy repsPlanned and weightPlanned values from previous set
            if let prevRepsPlanned = setDetails.last?.repsPlanned,
               let prevWeightPlanned = setDetails.last?.weightPlanned {
                setDetails.append(SetDetail(
                    repsPlanned: prevRepsPlanned,
                    weightPlanned: prevWeightPlanned,
                    repsDone: repsDone,
                    weightUsed: weightUsed
                ))
            }
        } else {
            setDetails[setsDone].fillIn(repsDone: repsDone, weightUsed: weightUsed)
        }
        setsDone += 1
    }
}

extension Exercise: WatchTransferrable {
    enum CodingKeys: String {
        case id
        case name
        case setsPlanned
        case setsDone
        case setDetails
        case dateAdded
    }
    
    var dictionaryForm: [String: Any] {
        let isoFormatter = ISO8601DateFormatter()
        return [
            CodingKeys.id.rawValue: id.uuidString,
            CodingKeys.name.rawValue: name,
            CodingKeys.setsPlanned.rawValue: setsPlanned,
            CodingKeys.setsDone.rawValue: setsDone,
            CodingKeys.setDetails.rawValue: setDetails.map { $0.dictionaryForm },
            CodingKeys.dateAdded.rawValue: isoFormatter.string(from: dateAdded)
        ]
    }
    
    convenience init?(from dictionary: [String: Any]) {
        guard
            let uuidString = dictionary[CodingKeys.id.rawValue] as? String,
            let id = UUID(uuidString: uuidString),
            let name = dictionary[CodingKeys.name.rawValue] as? String,
            let setsPlanned = dictionary[CodingKeys.setsPlanned.rawValue] as? Int,
            let setsDone = dictionary[CodingKeys.setsDone.rawValue] as? Int,
            let rawSetDetails = dictionary[CodingKeys.setDetails.rawValue] as? [[String: Any]],
            let setDetails = {
                // Return the constructed sets if they all went through
                // Otherwise, return nil, failing the guard
                let _sets = rawSetDetails.compactMap { SetDetail(from: $0) }
                return _sets.count == rawSetDetails.count ? _sets : nil
            }(),
            let dateAddedString = dictionary[CodingKeys.dateAdded.rawValue] as? String,
            let dateAdded = ISO8601DateFormatter().date(from: dateAddedString)
        else {
            print("Failed to create exercise from dictioanry")
            return nil
        }
        
        self.init(
            id: id,
            name: name,
            setsPlanned: setsPlanned,
            setsDone: setsDone,
            setDetails: setDetails,
            dateAdded: dateAdded
        )
    }
}

extension Exercise: Hashable, Equatable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {

            hasher.combine(id)
        
    }
}
