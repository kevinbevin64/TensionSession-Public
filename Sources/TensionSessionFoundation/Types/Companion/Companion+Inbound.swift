//
//  Companion+Inbound.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import WatchConnectivity

// MARK: Both iOS and watchOS

public extension Companion {
    
    nonisolated
    func process(_ dictionary: [String: Any]) {
        
        do {
            let instruction = try SyncInstruction(fromDictionary: dictionary)
            process(instruction)
        } catch {
            print("Failed to create instruction")
        }
    }
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        
        print("Received message: \(message)")
        
        process(message)
    }
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        process(userInfo)
    }
}

// MARK: watchOS

#if os(watchOS)
public extension Companion {
    
    @MainActor
    func receiveNewTemplate(_ payload: [String: Any]) {
        
        do {
            
            let newTemplate = try Workout(fromDictionary: payload)
            workoutManager?.addWorkout(newTemplate)
            
        } catch {
            
            print("Failed to create workout from dicationary")
            
        }
    }
    
    @MainActor
    func receiveEditedTemplate(_ payload: [String: Any]) {
        
        do {
            
            let newTemplate = try Workout(fromDictionary: payload)
            workoutManager?.editTemplate(accordingTo: newTemplate)
            
        } catch {
            
            print("Failed to create workout from dicationary")
            
        }
    }
    
    @MainActor
    func receiveTemplateToBeDeleted(_ payload: [String: Any]) {
        
        do {
            
            let workout = try Workout(fromDictionary: payload)
            workoutManager?.deleteTemplate(workout)
            
        } catch {
            
            print("Failed to create workout from dicationary")
            
        }
    }
    
    @MainActor
    func receiveTemplateWorkoutsHashCheckReply(_ payload: [String: Any]) {
        
        print("RECEIVED REPLY!!!")
        
        do {
            
            let syncStatus = try SyncStatus.TemplateWorkouts(fromDictionary: payload)
            
            switch syncStatus {
                
            case .matched:
                print("Matched")
                
            case .notMatched(let workouts):
                print("Did not match")
                workoutManager?.overwriteTemplates(workouts.map { Workout(fromDTO: $0) })
                
            }
            
        } catch {
            
            print("Failed to create workout from dicationary")
            
        }
    }
    
    @MainActor
    func receiveExerciseCatalogHashCheckReply(_ payload: [String: Any]) {
        
        print("RECEIVED REPLY!!!")
        
        do {
            
            let syncStatus = try SyncStatus.ExerciseCatalog(fromDictionary: payload)
            
            switch syncStatus {
                
            case .matched:
                print("Matched")
                
            case .notMatched(let catalogDTO):
                print("Did not match")
                editCatalog?(catalogDTO)
                
            }
            
        } catch {
            
            print("Failed to create workout from dicationary")
            
        }
    }
    
    @MainActor
    func receiveEditedCatalogDTO(_ payload: [String: Any]) {
        
        do {
            
            let catalogDTO = try Exercise.Catalog.DTO(fromDictionary: payload)
            editCatalog?(catalogDTO)
            
        } catch {
            
            print("Failed to create workout from dicationary")

        }
    }
    
    nonisolated
    func process(_ syncInstruction: SyncInstruction) {
        
        DispatchQueue.main.async { [weak self] in
            
            switch syncInstruction.operation {
            
            case .addTemplateWorkout:
                self?.receiveNewTemplate(syncInstruction.payload)
                
            case .editTemplateWorkout:
                self?.receiveEditedTemplate(syncInstruction.payload)
                
            case .deleteTemplateWorkout:
                self?.receiveTemplateToBeDeleted(syncInstruction.payload)
                
            case .templateWorkoutsHashCheckReply:
                self?.receiveTemplateWorkoutsHashCheckReply(syncInstruction.payload)
                
            case .exerciseCatalogHashCheckReply:
                self?.receiveExerciseCatalogHashCheckReply(syncInstruction.payload)
                
            case .editExerciseCatalog:
                self?.receiveEditedCatalogDTO(syncInstruction.payload)
                
            default:
                assertionFailure()
                
            }
        }
    }
}
#endif // os(watchOS)

