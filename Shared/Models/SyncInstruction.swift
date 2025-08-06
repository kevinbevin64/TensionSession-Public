//
//  Payload.swift
//  GymCoach
//
//  Created by Kevin Chen on 6/28/25.
//

import Foundation
import SwiftData

@Model
final class SyncInstruction: WatchTransferrable, Identifiable {
    var id = UUID()
    
    // For ensuring that the exact same keys are used for creating and parsing the dictionary.
    enum Keys: String {
        case operation
        case payload
    }

    // The type of operation being done
    var operation: Operation

    // The contents required for the operation to succeed
    var payloadData: Data
    var payload: [String: Any] {
        get {
            return (try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any]) ?? [:]
        }
        set {
            self.payloadData = (try? JSONSerialization.data(withJSONObject: newValue)) ?? Data()
        }
    }

    init(operation: Operation, payload: [String: Any] = [:]) {
        self.operation = operation
        self.payloadData = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
    }

    var dictionaryForm: [String: Any] {
        [
            Keys.operation.rawValue: operation.rawValue,
            Keys.payload.rawValue: payload,
        ]
    }

    init?(from dictionaryForm: [String: Any]) {
        // Require a valid operation and payload
        guard let rawOperation = dictionaryForm[Keys.operation.rawValue] as? String,
            let operation = Operation(rawValue: rawOperation),
            let payload = dictionaryForm[Keys.payload.rawValue] as? [String: Any]
        else {
            return nil
        }

        self.operation = operation
        self.payloadData = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
    }
}

extension SyncInstruction: Hashable, Equatable {
    static func == (lhs: SyncInstruction, rhs: SyncInstruction) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
