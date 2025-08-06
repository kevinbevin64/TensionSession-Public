//
//  Workout.swift
//  GymCoach
//
//  Created by Kevin Chen on 6/19/25.
//

import Foundation
import Observation
import SwiftData

// Represents a collection of exercises that are all done in the same session (e.g. Leg Day)
@Model
final class Workout: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var isTemplate: Bool // A workout is either a template or historical
    // When a workout is transferred from phone to watch as a template, the watch will generate a
    // new value for dateAdded. When a workout completed on watch is completed and sent back to
    // phone, the date added value no longer matters, because historical workouts use their start
    // and end times for sorting. This value is used by template workouts for sorting in the UI.
    var dateAdded: Date
    var startTime: Date?
    var endTime: Date?
    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise]

    enum Status {
        case notStarted
        case inProgress
        case completed
    }

    var status: Status {
        if startTime == nil {
            return .notStarted
        } else if endTime == nil {
            return .inProgress
        } else {
            return .completed
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        isTemplate: Bool = true,
        dateAdded: Date = Date(),
        startTime: Date? = nil,
        endTime: Date? = nil,
        exercises: [Exercise] = [],
    ) {
        self.id = id
        self.name = name
        self.isTemplate = isTemplate
        self.dateAdded = dateAdded
        self.startTime = startTime
        self.endTime = endTime
        self.exercises = exercises
    }

    init(cleanCopyOf workout: Workout) {
        // Copied properties
        self.name = workout.name
        self.isTemplate = workout.isTemplate
        self.dateAdded = workout.dateAdded
        self.exercises = workout.exercises.map { Exercise(cleanCopyOf: $0) }

        // New properties
        self.id = UUID()
        self.startTime = nil
        self.endTime = nil
    }

    func add(_ exercise: Exercise) {
        exercises.append(exercise)
    }

    func start() {
        startTime = Date()
    }

    func end() {
        endTime = Date()
        isTemplate = false
    }

    func edit(with reference: Workout) {
        self.id = reference.id
        self.name = reference.name
        self.isTemplate = reference.isTemplate
        self.dateAdded = reference.dateAdded
        self.startTime = reference.startTime
        self.endTime = reference.endTime
        self.exercises = reference.exercises
    }
}

// MARK: - For converting between an instance and its dictionary representation
extension Workout: WatchTransferrable {
    enum CodingKeys: String {
        case id // non-optional
        case name // non-optional
        case isTemplate // non-optional
//        case dateAdded // non-optional
        case startTime
        case endTime
        case exercises // non-optional
    }

    var dictionaryForm: [String: Any] {
        // Non-optional values
        var dict: [String: Any] = [
            CodingKeys.id.rawValue: id.uuidString,
            CodingKeys.name.rawValue: name,
            CodingKeys.isTemplate.rawValue: isTemplate,
            CodingKeys.exercises.rawValue: exercises.map { $0.dictionaryForm },
        ]

        // Add optional values if they contain values
        dict.optionallyAdd(startTime, forKey: CodingKeys.startTime.rawValue)
        dict.optionallyAdd(endTime, forKey: CodingKeys.endTime.rawValue)

        return dict
    }

    // Create a Workout instance from its dictionary representation
    convenience init?(from dictionary: [String: Any]) {
        guard
            let uuidString = dictionary[CodingKeys.id.rawValue] as? String,
            let id = UUID(uuidString: uuidString),
            let name = dictionary[CodingKeys.name.rawValue] as? String,
            let isTemplate = dictionary[CodingKeys.isTemplate.rawValue] as? Bool,
            let rawExercises = dictionary[CodingKeys.exercises.rawValue] as? [[String: Any]],
            let exercises: [Exercise] = {
                // Requires that all exercises can be fully formed
                var _exercises = [Exercise]()
                for exercise in rawExercises {
                    if let newExercise = Exercise(from: exercise) {
                        _exercises.append(newExercise)
                    } else {
                        return nil
                    }
                }
                return _exercises
            }()
        else {
            print("Failed to create workout from the dictionary")
            return nil
        }

        self.init(
            id: id,
            name: name,
            isTemplate: isTemplate,
            startTime: dictionary[CodingKeys.startTime.rawValue] as? Date,
            endTime: dictionary[CodingKeys.endTime.rawValue] as? Date,
            exercises: exercises
        )
    }
}

// MARK: - Hashable and Equatable
extension Workout: Hashable, Equatable {
    var hashedProperties: [AnyHashable] {
        return [id]
    }

    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.hashedProperties == rhs.hashedProperties
    }

    func hash(into hasher: inout Hasher) {
        for property in hashedProperties {
            hasher.combine(property)
        }
    }
}
