//
//  WorkoutGenerator+Error.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
public extension WorkoutGenerator {
    
    enum Error: Swift.Error {
        
        case unavailable(UnavailableReason)
        
        case generationError(String)
        
        case decodingError(String)
    }
    
    enum UnavailableReason: String {
        
        case deviceNotEligible = "This device is not eligible."
        
        case appleIntelligenceNotEnabled = """
            Enable Apple Intelligence in \ 
            Settings to use this feature.
            """

        case modelNotReady = "The model is not ready."
        
        case other = "The model is unavailable for an unknown reason"
    }
}
#endif // os(iOS)
