//
//  WorkoutGenerator+GeneratedWorkout.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
import FoundationModels

extension WorkoutGenerator {
    
    @Generable
    public struct GeneratedWorkout {
        
        public let name: String
        
        public let exercises: [GeneratedExercise]
        
        public let description: String
    }
}
#endif
