//
//  Companion.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/18/25.
//

import Foundation
import SwiftData
import WatchConnectivity

@Observable
final class Companion: NSObject, WCSessionDelegate, CompanionProtocol {
    private var session: WCSession { WCSession.default }
    private var dataDelegate: DataDelegate
    
    // MARK: - Setup
    init(dataDelegate: DataDelegate) {
        self.dataDelegate = dataDelegate
        super.init()
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Activation
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if error != nil {
            assertionFailure("Activation failed")
        } else {
            // Send any unsent instructions
            if session.activationState == .activated {
                #if DEBUG
                print("WCSession activated successfully. (\(Date())")
                #endif
                Task { @MainActor in
                #if os(iOS)
                    
                    print("iPhone has a paired apple watch: \(session.isPaired)")
                    sendPendingInstructions()
                    
                #elseif os(watchOS)
                    
                    if !dataDelegate.userInfo.wasWatchAppInstalled {
                        requestAllWorkouts()
                    } else {
                        sendPendingInstructions()
                    }
                    
                #endif
                    
                }
            }
        }
    }
    
    // MARK: - High-level functions
    func addTemplateWorkout(_ workout: Workout) {
        print("sending a template workout at \(Date())")
        send(
            SyncInstruction(
                operation: .addTemplateWorkout,
                payload: workout.dictionaryForm
            )
        )
    }
    
    func updateTemplateWorkout(_ workout: Workout) {
        send(
            SyncInstruction(
                operation: .updateTemplateWorkout,
                payload: workout.dictionaryForm
            )
        )
    }

    func deleteTemplateWorkout(_ workout: Workout) {
        send(
            SyncInstruction(
                operation: .deleteTemplateWorkout,
                payload: workout.dictionaryForm
            )
        )
    }
    
    func deleteAllTemplateWorkouts() {
        send(
            SyncInstruction(
                operation: .deleteAllTemplateWorkouts,
                payload: [:]
            )
        )
    }
    
    func addHistoricalWorkout(_ workout: Workout) {
        send(
            SyncInstruction(
                operation: .addHistoricalWorkout,
                payload: workout.dictionaryForm
            )
        )
    }
    
    func deleteAllHistoricalWorkouts() {
        send(
            SyncInstruction(
                operation: .deleteAllHistoricalWorkouts,
                payload: [:]
            )
        )
    }
    
    func updateUserInfo(_ userInfo: UserInfo) {
        send(
            SyncInstruction(
                operation: .updateUserInfo,
                payload: userInfo.dictionaryForm
            )
        )
    }
    
    func deleteAllWorkouts() {
        deleteAllTemplateWorkouts()
        deleteAllHistoricalWorkouts()
    }
    
    func requestAllWorkouts() {
        print("Requesting all workouts...")
        let requestInstruction = SyncInstruction(
            operation: .requestAllWorkouts,
            payload: [:]
        )
        #if os(watchOS)
        print("isCompanionAppInstalled: \(session.isCompanionAppInstalled)")
        print("iOSDeviceNeedsUnlockAfterRebootForReachability: \(session.iOSDeviceNeedsUnlockAfterRebootForReachability)")
        print("iPhone is reachable: \(session.isReachable)")
        #elseif os(iOS)
        print("watch is reachable: \(session.isReachable)")
        #endif
        if session.isReachable {
            session.sendMessage(
                requestInstruction.dictionaryForm,
                replyHandler: { rawInstruction in
                    print("Processing incoming initial-sync-stuff.")
                    self.process(rawInstruction)
                    
                    // rawInstruction's structure is as follows:
                    /*
                     "operation": "requestAllWorkouts",
                     "payload": [
                     "workouts": [ [String: Any], ... ] where each [String: Any] represents a workout
                     ]
                     */
                },
                errorHandler: { error in
                    assertionFailure("Failed to request all workouts! \(error)")
                }
            )
        }
    }
        
    @MainActor
    func sendPendingInstructions() {
        for pendingInstruction in dataDelegate.pendingSyncInstructions {
            dataDelegate.deletePendingSyncInstruction(pendingInstruction)
            send(pendingInstruction)
        }
    }
    
    // MARK: - Supporting functions
    // Helper for sending instructions with either sendMessage or transferUserInfo, depending
    // on the reachability of the counterpart.
    func send(_ instruction: SyncInstruction) {
        // Don't send if there's no watch to send to.
        #if os(iOS)
        guard session.isWatchAppInstalled else {
            return
        }
        #endif
        
        // Save the instruction for sending when session becomes activated
        guard session.activationState == .activated else {
            // Save the instruction to storage so it can be sent once the session is activated.
            Task { @MainActor in
                dataDelegate.addPendingSyncInstruction(instruction)
            }
            return
        }
        
        let fallback: () -> Void = { self.session.transferUserInfo(instruction.dictionaryForm) }

        if session.isReachable {
            session.sendMessage(
                instruction.dictionaryForm,
                replyHandler: nil,
                errorHandler: { error in
                    print("Errored when sending: \(error.localizedDescription)")
                    fallback()
                }
            )
        } else {
            print("Using the fallback")
            fallback()
        }
    }

    func process(_ rawInstruction: [String: Any]) {
        print("Processing instruction...")
        guard let instruction = SyncInstruction(from: rawInstruction) else {
            assertionFailure("Failed to form instruction.")
            return
        }
        Task { @MainActor in
            process(instruction)
        }
    }
    
