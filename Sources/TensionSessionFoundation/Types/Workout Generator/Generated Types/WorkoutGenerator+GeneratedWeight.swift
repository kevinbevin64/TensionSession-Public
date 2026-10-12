//
//  WorkoutGenerator+GeneratedWeight.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
import FoundationModels

extension WorkoutGenerator {
    
    @Generable
    public struct GeneratedWeight {
        
        public let wholeNumberValue: Int
        
        public let addHalf: Bool
        
        @Generable
        public enum Unit {
            case kilograms
            case pounds
        }
        
        public let unit: Unit
    }
}
#endif
