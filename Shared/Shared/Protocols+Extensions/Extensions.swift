//
//  Extensions.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/14/25.
//

import Foundation

// Adds the key-value pair if the value wraps a value. Otherwise, the dictionary remains unchanged.
extension Dictionary<String, Any> {
    mutating func optionallyAdd(_ value: Any?, forKey key: String) {
        if let value {
            self.updateValue(value, forKey: key)
        }
    }
}

extension Double {
    func roundedToNearestHalf() -> Self {
        (self * 2).rounded(.toNearestOrAwayFromZero) / 2
    }
    
    var oneDPString: String {
        return String(format: "%.1f", self)
    }
}

func devPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator: separator, terminator: terminator)
    #endif
}
