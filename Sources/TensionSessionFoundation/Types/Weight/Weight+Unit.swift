//
//  Weight+Unit.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import Foundation

nonisolated
public extension Weight {
    
    nonisolated enum Unit: String, Codable, Sendable {
        
        case kilograms
        case pounds
        
        public var displayName: (singular: String, plural: String) {
            switch self {
            case .kilograms: ("kg", "kg")
            case .pounds: ("lb", "lbs")
            }
        }
        
        public var unitMass: UnitMass {
            switch self {
            case .kilograms: return .kilograms
            case .pounds: return .pounds
            }
        }
        
        private static func from(_ unitMass: UnitMass) -> Unit {
            switch unitMass {
            case .pounds: return .pounds
            default: return .kilograms
            }
        }
        
        public static var system: Unit {
            Unit.from(UnitMass(forLocale: .autoupdatingCurrent))
        }
    }
}
