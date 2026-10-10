//
//  Exercise+Catalog+Hash.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/23/26.
//

import CryptoKit
import Foundation

extension Exercise.Catalog.DTO {
    
    nonisolated
    public struct Hash: Codable, Equatable, WatchTransferrable {
        
        public var digest: Data
        
        public init(digest: Data) {
            self.digest = digest
        }
        
        public var hexString: String {
            digest.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    public func getHash() -> Hash {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try? encoder.encode(self)
        let digest = Data(SHA256.hash(data: data ?? Data()))
        
        return Hash(digest: digest)
    }
}
