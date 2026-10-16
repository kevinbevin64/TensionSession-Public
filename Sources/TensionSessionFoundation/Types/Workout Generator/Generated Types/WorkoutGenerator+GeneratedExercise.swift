//
//  WorkoutGenerator+GeneratedExercise.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
import FoundationModels

extension WorkoutGenerator {
    
    @Generable
    public struct GeneratedExercise {
        
        public let kind: String
        
        public let equipment: GeneratedEquipment
        
        public let setsPlanned: Int
        
        public let repsPlanned: Int
        
        public let weightPlanned: GeneratedWeight
    }
}
#endif
