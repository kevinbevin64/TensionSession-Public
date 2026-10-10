//
//  Exercise+Catalog+WatchTransferrable.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/23/26.
//

import Foundation

extension Exercise.Catalog: WatchTransferrable {

    convenience init(fromDTO dto: DTO) {
        
        self.init()
        self.all = dto.all
    }
    
    func dictionaryForm() throws -> [String: Any] {
        
        return try getDTO().dictionaryForm()
    }
    
    convenience init(fromDictionary dictionary: [String: Any]) throws {
        
        let dto = try DTO(fromDictionary: dictionary)
        self.init(fromDTO: dto)
    }
}
