//
//  Weight.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/21/26.
//

import Foundation

nonisolated
public struct Weight: Codable, Hashable, Equatable, Sendable {
    
    public var value: Double
    
    public var unit: Unit
    
    public init(_ value: Double, _ unit: Unit) {
        self.value = value
        self.unit = unit
    }
    
    public init(_ value: Double) {
        self.value = value
        self.unit = Unit.system
    }
}

public extension Weight {
    
    func converted(to targetUnit: Unit) -> Weight {
        
        let measurement = Measurement(value: self.value, unit: unit.unitMass)
        let convertedMeasurement = measurement.converted(to: targetUnit.unitMass)
        return Weight(convertedMeasurement.value, targetUnit)
    }
}
