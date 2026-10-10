//
//  Companion+Outbound.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import WatchConnectivity

public extension Companion {
    
    func send(_ dictionary: [String: Any]) {
        
        #if DEBUG
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: nil
        )
        #else
        WCSession.default.transferUserInfo(
            dictionary
        )
        #endif
    }
    
    func sendInstantly(
        _ dictionary: [String: Any],
        replyHandler: (([String : Any]) -> Void)? = nil,
        errorHandler: ((any Swift.Error) -> Void)? = nil
    ) {
        
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: replyHandler,
            errorHandler: errorHandler
        )
    }
}

#if os(iOS)
public extension Companion {
    
    func addTemplateWorkout(_ workout: Workout) {
        
        do {
            
            let instruction = SyncInstruction(
                .addTemplateWorkout,
                try workout.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func editTemplateWorkout(_ workout: Workout) {
        
        do {
            
            let instruction = SyncInstruction(
                .editTemplateWorkout,
                try workout.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func deleteTemplateWorkout(_ workout: Workout) {
        
        do {
            
            let instruction = SyncInstruction(
                .deleteTemplateWorkout,
                try workout.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func editExerciseCatalog(_ catalog: Exercise.Catalog) {
        
        do {
            
            let instruction = SyncInstruction(
                .editExerciseCatalog,
                try catalog.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
}
#endif // os(iOS)

#if os(watchOS)
public extension Companion {
    
    func requestTemplateWorkoutsHashCheck() {
        
        print("Requesting template workouts hash check.")
        
        do {
            
            guard let hash = workoutManager?.getTemplateWorkoutsHash() else {
                return
            }
            
            let instruction = SyncInstruction(
                .templateWorkoutsHashCheckRequest,
                try hash.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            sendInstantly(
                rawInstruction,
                replyHandler: { dictionary in
                    print("WATCH RECEIVED REPLY DICTIONARY!!!")
                    self.process(dictionary)
                }
            )
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func requestExerciseCatalogHashCheck() {
        
        print("Requesting exercise catalog hash check.")
        
        do {
            
            guard let hash = getExerciseCatalogDTO?().getHash() else {
                return
            }
            
            let instruction = SyncInstruction(
                .exerciseCatalogHashCheckRequest,
                try hash.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            sendInstantly(
                rawInstruction,
                replyHandler: { dictionary in
                    print("WATCH RECEIVED REPLY DICTIONARY!!!")
                    self.process(dictionary)
                }
            )
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func requestAddCustomExerciseKind() throws {
        
        print("Requesting add custom exercise kind")
        
        do {
            
            let instruction = SyncInstruction(
                operationOnly: .addCustomExerciseKindRequest
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            var instantSendFailed: Bool = false
            
            sendInstantly(
                rawInstruction,
                errorHandler: { error in
                    instantSendFailed = true
                }
            )
            
            if instantSendFailed {
                throw Error.failedAddCustomExerciseRequest
            }
            
        } catch {
            
            print("Error: \(error.localizedDescription)")
            
            throw Error.failedAddCustomExerciseRequest
        }
    }
}
#endif
