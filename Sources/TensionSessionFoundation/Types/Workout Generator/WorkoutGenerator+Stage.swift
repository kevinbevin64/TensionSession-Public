//
//  WorkoutGenerator+Stage.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/12/26.
//

#if os(iOS)
public extension WorkoutGenerator {
    
    enum Stage {
        
        case ready
        case active
        case done(Workout)
        case errored(Error)
    }
}
#endif
