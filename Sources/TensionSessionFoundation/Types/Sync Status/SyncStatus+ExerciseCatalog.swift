//
//  SyncStatus+ExerciseCatalog.swift
//  TensionSession
//
//  Created by Kevin on 9/23/26.
//

extension SyncStatus {
    
    enum ExerciseCatalog: Codable, WatchTransferrable {
        
        case matched
        
        case notMatched(Exercise.Catalog.DTO)
    }
}
