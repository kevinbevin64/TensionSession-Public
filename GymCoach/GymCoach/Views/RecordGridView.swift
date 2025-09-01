//
//  RecordGridView.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/28/25.
//

import Foundation
import SwiftUI
import SwiftData

struct RecordGridView: View {
    @Environment(DataDelegate.self) var dataDelegate
    @Environment(Companion.self) var companion
    @Environment(WorkoutDataAnalyzer.self) var workoutDataAnalyzer
    
    @State var selectedWorkout: Workout?
    @State var timeKeeper = TimeKeeper()
    
    var body: some View {
        updatedBody
            .task {
                updateSelectedWorkout()
            }
    }
    
    @ViewBuilder
    var updatedBody: some View {
        if let selectedWorkout {
            NavigationStack {
                ScrollView {
                    if selectedWorkout.status != .inProgress {
                        // Workout selector
                        WorkoutSelector(
                            selection: $selectedWorkout,
                            options: dataDelegate.templateWorkouts
                        )
                        .padding( 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    let spacing = CGFloat(16)
                    let columns = [
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing)
                    ]
                    
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(selectedWorkout.exercises.sorted(by: { $0.dateAdded < $1.dateAdded } )) { exercise in
                            NavigationLink(value: exercise) {
                                RecordGridExerciseItem(exercise)
                            }
                            .disabled(selectedWorkout.status != .inProgress)
                        }
                    }
                    .padding()
                }
                .toolbar {
                    if selectedWorkout.status == .inProgress {
                        StopWorkoutButton { endWorkout(selectedWorkout) }
                        ToolbarTimeView(timeKeeper)
                        PauseWorkoutButton { togglePauseWorkout(selectedWorkout) }
                    } else {
                        StartWorkoutButton { startWorkout(selectedWorkout) }
                    }
                }
                .navigationTitle("Record")
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseView(exercise)
                        .environment(timeKeeper)
                }
            }
        } else {
            NoTemplatesPrompt()
        }
    }
    
}

#Preview {
    RecordView(
        dataDelegate: {
            let d = DataDelegate(
                context: {
                    let container = try! ModelContainer(
                        for: Workout.self, Exercise.self, SyncInstruction.self, UserInfo.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                    )
                    return ModelContext(container)
                }()
            )
            d.addTemplateWorkout(Workout(name: "Test workout 1"))
            d.addTemplateWorkout(Workout(name: "Test workout 2"))
            d.addTemplateWorkout(Workout(name: "Test workout 3"))
            return d
        }()
    )
}



// MARK: - VIEW LOGIC
extension RecordGridView {
    func startWorkout(_ selectedWorkout: Workout) {
        // Data
        let workoutCopy = Workout(cleanCopyOf: selectedWorkout)
        self.selectedWorkout = workoutCopy
        workoutCopy.start()
        print("Workout is in progress: \(self.selectedWorkout!.status == .inProgress)")
        // Time
        timeKeeper.resume()
        
        // Haptics
//        WKInterfaceDevice.current().play(.start)
    }
    
    func pauseWorkout(_ selectedWorkout: Workout) {
        timeKeeper.pause()
//        WKInterfaceDevice.current().play(.retry)
    }
    
    func resumeWorkout(_ selectedWorkout: Workout) {
        timeKeeper.resume()
//        WKInterfaceDevice.current().play(.start)
    }
    
    func togglePauseWorkout(_ selectedWorkout: Workout) {
        if timeKeeper.isRunning {
            pauseWorkout(selectedWorkout)
        } else {
            resumeWorkout(selectedWorkout)
        }
    }
    
    func endWorkout(_ selectedWorkout: Workout) {
        timeKeeper.reset()
        selectedWorkout.end()
//        WKInterfaceDevice.current().play(.success)
        
        // Update data
        dataDelegate.addHistoricalWorkout(selectedWorkout)
        companion.addHistoricalWorkout(selectedWorkout)
        
        // Update the WorkoutDataAnalyzer
        workoutDataAnalyzer.addData(from: selectedWorkout)
        
        // Make the selected workout one of the templates
        self.selectedWorkout = dataDelegate.templateWorkouts.first
//        if shouldShowDebrief(for: selectedWorkout) {
//            showDebrief()
//        }
    }
    
//    func showWorkoutOptions() {
//        isShowingWorkoutOptions = true
//    }
    
//    func showDebrief() {
//        isShowingDebrief = true
//    }
    
    // Returns true if there is at least one template workout
    // and at least one set was completed
    func shouldShowDebrief(for workout: Workout) -> Bool {
        if dataDelegate.templateWorkouts.isEmpty { return false }
        
        for exercise in workout.exercises {
            if exercise.setsDone != 0 {
                return true
            }
        }
        return false
    }
    
    func updateSelectedWorkout() {
        print("Updating selected workout")
        if let selectedWorkout {
            if selectedWorkout.status == .inProgress {
                // The workout is in progress; do nothing
            } else if !dataDelegate.templateWorkouts.contains(selectedWorkout) {
                // The workout is no longer in the template workouts, so find another
                // workout for replacement.
                // Invalidate the selectedWorkout
                setSelectedWorkout()
            }
        } else {
            // The selectedWorkout was originally nil
            setSelectedWorkout()
        }
    }
    
    func setSelectedWorkout(_ workout: Workout? = nil) {
        if let workout {
            self.selectedWorkout = workout
        } else {
            self.selectedWorkout = dataDelegate.templateWorkouts.first
        }
    }
}
