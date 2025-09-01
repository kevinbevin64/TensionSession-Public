//
//  UserPreferences.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/14/25.
//

import Foundation
import SwiftData

@Model
final class UserInfo {
    var weightPreference: WeightPreference
    var weightUnit: Weight.WeightUnit { weightPreference.weightUnit }
    
    // True if the watch app was already installed by the end of the previous WatchConnectivity session
    // False otherwise
    var wasWatchAppInstalled: Bool
    
    var weightAggregationMethod: WeightAggregationMethod

    init(
        weightPreference: WeightPreference? = nil,
        wasWatchAppInstalled: Bool = false,
        weightAggregationMethod: WeightAggregationMethod = .all
    ) {
        // Use the user's preference if no weight unit is supplied.
        if let weightPreference { self.weightPreference = weightPreference }
        else { self.weightPreference = .system }
        
        self.wasWatchAppInstalled = wasWatchAppInstalled
        self.weightAggregationMethod = weightAggregationMethod
    }
    
    func edit(with reference: UserInfo) {
        self.weightPreference = reference.weightPreference
        self.wasWatchAppInstalled = reference.wasWatchAppInstalled
    }
    
    func resetWeightUnit() {
        self.weightPreference = .system
    }
    
    enum WeightPreference: String, Codable {
        case system
        case kilograms
        case pounds
        
        var weightUnit: Weight.WeightUnit {
            switch self {
            case .system: return getSystemWeightUnit()
            case .kilograms: return .kilograms
            case .pounds: return .pounds
            }
        }
    }
}

extension UserInfo: WatchTransferrable {
    enum CodingKeys: String, CodingKey {
        case weightPreference
        case wasWatchAppInstalled
        case weightAggregationMethod
    }
    
    var dictionaryForm: [String : Any] {
        [
            CodingKeys.weightPreference.rawValue: weightPreference.rawValue,
            CodingKeys.wasWatchAppInstalled.rawValue: wasWatchAppInstalled,
            CodingKeys.weightAggregationMethod.rawValue: weightAggregationMethod.rawValue,
        ]
    }
    
    convenience init?(from dictionaryForm: [String : Any]) {
        guard let rawWeightPreference = dictionaryForm[CodingKeys.weightPreference.rawValue] as? String,
              let weightPreference = WeightPreference(rawValue: rawWeightPreference),
              let wasWatchAppInstalled = dictionaryForm[CodingKeys.wasWatchAppInstalled.rawValue] as? Bool,
              let rawWeightAggregationMethod = dictionaryForm[CodingKeys.weightAggregationMethod.rawValue] as? String,
              let weightAggregationMethod = WeightAggregationMethod(rawValue: rawWeightAggregationMethod)
        else {
            return nil
        }
        self.init(
            weightPreference: weightPreference,
            wasWatchAppInstalled: wasWatchAppInstalled,
            weightAggregationMethod: weightAggregationMethod
        )
    }
}