    // MARK: - Processing incoming data
    @MainActor
    func process(_ instruction: SyncInstruction) {
        
        switch instruction.operation {
            
        case .addHistoricalWorkout:
            dataDelegate.addHistoricalWorkout(Workout(from: instruction.payload)!)
            
        case .updateExerciseWeightsCache:
            let exerciseWeightsCache = ExerciseWeightsCache(from: instruction.payload)!
            if let i = dataDelegate.exerciseWeightsCaches.firstIndex(
                where: { $0.id == exerciseWeightsCache.id }
            ) {
                try? dataDelegate.exerciseWeightsCaches[i].addWeightsFrom(exerciseWeightsCache)
            } else {
                dataDelegate.addExerciseWeightsCache(exerciseWeightsCache)
            }
            
        #if os(watchOS)
            
        case .addTemplateWorkout:
            dataDelegate.addTemplateWorkout(Workout(from: instruction.payload)!)
            
        case .updateTemplateWorkout:
            let reference = Workout(from: instruction.payload)!
            guard dataDelegate.templateWorkouts.contains(reference),
                  let template = dataDelegate.templateWorkouts.first(where: { $0 == reference })
            else {
                assertionFailure("Attempted to update non-existent template workout.")
                return
            }
            template.edit(with: reference)
            
        case .deleteTemplateWorkout:
            print("Deleting a template workout")
            dataDelegate.deleteTemplateWorkout(Workout(from: instruction.payload)!)
            print("The remaining template workouts are:")
            for templateWorkout in dataDelegate.templateWorkouts {
                print(templateWorkout.name)
            }
            
        case .deleteAllTemplateWorkouts:
            dataDelegate.deleteAllTemplateWorkouts()
            
        case .deleteAllHistoricalWorkouts:
            dataDelegate.deleteAllHistoricalWorkouts()
            
        case .replyWithAllWorkouts:
            print("Accepting reply containing all workouts!")
            guard let rawWorkouts = instruction.payload["workouts"] as? [[String: Any]],
                  let workouts = {
                      var _workouts = [Workout]()
                      for rawWorkout in rawWorkouts {
                          if let workout = Workout(from: rawWorkout) {
                              _workouts.append(workout)
                          } else {
                              assertionFailure("""
                              Failed on the following workout: 
                              ================================
                              rawWorkout: \(rawWorkout)
                              """)
                          }
                      }
                      return _workouts
                  }()
            else {
                assertionFailure("Failed to convert ")
                return
            }
            for workout in workouts {
                if workout.isTemplate {
                    dataDelegate.addTemplateWorkout(workout)
                } else { // is historical
                    dataDelegate.addHistoricalWorkout(workout)
                }
            }
            // Once the initial sync completes, the watch no longer needs to request for all data
            // from the phone.
            dataDelegate.userInfo.wasWatchAppInstalled = true
            print("Telling iPhone that watch app was installed.")
            updateUserInfo(dataDelegate.userInfo) // Tell iPhone that watch app was installed
            
    
        #endif
            
        case .updateUserInfo:
            print("Received instruction to update user info")
            dataDelegate.userInfo.edit(with: UserInfo(from: instruction.payload)!)
            
        default:
            assertionFailure("Default case reached. This is an error.")
        }
    }
    
    // MARK: - Initial sync request
    func reply(to rawInstruction: [String: Any], with replyHandler: @escaping ([String: Any]) -> Void) {
        print("Replying to request...")
        guard let instruction = SyncInstruction(from: rawInstruction)
        else {
            assertionFailure("Failed to convert raw instruction into SyncInstruction.")
            return
        }
        Task { @MainActor in
            reply(to: instruction, with: replyHandler)
        }
    }
    
    @MainActor
    func reply(to instruction: SyncInstruction, with replyHandler: @escaping ([String: Any]) -> Void) {
        switch instruction.operation {
        case .requestAllWorkouts: // Reply to a request for all workouts
            var rawWorkouts: [[String: Any]] = []
            for workout in dataDelegate.templateWorkouts {
                rawWorkouts.append(workout.dictionaryForm)
            }
            for workout in dataDelegate.historicalWorkouts {
                rawWorkouts.append(workout.dictionaryForm)
            }
            
            replyHandler(SyncInstruction(
                operation: .replyWithAllWorkouts,
                payload: ["workouts": rawWorkouts]
            ).dictionaryForm)
            
        default:
            assertionFailure("Invalid request.")
        }
    }
    
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        reply(to: message, with: replyHandler)
    }
    
    #if os(iOS)
    func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            // When the watch app becomes uninstalled, set wasWatchAppInstalled to false.
            // .wasWatchAppInstalled becomes true through another process.
            // Specifically, this happens only after an initial sync with the watch completes.
            if !session.isWatchAppInstalled {
                dataDelegate.userInfo.wasWatchAppInstalled = false
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive. [Not supposed to happen]")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Session became inactive. [Not supposed to happen]")
    }
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        process(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        process(userInfo)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Session reachability changed: \(session.isReachable)")
        #if os(watchOS)
        
        Task { @MainActor in
            // Requests for all workouts if the watch app was just installed and the iPhone
            // is reachable.
            if !dataDelegate.userInfo.wasWatchAppInstalled && session.isReachable {
                requestAllWorkouts()
            }
        }
        
        #endif
    }
}
