//
//  GymCoachApp.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/18/25.
//

import SwiftData
import SwiftUI

@main
struct iOSApp: App {
    let dataDelegate: DataDelegate
    let companion: Companion
    
    init() {
        if VersionTracker.shouldStoreAppVersion() {
            VersionTracker.storeAppVersion()
        }
        
        let container = {
            try! ModelContainer(
                for: Workout.self, Exercise.self, SyncInstruction.self, UserInfo.self, ExerciseWeightsCache.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        }()
        let context = ModelContext(container)
        
        let _dataDelegate = DataDelegate(context: context)
        self.dataDelegate = _dataDelegate
        self.companion = Companion(dataDelegate: _dataDelegate)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(dataDelegate: dataDelegate, companion: companion)
                .environment(dataDelegate)
                .preferredColorScheme(.dark)
        }
    }
}
