//
//  Exercise+Catalog.swift
//  TensionSession
//
//  Created by Kevin on 9/17/26.
//

import Foundation
import SwiftData

extension Exercise {
    
    @Model
    public final class Catalog {
        
        public var all: [Kind]
        
        init() {
            self.all = [
                Kind("Ab Wheel", isBuiltIn: true),
                Kind("Arnold Press", isBuiltIn: true),
                Kind("Back Extension", isBuiltIn: true),
                Kind("Barbell Row", isBuiltIn: true),
                Kind("Battle Rope", isBuiltIn: true),
                Kind("Bench Press", isBuiltIn: true),
                Kind("Bench Press (Close-Grip)", isBuiltIn: true),
                Kind("Bench Press (Decline)", isBuiltIn: true),
                Kind("Bench Press (Incline)", isBuiltIn: true),
                Kind("Biceps Curl", isBuiltIn: true),
                Kind("Bicycle Crunch", isBuiltIn: true),
                Kind("Bird Dog", isBuiltIn: true),
                Kind("Box Jump", isBuiltIn: true),
                Kind("Bulgarian Split Squat", isBuiltIn: true),
                Kind("Burpee", isBuiltIn: true),
                Kind("Cable Crunch", isBuiltIn: true),
                Kind("Cable Curl", isBuiltIn: true),
                Kind("Cable Fly", isBuiltIn: true),
                Kind("Cable Row", isBuiltIn: true),
                Kind("Calf Raise", isBuiltIn: true),
                Kind("Calf Raise (Seated)", isBuiltIn: true),
                Kind("Chest Fly", isBuiltIn: true),
                Kind("Chest Press", isBuiltIn: true),
                Kind("Chin-Up", isBuiltIn: true),
                Kind("Clean", isBuiltIn: true),
                Kind("Clean And Jerk", isBuiltIn: true),
                Kind("Concentration Curl", isBuiltIn: true),
                Kind("Crunch", isBuiltIn: true),
                Kind("Dead Bug", isBuiltIn: true),
                Kind("Deadlift", isBuiltIn: true),
                Kind("Deadlift (Romanian)", isBuiltIn: true),
                Kind("Deadlift (Stiff-Leg)", isBuiltIn: true),
                Kind("Deadlift (Sumo)", isBuiltIn: true),
                Kind("Dip", isBuiltIn: true),
                Kind("Dumbbell Bench Press", isBuiltIn: true),
                Kind("Dumbbell Row", isBuiltIn: true),
                Kind("Face Pull", isBuiltIn: true),
                Kind("Farmer Carry", isBuiltIn: true),
                Kind("Front Raise", isBuiltIn: true),
                Kind("Glute Bridge", isBuiltIn: true),
                Kind("Glute Kickback", isBuiltIn: true),
                Kind("Good Morning", isBuiltIn: true),
                Kind("Hammer Curl", isBuiltIn: true),
                Kind("Hanging Leg Raise", isBuiltIn: true),
                Kind("Hip Abduction", isBuiltIn: true),
                Kind("Hip Adduction", isBuiltIn: true),
                Kind("Hip Thrust", isBuiltIn: true),
                Kind("Incline Curl", isBuiltIn: true),
                Kind("Jump Rope", isBuiltIn: true),
                Kind("Kettlebell Swing", isBuiltIn: true),
                Kind("Lat Pulldown", isBuiltIn: true),
                Kind("Lateral Lunge", isBuiltIn: true),
                Kind("Lateral Raise", isBuiltIn: true),
                Kind("Leg Curl (Lying)", isBuiltIn: true),
                Kind("Leg Curl (Seated)", isBuiltIn: true),
                Kind("Leg Extension", isBuiltIn: true),
                Kind("Leg Press", isBuiltIn: true),
                Kind("Leg Raise", isBuiltIn: true),
                Kind("Lunge", isBuiltIn: true),
                Kind("Mountain Climber", isBuiltIn: true),
                Kind("Muscle-Up", isBuiltIn: true),
                Kind("Nordic Hamstring Curl", isBuiltIn: true),
                Kind("Overhead Press", isBuiltIn: true),
                Kind("Overhead Triceps Extension", isBuiltIn: true),
                Kind("Pallof Press", isBuiltIn: true),
                Kind("Pec Deck", isBuiltIn: true),
                Kind("Pendlay Row", isBuiltIn: true),
                Kind("Plank", isBuiltIn: true),
                Kind("Preacher Curl", isBuiltIn: true),
                Kind("Pull-Up", isBuiltIn: true),
                Kind("Pullover", isBuiltIn: true),
                Kind("Push Press", isBuiltIn: true),
                Kind("Push-Up", isBuiltIn: true),
                Kind("Rear Delt Fly", isBuiltIn: true),
                Kind("Reverse Curl", isBuiltIn: true),
                Kind("Reverse Lunge", isBuiltIn: true),
                Kind("Rowing Machine", isBuiltIn: true),
                Kind("Russian Twist", isBuiltIn: true),
                Kind("Seated Row", isBuiltIn: true),
                Kind("Shrug", isBuiltIn: true),
                Kind("Side Plank", isBuiltIn: true),
                Kind("Sit-Up", isBuiltIn: true),
                Kind("Skull Crusher", isBuiltIn: true),
                Kind("Sled Push", isBuiltIn: true),
                Kind("Snatch", isBuiltIn: true),
                Kind("Split Squat", isBuiltIn: true),
                Kind("Squat", isBuiltIn: true),
                Kind("Squat (Front)", isBuiltIn: true),
                Kind("Squat (Goblet)", isBuiltIn: true),
                Kind("Squat (Hack)", isBuiltIn: true),
                Kind("Step-Up", isBuiltIn: true),
                Kind("T-Bar Row", isBuiltIn: true),
                Kind("Thruster", isBuiltIn: true),
                Kind("Triceps Extension", isBuiltIn: true),
                Kind("Triceps Kickback", isBuiltIn: true),
                Kind("Triceps Pushdown", isBuiltIn: true),
                Kind("Upright Row", isBuiltIn: true),
                Kind("Walking Lunge", isBuiltIn: true),
                Kind("Wall Ball", isBuiltIn: true),
                Kind("Wrist Curl", isBuiltIn: true)
            ]
        }
        
