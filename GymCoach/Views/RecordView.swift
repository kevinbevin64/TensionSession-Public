//
//  RecordView.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/23/25.
//

import Foundation
import SwiftUI
import SwiftData

struct RecordView: View {
    @State var viewModel: ViewModel
    
    init(dataDelegate: DataDelegate) {
        self.viewModel = .init(dataDelegate: dataDelegate)
    }
    
    var body: some View {
        Group {
            if !viewModel.templateWorkouts.isEmpty, let workout = viewModel.selectedWorkout {
                mainContent(for: workout)
            } else {
                NoTemplatesPrompt()
            }
        }
        .onAppear {
            viewModel.refresh()
        }
        .onChange(of: viewModel.templateWorkouts.map { $0.id }) { _ in
            viewModel.refresh()
        }
    }
    
    /// Shown when there is at least one workout.
    /// This contains the main content usually shown in the view.
    func mainContent(for workout: Workout) -> some View {
        NavigationStack {
            exerciseList(of: workout)
                .overlay { if workout.exercises.isEmpty { NoExercisesPrompt() } }
                .toolbar {
                    if workout.status == .inProgress {
                        StopWorkoutButton { viewModel.endWorkout() }
                        ToolbarTimeView(viewModel.timeKeeper)
                        PauseWorkoutButton { viewModel.pauseWorkout() }
                    } else {
                        StartWorkoutButton { viewModel.startWorkout() }
                    }
                }
                .navigationTitle("Record")
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseView(exercise, viewModel.timeKeeper)
                }
        }
    }
    
    /// The list of exercises for the given workout.
    /// This component also displays a workout selector at the top of the list, allowing users to
    /// switch to different workouts.
    func exerciseList(of workout: Workout) -> some View {
        List {
            if workout.status != .inProgress {
                // Workout selector
                WorkoutSelector(selection: $viewModel.selectedWorkout, options: viewModel.templateWorkouts)
            }
            
            // List of exercises
            ForEach(workout.exercises.sorted { $0.dateAdded < $1.dateAdded }) { exercise in
                ExerciseRecordCard(exercise, isActive: workout.status == .inProgress)
                    .listRowInsets(exerciseRecordCardEdgeInsets)
                    .roundedListItemStyle(cornerRadius: 16, backgroundColor: .exerciseCardBG)
            }
        }
        .roundedListStyle()
    }
    
    @Observable
    @MainActor final class ViewModel {
        let dataDelegate: DataDelegate
        var templateWorkouts: [Workout] { dataDelegate.templateWorkouts }
        var selectedWorkout: Workout?
//        var selectedExercise: Exercise? = nil
        var timeKeeper: TimeKeeper = TimeKeeper()
        
        init(dataDelegate: DataDelegate) {
            self.dataDelegate = dataDelegate
            selectedWorkout = dataDelegate.suggestedWorkout
        }
        
        func setSelectedWorkout(_ workout: Workout) {
            self.selectedWorkout = workout
        }
        
//        func setSelectedExercise(_ exercise: Exercise) {
//            selectedExercise = exercise
//        }
        
        func startWorkout() {
            guard let selectedWorkout else {
                assertionFailure("When called, this method should not have a nil selectedWorkout.")
                return
            }
            // Create a deep (and clean) copy of the workout
            self.selectedWorkout = {
                let workout = Workout(cleanCopyOf: selectedWorkout)
                workout.start()
                print(workout.name)
                return workout
            }()
            
            // Start the timer
            timeKeeper.resume()
            print("selectedWorkout is nil: \(self.selectedWorkout == nil)")
        }
        
        func pauseWorkout() {
            timeKeeper.isRunning ? timeKeeper.pause() : timeKeeper.resume()
        }
        
        func endWorkout() {
            guard let selectedWorkout else {
                assertionFailure("When called, this method should not have a nil selectedWorkout.")
                return
            }
            selectedWorkout.end()
            for exercise in selectedWorkout.exercises {
                if let i = dataDelegate.exerciseWeightsCaches.firstIndex(
                    where: { $0.name == exercise.name }
                ) {
                    print("While caching an exercise's weights, we found an existing cache")
                    // The cache exists, so we add to it
                    let cache = dataDelegate.exerciseWeightsCaches[i]
                    do {
                        try cache.addWeightsFrom(exercise)
                        print("Added the weights from exercise")
                    } catch {
                        print("Failed to add weights to the cache: \(error)")
                    }
                } else {
                    // The cache doesn't exist.
                    // Create a new cache and add it to this app's data
                    dataDelegate.addExerciseWeightsCache(
                        ExerciseWeightsCache(of: exercise)
                    )
                    print("Created a new cache")
                }
            }
            dataDelegate.addHistoricalWorkout(selectedWorkout)
            timeKeeper.reset()
        }
        
        // Adds an additional exercise to this workout (one that was unplanned)
        func addExercise() {
            guard let selectedWorkout else {
                assertionFailure("When called, this method should not have a nil selectedWorkout.")
                return
            }
            selectedWorkout.add(Exercise(name: "", sets: 3, reps: 12, weight: Weight(10, in: .kilograms)))
        }
        
        func refresh() {
            // Update the selectedWorkout if it was removed from the workout templates in PlanView
            if let selectedWorkout {
                if selectedWorkout.status == .inProgress { return }
                if !templateWorkouts.contains(selectedWorkout) {
                    self.selectedWorkout = dataDelegate.suggestedWorkout
//                    if let selectedExercise, !selectedWorkout.exercises.contains(selectedExercise) {
//                        self.selectedExercise = nil
//                    }
                }
            } else {
                selectedWorkout = dataDelegate.suggestedWorkout
            }
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
