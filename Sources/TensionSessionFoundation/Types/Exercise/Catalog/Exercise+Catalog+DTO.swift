//
//  Exercise+Catalog+DTO.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/23/26.
//

import Foundation

extension Exercise.Catalog {
    
    nonisolated
    public struct DTO: Codable & WatchTransferrable {
        
        public var all: [Kind]
    }

    func getDTO() -> DTO {
        
        return DTO(
            all: all
        )
    }
}
