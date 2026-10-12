//
//  WorkoutGenerator+Error.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
extension WorkoutGenerator {
    
    enum Error: Swift.Error {
        
        case unavailable
        case generationError
    }
}
#endif // os(iOS)