        public func contains(_ name: String) -> Bool {
            return all.contains(where: { $0.name == name })
        }
        
        func remove(_ name: String) {
            
            assert({
                guard let item = all.first(where: { $0.name == name }) else {
                    return false
                }
                if item.isBuiltIn {
                    return false
                }
                return true
            }())
            
            all.removeAll(where: { $0.name == name })
        }
        
        public func existingNamesSimilar(
            to trimmedAndNeatenedName: String,
            among kinds: [Kind]
        ) -> [Kind] {
            
            let query = trimmedAndNeatenedName.lowercased()
            guard query.isEmpty == false else { return [] }
            
            let ranked = kinds.compactMap { kind -> (kind: Kind, score: Int)? in
                
                let candidate = kind.name.lowercased()
                
                let source = Array(query)
                let target = Array(candidate)
                
                var firstMatchingLetterIndex = min(source.count, target.count)
                
                for index in 0..<firstMatchingLetterIndex {
                    if source[index] == target[index] {
                        firstMatchingLetterIndex = index
                        break
                    }
                }
                
                var editDistance = target.count
                
                if source.isEmpty == false {
                    
                    if target.isEmpty {
                        editDistance = source.count
                    } else {
                        
                        var previous = Array(0...target.count)
                        var current = Array(repeating: 0, count: target.count + 1)
                        
                        for i in 1...source.count {
                            
                            current[0] = i
                            
                            for j in 1...target.count {
                                
                                let substitution = previous[j - 1] + (source[i - 1] == target[j - 1] ? 0 : 1)
                                let insertion = current[j - 1] + 1
                                let deletion = previous[j] + 1
                                current[j] = min(substitution, insertion, deletion)
                            }
                            
                            swap(&previous, &current)
                        }
                        
                        editDistance = previous[target.count]
                    }
                }
                
                var score = editDistance + firstMatchingLetterIndex
                
                if candidate == query {
                    score = -1
                } else if candidate.hasPrefix(query) || query.hasPrefix(candidate) {
                    score = firstMatchingLetterIndex
                }
                
                return (kind, score)
            }
            .sorted { $0.score < $1.score }
            
            return Array(ranked.prefix(8).map { $0.kind })
        }
    }
}

// MARK: Main methods

public extension Exercise.Catalog {
    
    func existing(trimmedAndNeatened trimmedAndNeatenedName: String) throws -> Kind {
        
        guard let kind = all.first(where: { $0.name == trimmedAndNeatenedName }) else {
            throw Error.nameDoesNotExist
        }
        
        return kind
    }
    
    func addCustom(
        trimmedAndNeatened trimmedAndNeatenedName: String
    ) throws {
        
        guard Exercise.Catalog.Kind.isValid(trimmedAndNeatenedName) else {
            throw Exercise.Catalog.Kind.Error.invalidTrimmedAndNeatenedName
        }
        
        guard !all.contains(where: { $0.name == trimmedAndNeatenedName }) else {
            throw Error.nameAlreadyExists
        }
        
        let customKind = Kind(trimmedAndNeatenedName, isBuiltIn: false)
        all = all + [customKind]
    }
}
