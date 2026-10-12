//
//  WorkoutGenerator+Error.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
public extension WorkoutGenerator {
    
    enum Error: Swift.Error {
        
        case generationError
    }
}
#endif // os(iOS)
