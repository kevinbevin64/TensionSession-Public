//
//  WorkoutGenerator+GeneratedEquipment.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
import FoundationModels

extension WorkoutGenerator {
    
    @Generable
    public enum GeneratedEquipment: String, Codable, CaseIterable {
        
        case dumbbell
        case barbell
        case kettlebell
        case machine
        case cable
        case bodyweight
    }
}
#endif
