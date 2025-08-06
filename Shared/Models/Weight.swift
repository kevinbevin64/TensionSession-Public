//
// Weight.swift
// GymCoach
//
// Created by Kevin Chen a long time ago. 
//

import Foundation

struct Weight: Codable, Hashable {
    var value: Double
    var unit: WeightUnit
    var measurement: Measurement<UnitMass> { Measurement(value: value, unit: unit.unitMass) }
    
    enum WeightUnit: String, Codable {
        case kilograms = "kilograms"
        case pounds = "pounds"

        var unitMass: UnitMass {
            unitMassEquivalent(of: self)
        }
    }
    
    init(value: Double, unit: WeightUnit) {
        self.value = value
        self.unit = unit
    }
    
    init(_ value: Double, in unit: WeightUnit) {
        self.init(value: value, unit: unit)
    }
    
    func convert(to unit: UnitMass) -> Weight {
        Weight(
            value: measurement.converted(to: unit).value,
            unit: unit == .kilograms ? .kilograms : .pounds
        )
    }
    
    func convert(to unit: WeightUnit) -> Weight {
        convert(to: unitMassEquivalent(of: unit))
    }
}

// MARK: Converting WeightUnit and UnitMass

func unitMassEquivalent(of unit: Weight.WeightUnit) -> UnitMass {
    switch unit {
    case .kilograms: return .kilograms
    case .pounds: return .pounds
    }
}

func weightUnitEquivalent(of unit: UnitMass) -> Weight.WeightUnit {
    switch unit {
    case .kilograms: return .kilograms
    case .pounds: return .pounds
    default: preconditionFailure("Unsupported unit: \(unit)")
    }
}

func getSystemWeightUnit() -> Weight.WeightUnit {
    weightUnitEquivalent(of: getSystemWeightUnit())
}

func getSystemWeightUnit() -> UnitMass {
    UnitMass(forLocale: .autoupdatingCurrent)
}

// MARK: Arithmetic on Weights

extension Weight: AdditiveArithmetic, Equatable {
    static var zero: Weight {
        return Weight(0, in: getSystemWeightUnit())
    }
    
    static func + (lhs: Weight, rhs: Weight) -> Weight {
        let newMeasurement = lhs.measurement + rhs.measurement
        return Weight(newMeasurement.value, in: weightUnitEquivalent(of: newMeasurement.unit))
    }
    
    static func - (lhs: Weight, rhs: Weight) -> Weight {
        let newMeasurement = lhs.measurement - rhs.measurement
        return Weight(newMeasurement.value, in: weightUnitEquivalent(of: newMeasurement.unit))
    }
    
    static func == (lhs: Weight, rhs: Weight) -> Bool {
        return lhs.measurement == rhs.measurement
    }
}

// MARK: Comparable

extension Weight: Comparable {
    static func < (lhs: Weight, rhs: Weight) -> Bool {
        return lhs.measurement < rhs.measurement
    }
}

// MARK: WatchTransferrable

extension Weight: WatchTransferrable {
    enum CodingKeys: String, CodingKey {
        case value
        case unit
    }
    
    var dictionaryForm: [String : Any] {
        [
            CodingKeys.value.rawValue: self.value,
            CodingKeys.unit.rawValue: self.unit.rawValue
        ]
    }

    init?(from dictionaryForm: [String: Any]) {
        guard
            let value = dictionaryForm[CodingKeys.value.rawValue] as? Double,
            let unitRaw = dictionaryForm[CodingKeys.unit.rawValue] as? String,
            let unit = WeightUnit(rawValue: unitRaw)
        else {
            return nil
        }
        self.init(value: value, unit: unit)
    }
}

// MARK: CustomStringConvertible

extension Weight: CustomStringConvertible {
    var description: String {
        "\(value.oneDPString) \(unit.unitMass.symbol)"
    }
}
