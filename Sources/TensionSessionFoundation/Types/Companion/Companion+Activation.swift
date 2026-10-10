//
//  Companion+Activation.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import WatchConnectivity

public extension Companion {
    
    func activate() {
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Swift.Error)?
    ) {
        
        switch activationState {
        
        case .activated:
            print("Activation completed, ending with activated state.")
            #if os(watchOS)
            DispatchQueue.main.async { [weak self] in
                self?.sendInstantly(["Hello there": "HELLO?"])
                self?.startTimer(.seconds(3)) {
                    self?.requestTemplateWorkoutsHashCheck()
                }
                
                guard let self else { return }
                
                self.requestExerciseCatalogHashCheckSchedule = {
                    let schedule = Schedule { [weak self] in
                        self?.requestExerciseCatalogHashCheck()
                    }
                    schedule.invoke(after: .seconds(3))
                    return schedule
                }()
            }
            #endif
            
        case .inactive:
            print("Activation completed, ending with inactive state.")
            
        case .notActivated:
            print("Activation completed, ending with notActivated state.")
        
        @unknown default:
            print("Unknown case")
        }
        
        if let error {
            print("Error: \(error.localizedDescription)")
        } else {
            print("Error: nil")
        }
        
        updateStateProperties(session)
    }
}

#if os(iOS)
public extension Companion {
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        
        updateStateProperties(session)
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        
        updateStateProperties(session)
    }
}
#endif // os(iOS)

#if os(watchOS)
extension Companion {


}
#endif // os(watchOS)