// MARK: iOS

#if os(iOS)
public extension Companion {
    
    func receiveTemplateWorkoutsHashCheckRequest(
        _ payload: [String: any Sendable]
    ) -> [String: any Sendable] {
        
        print("Received check request!")
        
        do {
            
            let watchHash = try WorkoutManager.TemplateWorkoutsHash(
                fromDictionary: payload
            )
            guard let phoneHash = workoutManager?.getTemplateWorkoutsHash() else { return [:] } // FIXME:
            
            let syncStatus: SyncStatus.TemplateWorkouts
            
            if watchHash == phoneHash {
                syncStatus = .matched
            } else {
                let templateDTOs = workoutManager?.sortedTemplates.map { $0.getDTO() }
                syncStatus = .notMatched(templateDTOs ?? [])
            }
            
            let instruction = SyncInstruction(
                .templateWorkoutsHashCheckReply,
                try syncStatus.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            return rawInstruction as! [String: any Sendable]
            
        } catch {
            
            print("Failed to create workout from dicationary")
            return [:]
        }
    }
    
    func receiveExerciseCatalogHashCheckRequest(
        _ payload: [String: any Sendable]
    ) -> [String: any Sendable] {
        
        print("Received check request!")
        
        do {
            
            let watchHash = try Exercise.Catalog.DTO.Hash(
                fromDictionary: payload
            )
            guard let catalogDTO = getExerciseCatalogDTO?() else { return [:] }
            
            let syncStatus: SyncStatus.ExerciseCatalog
            
            if watchHash == catalogDTO.getHash() {
                syncStatus = .matched
            } else {
                syncStatus = .notMatched(catalogDTO)
            }
            
            let instruction = SyncInstruction(
                .exerciseCatalogHashCheckReply,
                try syncStatus.dictionaryForm()
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            return rawInstruction as! [String: any Sendable]
            
        } catch {
            
            print("Failed to create workout from dicationary")
            return [:]
        }
    }
    
    func receiveAddCustomExerciseKindRequest() {
        
        receiveAddCustomExerciseKindRequestAction?()
    }
    
    nonisolated
    func process(
        _ syncInstruction: SyncInstruction,
        replyHandler: @escaping ([String: Any]) -> Void
    ) {

        nonisolated(unsafe) let replyHandler = replyHandler
        
        DispatchQueue.main.async { [weak self] in
            
            switch syncInstruction.operation {
                
            case .templateWorkoutsHashCheckRequest:
                
                let reply = self?.receiveTemplateWorkoutsHashCheckRequest(syncInstruction.payload)
                if let reply {
                    replyHandler(reply as [String: Any])
                }
                
            case .exerciseCatalogHashCheckRequest:
                
                let reply = self?.receiveExerciseCatalogHashCheckRequest(syncInstruction.payload)
                if let reply {
                    replyHandler(reply as [String: Any])
                }
                
            default:
                assertionFailure()
            }
        }
    }
    
    nonisolated
    func process(
        _ syncInstruction: SyncInstruction
    ) {
        
        DispatchQueue.main.async { [weak self] in
            
            switch syncInstruction.operation {
            
            case .addCustomExerciseKindRequest:
                self?.receiveAddCustomExerciseKindRequest()

            default:
                assertionFailure()
            }
        }
    }
    
    nonisolated
    func process(
        _ dictionary: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        
        do {
            let instruction = try SyncInstruction(fromDictionary: dictionary)
            process(instruction, replyHandler: replyHandler)
        } catch {
            print("Failed to create instruction")
        }
    }
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        
        print("Received message with reply handler")
        
        process(message, replyHandler: replyHandler)
    }
}
#endif
